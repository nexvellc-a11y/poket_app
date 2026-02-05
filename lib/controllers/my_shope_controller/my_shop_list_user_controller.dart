import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:poketstore/model/my_shope_model/my_shop_list_user_model.dart';
import 'package:poketstore/service/my_product_service/my_shop_list_user_service.dart';

class MyShopListUserProvider extends ChangeNotifier {
  final MyShopListUserService _service = MyShopListUserService();

  List<ShopData> _shopList = [];
  bool _isLoading = false;
  String? _error;

  List<ShopData> get shopList => _shopList;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Optional: store products with shop name if needed later
  List<Map<String, dynamic>> allProductsWithShopName = [];

  /// Centralized state updater
  void _updateState({
    List<ShopData>? shopList,
    bool? isLoading,
    String? error,
  }) {
    if (shopList != null) _shopList = shopList;
    if (isLoading != null) _isLoading = isLoading;
    _error = error;
    notifyListeners();
  }

  /// Fetch user's shop list
  Future<void> fetchUserShopList(String userId) async {
    if (_isLoading) return; // prevent duplicate calls
    _updateState(isLoading: true, error: null);

    try {
      final response = await _service.fetchUserShopList(userId);

      if (response.data.isEmpty) {
        _updateState(shopList: [], error: "No shops found for this user.");
        log("No shops found for user: $userId");
      } else {
        _updateState(shopList: response.data);
        log("Fetched ${response.data.length} shops for user: $userId");
      }
    } catch (e, stackTrace) {
      _updateState(shopList: [], error: e.toString());
      log("Error fetching user shop list: $e", stackTrace: stackTrace);
    }
  }

  /// Optional: clear shop data (on logout, etc.)
  void clear() => _updateState(shopList: [], isLoading: false, error: null);
}
