// 3. Service Class
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:poketstore/model/home_product_model/home_product_model.dart';

class LocationProductService {
  final Dio _dio = Dio();
  final String _baseUrl = 'https://api.poketstor.com/api/products'; // Base URL

  // Function to fetch products by user ID
  Future<List<LocationProduct>> fetchProductsByUserId(String userId) async {
    try {
      final response = await _dio.get('$_baseUrl/nearbyshop/$userId');

      if (response.statusCode == 200 && response.data is Map) {
        //Improved null and type checking
        final Map<String, dynamic> responseData =
            response.data as Map<String, dynamic>;
        if (responseData.containsKey('products') &&
            responseData['products'] is List) {
          List<dynamic> productList = responseData['products'];
          return productList
              .map((productJson) => LocationProduct.fromJson(productJson))
              .toList();
        } else {
          log(
            'LocationProductService: "products" key is missing or not a List',
          );
          return [];
        }
      } else {
        log(
          'LocationProductService: Failed to fetch products. Status: ${response.statusCode}, Response: ${response.data}',
        );
        return [];
      }
    } catch (error) {
      log('LocationProductService: Error - $error');
      return [];
    }
  }
}
