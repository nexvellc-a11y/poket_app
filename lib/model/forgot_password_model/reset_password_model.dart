class ResetPasswordModel {
  final String message;

  ResetPasswordModel({required this.message});

  factory ResetPasswordModel.fromJson(Map<String, dynamic> json) {
    return ResetPasswordModel(message: json['message'] ?? '');
  }
}
