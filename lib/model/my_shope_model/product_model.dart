class Product {
  final String id;
  final String? shop;
  final String name;
  final double price;
  final String? description;
  final double quantity;
  final String productImage;
  final double sold;
  final String? estimatedTime;
  final String unitType;
  final String deliveryOption;
  final String userId;
  final bool favorite;
  final String category;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    this.shop,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.productImage,
    required this.sold,
    this.estimatedTime,
    required this.unitType,
    required this.deliveryOption,
    required this.userId,
    required this.favorite,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? "",
      shop: json['shop'],
      name: json['name'] ?? "",
      description: json['description'],
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      productImage:
          json['productImage'] ??
          "https://via.placeholder.com/150", // Fallback image
      sold: (json['sold'] as num?)?.toDouble() ?? 0.0,
      estimatedTime: json['estimatedTime'],
      unitType: json['unitType'] ?? "",
      deliveryOption: json['deliveryOption'] ?? "",
      userId: json['userId'] ?? "",
      favorite: json['favorite'] ?? false,
      category: json['category'] ?? "",
      createdAt: DateTime.tryParse(json['createdAt'] ?? "") ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? "") ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'shop': shop,
      'name': name,
      'price': price,
      'quantity': quantity,
      'productImage': productImage,
      'sold': sold,
      'estimatedTime': estimatedTime,
      'unitType': unitType,
      'deliveryOption': deliveryOption,
      'userId': userId,
      'description': description,
      'favorite': favorite,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
