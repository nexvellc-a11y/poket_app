class CartResponse {
  final Cart? cart;
  final String? message;

  CartResponse({this.cart, this.message});

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    return CartResponse(
      cart: json['cart'] != null ? Cart.fromJson(json['cart']) : null,
      message: json['message'],
    );
  }
}

class Cart {
  final String? id;
  final String? userId;
  final List<CartItem>? items;
  final double? totalCartPrice;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  Cart({
    this.id,
    this.userId,
    this.items,
    this.totalCartPrice,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['_id'],
      userId: json['userId'],
      items:
          json['items'] != null
              ? List<CartItem>.from(
                json['items']!.map((x) => CartItem.fromJson(x)),
              )
              : null,
      totalCartPrice:
          json['totalCartPrice'] != null
              ? (json['totalCartPrice'] as num).toDouble()
              : null,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      v: json['__v'],
    );
  }
}

class CartItem {
  final String? id;
  final CartProduct? product;
  final double? quantity;
  final double? productPrice;
  final double? totalProductPrice;
  final bool? isInCart;

  CartItem({
    this.id,
    this.product,
    this.quantity,
    this.productPrice,
    this.totalProductPrice,
    this.isInCart,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['_id'],
      product:
          json['productId'] != null
              ? (json['productId'] is String
                  ? CartProduct.fromJson({'_id': json['productId']})
                  : CartProduct.fromJson(json['productId']))
              : null,
      quantity:
          json['quantity'] != null
              ? (json['quantity'] as num).toDouble()
              : null,
      productPrice:
          json['productPrice'] != null
              ? (json['productPrice'] as num).toDouble()
              : null,
      totalProductPrice:
          json['totalProductPrice'] != null
              ? (json['totalProductPrice'] as num).toDouble()
              : null,
      isInCart: json['isInCart'],
    );
  }
}

class CartProduct {
  final String? id;
  final String? shop;
  final String? name;
  final String? description;
  final double? price;
  final double? quantity;
  final String? productImage;
  final int? sold;
  final String? estimatedTime;
  final String? productType;
  final String? deliveryOption;
  final String? userId;
  final bool? favorite;
  final String? category;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  CartProduct({
    this.id,
    this.shop,
    this.name,
    this.description,
    this.price,
    this.quantity,
    this.productImage,
    this.sold,
    this.estimatedTime,
    this.productType,
    this.deliveryOption,
    this.userId,
    this.favorite,
    this.category,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory CartProduct.fromJson(Map<String, dynamic> json) {
    return CartProduct(
      id: json['_id'],
      shop: json['shop'],
      name: json['name'],
      description: json['description'],
      price:
          json['price'] != null
              ? double.tryParse(json['price'].toString())
              : null,
      quantity:
          json['quantity'] != null
              ? (json['quantity'] as num).toDouble()
              : null,
      productImage: json['productImage'],
      sold:
          json['sold'] != null
              ? (json['sold'] is int
                  ? json['sold']
                  : (json['sold'] is double
                      ? (json['sold'] as double).toInt()
                      : int.tryParse(json['sold'].toString())))
              : null,

      estimatedTime: json['estimatedTime'],
      productType: json['unitType'],
      deliveryOption: json['deliveryOption'],
      userId: json['userId'],
      favorite: json['favorite'],
      category: json['category'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      v: json['__v'],
    );
  }
}

class CartRequest {
  final String? productId;
  final double? quantity;

  CartRequest({this.productId, this.quantity});

  Map<String, dynamic> toJson() => {
    if (productId != null) 'productId': productId,
    if (quantity != null) 'quantity': quantity,
  };
}
