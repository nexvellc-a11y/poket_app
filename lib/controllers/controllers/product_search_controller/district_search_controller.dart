import 'package:flutter/material.dart';
import 'package:poketstore/service/product_search_service/district_search_service.dart';

class DistrictController with ChangeNotifier {
  final DistrictService _districtService = DistrictService();

  List<String> districtList = [];
  bool isLoading = false;
  String errorMessage = "";

  Future<void> fetchDistricts(String state) async {
    try {
      isLoading = true;
      errorMessage = "";
      notifyListeners();

      final result = await _districtService.fetchDistricts(state);

      districtList = result.districts;
    } catch (e) {
      errorMessage = e.toString();
      districtList = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    districtList = [];
    notifyListeners();
  }
}
