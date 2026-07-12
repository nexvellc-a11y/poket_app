class DistrictModel {
  final bool success;
  final String state;
  final int count;
  final List<String> districts;

  DistrictModel({
    required this.success,
    required this.state,
    required this.count,
    required this.districts,
  });

  factory DistrictModel.fromJson(Map<String, dynamic> json) {
    return DistrictModel(
      success: json['success'] ?? false,
      state: json['state'] ?? "",
      count: json['count'] ?? 0,
      districts: List<String>.from(json['districts'] ?? []),
    );
  }
}
