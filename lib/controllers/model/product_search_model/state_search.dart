class StateModel {
  final bool success;
  final int count;
  final List<String> states;

  StateModel({
    required this.success,
    required this.count,
    required this.states,
  });

  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(
      success: json['success'] ?? false,
      count: json['count'] ?? 0,
      states: List<String>.from(json['states'] ?? []),
    );
  }
}
