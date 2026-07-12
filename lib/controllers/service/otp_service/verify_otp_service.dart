import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:poketstore/model/otp_model/verify_otp_model.dart';

class VerifyOtpService {
  final Dio _dio = Dio();
  final String _baseUrl = "https://api.poketstor.com/api/shops/verify-shop-otp";

  Future<VerifyOtpResponse?> verifyOtp({
    required String mobileNumber,
    required String otp,
    required String verificationId,
  }) async {
    try {
      final response = await _dio.post(
        _baseUrl,
        data: {
          "mobileNumber": mobileNumber,
          "otp": otp,
          "verificationId": verificationId,
        },
      );

      if (response.statusCode == 200) {
        return VerifyOtpResponse.fromJson(response.data);
      }
    } catch (e) {
      log("VerifyOtpService Error: $e");
    }
    return null;
  }
}
