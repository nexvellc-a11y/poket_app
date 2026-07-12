import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:poketstore/model/user_profile_model/user_profile_model.dart'; // Ensure this path is correct

class UserProfileService {
  final Dio _dio = Dio();
  final String _baseUrl = 'https://api.poketstor.com/api/user/details';

  Future<UserProfile?> fetchUserProfile(String userId) async {
    try {
      final response = await _dio.get('$_baseUrl/$userId');

      if (response.statusCode == 200 && response.data != null) {
        return UserProfile.fromJson(response.data);
      }
    } on DioException catch (e) {
      // Catch Dio-specific errors
      log('Dio error fetching user profile: ${e.message}');
      if (e.response != null) {
        log('Response data: ${e.response!.data}');
        log('Response status: ${e.response!.statusCode}');
      }
    } catch (e) {
      log('Generic error fetching user profile: $e');
    }
    return null;
  }

  Future<UserProfile?> updateUserProfile(
    String userId,
    Map<String, dynamic> updateData,
  ) async {
    try {
      // Changed from _dio.patch to _dio.put
      final response = await _dio.put(
        '$_baseUrl/update-user/$userId', // Correct endpoint for update
        data: updateData,
      );

      if (response.statusCode == 200 && response.data != null) {
        // Assuming the backend returns the updated user profile
        return UserProfile.fromJson(response.data);
      } else {
        log(
          'Failed to update user profile: Status Code ${response.statusCode}',
        );
        log('Response data: ${response.data}');
        return null;
      }
    } on DioException catch (e) {
      log('Dio error updating user profile: ${e.message}');
      if (e.response != null) {
        log('Response data: ${e.response!.data}');
        log('Response status: ${e.response!.statusCode}');
      }
      return null;
    } catch (e) {
      log('Generic error updating user profile: $e');
      return null;
    }
  }
}
