class LocationProduct {
  final String id;
  final Shop shop;
  final String name;
  final String description;
  final int price;
  final String productImage;
  final String productType;
  final String deliveryOption;
  final bool favorite;
  final String category;
  final String createdAt;
  final String updatedAt;

  LocationProduct({
    required this.id,
    required this.shop,
    required this.name,
    required this.description,
    required this.price,
    required this.productImage,
    required this.productType,
    required this.deliveryOption,
    required this.favorite,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LocationProduct.fromJson(Map<String, dynamic> json) {
    return LocationProduct(
      id: json['_id'] ?? "",
      shop: Shop.fromJson(json['shop'] ?? {}),
      name: json['name'] ?? "",
      description: json['description'] ?? "",
      price: json['price'] ?? 0,
      productImage: json['productImage'] ?? "",
      productType: json['productType'] ?? "",
      deliveryOption: json['deliveryOption'] ?? "",
      favorite: json['favorite'] ?? false,
      category: json['category'] ?? "",
      createdAt: json['createdAt'] ?? "",
      updatedAt: json['updatedAt'] ?? "",
    );
  }
}

// 2. Shop Model Class
class Shop {
  final String id;
  final String shopName;
  final String state;
  final String place;
  final String pinCode;
  final String locality;

  Shop({
    required this.id,
    required this.shopName,
    required this.state,
    required this.place,
    required this.pinCode,
    required this.locality,
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: json['_id'] ?? "",
      shopName: json['shopName'] ?? "",
      state: json['state'] ?? "",
      place: json['place'] ?? "",
      pinCode: json['pinCode'] ?? "",
      locality: json['locality'] ?? "",
    );
  }
}
