
class RegistrationModel {
  final String id;
  final String name;
  final String mobileNumber;
  final String state;
  final String district; // Added district field
  final String token;
  final String email;
  final String? fcmToken;
  final String? referredCode;

  RegistrationModel({
    required this.id,
    required this.name,
    required this.mobileNumber,
    required this.state,
    required this.district, // Added district field
    required this.token,
    required this.email,
    this.fcmToken,
    this.referredCode,
  });

  factory RegistrationModel.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] as Map<String, dynamic>?;

    return RegistrationModel(
      id: userJson?['id'] ?? '',
      name: userJson?['name'] ?? '',
      mobileNumber: userJson?['mobileNumber']?.toString() ?? '',
      state: userJson?['state'] ?? '',
      district: userJson?['district'] ?? '', // Parse district from response
      token: json['token'] ?? '',
      email: userJson?['email'] ?? '',
      fcmToken: userJson?['fcmToken'],
      referredCode: userJson?['referredCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mobileNumber': mobileNumber,
      'state': state,
      'district': district, // Include district in JSON
      'token': token,
      'email': email,
      'fcmToken': fcmToken,
      'referredCode': referredCode,
    };
  }
}