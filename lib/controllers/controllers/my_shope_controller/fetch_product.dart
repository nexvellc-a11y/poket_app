import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:poketstore/model/my_shope_model/product_model.dart';
import 'package:poketstore/service/my_product_service/product_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FetchProductProvider with ChangeNotifier {
  final ProductService _service = ProductService();

  List<Product> _products = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// 🔑 Central state updater
  void _updateState({
    List<Product>? products,
    bool? isLoading,
    String? errorMessage,
  }) {
    if (products != null) _products = products;
    if (isLoading != null) _isLoading = isLoading;
    _errorMessage = errorMessage;
    notifyListeners();
  }

  void _startLoading() {
    _updateState(isLoading: true, errorMessage: null);
  }

  /// Load all products
  Future<void> loadProducts() async {
    if (_isLoading) return;

    log("Fetching all products...");
    _startLoading();

    try {
      final fetchedProducts = await _service.fetchProducts();

      if (fetchedProducts.isEmpty) {
        _updateState(
          products: [],
          isLoading: false,
          errorMessage: "No products available.",
        );
      } else {
        _updateState(products: fetchedProducts, isLoading: false);
        log("Fetched ${fetchedProducts.length} products");
      }
    } catch (e, s) {
      log("Load products failed", error: e, stackTrace: s);
      _updateState(isLoading: false, errorMessage: "Failed to load products");
    }
  }

  /// Load products for logged-in user
  Future<void> loadProductsForUser() async {
    if (_isLoading) return;

    log("Fetching products for user...");
    _startLoading();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null || userId.isEmpty) {
        _updateState(
          isLoading: false,
          errorMessage: "User ID not found. Please log in again.",
        );
        return;
      }

      final fetchedProducts = await _service.fetchProductsForUser(userId);

      if (fetchedProducts.isEmpty) {
        _updateState(
          products: [],
          isLoading: false,
          errorMessage: "No products found for this user.",
        );
      } else {
        _updateState(products: fetchedProducts, isLoading: false);
        log("Fetched ${fetchedProducts.length} products for user $userId");
      }
    } catch (e, s) {
      log("Load user products failed", error: e, stackTrace: s);
      _updateState(
        isLoading: false,
        errorMessage: "Failed to load user products",
      );
    }
  }

  /// Optional: clear data on logout
  void clear() {
    _updateState(products: [], isLoading: false, errorMessage: null);
  }
}
