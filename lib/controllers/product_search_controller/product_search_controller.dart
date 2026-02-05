// poketstore/controllers/product_search_controller/product_search_provider.dart
import 'package:flutter/material.dart';
import 'package:poketstore/model/product_search_model/product_search_model.dart';
import 'package:poketstore/service/product_search_service/product_search_service.dart';

// ProductSearchProvider manages the state for product search results.
class ProductSearchProvider extends ChangeNotifier {
  final ProductSearchService _productSearchService = ProductSearchService();

  List<ProductSearchModel> searchResults = []; // List to hold search results.
  bool isLoading = false; // Indicates if data is currently being fetched.
  String errorMessage = ''; // Stores any error messages.

  // Method to fetch search results based on product name and locality.
  Future<void> fetchSearchResults(String productName, String locality) async {
    isLoading = true; // Set loading to true before starting the fetch.
    errorMessage = ''; // Clear any previous error messages.
    notifyListeners(); // Notify listeners to update UI (e.g., show loading indicator).

    try {
      // Call the service to get the search results.
      searchResults = await _productSearchService.searchProducts(
        productName,
        locality,
      );
    } catch (e) {
      // If an error occurs, store the error message.
      errorMessage = e.toString().replaceFirst(
        'Exception: ',
        '',
      ); // Clean up exception message.
      searchResults = []; // Clear results on error.
    } finally {
      isLoading =
          false; // Set loading to false after fetch completes (success or failure).
      notifyListeners(); // Notify listeners again to update UI (e.g., hide loading indicator, show results/error).
    }
  }

  // NEW METHOD: Fetch products by locality only.
  Future<void> fetchProductsByDistrict(String district) async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      searchResults = await _productSearchService.searchProducts(
        "", // productName empty
        district, // using district instead of locality
      );
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      searchResults = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clearSearchResults() {
    searchResults = [];
    errorMessage = '';
    isLoading = false;
    notifyListeners();
  }
}
