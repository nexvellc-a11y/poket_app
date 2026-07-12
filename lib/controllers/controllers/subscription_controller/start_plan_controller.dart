// StartSubscriptionProvider
import 'package:flutter/foundation.dart';
import 'package:poketstore/model/subscription_model/start_plan_model.dart';
import 'package:poketstore/service/subscription_service/start_plan_service.dart';

class StartSubscriptionProvider with ChangeNotifier {
  StartSubscriptionResponse? _subscriptionResponse;
  String? _errorMessage;
  bool _isLoading = false;

  StartSubscriptionResponse? get subscriptionResponse => _subscriptionResponse;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  final SubscriptionService _subscriptionService = SubscriptionService();

  Future<StartSubscriptionResponse?> startSubscription({
    required String subscriptionPlanId,
    required String shopId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _subscriptionService.startSubscription(
        subscriptionPlanId: subscriptionPlanId,
        shopId: shopId,
      );

      _subscriptionResponse = result;
      return result;
    } catch (e) {
      // ✅ This will now show API message for 400
      _errorMessage = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
