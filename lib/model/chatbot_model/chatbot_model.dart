class ChatRequest {
  final String message;

  ChatRequest({required this.message});

  Map<String, dynamic> toJson() {
    return {
      'message': message,
    };
  }
}

class ChatResponse {
  final String reply;
  final String appLink;
  final bool showAppButton;
  final String buttonText;

  ChatResponse({
    required this.reply,
    required this.appLink,
    required this.showAppButton,
    required this.buttonText,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      reply: json['reply'] ?? '',
      appLink: json['appLink'] ?? '',
      showAppButton: json['showAppButton'] ?? false,
      buttonText: json['buttonText'] ?? '',
    );
  }
}