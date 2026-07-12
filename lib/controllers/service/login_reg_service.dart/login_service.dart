import 'dart:developer';

// import 'package:dio/dio.dart';
import 'package:poketstore/network/dio_network_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginService {
  Future<Map<String, dynamic>> loginUser(
    String mobileNumber,
    String password,
  ) async {
    try {
      log("Attempting login with mobileNumber: $mobileNumber");

      final response = await DioNetworkService.dio.post(
        '/auth/user/login', // ✅ use relative path (important)
        data: {"mobileNumber": mobileNumber, "password": password},
      );

      log("Response status: ${response.statusCode}");
      log("Response data: ${response.data}");

      if (response.statusCode == 200) {
        final data = response.data;

        // ✅ Extract tokens
        final accessToken = data['accessToken'];
        final refreshToken = data['refreshToken'];

        // ✅ LOG TOKENS
        log("🔐 Access Token: $accessToken");
        log("🔄 Refresh Token: $refreshToken");

        // ✅ SAVE TOKENS
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', accessToken);
        await prefs.setString('refreshToken', refreshToken);

        // ✅ UPDATE Dio memory tokens (IMPORTANT)
        DioNetworkService.accessToken = accessToken;
        DioNetworkService.refreshToken = refreshToken;

        return data;
      } else {
        throw Exception("Login failed: ${response.statusCode}");
      }
    } catch (e) {
      log("Login Error: $e");
      throw Exception("Login Error: $e");
    }
  }
}
