// import 'package:flutter/material.dart';

// class NotificationProvider extends ChangeNotifier {
//   bool isNotificationEnabled = true;

//   final List<Map<String, String>> _fcmMessages = [];

//   List<Map<String, String>> get fcmMessages => _fcmMessages.reversed.toList();

//   void toggleNotification() {
//     isNotificationEnabled = !isNotificationEnabled;
//     notifyListeners();
//   }

//   void addFcmMessage(String title, String body) {
//     _fcmMessages.add({'title': title, 'body': body});
//     notifyListeners();
//   }
// }
