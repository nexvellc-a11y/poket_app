import 'package:flutter/material.dart';

// Provider Class
class LocationProvider extends ChangeNotifier {
  String? selectedZone;
  String? selectedArea;
  String pincode = "";

  final List<String> zones = ["Zone 1", "Zone 2", "Zone 3"];
  final List<String> areas = ["Area A", "Area B", "Area C"];

  void updateZone(String? zone) {
    selectedZone = zone;
    notifyListeners();
  }

  void updateArea(String? area) {
    selectedArea = area;
    notifyListeners();
  }

  void updatePincode(String value) {
    pincode = value;
    notifyListeners();
  }
}
