import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:poketstore/model/service_booking_model/service_booking_model.dart';
import 'package:poketstore/network/dio_network_service.dart';

class ServiceBookingService {
  final Dio _dio = DioNetworkService.dio;

  Future<ServiceBookingResponse> bookService(
    ServiceBookingRequest request,
  ) async {
    try {
      log("➡️ POST /api/order/book-service");
      final response = await _dio.post(
        "/api/order/book-service",
        data: request.toJson(),
      );

      log("✅ Service Booked: ${response.data}");
      return ServiceBookingResponse.fromJson(response.data);
    } on DioException catch (e) {
      log("❌ Book Service Error: ${e.response?.data}");
      throw Exception(e.response?.data["message"] ?? "Service booking failed");
    }
  }
}
