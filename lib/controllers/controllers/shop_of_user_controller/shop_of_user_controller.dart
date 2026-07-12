import 'package:flutter/material.dart';
import 'package:poketstore/model/shop_of_user_model/shop_of_user_model.dart';
import 'package:poketstore/service/shop_of_user_service/shop_of_user_service.dart';
import 'dart:developer'; // Added for logging

class ShopOfUserProvider extends ChangeNotifier {
  List<ShopOfUser> shopList = [];
  String errorMessage = "";
  bool isLoading = false;

  Future<void> fetchUserShops() async {
    try {
      isLoading = true;
      errorMessage = ""; // Clear previous error message
      notifyListeners();

      final shops = await ShopOfUserService().getShopsByUser();
      shopList = shops;
      log(
        "✅ Shops fetched successfully. Count: ${shopList.length}",
      ); // Log success
    } catch (e) {
      log(
        "❌ ShopOfUserProvider fetchUserShops Error: $e",
      ); // Log the actual error
      shopList = []; // <--- Crucial change: Clear the list on error
      errorMessage =
          "Failed to load shops: ${e.toString()}"; // More descriptive error
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
