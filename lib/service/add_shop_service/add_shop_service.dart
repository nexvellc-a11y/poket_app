import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:poketstore/model/add_shope_model/add_shop_model.dart';
import 'package:poketstore/model/my_shope_model/shope_details_model.dart';
import 'package:poketstore/network/dio_network_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShopService {
  final Dio _dio = DioNetworkService.dio;
  final String baseUrl = "/api/shops";

  /// 🔹 Fetch shops
  Future<List<ShopModel>> fetchShops() async {
    try {
      final response = await _dio.get(baseUrl);
      final List<dynamic> data = response.data;
      return data.map((e) => ShopModel.fromJson(e)).toList();
    } on DioException catch (e) {
      log("❌ fetchShops error: ${e.response?.data ?? e.message}");
      throw Exception(e.response?.data['message'] ?? 'Failed to load shops');
    }
  }

  /// 🔹 Add shop (with userId from SharedPreferences)
  Future<String> addShop(ShopModel shop, File? imageFile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null || userId.isEmpty) {
        throw Exception("User ID not found. Please log in again.");
      }

      log("📤 addShop() called");
      log("👤 userId: $userId");
      log("🏪 shopName: ${shop.shopName}");
      log("📞 mobile: ${shop.mobileNumber}");
      log("🖼 image attached: ${imageFile != null}");
      log('district:${shop.district}');

      final formData = FormData.fromMap({
        "shopName": shop.shopName,
        "category": shop.category,
        "sellerType": shop.sellerType,
        "state": shop.state,
        "place": shop.place,
        "pinCode": shop.pinCode,
        "locality": shop.locality,
        "email": shop.email,
        "agentCode": shop.agentCode,
        "mobileNumber": shop.mobileNumber,
        "landlineNumber": shop.landlineNumber,
        "district": shop.district,
        "userId": userId,
        if (imageFile != null)
          "headerImage": await MultipartFile.fromFile(
            imageFile.path,
            filename: imageFile.path.split('/').last,
          ),
      });

      log("📦 FormData fields: ${formData.fields}");
      log("📎 FormData files: ${formData.files.map((e) => e.key).toList()}");

      final response = await _dio.post(
        baseUrl,
        data: formData,
        options: Options(headers: {"Content-Type": "multipart/form-data"}),
      );

      log("✅ addShop success");
      log("📥 Status code: ${response.statusCode}");
      log("📥 Response data service: ${response.data}");

      if (response.data is Map &&
          response.data['shop'] != null &&
          response.data['shop']['_id'] != null) {
        return response.data['shop']['_id'];
      } else {
        throw Exception('Invalid response from server');
      }
    } on DioException catch (e) {
      log("❌ addShop DioException");
      log("🔴 Status: ${e.response?.statusCode}");
      log("🔴 Data: ${e.response?.data}");
      log("🔴 Message: ${e.message}");

      if (e.response?.statusCode == 413) {
        throw Exception(
          'Image is too large. Please upload an image under 2MB.',
        );
      }

      if (e.response?.data is Map) {
        throw Exception(e.response?.data['message'] ?? 'Failed to add shop');
      }

      throw Exception('Upload failed. Please try again.');
    } catch (e) {
      log("❌ addShop unknown error: $e");
      rethrow;
    }
  }

  /// 🔹 Update shop
  Future<void> updateShop(
    String id,
    ShopeDetailsModel shopDetails,
    File? newImageFile,
  ) async {
    try {
      final formData = FormData.fromMap({
        "shopName": shopDetails.shopName,
        "category": shopDetails.category?.first,
        "sellerType": shopDetails.sellerType,
        "state": shopDetails.state,
        "place": shopDetails.place,
        "pinCode": shopDetails.pinCode,
        "locality": shopDetails.locality,
        "email": shopDetails.email,
        "mobileNumber": shopDetails.mobileNumber,
        "landlineNumber": shopDetails.landlineNumber,
        if (newImageFile != null)
          "headerImage": await MultipartFile.fromFile(
            newImageFile.path,
            filename: "shop_image.jpg",
          ),
      });

      await _dio.put('$baseUrl/$id', data: formData);
    } on DioException catch (e) {
      log("❌ updateShop error: ${e.response?.data ?? e.message}");
      throw Exception(e.response?.data['message'] ?? 'Update failed');
    }
  }

  /// 🔹 Delete shop
  Future<void> deleteShop(String id) async {
    try {
      await _dio.delete('$baseUrl/$id');
    } on DioException catch (e) {
      log("❌ deleteShop error: ${e.response?.data ?? e.message}");
      throw Exception(e.response?.data['message'] ?? 'Delete failed');
    }
  }
}
