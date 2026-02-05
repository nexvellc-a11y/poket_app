import 'package:flutter/material.dart';

class SearchProducerProvider extends ChangeNotifier {
  String? selectedState;
  final List<String> states = ["California", "Texas", "New York", "Florida"];

  final List<Map<String, String>> producers = [
    {"name": "James Anderson", "category": "Lorem Ipsum"},
    {"name": "John Doe", "category": "Dolor Sit Amet"},
    {"name": "Jane Smith", "category": "Consectetur Adipiscing"},
  ];

  void updateSelectedState(String? state) {
    selectedState = state;
    notifyListeners(); // Notify UI to rebuild
  }
}
