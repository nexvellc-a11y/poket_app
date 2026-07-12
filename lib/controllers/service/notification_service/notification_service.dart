import 'package:dio/dio.dart';
import 'package:poketstore/model/notification_model/notification_model.dart';

class NotificationService {
  final Dio _dio = Dio();
  final String baseUrl = 'https://api.poketstor.com/api/notification';

  Future<List<NotificationModel>> fetchNotifications(String userId) async {
    final response = await _dio.get(
      '$baseUrl/get-specific-recipient-whole-notification/$userId',
    );
    List data = response.data;
    return data.map((e) => NotificationModel.fromJson(e)).toList();
  }

  Future<void> markAsRead(String notificationId, String userId) async {
    await _dio.put(
      '$baseUrl/$notificationId/read',
      data: {'userId': userId, 'isRead': true},
    );
  }
}
