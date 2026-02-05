/// ----------------------------------------------------------
/// PRODUCT SEARCH RESPONSE
/// ----------------------------------------------------------
class ProductSearchResponse {
  final bool success;
  final List<ProductSearchModel> data;

  ProductSearchResponse({required this.success, required this.data});

  factory ProductSearchResponse.fromJson(Map<String, dynamic> json) {
    return ProductSearchResponse(
      success: json['success'] as bool? ?? false,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => ProductSearchModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

/// ----------------------------------------------------------
/// PRODUCT MODEL
/// ----------------------------------------------------------
class ProductSearchModel {
  final String id;
  final ShopModel shop;
  final String name;
  final double price;
  final double quantity;
  final String productImage;
  final double sold;
  final String estimatedTime;
  final String unitType;
  final String deliveryOption;
  final String userId;
  final bool favorite;
  final String category;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int v;

  ProductSearchModel({
    required this.id,
    required this.shop,
    required this.name,
    required this.price,
    required this.quantity,
    required this.productImage,
    required this.sold,
    required this.estimatedTime,
    required this.unitType,
    required this.deliveryOption,
    required this.userId,
    required this.favorite,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory ProductSearchModel.fromJson(Map<String, dynamic> json) {
    return ProductSearchModel(
      id: json['_id']?.toString() ?? '',
      shop: ShopModel.fromJson(json['shop'] ?? {}),

      name: json['name']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,

      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      productImage: json['productImage']?.toString() ?? '',

      sold: (json['sold'] as num?)?.toDouble() ?? 0.0,

      estimatedTime: json['estimatedTime']?.toString() ?? '',
      unitType: json['unitType']?.toString() ?? '',
      deliveryOption: json['deliveryOption']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      favorite: json['favorite'] as bool? ?? false,
      category: json['category']?.toString() ?? '',

      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'])
              : null,
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.tryParse(json['updatedAt'])
              : null,

      v: json['__v'] as int? ?? 0,
    );
  }
}

/// ----------------------------------------------------------
/// SHOP MODEL
/// ----------------------------------------------------------
class ShopModel {
  final String id;
  final SubscriptionModel? subscription;
  final String owner;
  final String shopName;
  final List<String> category;
  final String sellerType;
  final String state;
  final String place;
  final String locality;
  final String pinCode;
  final String email;
  final String landlineNumber;
  final String mobileNumber;
  final bool isBanned;
  final String headerImage;
  final String agentCode;
  final bool isVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ShopModel({
    required this.id,
    required this.subscription,
    required this.owner,
    required this.shopName,
    required this.category,
    required this.sellerType,
    required this.state,
    required this.place,
    required this.locality,
    required this.pinCode,
    required this.email,
    required this.landlineNumber,
    required this.mobileNumber,
    required this.isBanned,
    required this.headerImage,
    required this.agentCode,
    required this.isVerified,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    return ShopModel(
      id: json['_id']?.toString() ?? '',
      subscription:
          json['subscription'] != null
              ? SubscriptionModel.fromJson(json['subscription'])
              : null,
      owner: json['owner']?.toString() ?? '',
      shopName: json['shopName']?.toString() ?? '',
      category:
          (json['category'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      sellerType: json['sellerType']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      place: json['place']?.toString() ?? '',
      locality: json['locality']?.toString() ?? '',
      pinCode: json['pinCode']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      landlineNumber: json['landlineNumber']?.toString() ?? '',
      mobileNumber: json['mobileNumber']?.toString() ?? '',
      isBanned: json['isBanned'] as bool? ?? false,
      headerImage: json['headerImage']?.toString() ?? '',
      agentCode: json['agentCode']?.toString() ?? '',
      isVerified: json['isVerified'] as bool? ?? false,

      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'])
              : null,
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.tryParse(json['updatedAt'])
              : null,
    );
  }
}

/// ----------------------------------------------------------
/// SUBSCRIPTION MODEL
/// ----------------------------------------------------------
class SubscriptionModel {
  final bool isActive;
  final DateTime? endDate;
  final String plan;
  final DateTime? startDate;

  SubscriptionModel({
    required this.isActive,
    required this.endDate,
    required this.plan,
    required this.startDate,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      isActive: json['isActive'] as bool? ?? false,
      endDate:
          json['endDate'] != null ? DateTime.tryParse(json['endDate']) : null,
      plan: json['plan']?.toString() ?? '',
      startDate:
          json['startDate'] != null
              ? DateTime.tryParse(json['startDate'])
              : null,
    );
  }
}
