import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:poketstore/model/reward_model/reward_model.dart';
import 'package:poketstore/network/dio_network_service.dart';

class RewardService {
  final Dio _dio = DioNetworkService.dio;

  Future<RewardModel> completeOrder({
    required String orderId,
    required String shopId,
  }) async {
    final String endpoint = "/api/shops/orders/$orderId/complete";

    log("➡️ PUT $endpoint", name: 'RewardService');
    log("📦 Payload: { shopId: $shopId }", name: 'RewardService');

    try {
      final response = await _dio.put(endpoint, data: {"shopId": shopId});

      log("✅ Response (${response.statusCode})", name: 'RewardService');
      log("📥 Data: ${response.data}", name: 'RewardService');

      return RewardModel.fromJson(response.data);
    } on DioException catch (e, stack) {
      log(
        "❌ DioException while completing order",
        name: 'RewardService',
        error: e.response?.data ?? e.message,
        stackTrace: stack,
      );

      throw Exception(
        e.response?.data['message'] ?? "Failed to complete order",
      );
    } catch (e, stack) {
      log(
        "❌ Unexpected error",
        name: 'RewardService',
        error: e,
        stackTrace: stack,
      );
      throw Exception("Failed to complete order");
    }
  }
}
