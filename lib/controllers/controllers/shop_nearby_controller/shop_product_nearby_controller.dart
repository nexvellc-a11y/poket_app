import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:poketstore/model/shop_nearby_model/shop_product_nearby_model.dart';
import 'package:poketstore/service/shop_nearby_service/shop_product_nearby_service.dart';

class ShopProductNearbyProductController extends ChangeNotifier {
  final ShopProductNearbyService _productService = ShopProductNearbyService();
  ProductByShopModel? productData;
  bool isLoading = false;
  ProductByShopModel? _productData; // Original fetched data
  List<Product> filteredProducts = [];

  Future<void> loadProducts(String shopId) async {
    isLoading = true;
    productData = await _productService.fetchProductsByShopId(shopId);
    log("Loaded Products: ${productData?.products?.length ?? 0}");
    isLoading = false;
    notifyListeners();
  }

  void filterProducts(String query) {
    log("Search query: '$query'");
    if (query.isEmpty) {
      filteredProducts = [];
      notifyListeners();
      return;
    }

    final lowerQuery = query.toLowerCase();

    filteredProducts =
        productData?.products
            ?.where(
              (product) =>
                  product.name?.toLowerCase().contains(lowerQuery) ?? false,
            )
            .toList() ??
        [];
    log("Filtered Products Count: ${filteredProducts.length}");
    notifyListeners();
  }
}
