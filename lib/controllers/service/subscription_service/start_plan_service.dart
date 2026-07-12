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
      String errorMessage = "Something went wrong";

      if (e.response != null) {
        final data = e.response?.data;

        // ✅ Extract backend error message for 400
        if (e.response?.statusCode == 400) {
          errorMessage =
              data is Map && data["message"] != null
                  ? data["message"]
                  : "Bad request";
        } else {
          errorMessage =
              data is Map && data["message"] != null
                  ? data["message"]
                  : e.message ?? errorMessage;
        }
      }

      log("❌ SubscriptionService Dio error: $errorMessage", stackTrace: s);

      // 🔥 THROW error so provider can catch it
      throw errorMessage;
    } catch (e, s) {
      log("❌ SubscriptionService error: $e", stackTrace: s);
      throw "Unexpected error occurred";
    }
  }
}
