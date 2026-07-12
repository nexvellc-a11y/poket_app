class ForgotPasswordModel {
  final String message;

  ForgotPasswordModel({required this.message});

  factory ForgotPasswordModel.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordModel(message: json['message'] ?? '');
  }
}
