import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:poketstore/model/fcm_model/fcm_model.dart';

class FCMService {
  final Dio dio = Dio();
  final String baseUrl = "https://api.poketstor.com";

  Future<String?> saveFcmToken(FCMModel model) async {
    final url = "$baseUrl/auth/user/save-fcm-token";

    try {
      final response = await dio.post(url, data: model.toJson());

      if (response.statusCode == 200) {
        return response.data['message'];
      } else {
        log("Unexpected status code: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      log("Error saving FCM token: $e");
      return null;
    }
  }
}
