class GroceriesListModel {
  final Map<String, List<String>> keyWithCategory;

  GroceriesListModel({required this.keyWithCategory});

  factory GroceriesListModel.fromJson(Map<String, dynamic> json) {
    final Map<String, List<String>> mapped = {};
    if (json['KeyWithCategory'] != null) {
      json['KeyWithCategory'].forEach((key, value) {
        mapped[key] = List<String>.from(value);
      });
    }
    return GroceriesListModel(keyWithCategory: mapped);
  }
}
