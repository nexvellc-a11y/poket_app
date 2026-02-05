import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poketstore/model/notification_model/notification_model.dart';
import 'package:poketstore/service/notification_service/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _service = NotificationService();

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;
  String? _userId;

  // Getters
  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _error;

  int get unreadCount =>
      _notifications.where((n) => !n.recipient.isRead).length;

  /// Load userId once and cache it
  Future<String?> _getUserId() async {
    if (_userId != null) return _userId;

    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('userId');
    return _userId;
  }

  /// Load notifications for logged-in user
  Future<void> loadNotificationsForCurrentUser() async {
    if (_isLoading) return;

    _setLoading(true);
    _setError(null);

    try {
      final userId = await _getUserId();
      if (userId == null) {
        _setError('User not logged in');
        return;
      }

      _notifications = await _service.fetchNotifications(userId);
      log("Notifications loaded: ${_notifications.length}");
    } catch (e, stackTrace) {
      _setError("Failed to load notifications");
      log("Notification load error", error: e, stackTrace: stackTrace);
    } finally {
      _setLoading(false);
    }
  }

  /// Mark notification as read (optimistic update)
  Future<void> markAsRead(String notificationId) async {
    final userId = await _getUserId();
    if (userId == null) {
      _setError('User not logged in');
      return;
    }

    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index == -1 || _notifications[index].recipient.isRead) return;

    // 🔥 Optimistic UI update
    _notifications[index] = _notifications[index].copyWith(
      recipient: _notifications[index].recipient.copyWith(isRead: true),
    );
    notifyListeners();

    try {
      await _service.markAsRead(notificationId, userId);
      log("Notification marked as read: $notificationId");
    } catch (e, stackTrace) {
      log(
        "Failed to mark notification as read",
        error: e,
        stackTrace: stackTrace,
      );
      _setError("Failed to update notification status");
    }
  }

  // ---------- Helpers ----------

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _error = message;
    notifyListeners();
  }

  /// Optional: clear on logout
  void clear() {
    _notifications.clear();
    _userId = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
