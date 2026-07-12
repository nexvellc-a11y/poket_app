import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:poketstore/model/my_shope_model/shope_details_model.dart';
import 'package:poketstore/service/my_product_service/shope_details_service.dart';

class ShopeDetailsProvider extends ChangeNotifier {
  final ShopeDetailsService _service = ShopeDetailsService();

  ShopeDetailsModel? _shopDetails;
  bool _isLoading = false;
  String? _errorMessage;

  ShopeDetailsModel? get shopDetails => _shopDetails;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Centralized state update
  void _updateState({
    ShopeDetailsModel? shopDetails,
    bool? isLoading,
    String? errorMessage,
  }) {
    if (shopDetails != null) _shopDetails = shopDetails;
    if (isLoading != null) _isLoading = isLoading;
    _errorMessage = errorMessage;
    notifyListeners();
  }

  /// Load shop details by ID
  Future<void> loadShopeDetails(String id) async {
    if (_isLoading) return; // Prevent duplicate calls
    _updateState(isLoading: true, errorMessage: null);

    try {
      final details = await _service.fetchShopeDetails(id);

      if (details == null) {
        _updateState(errorMessage: "Shop details not found.");
        log("Shop details not found for ID: $id");
      } else {
        _updateState(shopDetails: details);
        log("Shop details loaded for ID: $id");
      }
    } catch (e, stackTrace) {
      _updateState(errorMessage: "Failed to load shop details.");
      log("Error loading shop details for ID $id: $e", stackTrace: stackTrace);
    } finally {
      _updateState(isLoading: false);
    }
  }

  /// Refresh shop details
  Future<void> refreshDetails(String shopId) async => loadShopeDetails(shopId);

  /// Optional: clear provider state
  void clear() =>
      _updateState(shopDetails: null, isLoading: false, errorMessage: null);
}
