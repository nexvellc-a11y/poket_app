class MyShopListUserResponse {
  final String message;
  final List<ShopData> data;

  MyShopListUserResponse({required this.message, required this.data});

  factory MyShopListUserResponse.fromJson(Map<String, dynamic> json) {
    return MyShopListUserResponse(
      message: json['message'] ?? '',
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => ShopData.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class ShopData {
  final String shopName;
  final List<Product> products;

  ShopData({required this.shopName, required this.products});

  factory ShopData.fromJson(Map<String, dynamic> json) {
    return ShopData(
      shopName: json['shopName'] ?? '',
      products:
          (json['products'] as List<dynamic>?)
              ?.map((e) => Product.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class Product {
  final String id;
  final String shop;
  final String name;
  final String? description;
  final double? price;
  final double? quantity;
  final String? productImage;
  final double? sold;
  final String? estimatedTime;
  final String? productType;
  final String? deliveryOption;
  final String? userId;
  final String? adminId;
  final bool favorite;
  final String?
  category; // Changed from List<String>? to String? as per the JSON
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  Product({
    required this.id,
    required this.shop,
    required this.name,
    this.description,
    this.price,
    this.quantity,
    this.productImage,
    this.sold,
    this.estimatedTime,
    this.productType,
    this.deliveryOption,
    this.userId,
    this.adminId,
    required this.favorite,
    this.category,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? '',
      shop: json['shop'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      price: (json['price'] as num?)?.toDouble(),
      quantity: (json['quantity'] as num?)?.toDouble(),
      productImage: json['productImage'],
      sold: (json['sold'] as num?)?.toDouble(),
      estimatedTime: json['estimatedTime'],
      productType: json['productType'],
      deliveryOption: json['deliveryOption'],
      userId: json['userId'],
      adminId: json['adminId'],
      favorite: json['favorite'] ?? false,
      category: json['category']?.toString(),
      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'])
              : null,
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.tryParse(json['updatedAt'])
              : null,
      v: json['__v'],
    );
  }
}
