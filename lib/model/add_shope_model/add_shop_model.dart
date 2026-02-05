// class ShopModel {
//   final String? id;
//   final String? owner; // renamed from userId
//   final String? shopName;
//   final List<String>? category;
//   final String? sellerType;
//   final String? state;
//   final String? place;
//   final String? pinCode;
//   final String? locality;
//   final String? headerImage;
//   final String? email;
//   final String? mobileNumber;
//   final String? landlineNumber;
//   final bool? isBanned;
//   final String? agentCode;
//   final String? registeredBySalesman;
//   final Subscription? subscription;
//   final DateTime? createdAt;
//   final DateTime? updatedAt;

//   ShopModel({
//     this.id,
//     this.owner,
//     this.shopName,
//     this.category,
//     this.sellerType,
//     this.state,
//     this.place,
//     this.pinCode,
//     this.locality,
//     this.headerImage,
//     this.email,
//     this.mobileNumber,
//     this.landlineNumber,
//     this.isBanned,
//     this.agentCode,
//     this.registeredBySalesman,
//     this.subscription,
//     this.createdAt,
//     this.updatedAt,
//   });

//   factory ShopModel.fromJson(Map<String, dynamic> json) {
//     return ShopModel(
//       id: json["_id"],
//       owner: json["owner"],
//       shopName: json["shopName"],
//       category:
//           (json["category"] as List<dynamic>?)
//               ?.map((e) => e.toString())
//               .toList() ??
//           [],
//       sellerType: json["sellerType"],
//       state: json["state"],
//       place: json["place"],
//       pinCode: json["pinCode"],
//       locality: json["locality"],
//       headerImage: json["headerImage"],
//       email: json["email"],
//       mobileNumber: json["mobileNumber"],
//       landlineNumber: json["landlineNumber"],
//       isBanned: json["isBanned"],
//       agentCode: json["agentCode"],
//       registeredBySalesman: json["registeredBySalesman"],
//       subscription:
//           json["subscription"] != null
//               ? Subscription.fromJson(json["subscription"])
//               : null,
//       createdAt:
//           json["createdAt"] != null ? DateTime.parse(json["createdAt"]) : null,
//       updatedAt:
//           json["updatedAt"] != null ? DateTime.parse(json["updatedAt"]) : null,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       "_id": id,
//       "owner": owner,
//       "shopName": shopName,
//       "category": category,
//       "sellerType": sellerType,
//       "state": state,
//       "place": place,
//       "pinCode": pinCode,
//       "locality": locality,
//       "headerImage": headerImage,
//       "email": email,
//       "mobileNumber": mobileNumber,
//       "landlineNumber": landlineNumber,
//       "isBanned": isBanned,
//       "agentCode": agentCode,
//       "registeredBySalesman": registeredBySalesman,
//       "subscription": subscription?.toJson(),
//       "createdAt": createdAt?.toIso8601String(),
//       "updatedAt": updatedAt?.toIso8601String(),
//     };
//   }
// }

// class Subscription {
//   final bool? isActive;

//   Subscription({this.isActive});

//   factory Subscription.fromJson(Map<String, dynamic> json) {
//     return Subscription(isActive: json["isActive"]);
//   }

//   Map<String, dynamic> toJson() {
//     return {"isActive": isActive};
//   }
// }
class ShopResponse {
  final bool success;
  final String message;
  final ShopModel? shop;
  final Fcm? fcm;

  ShopResponse({
    required this.success,
    required this.message,
    this.shop,
    this.fcm,
  });

  factory ShopResponse.fromJson(Map<String, dynamic> json) {
    return ShopResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      shop: json['shop'] != null ? ShopModel.fromJson(json['shop']) : null,
      fcm: json['fcm'] != null ? Fcm.fromJson(json['fcm']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "success": success,
      "message": message,
      "shop": shop?.toJson(),
      "fcm": fcm?.toJson(),
    };
  }
}

class ShopModel {
  final String? id;
  final String? owner;
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
  final String? agentCode;
  final bool? isBanned;
  final String? registeredBySalesman;
  final Subscription? subscription;
  final bool? isVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isGstRegistered; // Add this
  final String? gstNumber;
  final String? district;

  ShopModel({
    this.id,
    this.owner,
    this.shopName,
    this.category,
    this.sellerType,
    this.state,
    this.agentCode,
    this.landlineNumber,
    this.place,
    this.pinCode,
    this.locality,
    this.headerImage,
    this.email,
    this.mobileNumber,
    this.isBanned,
    this.registeredBySalesman,
    this.subscription,
    this.isVerified,
    this.createdAt,
    this.updatedAt,
    this.isGstRegistered = false, // Default to false
    this.gstNumber,
    this.district,
  });

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    return ShopModel(
      id: json["_id"],
      owner: json["owner"],
      shopName: json["shopName"],
      agentCode: json["agentCode"],
      landlineNumber: json["landlineNumber"],
      category:
          (json["category"] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      sellerType: json["sellerType"],
      state: json["state"],
      place: json["place"],
      pinCode: json["pinCode"],
      locality: json["locality"],
      headerImage: json["headerImage"],
      email: json["email"],
      mobileNumber: json["mobileNumber"],
      isBanned: json["isBanned"],
      district: json['district'],
      registeredBySalesman: json["registeredBySalesman"],
      subscription:
          json["subscription"] != null
              ? Subscription.fromJson(json["subscription"])
              : null,
      isVerified: json["isVerified"],
      createdAt:
          json["createdAt"] != null ? DateTime.parse(json["createdAt"]) : null,
      updatedAt:
          json["updatedAt"] != null ? DateTime.parse(json["updatedAt"]) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "owner": owner,
      "shopName": shopName,
      "category": category,
      "sellerType": sellerType,
      "state": state,
      "place": place,
      "pinCode": pinCode,
      "locality": locality,
      "landlineNumber": landlineNumber,
      "agentCode": agentCode,
      "headerImage": headerImage,
      "email": email,
      "mobileNumber": mobileNumber,
      "isBanned": isBanned,
      "registeredBySalesman": registeredBySalesman,
      "subscription": subscription?.toJson(),
      "isVerified": isVerified,
      'district': district,
      "createdAt": createdAt?.toIso8601String(),
      "updatedAt": updatedAt?.toIso8601String(),
      'isGstRegistered': isGstRegistered, // Add this
      'gstNumber': isGstRegistered ? gstNumber : null,
    };
  }
}

class Subscription {
  final bool? isActive;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? plan;

  Subscription({this.isActive, this.startDate, this.endDate, this.plan});

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      isActive: json["isActive"],
      startDate:
          json["startDate"] != null ? DateTime.parse(json["startDate"]) : null,
      endDate: json["endDate"] != null ? DateTime.parse(json["endDate"]) : null,
      plan: json["plan"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "isActive": isActive,
      "startDate": startDate?.toIso8601String(),
      "endDate": endDate?.toIso8601String(),
      "plan": plan,
    };
  }
}

class Fcm {
  final int? successCount;
  final int? failureCount;

  Fcm({this.successCount, this.failureCount});

  factory Fcm.fromJson(Map<String, dynamic> json) {
    return Fcm(
      successCount: json["successCount"],
      failureCount: json["failureCount"],
    );
  }

  Map<String, dynamic> toJson() {
    return {"successCount": successCount, "failureCount": failureCount};
  }
}
