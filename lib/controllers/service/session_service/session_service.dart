import 'dart:developer';
import 'package:dio/dio.dart';

class SessionService {
  final Dio _dio;

  SessionService(this._dio);

  Future<bool> validateSession() async {
    try {
      log('🔍 Checking session with server', name: 'SessionService');

      final response = await _dio.get('/auth/me');

      log(
        '✅ Session valid | Status: ${response.statusCode}',
        name: 'SessionService',
      );

      return response.statusCode == 200;
    } on DioException catch (e) {
      log(
        '❌ Session invalid | Status: ${e.response?.statusCode}',
        name: 'SessionService',
      );
      return false;
    }
  }
}
