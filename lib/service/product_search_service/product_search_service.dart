import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poketstore/model/product_search_model/product_search_model.dart';

class ProductSearchService {
  static const String _baseUrl =
      'https://api.poketstor.com/api/products/search';
  final Dio _dio = Dio();

  Future<List<ProductSearchModel>> searchProducts(
    String productName,
    String selectedDistrict,
  ) async {
    try {
      // Replace empty strings with 'null' for API compatibility.
      final String nameParam = productName.isEmpty ? 'null' : productName;
      final String selectedDistrictParam =
          selectedDistrict.isEmpty ? 'null' : selectedDistrict;

      // Get userId from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId') ?? '';

      // Construct the API URL with query parameter
      final String url =
          '$_baseUrl/$nameParam/$selectedDistrictParam${userId.isNotEmpty ? '?userId=$userId' : ''}';

      log('Searching products at: $url'); // Log the constructed URL

      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        if (responseData['success'] == true) {
          final List<dynamic> productListJson = responseData['data'];
          return productListJson
              .map((json) => ProductSearchModel.fromJson(json))
              .toList();
        } else {
          throw Exception(
            responseData['message'] ?? 'Failed to search products',
          );
        }
      } else {
        throw Exception(
          'Failed to load products. Status code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      log('Dio Error searching products: ${e.message}');
      if (e.response != null) {
        log('Dio Error Response Data: ${e.response?.data}');
        log('Dio Error Response Headers: ${e.response?.headers}');
        log(
          'Dio Error Response Request Options: ${e.response?.requestOptions}',
        );
        throw Exception(
          'Failed to search products: ${e.response?.data['message'] ?? e.message}',
        );
      } else {
        throw Exception('Error sending request: ${e.message}');
      }
    } catch (e) {
      log('Unexpected Error searching products: $e');
      throw Exception('Unexpected error searching products: $e');
    }
  }
}
