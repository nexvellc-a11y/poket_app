import 'package:flutter/material.dart';

class BottomBarProvider extends ChangeNotifier {
  int selectedIndex = 0; // Track selected index

  void changeTab(int index) {
    selectedIndex = index;

    notifyListeners();
  }
}
