import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:poketstore/model/forgot_password_model/forgot_password_model.dart';
import 'package:poketstore/network/dio_network_service.dart';

class ForgotPasswordService {
  final Dio _dio = Dio();

  Future<ForgotPasswordModel> forgotPassword(String email) async {
    try {
      log("Sending forgot password request for $email");

      final response = await _dio.post(
        'https://api.poketstor.com/auth/user/forgot-password',
        data: {"email": email},
      );

      log("Forgot Password Response: ${response.data}");

      if (response.statusCode == 200) {
        return ForgotPasswordModel.fromJson(response.data);
      } else {
        throw Exception("Failed to send reset link");
      }
    } catch (e) {
      log("Forgot Password Error: $e");
      throw Exception("Unable to send reset password email");
    }
  }
}
