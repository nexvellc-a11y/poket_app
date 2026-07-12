class SubscriptionModel {
  final bool? success;
  final List<Plan>? plans;

  SubscriptionModel({this.success, this.plans});

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      success: json["success"],
      plans:
          json["plans"] == null
              ? []
              : List<Plan>.from(json["plans"].map((x) => Plan.fromJson(x))),
    );
  }
}

class Plan {
  final String? id;
  final String? name;
  final String? durationType;
  final int? monthlyPrice;
  final int? durationInMonths;
  final int? billableMonths;
  final int? baseAmount;
  final int? gstAmount;
  final int? totalAmount;
  final int? productLimit;
  final String? description;

  Plan({
    this.id,
    this.name,
    this.durationType,
    this.monthlyPrice,
    this.durationInMonths,
    this.billableMonths,
    this.baseAmount,
    this.gstAmount,
    this.totalAmount,
    this.productLimit,
    this.description,
  });

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json["_id"],
      name: json["name"],
      durationType: json["durationType"],
      monthlyPrice: json["monthlyPrice"],
      durationInMonths: json["durationInMonths"],
      billableMonths: json["billableMonths"],
      baseAmount: json["baseAmount"],
      gstAmount: json["gstAmount"],
      totalAmount: json["totalAmount"],
      productLimit: json["productLimit"],
      description: json["description"],
    );
  }
}
