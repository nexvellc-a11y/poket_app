import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:poketstore/model/shop_nearby_model/shop_nearby_model.dart';
import 'package:poketstore/service/shop_nearby_service/shop_nearby_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShopNearbyController extends ChangeNotifier {
  final ShopNearbyService _service = ShopNearbyService();

  List<ShopNearbyModel> _shops = [];
  bool _isLoading = false;
  String? _error;

  List<ShopNearbyModel> get shops => _shops;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Main method called from UI
  Future<void> loadNearbyShops() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 🔐 Get token from SharedPreferences
      // final prefs = await SharedPreferences.getInstance();
      // final token = prefs.getString('token');

      // if (token == null || token.isEmpty) {
      //   throw Exception('Authentication token not found');
      // }

      // 📍 Get pincode from location
      final pincode = await _getPincodeFromLocation();

      // 🌐 Fetch nearby shops using token
      _shops = await _service.fetchNearbyShops();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get pincode using Geolocator + Geocoding
  Future<String> _getPincodeFromLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied');
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    final pincode = placemarks.first.postalCode;

    if (pincode == null || pincode.isEmpty) {
      throw Exception('Unable to fetch pincode');
    }

    return pincode;
  }
}
