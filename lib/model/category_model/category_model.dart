class CategoryModel {
  final List<String> categories;

  CategoryModel({required this.categories});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      categories: List<String>.from(json['categories']),
    );
  }
}
