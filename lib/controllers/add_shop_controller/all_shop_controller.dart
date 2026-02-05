import 'package:flutter/material.dart';
import 'package:poketstore/model/add_shope_model/all_shop_model.dart';
import 'package:poketstore/service/add_shop_service/all_shop_service.dart';

class AllShopController extends ChangeNotifier {
  final AllShopService _shopService = AllShopService();

  List<AllShop> _shops = [];
  bool _isLoading = false;
  String? _error;

  List<AllShop> get shops => _shops;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadShops() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _shops = await _shopService.fetchShops();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool isMobileExists(String mobile) {
    return _shops.any((shop) => shop.mobileNumber == mobile);
  }
}
