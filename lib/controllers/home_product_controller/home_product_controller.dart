import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:poketstore/model/home_product_model/home_product_model.dart';
import 'package:poketstore/service/home_product_service/home_product_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeProductController extends ChangeNotifier {
  final LocationProductService _service = LocationProductService();

  List<LocationProduct> products = [];
  bool isLoading = false;
  String? errorMessage;

  /// Load products based on stored user ID
  Future<void> loadProducts() async {
    _setState(isLoading: true, error: null);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        log('HomeProductController: User ID not found');
        _setState(isLoading: false, error: "User ID not found.");
        return;
      }

      final result = await _service.fetchProductsByUserId(userId);

      products = result;
      log(
        'HomeProductController: Loaded ${products.length} products for user: $userId',
      );

      _setState(isLoading: false);
    } catch (e, stackTrace) {
      log(
        'HomeProductController: Failed to load products',
        error: e,
        stackTrace: stackTrace,
      );

      _setState(isLoading: false, error: "Failed to load products");
    }
  }

  /// Clear product data (e.g., on logout)
  void clearProducts() {
    products.clear();
    _setState(isLoading: false, error: null);
  }

  /// Centralized state updater (less rebuilds, safer)
  void _setState({bool? isLoading, String? error}) {
    if (isLoading != null) this.isLoading = isLoading;
    errorMessage = error;
    notifyListeners();
  }
}
