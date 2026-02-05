import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:poketstore/model/location_model/location_model.dart';

class LocationMapService {
  final Dio dio = Dio();

  Future<LocationMapModel?> fetchUserLocation(String userId) async {
    try {
      final response = await dio.get(
        'https://api.poketstor.com/api/user/location/$userId',
      );
      log("🔍 Status Code: ${response.statusCode}");
      log("📦 Response Data: ${response.data}");

      if (response.statusCode == 200 && response.data['success'] == true) {
        return LocationMapModel.fromJson(response.data['location']);
      } else {
        log(
          "⚠️ Failed to fetch location: ${response.data['message'] ?? 'Unknown error'}",
        );
        return null;
      }
    } on DioException catch (e) {
      if (e.response != null) {
        log(
          'Error fetching location (Status: ${e.response?.statusCode}): ${e.response?.data}',
        );
      } else {
        log('Error fetching location: ${e.message}');
      }
      return null;
    } catch (e) {
      log('An unexpected error occurred while fetching location: $e');
      return null;
    }
  }

  Future<LocationMapModel?> updateLocation(
    String userId,
    LocationMapModel location,
  ) async {
    try {
      final response = await dio.put(
        'https://api.poketstor.com/api/user/updatelocation/$userId',
        data: location.toJson(),
      );

      // ✅ Log the full response data and status code
      log(
        "📡 Location update response [${response.statusCode}]: ${response.data}",
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        // Corrected: Access the nested 'location' map for deserialization
        return LocationMapModel.fromJson(response.data['location']);
      } else {
        log(
          "⚠️ Server returned an error: ${response.data['message'] ?? 'Unknown error'}",
        );
        return null;
      }
    } on DioException catch (e) {
      // Catch DioException specifically
      if (e.response != null) {
        log(
          '❌ Error updating location (Status: ${e.response?.statusCode}): ${e.response?.data}',
        );
      } else {
        log('❌ Error updating location: ${e.message}');
      }
      return null;
    } catch (e) {
      log("❌ An unexpected error occurred while updating location: $e");
      return null;
    }
  }
}
