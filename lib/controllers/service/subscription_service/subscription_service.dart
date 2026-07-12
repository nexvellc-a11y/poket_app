import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:poketstore/model/subscription_model/subscription_model.dart';

class SubscriptionService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "https://api.poketstor.com/api/subscription-plans",
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  Future<SubscriptionModel?> fetchPlans() async {
    try {
      final response = await _dio.get("/getallplan");
      if (response.statusCode == 200) {
        return SubscriptionModel.fromJson(response.data);
      } else {
        log("Error: ${response.statusMessage}");
      }
    } catch (e, st) {
      log("Exception in fetchPlans: $e", stackTrace: st);
    }
    return null;
  }
}
