class PayoutRequestModel {
  final bool success;
  final String message;

  PayoutRequestModel({
    required this.success,
    required this.message,
  });

  factory PayoutRequestModel.fromJson(Map<String, dynamic> json) {
    return PayoutRequestModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }
}