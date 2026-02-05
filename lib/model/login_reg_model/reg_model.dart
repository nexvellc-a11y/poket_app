class RegistrationModel {
  final String id;
  final String name;
  final String mobileNumber;
  final String state;
  final String place;
  final String locality;
  final String pincode;
  final String token;
  final String email;
  final String? fcmToken; // New: FCM token field

  RegistrationModel({
    required this.id,
    required this.locality,
    required this.name,
    required this.mobileNumber,
    required this.state,
    required this.place,
    required this.pincode,
    required this.token,
    required this.email,
    this.fcmToken, // Make it optional
  });

  factory RegistrationModel.fromJson(Map<String, dynamic> json) {
    final userJson =
        json['user'] as Map<String, dynamic>?; // Safely cast to Map

    // Add null checks for userJson and convert int to String where necessary
    return RegistrationModel(
      id: userJson?['id'] ?? '',
      name: userJson?['name'] ?? '',
      locality: userJson?['locality'] ?? '',
      // Convert mobileNumber from int to String
      mobileNumber: userJson?['mobileNumber']?.toString() ?? '',
      state: userJson?['state'] ?? '',
      place: userJson?['place'] ?? '',
      // Convert pincode from int to String
      pincode: userJson?['pincode']?.toString() ?? '',
      token: json['token'] ?? '', // token is directly under the top-level json
      email: userJson?['email'] ?? '',
      fcmToken: userJson?['fcmToken'], // FCM token is under 'user' and nullable
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mobileNumber': mobileNumber,
      'state': state,
      'place': place,
      'pincode': pincode,
      'token': token,
      'locality': locality,
      'email': email,
      'fcmToken': fcmToken,
    };
  }
}
