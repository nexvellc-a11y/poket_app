import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:poketstore/model/cart_model/cart_model.dart';
import 'package:poketstore/service/cart_service/cart_service.dart';

class CartController extends ChangeNotifier {
  final CartService _service = CartService();

  Cart? _cart;
  bool _isLoading = false;
  bool _isUpdating = false;
  bool _isAdding = false;

  // ───── Getters ─────
  Cart? get cart => _cart;
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  bool get isAdding => _isAdding;

  int get itemCount => _cart?.items?.length ?? 0;
  double get totalPrice => _cart?.totalCartPrice ?? 0.0;

  // ───── Helpers ─────
  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }

  void _setAdding(bool value) {
    if (_isAdding == value) return;
    _isAdding = value;
    notifyListeners();
  }

  void _setUpdating(bool value) {
    if (_isUpdating == value) return;
    _isUpdating = value;
    notifyListeners();
  }

  // ───── API Calls ─────

  Future<void> fetchCart({bool showLoader = true}) async {
    if (showLoader) _setLoading(true);

    try {
      final response = await _service.getCart();
      _cart = response?.cart;
    } catch (e, st) {
      log("❌ fetchCart error", error: e, stackTrace: st);
      _cart = null;
    } finally {
      if (showLoader) _setLoading(false);
    }
  }

  Future<bool> addToCart(String productId, double quantity) async {
    _setAdding(true);

    try {
      final response = await _service.addToCart(
        CartRequest(productId: productId, quantity: quantity),
      );

      if (response != null) {
        _cart = response.cart; // 🔹 update locally, no refetch
        return true;
      }
      return false;
    } catch (e, st) {
      log("❌ addToCart error", error: e, stackTrace: st);
      return false;
    } finally {
      _setAdding(false);
    }
  }

  Future<bool> updateQuantity(String productId, double newQuantity) async {
    _setUpdating(true);

    try {
      final success = await _service.updateCartItem(productId, newQuantity);
      if (success) {
        await fetchCart(showLoader: false); // 🔹 silent refresh
      }
      return success;
    } catch (e, st) {
      log("❌ updateQuantity error", error: e, stackTrace: st);
      return false;
    } finally {
      _setUpdating(false);
    }
  }

  Future<bool> removeItem(String productId) async {
    _setUpdating(true);

    try {
      final success = await _service.removeCartItem(productId);
      if (success) {
        await fetchCart(showLoader: false); // 🔹 silent refresh
      }
      return success;
    } catch (e, st) {
      log("❌ removeItem error", error: e, stackTrace: st);
      return false;
    } finally {
      _setUpdating(false);
    }
  }

  // ───── Local Queries (Fast) ─────

  bool isProductInCart(String productId) {
    final items = _cart?.items;
    if (items == null || items.isEmpty) return false;

    return items.any((i) => i.product?.id == productId && i.isInCart == true);
  }

  double? getProductQuantity(String productId) {
    final items = _cart?.items;
    if (items == null || items.isEmpty) return null;

    for (final item in items) {
      if (item.product?.id == productId && item.isInCart == true) {
        return item.quantity;
      }
    }
    return null;
  }
}
