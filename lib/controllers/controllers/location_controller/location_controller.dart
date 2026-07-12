import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:poketstore/model/location_model/location_model.dart';
import 'package:poketstore/service/location_service/location_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationMapController extends ChangeNotifier {
  final LocationMapService _service = LocationMapService();

  LocationMapModel? locationMap;
  bool isLoading = false;
  String? error;

  /* -------------------- PUBLIC METHODS -------------------- */

  Future<void> loadCurrentUserLocation() async {
    _setState(isLoading: true, error: null);

    try {
      final userId = await _getUserId();
      if (userId == null) {
        _setState(
          isLoading: false,
          error: "User not logged in. Cannot load location.",
        );
        return;
      }

      await _loadUserLocationInternal(userId);
    } catch (e, s) {
      log("❌ loadCurrentUserLocation error", error: e, stackTrace: s);
      _setState(isLoading: false, error: "Failed to load user location");
    }
  }

  Future<void> updateUserLocation(
    String userId,
    LocationMapModel newLocation,
  ) async {
    _setState(isLoading: true, error: null);

    try {
      log("🔄 Updating location: ${newLocation.toJson()}");

      final updated = await _service.updateLocation(userId, newLocation);

      if (updated == null) {
        _setState(
          isLoading: false,
          error: "Failed to update location on server",
        );
        return;
      }

      locationMap = updated;
      log("✅ Location updated successfully");
      _setState(isLoading: false);
    } catch (e, s) {
      log("❌ updateUserLocation error", error: e, stackTrace: s);
      _setState(isLoading: false, error: "Error updating location");
    }
  }

  Future<void> getCurrentAndSaveUserLocation() async {
    _setState(isLoading: true, error: null);

    try {
      final permissionGranted = await _handleLocationPermission();
      if (!permissionGranted) return;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) {
        _setState(isLoading: false, error: "Unable to determine address");
        return;
      }

      final place = placemarks.first;
      final userId = await _getUserId();

      if (userId == null) {
        _setState(
          isLoading: false,
          error: "User not logged in. Cannot save location.",
        );
        return;
      }

      final newLocation = LocationMapModel(
        latitude: position.latitude.toString(),
        longitude: position.longitude.toString(),
        locality: place.locality ?? '',
        state: place.administrativeArea ?? '',
        pincode: place.postalCode ?? '',
        place: place.name ?? '',
      );

      log("📍 Prepared location: ${newLocation.toJson()}");

      await updateUserLocation(userId, newLocation);
    } catch (e, s) {
      log("❌ getCurrentAndSaveUserLocation error", error: e, stackTrace: s);
      _setState(isLoading: false, error: "Failed to get or save location");
    }
  }

  void clearLocation() {
    locationMap = null;
    _setState(isLoading: false, error: null);
  }

  /* -------------------- PRIVATE HELPERS -------------------- */

  Future<void> _loadUserLocationInternal(String userId) async {
    try {
      final result = await _service.fetchUserLocation(userId);

      if (result == null) {
        _setState(isLoading: false, error: "Failed to fetch location");
        return;
      }

      locationMap = result;
      log("📍 Location loaded for user $userId");
      _setState(isLoading: false);
    } catch (e, s) {
      log("❌ loadUserLocation error", error: e, stackTrace: s);
      _setState(isLoading: false, error: "Error loading user location");
    }
  }

  Future<String?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  Future<bool> _handleLocationPermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      _setState(isLoading: false, error: "Location services are disabled");
      return false;
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      _setState(isLoading: false, error: "Location permission denied");
      return false;
    }

    if (permission == LocationPermission.deniedForever) {
      _setState(
        isLoading: false,
        error: "Enable location permission from settings",
      );
      return false;
    }

    return true;
  }

  void _setState({bool? isLoading, String? error}) {
    if (isLoading != null) this.isLoading = isLoading;
    this.error = error;
    notifyListeners();
  }
}
