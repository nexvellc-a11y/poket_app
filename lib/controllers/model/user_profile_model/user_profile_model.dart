class UserProfile {
  final String id;
  final String name;
  final String email;
  final String mobileNumber;
  final String password;
  final String role;
  final String? subscriptionId;
  final List<dynamic> favorites;
  final String? otp;
  final String? otpExpiry;
  final String? resetPasswordToken;
  final String? resetPasswordExpiry;
  final bool isVerified;
  final Rewards rewards;
  final String? referredBy;
  final List<String> fcmTokens;
  final int referralCount;
  final double referralEarnings;
  final String referralCode;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.mobileNumber,
    required this.password,
    required this.role,
    this.subscriptionId,
    required this.favorites,
    this.otp,
    this.otpExpiry,
    this.resetPasswordToken,
    this.resetPasswordExpiry,
    required this.isVerified,
    required this.rewards,
    this.referredBy,
    required this.fcmTokens,
    required this.referralCount,
    required this.referralEarnings,
    required this.referralCode,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['_id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      mobileNumber: json['mobileNumber']?.toString() ?? '',
      password: json['password'] ?? '',
      role: json['role'] ?? '',
      subscriptionId: json['subscriptionId']?.toString(),
      favorites: List<dynamic>.from(json['favorites'] ?? []),
      otp: json['otp']?.toString(),
      otpExpiry: json['otpExpiry']?.toString(),
      resetPasswordToken: json['resetPasswordToken']?.toString(),
      resetPasswordExpiry: json['resetPasswordExpiry']?.toString(),
      isVerified: json['isVerified'] ?? false,
      rewards: Rewards.fromJson(json['rewards'] ?? {}),
      referredBy: json['referredBy']?.toString(),
      fcmTokens: List<String>.from(json['fcmTokens'] ?? []),
      referralCount: (json['referralCount'] as num?)?.toInt() ?? 0,
      referralEarnings: (json['referralEarnings'] as num?)?.toDouble() ?? 0.0,
      referralCode: json['referralCode'] ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now(),
      v: (json['__v'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'mobileNumber': mobileNumber,
      'password': password,
      'role': role,
      'subscriptionId': subscriptionId,
      'favorites': favorites,
      'otp': otp,
      'otpExpiry': otpExpiry,
      'resetPasswordToken': resetPasswordToken,
      'resetPasswordExpiry': resetPasswordExpiry,
      'isVerified': isVerified,
      'rewards': rewards.toJson(),
      'referredBy': referredBy,
      'fcmTokens': fcmTokens,
      'referralCount': referralCount,
      'referralEarnings': referralEarnings,
      'referralCode': referralCode,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': v,
    };
  }
}

class Rewards {
  final double points;
  final double totalEarned;

  Rewards({required this.points, required this.totalEarned});

  factory Rewards.fromJson(Map<String, dynamic> json) {
    return Rewards(
      points: (json['points'] as num?)?.toDouble() ?? 0.0,
      totalEarned: (json['totalEarned'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'points': points, 'totalEarned': totalEarned};
  }
}