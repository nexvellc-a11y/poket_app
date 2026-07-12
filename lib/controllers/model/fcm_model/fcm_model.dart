class FCMModel {
  final String userId;
  final String fcmToken;

  FCMModel({required this.userId, required this.fcmToken});

  Map<String, dynamic> toJson() {
    return {'userId': userId, 'fcmToken': fcmToken};
  }
}
