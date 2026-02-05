import 'dart:developer';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationHelper {
  static Future<Map<String, dynamic>> getCurrentLocation() async {
    // Check permission
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location service disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied');
    }

    // Get current position
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    log('📍 Lat: ${position.latitude}, Lng: ${position.longitude}');

    // Get address
    final placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    final placemark = placemarks.first;

    log('🏷️ Pincode: ${placemark.postalCode}');

    return {
      'latitude': position.latitude,
      'longitude': position.longitude,
      'pincode': placemark.postalCode,
    };
  }
}
