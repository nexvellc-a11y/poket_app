import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:poketstore/model/otp_model/send_otp_model.dart';

class SendOtpService {
  late final Dio _dio;

  SendOtpService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: "https://api.poketstor.com",
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      ),
    );

    // 🔍 Debug interceptor (REMOVE in production)
    _dio.interceptors.add(
      LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: true,
      ),
    );
  }

  Future<SendOtpResponse?> sendOtp(String mobileNumber) async {
    try {
      log("📤 Sending OTP to: $mobileNumber");

      final response = await _dio.post(
        "/api/shops/send-shop-otp",
        data: {"mobileNumber": mobileNumber},
      );

      log("✅ OTP API Response: ${response.data}");

      if (response.statusCode == 200) {
        return SendOtpResponse.fromJson(response.data);
      }
    } on DioException catch (e) {
      log("❌ OTP API FAILED");
      log("Status Code: ${e.response?.statusCode}");
      log("Response Data: ${e.response?.data}");
    } catch (e) {
      log("❌ Unexpected Error: $e");
    }

    return null;
  }
}
