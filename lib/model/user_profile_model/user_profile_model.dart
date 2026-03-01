class UserProfile {
  final String id;
  final String name;
  final String email;
  final String mobileNumber;
  final String role;
  final String? subscriptionId;
  final List<dynamic> favorites;
  final bool isVerified;
  final Rewards rewards;
  final List<String> fcmTokens;
  final int v;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.mobileNumber,
    required this.role,
    required this.subscriptionId,
    required this.favorites,
    required this.isVerified,
    required this.rewards,
    required this.fcmTokens,
    required this.v,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['_id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      mobileNumber: json['mobileNumber']?.toString() ?? '',
      role: json['role'] ?? '',
      subscriptionId: json['subscriptionId']?.toString(),
      favorites: List<dynamic>.from(json['favorites'] ?? []),
      isVerified: json['isVerified'] ?? false,
      rewards: Rewards.fromJson(json['rewards'] ?? {}),
      fcmTokens: List<String>.from(json['fcmTokens'] ?? []),
      v: (json['__v'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'mobileNumber': mobileNumber,
      'role': role,
      'subscriptionId': subscriptionId,
      'favorites': favorites,
      'isVerified': isVerified,
      'rewards': rewards.toJson(),
      'fcmTokens': fcmTokens,
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
