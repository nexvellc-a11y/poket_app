import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:poketstore/model/shop_of_user_model/shop_of_user_model.dart';
import 'package:poketstore/network/dio_network_service.dart';

class ShopOfUserService {
  final Dio _dio = DioNetworkService.dio;

  Future<List<ShopOfUser>> getShopsByUser() async {
    try {
      final response = await _dio.get('/api/shops/by-user');

      final List data = response.data['data'] ?? [];
      return data.map((e) => ShopOfUser.fromJson(e)).toList();
    } on DioException catch (e, s) {
      log(
        "❌ ShopOfUserService Dio error: ${e.response?.data ?? e.message}",
        stackTrace: s,
      );
      rethrow;
    } catch (e, s) {
      log("❌ ShopOfUserService error: $e", stackTrace: s);
      rethrow;
    }
  }
}
