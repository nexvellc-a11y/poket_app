class ShopeDetailsModel {
  final String? id;
  final String? shopName;
  final List<String>? category;
  final String? sellerType;
  final String? state;
  final String? place;
  final String? pinCode;
  final String? locality;
  final String? headerImage;
  final String? email;
  final String? mobileNumber;
  final String? landlineNumber;
  Subscription? subscription;
  final String? agentCode;
  final bool isGstRegistered;
  final String? gstNumber;
  final String? district;

  Rewards? rewards; // ✅ NEW

  ShopeDetailsModel({
    this.id,
    this.shopName,
    this.category,
    this.sellerType,
    this.state,
    this.place,
    this.pinCode,
    this.locality,
    this.headerImage,
    this.email,
    this.subscription,
    this.mobileNumber,
    this.landlineNumber,
    this.agentCode,
    this.isGstRegistered = false,
    this.gstNumber,
    this.district,
    this.rewards, // ✅ NEW
  });

  factory ShopeDetailsModel.fromJson(Map<String, dynamic> json) {
    return ShopeDetailsModel(
      id: json['_id'] as String?,
      shopName: json['shopName'] as String?,
      category: (json['category'] as List?)?.map((e) => e.toString()).toList(),
      sellerType: json['sellerType'] as String?,
      state: json['state'] as String?,
      place: json['place'] as String?,
      pinCode: json['pinCode'] as String?,
      locality: json['locality'] as String?,
      headerImage: json['headerImage'] as String?,
      email: json['email'] as String?,
      mobileNumber: json['mobileNumber'] as String?,
      landlineNumber: json['landlineNumber'] as String?,
      agentCode: json['agentCode'] as String?,
      district: json['district'] as String?,

      // ✅ GST parsing FIX (important)
      isGstRegistered: json['gst']?['isRegistered'] ?? false,
      gstNumber: json['gst']?['gstNumber'],

      // ✅ Subscription
      subscription:
          json["subscription"] == null
              ? null
              : Subscription.fromJson(json["subscription"]),

      // ✅ Rewards parsing
      rewards:
          json["rewards"] == null ? null : Rewards.fromJson(json["rewards"]),
    );
  }
}

class Subscription {
  final bool isActive;
  final bool isExpired;
  final int remainingDays;
  final String? plan;
  final DateTime? startDate;
  final DateTime? endDate;

  Subscription({
    this.isActive = false,
    this.isExpired = false,
    this.remainingDays = 0,
    this.plan,
    this.startDate,
    this.endDate,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      isActive: json['isActive'] ?? false,
      isExpired: json['isExpired'] ?? false,
      remainingDays: json['remainingDays'] ?? 0,
      plan: json['plan'],
      startDate:
          json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
    );
  }
}

class Rewards {
  final double points;
  final double totalEarned;

  Rewards({this.points = 0, this.totalEarned = 0});

  factory Rewards.fromJson(Map<String, dynamic> json) {
    return Rewards(
      points: (json['points'] ?? 0).toDouble(),
      totalEarned: (json['totalEarned'] ?? 0).toDouble(),
    );
  }
}
