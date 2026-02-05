import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:poketstore/model/shop_nearby_model/shop_nearby_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:poketstore/network/dio_network_service.dart';

class ShopNearbyService {
  final Dio _dio = DioNetworkService.dio;
  static const String baseUrl = '/api/shops/nearby';

  /// Fetch nearby shops using current location pincode
  Future<List<ShopNearbyModel>> fetchNearbyShops() async {
    try {
      final pincode = await _getPincodeFromLocation();
      final url = '$baseUrl/$pincode';

      log('📡 FETCH NEARBY SHOPS');
      log('➡️ URL: $url');

      final response = await _dio.get(url);

      log('✅ STATUS: ${response.statusCode}');
      log('📦 BODY: ${response.data}');

      if (response.statusCode == 200) {
        final List shops = response.data['shops'] ?? [];
        return shops.map((json) => ShopNearbyModel.fromJson(json)).toList();
      }

      throw Exception('Unexpected status: ${response.statusCode}');
    } on DioException catch (e, s) {
      log('❌ DIO ERROR: ${e.response?.data ?? e.message}', stackTrace: s);
      rethrow;
    } catch (e, s) {
      log('❌ ERROR: $e', stackTrace: s);
      rethrow;
    }
  }

  /// Get the pincode from the device's current location
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
      throw Exception('Unable to fetch pincode from location');
    }

    log('📍 Current pincode: $pincode');
    return pincode;
  }
}
