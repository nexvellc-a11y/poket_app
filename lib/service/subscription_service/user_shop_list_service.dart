import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:poketstore/model/subscription_model/user_shop_list_model.dart';
import 'package:poketstore/network/dio_network_service.dart';

class UserShopListService {
  final Dio _dio = DioNetworkService.dio;

  Future<List<UserShopListModel>> getShopsByUser() async {
    try {
      final response = await _dio.get('/api/shops/by-user');

      if (response.statusCode == 200) {
        final List data = response.data['data'];
        return data.map((e) => UserShopListModel.fromJson(e)).toList();
      } else {
        log('Failed to fetch shops');
        return [];
      }
    } catch (e, s) {
      log('getShopsByUser error: $e', stackTrace: s);
      return [];
    }
  }
}
