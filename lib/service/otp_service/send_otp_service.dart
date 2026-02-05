import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:poketstore/model/otp_model/send_otp_model.dart';

class SendOtpService {
  final Dio _dio = Dio();
  final String _baseUrl = "https://api.poketstor.com/api/shops/send-shop-otp";

  Future<SendOtpResponse?> sendOtp(String mobileNumber) async {
    try {
      final response = await _dio.post(
        _baseUrl,
        data: {"mobileNumber": mobileNumber},
      );

      if (response.statusCode == 200) {
        return SendOtpResponse.fromJson(response.data);
      }
    } catch (e) {
      log("SendOtpService Error: $e");
    }
    return null;
  }
}
