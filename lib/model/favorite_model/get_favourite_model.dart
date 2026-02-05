class GetFavoriteModel {
  final String id;
  final String shop;
  final String name;
  final String description;
  final int price;
  final int quantity;
  final String productImage;
  final String estimatedTime;
  final String productType;
  final String deliveryOption;
  final String category;

  GetFavoriteModel({
    required this.id,
    required this.shop,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.productImage,
    required this.estimatedTime,
    required this.productType,
    required this.deliveryOption,
    required this.category,
  });

  factory GetFavoriteModel.fromJson(Map<String, dynamic> json) {
    return GetFavoriteModel(
      id: json['_id'],
      shop: json['shop'],
      name: json['name'],
      description: json['description'],
      price: json['price'],
      quantity: json['quantity'],
      productImage: json['productImage'],
      estimatedTime: json['estimatedTime'],
      productType: json['productType'],
      deliveryOption: json['deliveryOption'],
      category: json['category'],
    );
  }
}
