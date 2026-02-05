import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:poketstore/model/add_shope_model/add_shop_model.dart';
import 'package:poketstore/model/my_shope_model/shope_details_model.dart';
import 'package:poketstore/service/add_shop_service/add_shop_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShopProvider with ChangeNotifier {
  final ShopService _shopService = ShopService();
  List<ShopModel> shops = [];
  bool isLoading = false;
  String errorMessage = '';

  Future<void> fetchShops() async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      shops = await _shopService.fetchShops();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> addShop(ShopModel shop, File? imageFile) async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    log("🟢 addShop() called from controller");
    log("➡️ Shop Data:");
    log("  shopName: ${shop.shopName}");
    log("  category: ${shop.category}");
    log("  sellerType: ${shop.sellerType}");
    log("  state: ${shop.state}");
    log("  place: ${shop.place}");
    log("  pinCode: ${shop.pinCode}");
    log("  locality: ${shop.locality}");
    log("  email: ${shop.email}");
    log("  agentCode: ${shop.agentCode}");
    log("  mobileNumber: ${shop.mobileNumber}");
    log("  landlineNumber: ${shop.landlineNumber}");
    log("  headerImage: ${imageFile?.path ?? 'No image selected'}");
    log("district:${shop.district}");

    try {
      final String newShopId = await _shopService.addShop(shop, imageFile);
      log("✅ Shop created successfully with ID: $newShopId");
      return newShopId;
    } catch (e, stackTrace) {
      errorMessage = e.toString();
      log(
        "❌ Error in controller addShop: $errorMessage",
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    } finally {
      isLoading = false;
      log("🔄 Fetching updated shop list...");
      await fetchShops();
      notifyListeners();
      log("🟢 Controller addShop() finished");
    }
  }

  Future<void> updateShop(
    ShopeDetailsModel shopDetails,
    File? newImageFile, // Added newImageFile parameter
  ) async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      if (shopDetails.id == null || shopDetails.id!.isEmpty) {
        throw Exception("Shop ID is required for updating.");
      }

      // final prefs = await SharedPreferences.getInstance();
      // final token = prefs.getString('token');

      // if (token == null || token.isEmpty) {
      //   throw Exception("Authentication token not found. Please log in again.");
      // }

      await _shopService.updateShop(shopDetails.id!, shopDetails, newImageFile);
      errorMessage = "";
      log("✅ Shop updated successfully!");
    } catch (e) {
      errorMessage = e.toString();
      log("❌ Provider error updating shop: $e");
    } finally {
      isLoading = false;
      fetchShops(); // Refresh shops after update
      notifyListeners();
    }
  }
  // Assuming this method is part of your AddShopController or a similar ShopProvider class

  Future<void> deleteShop(
    String shopId,
    BuildContext context,
    void Function() callback, // This callback will trigger fetchUserShops
  ) async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      // Assuming _shopService.deleteShop is properly implemented and throws on actual failure
      await _shopService.deleteShop(shopId);
      errorMessage = ""; // Clear error message on success
      log("✅ Shop deleted successfully from backend: $shopId");

      // Trigger the callback to refresh the list on the previous screen
      callback.call();

      // Show success snackbar
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Shop deleted successfully!'),
          backgroundColor: Color.fromARGB(
            255,
            7,
            3,
            201,
          ), // Use your primary blue
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          margin: EdgeInsets.all(10),
        ),
      );

      // Pop the current screen (ShopeDetailsScreen) after successful deletion and refresh
      // The ShopeDetailsScreen already handles this pop with `true`,
      // so this specific `pop` might be redundant or could cause issues if called twice.
      // Let's rely on the ShopeDetailsScreen to pop with `true`.
      // Remove this line if ShopeDetailsScreen handles it:
      // Navigator.of(context).pop(true);
    } catch (e) {
      // Log the error for debugging
      log("❌ Provider error deleting shop: $e");
      errorMessage =
          "Error deleting shop: ${e.toString()}"; // Set error message

      // Show error snackbar
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          margin: EdgeInsets.all(10),
        ),
      );
      // Do not pop here if deletion failed; let the user stay on the details screen to retry or review.
      // If the delete actually failed on the backend, you shouldn't pop with true.
      // If you still want to pop, pop without a true result:
      // Navigator.of(context).pop();
    } finally {
      isLoading = false;
      notifyListeners(); // Notify listeners whether success or failure
    }
  }
}
