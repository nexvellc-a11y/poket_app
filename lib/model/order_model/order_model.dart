// To parse this JSON data, do
//
//     final orderItemModel = orderItemModelFromJson(jsonString);

import 'dart:convert';

OrderItemModel orderItemModelFromJson(String str) =>
    OrderItemModel.fromJson(json.decode(str));

String orderItemModelToJson(OrderItemModel data) => json.encode(data.toJson());

class OrderItemModel {
  List<Item>? items;
  String? addressId;
  int? totalCartAmount;

  OrderItemModel({this.items, this.addressId, this.totalCartAmount});

  factory OrderItemModel.fromJson(Map<String, dynamic> json) => OrderItemModel(
    items:
        json["items"] == null
            ? []
            : List<Item>.from(json["items"]!.map((x) => Item.fromJson(x))),
    addressId: json["addressId"],
    totalCartAmount: json["totalCartAmount"],
  );

  Map<String, dynamic> toJson() => {
    "items":
        items == null ? [] : List<dynamic>.from(items!.map((x) => x.toJson())),
    "addressId": addressId,
    "totalCartAmount": totalCartAmount,
  };
}

class Item {
  String? productId;
  String? name;
  double? price;
  double? quantity;
  double? priceWithQuantity;
  double? weightInGrams;

  Item({
    this.productId,
    this.name,
    this.price,
    this.quantity,
    this.priceWithQuantity,
    this.weightInGrams,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    productId: json["productId"],
    name: json["name"],
    price: json["price"],
    quantity: json["quantity"],
    priceWithQuantity: json["priceWithQuantity"],
    weightInGrams: json["weightInGrams"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "productId": productId,
    "name": name,
    "price": price,
    "quantity": quantity,
    "priceWithQuantity": priceWithQuantity,
    "weightInGrams": weightInGrams,
  };
}
