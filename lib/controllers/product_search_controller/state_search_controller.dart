import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:poketstore/model/product_search_model/state_search.dart';
import 'package:poketstore/service/product_search_service/state_search_service.dart';

class StateController extends ChangeNotifier {
  final StateService _service = StateService();

  bool isLoading = false;
  List<String> statesList = [];

  Future<void> fetchStates() async {
    isLoading = true;
    notifyListeners();

    try {
      StateModel? data = await _service.getStates();

      if (data != null && data.success) {
        statesList = data.states;
      }
    } catch (e) {
      log("State Controller Error: $e");
    }

    isLoading = false;
    notifyListeners();
  }
}
