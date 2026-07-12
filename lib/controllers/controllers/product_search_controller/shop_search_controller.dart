// controllers/shop_search_controller.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poketstore/model/product_search_model/shop_search_model.dart';
import 'package:poketstore/service/product_search_service/shop_search_service.dart';

class ShopSearchController extends ChangeNotifier {
  final ShopSearchService _service = ShopSearchService();

  bool isLoading = false;
  String errorMessage = '';
  List<ShopSearchDetailsModel> shops = [];

  /// 🔍 Search with both query and userId

  /// ✅ Public getter

  /// 🔍 Search with both query and userId
  Future<void> searchShops(String query, String userId) async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    final result = await _service.searchShops(query, userId);
    if (result != null) {
      shops = result.shops;
    } else {
      errorMessage = "Failed to load shops.";
    }

    isLoading = false;
    notifyListeners();
  }

  /// ✅ Search using SharedPreferences for userId
  Future<void> searchShopsWithPrefs(String query) async {
    isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId != null && userId.isNotEmpty) {
      await searchShops(query, userId);
    } else {
      errorMessage = 'User ID not found in preferences';
      isLoading = false;
      notifyListeners();
    }
  }
}
