import 'dart:developer';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:poketstore/model/order_model/order_model.dart';
import 'package:poketstore/network/dio_network_service.dart';

class OrderService {
  final Dio _dio = DioNetworkService.dio;
  static const String _baseUrl = '/api/order/place';

  Future<Map<String, dynamic>?> placeOrder(
    OrderItemModel orderItemModel,
  ) async {
    try {
      final body = orderItemModel.toJson();

      log("===== ORDER API CALL STARTED =====");
      log("📦 Payload: ${jsonEncode(body)}");
      log("🌍 Endpoint: $_baseUrl");

      final response = await _dio.post(_baseUrl, data: body);

      log("📨 Response Status Code: ${response.statusCode}");
      log("📨 Response Data: ${jsonEncode(response.data)}");

      if (response.statusCode == 200) {
        log("✅ Order placed successfully.");
        return {
          'message': response.data['message'],
          'order': response.data['order'],
        };
      }

      return null;
    } on DioException catch (e, stacktrace) {
      log(
        "❌ Order API error: ${e.response?.data ?? e.message}",
        stackTrace: stacktrace,
      );
      return null;
    } catch (e, stacktrace) {
      log("❗ Unexpected error: $e", stackTrace: stacktrace);
      return null;
    }
  }
}
