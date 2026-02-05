import 'package:flutter/material.dart';
import 'package:poketstore/model/product_by_shop/product_by_shop_model.dart';
import 'package:poketstore/service/product_by_shop_service/product_by_shop_service.dart';

class ProductsByShopProvider extends ChangeNotifier {
  List<ProductsByShop> productList = [];
  bool isLoading = false;

  Future<void> getProductsByShopId(String shopId) async {
    isLoading = true;
    notifyListeners();

    productList = await ProductsByShopService().fetchProductsByShopId(shopId);

    isLoading = false;
    notifyListeners();
  }
}
