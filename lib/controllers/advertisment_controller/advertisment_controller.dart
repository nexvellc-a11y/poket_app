import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:poketstore/model/advertisment_model/advertisment_model.dart';
import 'package:poketstore/service/advertisment_service/advertisment_service.dart';

class AdvertisementController extends ChangeNotifier {
  final AdvertisementService _service = AdvertisementService();

  List<AdvertisementModel> _ads = [];
  bool _isLoading = false;
  String? _error;

  List<AdvertisementModel> get ads => _ads;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }

  Future<void> getAdvertisements({bool forceRefresh = false}) async {
    // 🔹 Prevent unnecessary API calls
    if (_ads.isNotEmpty && !forceRefresh) return;

    _error = null;
    _setLoading(true);

    try {
      final result = await _service.fetchAdvertisements();
      _ads = result;
    } catch (e, st) {
      _error = e.toString();
      log("❌ AdvertisementController error", error: e, stackTrace: st);
    } finally {
      _setLoading(false);
    }
  }
}
