import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:poketstore/model/order_model/order_model.dart';
import 'package:poketstore/service/order_service/order_service.dart';

class OrderController extends ChangeNotifier {
  final OrderService _orderService = OrderService();

  bool _isLoading = false;
  String? _message;
  Map<String, dynamic>? _placedOrder;

  // Getters (safer than public vars)
  bool get isLoading => _isLoading;
  String? get message => _message;
  Map<String, dynamic>? get placedOrder => _placedOrder;

  Future<void> placeOrder(OrderItemModel orderItemModel) async {
    if (_isLoading) return; // 🚫 Prevent duplicate calls

    _setLoading(true);
    _message = null;
    _placedOrder = null;

    try {
      final result = await _orderService.placeOrder(orderItemModel);

      if (result != null) {
        _message = result['message'] ?? 'Order placed successfully';
        _placedOrder = result['order'];
        log('Order placed: $_placedOrder');
      } else {
        _message = 'Order failed';
        log('Order failed: null response');
      }
    } catch (e, stackTrace) {
      _message = 'Something went wrong while placing order';
      log('Order error', error: e, stackTrace: stackTrace);
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Optional: reset state (useful after showing success screen)
  void clear() {
    _message = null;
    _placedOrder = null;
    notifyListeners();
  }
}
