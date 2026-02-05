// models/shop_search_model.dart
class ShopSearchModel {
  final String message;
  final List<ShopSearchDetailsModel> shops;

  ShopSearchModel({required this.message, required this.shops});

  factory ShopSearchModel.fromJson(Map<String, dynamic> json) {
    return ShopSearchModel(
      message: json['message'] ?? '',
      shops:
          (json['shops'] as List<dynamic>)
              .map((e) => ShopSearchDetailsModel.fromJson(e))
              .toList(),
    );
  }
}

class ShopSearchDetailsModel {
  final String? id;
  final String? owner;
  final String? shopName;
  final List<String>? category;
  final String? sellerType;
  final String? state;
  final String? place;
  final String? locality;
  final String? pinCode;
  final String? headerImage;
  final String? createdAt;
  final String? updatedAt;

  ShopSearchDetailsModel({
    this.id,
    this.owner,
    this.shopName,
    this.category,
    this.sellerType,
    this.state,
    this.place,
    this.locality,
    this.pinCode,
    this.headerImage,
    this.createdAt,
    this.updatedAt,
  });

  factory ShopSearchDetailsModel.fromJson(Map<String, dynamic> json) {
    return ShopSearchDetailsModel(
      id: json['_id'],
      owner: json['owner'],
      shopName: json['shopName'],
      category: (json['category'] as List?)?.map((e) => e.toString()).toList(),
      sellerType: json['sellerType'],
      state: json['state'],
      place: json['place'],
      locality: json['locality'],
      pinCode: json['pinCode'],
      headerImage: json['headerImage'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}
