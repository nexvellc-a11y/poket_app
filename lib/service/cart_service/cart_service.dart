import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:poketstore/model/cart_model/cart_model.dart';
import 'package:poketstore/network/dio_network_service.dart';

class CartService {
  final Dio _dio = DioNetworkService.dio;
  static const String _baseUrl = '/api';

  Future<CartResponse?> addToCart(CartRequest request) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/cart/add',
        data: request.toJson(),
      );
      return CartResponse.fromJson(response.data);
    } on DioException catch (e) {
      log('❌ Add to cart error: ${e.response?.data ?? e.message}');
      return null;
    }
  }

  Future<CartResponse?> getCart() async {
    try {
      final response = await _dio.get('$_baseUrl/cart');
      return CartResponse.fromJson(response.data);
    } on DioException catch (e) {
      log('❌ Fetch cart error: ${e.response?.data ?? e.message}');
      return null;
    }
  }

  Future<bool> updateCartItem(String productId, double quantity) async {
    try {
      await _dio.put(
        '$_baseUrl/cart/update-quantity/$productId',
        data: {'quantity': quantity},
      );
      return true;
    } on DioException catch (e) {
      log('❌ Update quantity error: ${e.response?.data ?? e.message}');
      return false;
    }
  }

  Future<bool> removeCartItem(String productId) async {
    try {
      await _dio.delete('$_baseUrl/cart/remove/$productId');
      return true;
    } on DioException catch (e) {
      log('❌ Remove item error: ${e.response?.data ?? e.message}');
      return false;
    }
  }
}
