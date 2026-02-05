import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:poketstore/model/subscription_model/start_plan_model.dart';
import 'package:poketstore/network/dio_network_service.dart';

class SubscriptionService {
  final Dio _dio = DioNetworkService.dio;

  Future<StartSubscriptionResponse?> startSubscription({
    required String subscriptionPlanId,
    required String shopId,
  }) async {
    try {
      final response = await _dio.post(
        '/api/subscription/start-subscription',
        data: {"subscriptionPlanId": subscriptionPlanId, "shopId": shopId},
      );

      log("Response status: ${response.statusCode}");
      log("Response data: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return StartSubscriptionResponse.fromJson(response.data);
      }
      return null;
    } on DioException catch (e, s) {
      log(
        "❌ SubscriptionService Dio error: ${e.response?.data ?? e.message}",
        stackTrace: s,
      );
      return null;
    } catch (e, s) {
      log("❌ SubscriptionService error: $e", stackTrace: s);
      return null;
    }
  }
}
