class VerifyOtpResponse {
  final bool success;
  final String message;
  final UserData? data;
  final ProviderResponse? providerResponse;

  VerifyOtpResponse({
    required this.success,
    required this.message,
    this.data,
    this.providerResponse,
  });

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? UserData.fromJson(json['data']) : null,
      providerResponse:
          json['providerResponse'] != null
              ? ProviderResponse.fromJson(json['providerResponse'])
              : null,
    );
  }
}

class UserData {
  final String id;
  final String mobileNumber;
  final String verificationId;
  final bool isVerified;
  final String expiresAt;
  final String createdAt;
  final String updatedAt;
  final int v;

  UserData({
    required this.id,
    required this.mobileNumber,
    required this.verificationId,
    required this.isVerified,
    required this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['_id'] ?? '',
      mobileNumber: json['mobileNumber'] ?? '',
      verificationId: json['verificationId'] ?? '',
      isVerified: json['isVerified'] ?? false,
      expiresAt: json['expiresAt'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      v: json['__v'] ?? 0,
    );
  }
}

class ProviderResponse {
  final int responseCode;
  final String message;
  final ProviderData? data;

  ProviderResponse({
    required this.responseCode,
    required this.message,
    this.data,
  });

  factory ProviderResponse.fromJson(Map<String, dynamic> json) {
    return ProviderResponse(
      responseCode: json['responseCode'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null ? ProviderData.fromJson(json['data']) : null,
    );
  }
}

class ProviderData {
  final int verificationId;
  final String mobileNumber;
  final String verificationStatus;
  final String responseCode;
  final String? errorMessage;
  final String transactionId;
  final String? authToken;

  ProviderData({
    required this.verificationId,
    required this.mobileNumber,
    required this.verificationStatus,
    required this.responseCode,
    this.errorMessage,
    required this.transactionId,
    this.authToken,
  });

  factory ProviderData.fromJson(Map<String, dynamic> json) {
    return ProviderData(
      verificationId: json['verificationId'] ?? 0,
      mobileNumber: json['mobileNumber'] ?? '',
      verificationStatus: json['verificationStatus'] ?? '',
      responseCode: json['responseCode'] ?? '',
      errorMessage: json['errorMessage'],
      transactionId: json['transactionId'] ?? '',
      authToken: json['authToken'],
    );
  }
}
