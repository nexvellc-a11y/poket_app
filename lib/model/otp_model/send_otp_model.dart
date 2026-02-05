class SendOtpResponse {
  final bool success;
  final String message;
  final String verificationId;

  SendOtpResponse({
    required this.success,
    required this.message,
    required this.verificationId,
  });

  factory SendOtpResponse.fromJson(Map<String, dynamic> json) {
    return SendOtpResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      verificationId: json['verificationId'] ?? '',
    );
  }
}
