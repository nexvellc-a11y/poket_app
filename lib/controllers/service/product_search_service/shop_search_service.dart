// services/shop_search_service.dart
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:poketstore/model/product_search_model/shop_search_model.dart';

class ShopSearchService {
  final Dio _dio = Dio();

  Future<ShopSearchModel?> searchShops(String query, String userId) async {
    try {
      final response = await _dio.get(
        'https://api.poketstor.com/api/shops/search/$query/$userId',
      );

      if (response.statusCode == 200) {
        return ShopSearchModel.fromJson(response.data);
      } else {
        log('Failed to fetch shops: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      log('Error fetching shops: $e');
      return null;
    }
  }
}
