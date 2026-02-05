class ShopNearbyResponse {
  final List<ShopNearbyModel>? shops;

  ShopNearbyResponse({this.shops});

  factory ShopNearbyResponse.fromJson(Map<String, dynamic> json) {
    return ShopNearbyResponse(
      shops:
          (json['shops'] as List<dynamic>?)
              ?.map((e) => ShopNearbyModel.fromJson(e))
              .toList(),
    );
  }
}

class ShopNearbyModel {
  final SubscriptionModel? subscription;
  final String? id;
  final String? owner;
  final String? shopName;
  final List<String>? category;
  final String? sellerType;
  final String? state;
  final String? place;
  final String? locality;
  final String? pinCode;
  final String? email;
  final String? landlineNumber;
  final String? mobileNumber;
  final bool? isBanned;
  final String? headerImage;
  final String? agentCode;
  final double? distance;
  final String? registeredBySalesman;
  final bool? isVerified;
  final String? createdAt;
  final String? updatedAt;

  ShopNearbyModel({
    this.subscription,
    this.id,
    this.owner,
    this.shopName,
    this.category,
    this.sellerType,
    this.state,
    this.place,
    this.locality,
    this.pinCode,
    this.email,
    this.landlineNumber,
    this.mobileNumber,
    this.isBanned,
    this.headerImage,
    this.agentCode,
    this.registeredBySalesman,
    this.isVerified,
    this.createdAt,
    this.distance,
    this.updatedAt,
  });

  factory ShopNearbyModel.fromJson(Map<String, dynamic> json) {
    return ShopNearbyModel(
      subscription:
          json['subscription'] != null
              ? SubscriptionModel.fromJson(json['subscription'])
              : null,
      id: json['_id'] as String?,
      distance: json['distance'],
      owner: json['owner'] as String?,
      shopName: json['shopName'] as String?,
      category:
          (json['category'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList(),
      sellerType: json['sellerType'] as String?,
      state: json['state'] as String?,
      place: json['place'] as String?,
      locality: json['locality'] as String?,
      pinCode: json['pinCode'] as String?,
      email: json['email'] as String?,
      landlineNumber: json['landlineNumber'] as String?,
      mobileNumber: json['mobileNumber'] as String?,
      isBanned: json['isBanned'] as bool?,
      headerImage: json['headerImage'] as String?,
      agentCode: json['agentCode'] as String?,
      registeredBySalesman: json['registeredBySalesman']?.toString(),
      isVerified: json['isVerified'] as bool?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }
}

class SubscriptionModel {
  final bool? isActive;
  final String? startDate;
  final String? endDate;
  final String? plan;

  SubscriptionModel({this.isActive, this.startDate, this.endDate, this.plan});

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      isActive: json['isActive'] as bool?,
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
      plan: json['plan'] as String?,
    );
  }
}
