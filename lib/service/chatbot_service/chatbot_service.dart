import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:poketstore/model/chatbot_model/chatbot_model.dart';


class ChatService {
  static const String baseUrl = 'https://api.poketstor.com/api/chat';

  Future<ChatResponse> sendMessage(String message) async {
    try {
      final request = ChatRequest(message: message);
      
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return ChatResponse.fromJson(data);
      } else {
        throw Exception('Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }
}