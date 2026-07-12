import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:poketstore/model/shop_nearby_model/shop_product_nearby_model.dart';

class ShopProductNearbyService {
  final Dio _dio = Dio();
  final String baseUrl = 'https://api.poketstor.com/api/products/by-shopId/';

  Future<ProductByShopModel?> fetchProductsByShopId(String shopId) async {
    try {
      final response = await _dio.get('$baseUrl$shopId');
      if (response.statusCode == 200) {
        return ProductByShopModel.fromJson(response.data);
      } else {
        log('Error: ${response.statusCode}');
      }
    } catch (e) {
      log('Fetch error: $e');
    }
    return null;
  }
}
