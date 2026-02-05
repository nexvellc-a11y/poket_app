class ProductsByShop {
  final String id;
  final String name;
  final String description;
  final int price;
  final int quantity;
  final List<String> category;
  final String productImage;
  final String estimatedTime;
  final String productType;
  final String deliveryOption;

  ProductsByShop({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.category,
    required this.productImage,
    required this.estimatedTime,
    required this.productType,
    required this.deliveryOption,
  });

  factory ProductsByShop.fromJson(Map<String, dynamic> json) {
    return ProductsByShop(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: json['price'] ?? 0,
      quantity: json['quantity'] ?? 0,
      category: List<String>.from(json['category'] ?? []),
      productImage: json['productImage'] ?? '',
      estimatedTime: json['estimatedTime'] ?? '',
      productType: json['productType'] ?? '',
      deliveryOption: json['deliveryOption'] ?? '',
    );
  }
}
