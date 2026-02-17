import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:poketstore/model/forgot_password_model/reset_password_model.dart';
import 'package:poketstore/network/dio_network_service.dart';

class ResetPasswordService {
  final Dio _dio = Dio();

  Future<ResetPasswordModel> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      log("Reset password request");

      final response = await _dio.post(
        'https://api.poketstor.com/auth/user/reset-password',
        data: {"token": token, "newPassword": newPassword},
      );

      log("Reset Password Response: ${response.data}");

      if (response.statusCode == 200) {
        return ResetPasswordModel.fromJson(response.data);
      } else {
        throw Exception("Password reset failed");
      }
    } catch (e) {
      log("Reset Password Error: $e");
      throw Exception("Unable to reset password");
    }
  }
}
