import 'dart:io';
import 'package:flutter/material.dart';
import 'package:poketstore/model/my_shope_model/product_model.dart';
import 'package:poketstore/service/my_product_service/product_service.dart';
import 'dart:developer'; // Import the developer library for logging

// Assuming FetchProductProvider exists and manages a list of products,
// especially for a user.

/// A [ChangeNotifier] for managing product-related state and interactions
/// with the [ProductService].
///
/// This provider handles operations like creating, fetching (single), updating,
/// and deleting products, notifying its listeners of state changes (e.g., loading, errors).
class ProductProvider with ChangeNotifier {
  final ProductService _productService = ProductService();

  Product? _product; // Private variable for a single product's state
  bool _isLoading = false; // Private variable for loading state
  String? _errorMessage; // Private variable for error messages
  String? _shopIdForSubscription;
  // Public getters to access the private state variables
  Product? get product => _product;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get shopIdForSubscription => _shopIdForSubscription;
  bool _subscriptionRequired = false;

  bool get subscriptionRequired => _subscriptionRequired;

  /// Sets the loading state and notifies listeners.
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Sets the error message and notifies listeners.
  void _setErrorMessage(String? message, {String? shopId}) {
    _errorMessage = message;
    _shopIdForSubscription = shopId;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    _shopIdForSubscription = null;
    notifyListeners();
  }

  /// Creates a new product.
  ///
  /// This method communicates with the [ProductService] to send product data
  /// to the backend. It updates loading and error states accordingly.
  Future<void> createProduct({
    required String userId,
    required String shopId,
    File? productImage,
    String? name,
    String? description,
    int? price,
    int? quantity,
    String? category,
    String? estimatedTime,
    String? unitType,
    String? deliveryOption,
  }) async {
    _setLoading(true);
    _clearError();

    _product = null;
    _subscriptionRequired = false;
    notifyListeners();

    try {
      final Product? newProduct = await _productService.createProduct(
        userId: userId,
        shopId: shopId,
        productImage: productImage,
        name: name,
        description: description,
        price: price,
        quantity: quantity,
        estimatedTime: estimatedTime,
        unitType: unitType,
        deliveryOption: deliveryOption,
      );

      if (newProduct != null) {
        _product = newProduct;
        log("Product created successfully");
      } else {
        _subscriptionRequired = true; // 🔥 key line
        _setErrorMessage(
          "Subscription is not active. Please subscribe to continue",
        );
      }
    } catch (e, stackTrace) {
      _setErrorMessage("Failed to create product");
      log("Error creating product", error: e, stackTrace: stackTrace);
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  /// Fetches a single product's details by its ID.
  ///
  /// This method updates the [_product] state and handles loading and errors.
  Future<void> fetchProduct(String productId) async {
    _setLoading(true);
    _setErrorMessage(null); // Clear any previous errors

    log("Attempting to fetch product with ID: $productId");

    try {
      _product = await _productService.fetchProduct(productId);
      log("Product fetched successfully: ${_product?.name}");
    } catch (e, stackTrace) {
      _product = null; // Clear product on error
      _setErrorMessage("Failed to load product details: ${e.toString()}");
      log(
        "Error fetching product ID $productId: $e",
        error: e,
        stackTrace: stackTrace,
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Updates an existing product.
  ///
  /// This method calls the [ProductService] to perform the update.
  /// It also triggers a refresh of the single product and potentially
  /// the list of products for the user (via `FetchProductProvider`).
  ///
  /// Note: The `data` parameter in your original code was unused in the service call.
  /// Ensure you pass the individual fields for update as your service expects.
  /// I've updated the signature and the call to reflect the service's parameters.
  Future<bool> updateProduct(
    String productId, {
    File? productImage,
    String? name,
    String? description,
    int? price,
    int? quantity,
    List<String>? category,
    String? estimatedTime,
    String? unitType,
    String? deliveryOption,
  }) async {
    _setLoading(true);
    _setErrorMessage(null);

    log("Attempting to update product with ID: $productId");
    // Log individual fields for clarity during update attempt
    log("Update Image Path: ${productImage?.path}");
    log("Update Name: $name");
    // ... log other fields if needed for debugging

    try {
      final bool success = await _productService.updateProduct(
        productId,
        productImage: productImage,
        name: name,
        description: description,
        price: price,
        quantity: quantity,
        category: category,
        estimatedTime: estimatedTime,
        unitType: unitType,
        deliveryOption: deliveryOption,
      );

      if (success) {
        log("Product $productId updated successfully.");
        // Refresh the single product details after successful update
        await fetchProduct(productId);
        // Consider notifying listeners of FetchProductProvider if it's responsible
        // for displaying lists that need refreshing.
        // This part would depend on how your `FetchProductProvider` is set up
        // and if it listens for changes to individual products.
        // If it manages a list of all products for the user, then calling its
        // refresh method is appropriate.
        // Example: If `FetchProductProvider` is accessible here, you might do:
        // Provider.of<FetchProductProvider>(context, listen: false).loadProductsForUser();
        // However, passing `context` directly into a provider method is generally discouraged
        // as it breaks testability and can lead to issues if the context is no longer valid.
        // A better approach is often to have `FetchProductProvider` listen to changes
        // in `ProductProvider` or to trigger a refresh from the UI layer.
        return true;
      } else {
        _setErrorMessage(
          "Failed to update product $productId. Please check details.",
        );
        log("Product update failed for ID: $productId.");
        return false;
      }
    } catch (e, stackTrace) {
      _setErrorMessage(
        "An error occurred during product update: ${e.toString()}",
      );
      log(
        "Error updating product $productId: $e",
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Deletes a product by its ID.
  ///
  /// Updates the [_product] state to null if the deletion is successful.
  Future<bool> deleteProduct(String productId) async {
    _setLoading(true);
    _setErrorMessage(null);

    log("Attempting to delete product with ID: $productId");

    try {
      final bool success = await _productService.deleteProduct(productId);
      if (success) {
        _product = null; // Clear the current product if it was the one deleted
        log("Product $productId deleted successfully.");
        // You might want to also trigger a refresh in your list provider here
        // if it's actively displaying products (e.g., for a user's shop).
        // For example:
        // Provider.of<FetchProductProvider>(context, listen: false).loadProductsForUser();
        // (Again, be mindful of passing `context` directly into provider methods)
        return true;
      } else {
        _setErrorMessage(
          "Failed to delete product $productId. It might not exist.",
        );
        log("Product deletion failed for ID: $productId.");
        return false;
      }
    } catch (e, stackTrace) {
      _setErrorMessage(
        "An error occurred during product deletion: ${e.toString()}",
      );
      log(
        "Error deleting product $productId: $e",
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    } finally {
      _setLoading(false);
    }
  }
}
