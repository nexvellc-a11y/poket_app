import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:poketstore/model/fcm_model/fcm_model.dart';
import 'package:poketstore/service/fcm_service/fcm_service.dart';
import 'package:poketstore/service/notification(fcm)_service.dart/notification(fcm)_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FCMProvider extends ChangeNotifier {
  final FCMService _service = FCMService();
  final FirebasePushService _firebasePushService = FirebasePushService();

  bool isLoading = false;
  String? message;
  String? error;

  String? _userId; // 🔹 cache userId

  // ───── Helpers ─────

  void _setLoading(bool value) {
    if (isLoading == value) return;
    isLoading = value;
    notifyListeners();
  }

  Future<String?> _getUserId() async {
    if (_userId != null) return _userId;

    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('userId');
    return _userId;
  }

  void _setError(String? value) {
    error = value;
    if (value != null) message = null;
    notifyListeners();
  }

  void _setMessage(String? value) {
    message = value;
    if (value != null) error = null;
    notifyListeners();
  }

  // ───── Main Action ─────

  Future<void> registerFcmToken(BuildContext context) async {
    _setLoading(true);
    error = null;
    message = null;

    try {
      // 1️⃣ Init Firebase
      await _firebasePushService.init(context);

      // 2️⃣ Get FCM token
      final fcmToken = await _firebasePushService.getToken();
      if (fcmToken == null) {
        _setError("Failed to retrieve FCM token.");
        return;
      }

      log("✅ FCM Token: $fcmToken");

      // 3️⃣ Get userId (cached)
      final userId = await _getUserId();
      if (userId == null) {
        _setError("User not logged in.");
        return;
      }

      // 4️⃣ Send to backend
      final model = FCMModel(userId: userId, fcmToken: fcmToken);
      final result = await _service.saveFcmToken(model);

      if (result != null) {
        _setMessage(result);
      } else {
        _setError("Failed to save FCM token.");
      }
    } catch (e, st) {
      log("❌ registerFcmToken error", error: e, stackTrace: st);
      _setError("Something went wrong while registering notifications.");
    } finally {
      _setLoading(false);
    }
  }
}
