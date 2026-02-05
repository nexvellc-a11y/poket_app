import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:poketstore/model/product_by_shop/product_by_shop_model.dart';

class ProductsByShopService {
  final Dio _dio = Dio();

  Future<List<ProductsByShop>> fetchProductsByShopId(String shopId) async {
    final url = 'https://api.poketstor.com/api/products/by-shopId/$shopId';

    try {
      final response = await _dio.get(url);
      if (response.statusCode == 200 && response.data['products'] != null) {
        List products = response.data['products'];
        return products.map((json) => ProductsByShop.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      log('Error fetching products by shop ID: $e');
      return [];
    }
  }
}
