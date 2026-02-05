class UserProfile {
  final String id;
  final String name;
  final String email;
  final String mobileNumber;
  final String state;
  final String place;
  final String locality;
  final String pincode;
  final String role;
  final String subscriptionId;
  final List<dynamic> favorites;
  final bool isVerified;
  final Rewards rewards;
  final List<String> fcmTokens;
  final int v; // Corresponds to __v in the JSON

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.mobileNumber,
    required this.state,
    required this.place,
    required this.locality,
    required this.pincode,
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
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      mobileNumber: json['mobileNumber']?.toString() ?? '',
      state: json['state'] ?? '',
      place: json['place'] ?? '',
      locality: json['locality'] ?? '',
      pincode: json['pincode'] ?? '',
      role: json['role'] ?? '',
      subscriptionId: json['subscriptionId'] ?? '',
      favorites: List<dynamic>.from(json['favorites'] ?? []),
      isVerified: json['isVerified'] ?? false,
      rewards: Rewards.fromJson(json['rewards'] ?? {}),
      fcmTokens: List<String>.from(json['fcmTokens'] ?? []),
      v: json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'mobileNumber': mobileNumber,
      'state': state,
      'place': place,
      'locality': locality,
      'pincode': pincode,
      'role': role,
      'subscriptionId': subscriptionId,
      'favorites': favorites,
      'isVerified': isVerified,
      'fcmTokens': fcmTokens,
      'rewards': rewards.toJson(),
      '__v': v,
    };
  }
}

class Rewards {
  final int points;
  final int totalEarned;

  Rewards({required this.points, required this.totalEarned});

  factory Rewards.fromJson(Map<String, dynamic> json) {
    return Rewards(
      points: json['points'] ?? 0,
      totalEarned: json['totalEarned'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'points': points, 'totalEarned': totalEarned};
  }
}
