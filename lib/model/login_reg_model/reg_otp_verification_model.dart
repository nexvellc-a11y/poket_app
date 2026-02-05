// lib/model/login_reg_model/otp_verification_model.dart
class OtpVerificationModel {
  final String message;
  final String token;
  final String userId;

  OtpVerificationModel({
    required this.message,
    required this.token,
    required this.userId,
  });

  factory OtpVerificationModel.fromJson(Map<String, dynamic> json) {
    return OtpVerificationModel(
      message: json['message'],
      token: json['token'],
      userId: json['userId'],
    );
  }
}
