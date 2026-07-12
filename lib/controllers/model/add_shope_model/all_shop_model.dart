class AllShop {
  final String id;
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
  final String? headerImage;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Subscription subscription;

  AllShop({
    required this.id,
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
    this.headerImage,
    required this.isVerified,
    required this.createdAt,
    required this.updatedAt,
    required this.subscription,
  });

  factory AllShop.fromJson(Map<String, dynamic> json) {
    return AllShop(
      id: json["_id"],
      shopName: json["shopName"],
      category: List<String>.from(json["category"]),
      sellerType: json["sellerType"],
      state: json["state"],
      place: json["place"],
      locality: json["locality"],
      pinCode: json["pinCode"],
      email: json["email"] ?? "",
      landlineNumber: json["landlineNumber"] ?? "",
      mobileNumber: json["mobileNumber"],
      isBanned: json["isBanned"] ?? false,
      headerImage: json["headerImage"],
      isVerified: json["isVerified"] ?? false,
      createdAt: DateTime.parse(json["createdAt"]),
      updatedAt: DateTime.parse(json["updatedAt"]),
      subscription: Subscription.fromJson(json["subscription"]),
    );
  }
}

class Subscription {
  final bool isActive;
  final String? plan;
  final DateTime? startDate;
  final DateTime? endDate;

  Subscription({
    required this.isActive,
    this.plan,
    this.startDate,
    this.endDate,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      isActive: json["isActive"] ?? false,
      plan: json["plan"],
      startDate:
          json["startDate"] != null ? DateTime.parse(json["startDate"]) : null,
      endDate: json["endDate"] != null ? DateTime.parse(json["endDate"]) : null,
    );
  }
}
