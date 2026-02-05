// To parse this JSON data, do
//
//     final subscriptionModel = subscriptionModelFromJson(jsonString);

import 'dart:convert';

SubscriptionModel subscriptionModelFromJson(String str) =>
    SubscriptionModel.fromJson(json.decode(str));

String subscriptionModelToJson(SubscriptionModel data) =>
    json.encode(data.toJson());

class SubscriptionModel {
  final bool? success;
  final List<Plan>? plans;

  SubscriptionModel({this.success, this.plans});

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) =>
      SubscriptionModel(
        success: json["success"],
        plans:
            json["plans"] == null
                ? []
                : List<Plan>.from(json["plans"].map((x) => Plan.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "plans":
        plans == null ? [] : List<dynamic>.from(plans!.map((x) => x.toJson())),
  };
}

class Plan {
  final String? id;
  final String? name;
  final String? durationType;
  final int? baseAmount;
  final int? gstAmount;
  final int? totalAmount;
  final String? description;
  final DateTime? createdAt;
  final int? v;

  Plan({
    this.id,
    this.name,
    this.durationType,
    this.baseAmount,
    this.gstAmount,
    this.totalAmount,
    this.description,
    this.createdAt,
    this.v,
  });

  factory Plan.fromJson(Map<String, dynamic> json) => Plan(
    id: json["_id"],
    name: json["name"],
    durationType: json["durationType"],
    baseAmount: json["baseAmount"],
    gstAmount: json["gstAmount"],
    totalAmount: json["totalAmount"],
    description: json["description"],
    createdAt:
        json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "durationType": durationType,
    "baseAmount": baseAmount,
    "gstAmount": gstAmount,
    "totalAmount": totalAmount,
    "description": description,
    "createdAt": createdAt?.toIso8601String(),
    "__v": v,
  };
}
