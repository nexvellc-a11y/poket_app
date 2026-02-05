import 'package:flutter/material.dart';

class FCMNotificationController extends ChangeNotifier {
  final List<Map<String, String>> _notifications = [];

  List<Map<String, String>> get notifications =>
      List.unmodifiable(_notifications);

  void addNotification(String title, String body) {
    _notifications.add({'title': title, 'body': body});
    notifyListeners();
  }

  void clearNotifications() {
    _notifications.clear();
    notifyListeners();
  }
}
