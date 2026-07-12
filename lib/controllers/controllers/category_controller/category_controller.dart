import 'package:flutter/material.dart';
import 'package:poketstore/service/category_service/category_service.dart';

class CategoryController extends ChangeNotifier {
  final CategoryService _service = CategoryService();

  bool isLoading = false;
  List<String> categoryList = [];

  Future<void> loadCategories() async {
    isLoading = true;
    notifyListeners();

    try {
      final model = await _service.fetchCategories();
      categoryList = model.categories;
    } catch (e) {
      // handle error or log
      categoryList = [];
    }

    isLoading = false;
    notifyListeners();
  }
}
