import 'package:flutter/material.dart';
import 'package:poketstore/model/subscription_model/user_shop_list_model.dart';
import 'package:poketstore/service/subscription_service/user_shop_list_service.dart';

class UserShopListController extends ChangeNotifier {
  final UserShopListService _shopService = UserShopListService();

  List<UserShopListModel> shops = [];
  bool isLoading = false;

  Future<void> fetchUserShops() async {
    isLoading = true;
    notifyListeners();

    shops = await _shopService.getShopsByUser();

    isLoading = false;
    notifyListeners();
  }
}
