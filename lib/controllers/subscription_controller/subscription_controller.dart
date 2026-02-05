import 'package:flutter/material.dart';
import 'package:poketstore/model/subscription_model/subscription_model.dart';
import 'package:poketstore/service/subscription_service/subscription_service.dart';

class SubscriptionProvider extends ChangeNotifier {
  final SubscriptionService _service = SubscriptionService();

  bool _isLoading = false;
  List<Plan> _plans = [];
  String? _errorMessage;

  bool get isLoading => _isLoading;
  List<Plan> get plans => _plans;
  String? get errorMessage => _errorMessage;

  Future<void> loadPlans() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _service.fetchPlans();
    if (result != null && result.success == true) {
      _plans = result.plans ?? [];
    } else {
      _errorMessage = "Failed to load plans";
    }

    _isLoading = false;
    notifyListeners();
  }
}
