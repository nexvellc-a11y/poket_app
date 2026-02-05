import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:poketstore/model/order_model/order_details_model.dart';
import 'package:poketstore/model/order_model/order_list_model.dart';
import 'package:poketstore/service/order_service/order_list_details_service.dart';

class OrderListController extends ChangeNotifier {
  final OrderListService _service = OrderListService();

  List<OrderSummary> _orders = [];
  OrderDetail? _orderDetail;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<OrderSummary> get orders => _orders;
  OrderDetail? get orderDetail => _orderDetail;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch all orders for a user
  Future<void> getOrders(String userId) async {
    if (_isLoading) return; // 🚫 Prevent duplicate calls

    _setLoading(true);
    _error = null;

    log("📦 Fetching orders for userId: $userId");

    try {
      _orders = await _service.fetchOrders(userId);
      log("✅ Orders fetched: ${_orders.length}");
    } catch (e, stackTrace) {
      _error = "Failed to load orders";
      log("❌ Error fetching orders", error: e, stackTrace: stackTrace);
    } finally {
      _setLoading(false);
    }
  }

  /// Fetch single order details
  Future<void> getOrderDetails(String orderId) async {
    _error = null;
    _orderDetail = null;
    notifyListeners(); // 🔄 Update UI immediately (loading state optional)

    log("📄 Fetching order details for orderId: $orderId");

    try {
      _orderDetail = await _service.fetchOrderDetails(orderId);
      log("✅ Order details loaded");
    } catch (e, stackTrace) {
      _error = "Failed to load order details";
      log("❌ Error fetching order details", error: e, stackTrace: stackTrace);
    } finally {
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Optional helper to clear order details (useful on back navigation)
  void clearOrderDetail() {
    _orderDetail = null;
    notifyListeners();
  }
}
