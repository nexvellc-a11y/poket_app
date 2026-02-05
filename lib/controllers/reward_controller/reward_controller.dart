import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:poketstore/model/reward_model/reward_model.dart';
import 'package:poketstore/service/reward_service/reward_service.dart';

class RewardController extends ChangeNotifier {
  final RewardService _service = RewardService();

  bool _isLoading = false;
  String? _message;
  double? _rewardPoints;
  String? _error;

  // Getters
  bool get isLoading => _isLoading;
  String? get message => _message;
  double? get rewardPoints => _rewardPoints;
  String? get error => _error;

  Future<bool> completeOrder({
    required String orderId,
    required String shopId,
  }) async {
    if (_isLoading) {
      log(
        "⚠️ completeOrder blocked (already loading)",
        name: 'RewardController',
      );
      return false;
    }

    _setLoading(true);
    _resetState();

    log(
      "➡️ Completing order started | orderId=$orderId | shopId=$shopId",
      name: 'RewardController',
    );

    try {
      final RewardModel response = await _service.completeOrder(
        orderId: orderId,
        shopId: shopId,
      );

      _message = response.message;
      _rewardPoints = response.rewardPoints;

      log(
        "✅ Order completed successfully | reward=${response.rewardPoints}",
        name: 'RewardController',
      );

      return response.success;
    } catch (e, stack) {
      _error = e.toString();

      log(
        "❌ Error completing order | orderId=$orderId",
        name: 'RewardController',
        error: e,
        stackTrace: stack,
      );

      return false;
    } finally {
      _setLoading(false);
      log("⬅️ completeOrder finished", name: 'RewardController');
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _resetState() {
    _message = null;
    _rewardPoints = null;
    _error = null;
  }

  void clearState() {
    _resetState();
    notifyListeners();

    log("🧹 RewardController state cleared", name: 'RewardController');
  }
}
