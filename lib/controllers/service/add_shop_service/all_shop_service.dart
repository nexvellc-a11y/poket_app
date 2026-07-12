import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:poketstore/model/add_shope_model/all_shop_model.dart';
import 'package:poketstore/network/dio_network_service.dart';

class AllShopService {
  final Dio _dio = DioNetworkService.dio;
  final String baseUrl = "/api";

  Future<List<AllShop>> fetchShops() async {
    try {
      final response = await _dio.get("$baseUrl/shops");

      final List<dynamic> data = response.data;
      return data.map((e) => AllShop.fromJson(e)).toList();
    } on DioException catch (e, s) {
      log(
        "❌ Error fetching shops: ${e.response?.data ?? e.message}",
        stackTrace: s,
      );
      throw Exception(e.response?.data['message'] ?? 'Failed to load shops');
    }
  }
}
