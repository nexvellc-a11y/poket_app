class RewardModel {
  final bool success;
  final String message;
  final double rewardPoints;

  RewardModel({
    required this.success,
    required this.message,
    required this.rewardPoints,
  });

  factory RewardModel.fromJson(Map<String, dynamic> json) {
    return RewardModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      rewardPoints: (json['rewardPoints'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
