import 'dart:convert';

StartSubscriptionResponse startSubscriptionResponseFromJson(String str) =>
    StartSubscriptionResponse.fromJson(json.decode(str));

String startSubscriptionResponseToJson(StartSubscriptionResponse data) =>
    json.encode(data.toJson());

class StartSubscriptionResponse {
  bool? success;
  String? message;
  String? orderId;
  int? amount;
  String? currency;
  Plan? plan;
  Subscription? subscription;
  String? razorpayKey;

  StartSubscriptionResponse({
    this.success,
    this.message,
    this.orderId,
    this.amount,
    this.currency,
    this.plan,
    this.subscription,
    this.razorpayKey,
  });

  factory StartSubscriptionResponse.fromJson(Map<String, dynamic> json) =>
      StartSubscriptionResponse(
        success: json["success"],
        message: json["message"],
        orderId: json["orderId"],
        amount: json["amount"],
        currency: json["currency"],
        plan: json["plan"] == null ? null : Plan.fromJson(json["plan"]),
        subscription:
            json["subscription"] == null
                ? null
                : Subscription.fromJson(json["subscription"]),
        razorpayKey: json["razorpayKey"],
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "orderId": orderId,
    "amount": amount,
    "currency": currency,
    "plan": plan?.toJson(),
    "subscription": subscription?.toJson(),
    "razorpayKey": razorpayKey,
  };
}

class Plan {
  String? id;
  String? name;
  String? durationType;
  int? amount;
  String? description;
  DateTime? createdAt;
  int? v;

  Plan({
    this.id,
    this.name,
    this.durationType,
    this.amount,
    this.description,
    this.createdAt,
    this.v,
  });

  factory Plan.fromJson(Map<String, dynamic> json) => Plan(
    id: json["_id"],
    name: json["name"],
    durationType: json["durationType"],
    amount: json["amount"],
    description: json["description"],
    createdAt:
        json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "durationType": durationType,
    "amount": amount,
    "description": description,
    "createdAt": createdAt?.toIso8601String(),
    "__v": v,
  };
}

class Subscription {
  bool? isActive;

  Subscription({this.isActive});

  factory Subscription.fromJson(Map<String, dynamic> json) =>
      Subscription(isActive: json["isActive"]);

  Map<String, dynamic> toJson() => {"isActive": isActive};
}
