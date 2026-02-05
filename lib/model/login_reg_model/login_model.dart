class LoginModel {
  final String message;
  final String accessToken;
  final String refreshToken;
  final UserModel user;

  LoginModel({
    required this.message,
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      message: json['message'],
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      user: UserModel.fromJson(json['user']),
    );
  }
}

class UserModel {
  final String id;
  final String name;
  final String mobileNumber;
  final String role;

  UserModel({
    required this.id,
    required this.name,
    required this.mobileNumber,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      mobileNumber: json['mobileNumber'].toString(),
      role: json['role'],
    );
  }
}
