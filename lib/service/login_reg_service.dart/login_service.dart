import 'dart:developer';

// import 'package:dio/dio.dart';
import 'package:poketstore/network/dio_network_service.dart';

class LoginService {
  Future<Map<String, dynamic>> loginUser(
    String mobileNumber,
    String password,
  ) async {
    try {
      log("Attempting login with mobileNumber: $mobileNumber");

      final response = await DioNetworkService.dio.post(
        'https://api.poketstor.com/auth/user/login',
        data: {"mobileNumber": mobileNumber, "password": password},
      );

      log("Response status: ${response.statusCode}");
      log("Response data: ${response.data}");

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception("Login failed: ${response.statusCode}");
      }
    } catch (e) {
      log("Login Error: $e");
      throw Exception("Login Error: $e");
    }
  }
}
