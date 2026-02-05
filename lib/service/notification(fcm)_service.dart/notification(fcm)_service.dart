// ignore_for_file: file_names, use_build_context_synchronously

import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class FirebasePushService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterTts _flutterTts = FlutterTts();

  Future<void> init(BuildContext context) async {
    // Request permissions
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    log('Notification permission: ${settings.authorizationStatus}');

    // Get FCM token
    String? token = await _messaging.getToken();
    log("FCM Token: $token");

    // Initialize TTS
    await _initTts();

    // Foreground notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log("🔔 Foreground Notification Received!");
      final title = message.notification?.title ?? '';
      final body = message.notification?.body ?? '';
      log("Title: $title | Body: $body");

      // Speak only for New Order
      if (title.contains("New Order Alert!")) {
        _speak("$title. $body");
      }

      // Show snackbar for all notifications
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("$title\n$body"),
          backgroundColor: Colors.black87,
          behavior: SnackBarBehavior.floating,
        ),
      );
    });

    // Background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("en-IN");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.awaitSpeakCompletion(
      true,
    ); // wait until speaking finishes
  }

  Future<void> _speak(String text) async {
    try {
      log("🔊 TTS speaking: $text");
      await _flutterTts.stop(); // stop any ongoing speech
      await _flutterTts.speak(text);
    } catch (e) {
      log("TTS Error: $e");
    }
  }

  Future<String?> getToken() async => await _messaging.getToken();
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  log("🔙 Handling background message: ${message.messageId}");
  if (message.notification != null) {
    log("Background notification title: ${message.notification?.title}");
    log("Background notification body: ${message.notification?.body}");
  }
}
