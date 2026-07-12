import 'dart:convert';

List<NotificationModel> notificationListFromJson(String str) =>
    List<NotificationModel>.from(
      json.decode(str).map((x) => NotificationModel.fromJson(x)),
    );

// 🔹 Convert List<NotificationModel> back to JSON string
String notificationListToJson(List<NotificationModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

// =============================================================
// Notification Model
// =============================================================
class NotificationModel {
  final String id;
  final String titleUser;
  final String bodyUser;
  final String title;
  final String body;
  final String type;
  final NotificationData data;
  final DateTime createdAt;
  final Recipient recipient;

  NotificationModel({
    required this.id,
    required this.titleUser,
    required this.bodyUser,
    required this.title,
    required this.body,
    required this.type,
    required this.data,
    required this.createdAt,
    required this.recipient,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id: json["_id"] ?? "",
        titleUser: json["titleUser"] ?? "",
        bodyUser: json["bodyUser"] ?? "",
        title: json["title"] ?? "",
        body: json["body"] ?? "",
        type: json["type"] ?? "",
        data: NotificationData.fromJson(json["data"] ?? {}),
        createdAt: DateTime.parse(
          json["createdAt"] ?? DateTime.now().toIso8601String(),
        ),
        recipient: Recipient.fromJson(json["recipient"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "titleUser": titleUser,
    "bodyUser": bodyUser,
    "title": title,
    "body": body,
    "type": type,
    "data": data.toJson(),
    "createdAt": createdAt.toIso8601String(),
    "recipient": recipient.toJson(),
  };

  NotificationModel copyWith({
    String? id,
    String? titleUser,
    String? bodyUser,
    String? title,
    String? body,
    String? type,
    NotificationData? data,
    DateTime? createdAt,
    Recipient? recipient,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      titleUser: titleUser ?? this.titleUser,
      bodyUser: bodyUser ?? this.bodyUser,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      recipient: recipient ?? this.recipient,
    );
  }
}

// =============================================================
// Notification Data
// =============================================================
class NotificationData {
  final String shopId;
  final String shopName;
  final String productId;
  final String productName;
  final String orderId;
  final String userName;
  final DateTime? orderTime;
  final String planId;
  final String planName;
  final double? amount;
  final String subscriptionId;
  final int? durationDays;
  final DateTime? startDate;
  final DateTime? endDate;
  final FullDetails? fullDetails;

  NotificationData({
    this.shopId = "",
    this.shopName = "",
    this.productId = "",
    this.productName = "",
    this.orderId = "",
    this.userName = "",
    this.orderTime,
    this.planId = "",
    this.planName = "",
    this.amount,
    this.subscriptionId = "",
    this.durationDays,
    this.startDate,
    this.endDate,
    this.fullDetails,
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    // Handle different notification types with different data structures
    return NotificationData(
      shopId: json["shopId"]?.toString() ?? "",
      shopName: json["shopName"]?.toString() ?? "",
      productId: json["productId"]?.toString() ?? "",
      productName: json["productName"]?.toString() ?? "",
      orderId: json["orderId"]?.toString() ?? "",
      userName: json["userName"]?.toString() ?? "",
      orderTime:
          json["orderTime"] != null ? DateTime.parse(json["orderTime"]) : null,
      planId: json["planId"]?.toString() ?? "",
      planName: json["planName"]?.toString() ?? "",
      amount:
          json["amount"] != null
              ? (json["amount"] is int
                  ? json["amount"].toDouble()
                  : json["amount"])
              : null,
      subscriptionId: json["subscriptionId"]?.toString() ?? "",
      durationDays:
          json["durationDays"] != null
              ? int.tryParse(json["durationDays"].toString())
              : null,
      startDate:
          json["startDate"] != null ? DateTime.parse(json["startDate"]) : null,
      endDate: json["endDate"] != null ? DateTime.parse(json["endDate"]) : null,
      fullDetails:
          json["fullDetails"] != null
              ? FullDetails.fromJson(json["fullDetails"])
              : null,
    );
  }

  Map<String, dynamic> toJson() => {
    "shopId": shopId,
    "shopName": shopName,
    "productId": productId,
    "productName": productName,
    "orderId": orderId,
    "userName": userName,
    "orderTime": orderTime?.toIso8601String(),
    "planId": planId,
    "planName": planName,
    "amount": amount,
    "subscriptionId": subscriptionId,
    "durationDays": durationDays,
    "startDate": startDate?.toIso8601String(),
    "endDate": endDate?.toIso8601String(),
    "fullDetails": fullDetails?.toJson(),
  };

  NotificationData copyWith({
    String? shopId,
    String? shopName,
    String? productId,
    String? productName,
    String? orderId,
    String? userName,
    DateTime? orderTime,
    String? planId,
    String? planName,
    double? amount,
    String? subscriptionId,
    int? durationDays,
    DateTime? startDate,
    DateTime? endDate,
    FullDetails? fullDetails,
  }) {
    return NotificationData(
      shopId: shopId ?? this.shopId,
      shopName: shopName ?? this.shopName,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      orderId: orderId ?? this.orderId,
      userName: userName ?? this.userName,
      orderTime: orderTime ?? this.orderTime,
      planId: planId ?? this.planId,
      planName: planName ?? this.planName,
      amount: amount ?? this.amount,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      durationDays: durationDays ?? this.durationDays,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      fullDetails: fullDetails ?? this.fullDetails,
    );
  }
}

// =============================================================
// Full Details
// =============================================================
class FullDetails {
  final Customer? customer;
  final Address? address;
  final List<OrderItem> items;
  final double? totalAmount;
  final DateTime? orderTime;

  FullDetails({
    this.customer,
    this.address,
    this.items = const [],
    this.totalAmount,
    this.orderTime,
  });

  factory FullDetails.fromJson(Map<String, dynamic> json) => FullDetails(
    customer:
        json["customer"] != null ? Customer.fromJson(json["customer"]) : null,
    address: json["address"] != null ? Address.fromJson(json["address"]) : null,
    items:
        json["items"] != null
            ? List<OrderItem>.from(
              (json["items"] as List).map((x) => OrderItem.fromJson(x)),
            )
            : [],
    totalAmount:
        json["totalAmount"] != null
            ? (json["totalAmount"] is int
                ? json["totalAmount"].toDouble()
                : json["totalAmount"])
            : null,
    orderTime:
        json["orderTime"] != null ? DateTime.parse(json["orderTime"]) : null,
  );

  Map<String, dynamic> toJson() => {
    "customer": customer?.toJson(),
    "address": address?.toJson(),
    "items": List<dynamic>.from(items.map((x) => x.toJson())),
    "totalAmount": totalAmount,
    "orderTime": orderTime?.toIso8601String(),
  };

  FullDetails copyWith({
    Customer? customer,
    Address? address,
    List<OrderItem>? items,
    double? totalAmount,
    DateTime? orderTime,
  }) {
    return FullDetails(
      customer: customer ?? this.customer,
      address: address ?? this.address,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      orderTime: orderTime ?? this.orderTime,
    );
  }
}

// =============================================================
// Customer
// =============================================================
class Customer {
  final String name;
  final String email;
  final String phone;

  Customer({required this.name, required this.email, required this.phone});

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
    name: json["name"] ?? "",
    email: json["email"] ?? "",
    phone: json["phone"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "email": email,
    "phone": phone,
  };

  Customer copyWith({String? name, String? email, String? phone}) {
    return Customer(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }
}

// =============================================================
// Address
// =============================================================
class Address {
  final String country;
  final String state;
  final String town;
  final String area;
  final String landmark;
  final String pincode;
  final String houseNo;

  Address({
    required this.country,
    required this.state,
    required this.town,
    required this.area,
    required this.landmark,
    required this.pincode,
    required this.houseNo,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    country: json["country"] ?? "",
    state: json["state"] ?? "",
    town: json["town"] ?? "",
    area: json["area"] ?? "",
    landmark: json["landmark"] ?? "",
    pincode: json["pincode"] ?? "",
    houseNo: json["houseNo"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "country": country,
    "state": state,
    "town": town,
    "area": area,
    "landmark": landmark,
    "pincode": pincode,
    "houseNo": houseNo,
  };

  Address copyWith({
    String? country,
    String? state,
    String? town,
    String? area,
    String? landmark,
    String? pincode,
    String? houseNo,
  }) {
    return Address(
      country: country ?? this.country,
      state: state ?? this.state,
      town: town ?? this.town,
      area: area ?? this.area,
      landmark: landmark ?? this.landmark,
      pincode: pincode ?? this.pincode,
      houseNo: houseNo ?? this.houseNo,
    );
  }
}

// =============================================================
// Order Item
// =============================================================
class OrderItem {
  final String name;
  final int price;
  final double quantity;
  final dynamic weightInGrams;
  final double priceWithQuantity;

  OrderItem({
    required this.name,
    required this.price,
    required this.quantity,
    required this.weightInGrams,
    required this.priceWithQuantity,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    name: json["name"] ?? "",
    price: json["price"] ?? 0,
    quantity: (json["quantity"] ?? 0.0).toDouble(),
    weightInGrams: json["weightInGrams"],
    priceWithQuantity: (json["priceWithQuantity"] ?? 0.0).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "price": price,
    "quantity": quantity,
    "weightInGrams": weightInGrams,
    "priceWithQuantity": priceWithQuantity,
  };

  OrderItem copyWith({
    String? name,
    int? price,
    double? quantity,
    dynamic weightInGrams,
    double? priceWithQuantity,
  }) {
    return OrderItem(
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      weightInGrams: weightInGrams ?? this.weightInGrams,
      priceWithQuantity: priceWithQuantity ?? this.priceWithQuantity,
    );
  }
}

// =============================================================
// Recipient
// =============================================================
class Recipient {
  final String userId;
  final bool isRead;

  Recipient({required this.userId, required this.isRead});

  factory Recipient.fromJson(Map<String, dynamic> json) =>
      Recipient(userId: json["userId"] ?? "", isRead: json["isRead"] ?? false);

  Map<String, dynamic> toJson() => {"userId": userId, "isRead": isRead};

  Recipient copyWith({String? userId, bool? isRead}) {
    return Recipient(
      userId: userId ?? this.userId,
      isRead: isRead ?? this.isRead,
    );
  }
}
