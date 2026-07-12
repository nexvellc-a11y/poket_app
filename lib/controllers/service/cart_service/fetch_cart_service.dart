// // lib/service/cart_service/cart_service.dart
// import 'dart:developer';
// import 'package:dio/dio.dart';
// import 'package:poketstore/model/cart_model/cart_model.dart';
// import 'package:poketstore/model/cart_model/fetch_cart_model.dart'; // Make sure this path is correct

// class FetchCartService {
//   final Dio _dio = Dio();
//   static const String _baseUrl =
//       'https://api.poketstor.com/api'; // Base URL

//   Future<CartResponseModel?> getCart(String token) async {
//     const url = '$_baseUrl/cart';
//     try {
//       final response = await _dio.get(
//         url,
//         options: Options(headers: {'Authorization': 'Bearer $token'}),
//       );
//       log("Cart API response: ${response.data}");
//       return CartResponseModel.fromJson(response.data);
//     } catch (e) {
//       log("Cart fetch error: $e");
//       return null;
//     }
//   }

//   Future<bool> updateCartItemQuantity(
//     String token,
//     String productId,
//     double quantity,
//   ) async {
//     final url = '$_baseUrl/cart/update-quantity/$productId';
//     try {
//       await _dio.put(
//         url,
//         data: {'quantity': quantity},
//         options: Options(headers: {'Authorization': 'Bearer $token'}),
//       );
//       log("Quantity updated successfully for product $productId to $quantity");
//       return true;
//     } on DioException catch (e) {
//       if (e.response != null) {
//         log("Update quantity error response: ${e.response!.data}");
//       } else {
//         log("Update quantity error: $e");
//       }
//       return false;
//     } catch (e) {
//       log("Unexpected error updating quantity: $e");
//       return false;
//     }
//   }

//   Future<bool> removeCartItem(String token, String productId) async {
//     final url = '$_baseUrl/cart/remove/$productId';
//     try {
//       await _dio.delete(
//         url,
//         options: Options(headers: {'Authorization': 'Bearer $token'}),
//       );
//       log("Item with product ID $productId removed from cart successfully.");
//       return true;
//     } on DioException catch (e) {
//       if (e.response != null) {
//         log("Remove item error response: ${e.response!.data}");
//       } else {
//         log("Remove item error: $e");
//       }
//       return false;
//     } catch (e) {
//       log("Unexpected error removing item: $e");
//       return false;
//     }
//   }
// }
