import 'dart:convert';

ProductByShopModel productByShopModelFromJson(String str) =>
    ProductByShopModel.fromJson(json.decode(str));

String productByShopModelToJson(ProductByShopModel data) =>
    json.encode(data.toJson());

class ProductByShopModel {
  final String? message;
  final List<Product>? products;

  ProductByShopModel({this.message, this.products});

  factory ProductByShopModel.fromJson(Map<String, dynamic> json) =>
      ProductByShopModel(
        message: json["message"],
        products:
            json["products"] == null
                ? []
                : List<Product>.from(
                  json["products"].map((x) => Product.fromJson(x)),
                ),
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "products":
        products == null
            ? []
            : List<dynamic>.from(products!.map((x) => x.toJson())),
  };
}

class Product {
  final String? id;
  final String? shop;
  final String? name;
  final double? price;
  final double? quantity;
  final String? productImage;
  final double? sold;
  final String? estimatedTime;
  final String? unitType;
  final String? deliveryOption;
  final String? userId;
  final bool? favorite;
  final String? category;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  Product({
    this.id,
    this.shop,
    this.name,
    this.price,
    this.quantity,
    this.productImage,
    this.sold,
    this.estimatedTime,
    this.unitType,
    this.deliveryOption,
    this.userId,
    this.favorite,
    this.category,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json["_id"],
    shop: json["shop"],
    name: json["name"],
    price: (json["price"] as num?)?.toDouble(),
    quantity: (json["quantity"] as num?)?.toDouble(),
    productImage: json["productImage"],
    sold: (json["sold"] as num?)?.toDouble(),
    estimatedTime: json["estimatedTime"],
    unitType: json["unitType"],
    deliveryOption: json["deliveryOption"],
    userId: json["userId"],
    favorite: json["favorite"],
    category: json["category"],
    createdAt:
        json["createdAt"] != null ? DateTime.parse(json["createdAt"]) : null,
    updatedAt:
        json["updatedAt"] != null ? DateTime.parse(json["updatedAt"]) : null,
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "shop": shop,
    "name": name,
    "price": price,
    "quantity": quantity,
    "productImage": productImage,
    "sold": sold,
    "estimatedTime": estimatedTime,
    "unitType": unitType,
    "deliveryOption": deliveryOption,
    "userId": userId,
    "favorite": favorite,
    "category": category,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
  };
}
