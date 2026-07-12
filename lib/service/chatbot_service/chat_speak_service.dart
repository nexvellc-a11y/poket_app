// tts_service.dart
import 'dart:developer';

import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final FlutterTts _flutterTts = FlutterTts();
  static bool _isSpeaking = false;

  static Future<void> speak(String text, {String language = 'en-US'}) async {
    try {
      await _flutterTts.setLanguage(language);
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setPitch(1.0);
      await _flutterTts.setVolume(1.0);
      
      // Set up listeners for speech events
      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
        log('Speech completed');
      });
      
      _flutterTts.setErrorHandler((msg) {
        _isSpeaking = false;
        log('Speech error: $msg');
      });
      
      _isSpeaking = true;
      await _flutterTts.speak(text);
    } catch (e) {
      _isSpeaking = false;
      log('TTS Error: $e');
    }
  }

  static Future<void> stop() async {
    try {
      await _flutterTts.stop();
      _isSpeaking = false;
    } catch (e) {
      log('TTS Stop Error: $e');
    }
  }

  static bool get isSpeaking => _isSpeaking;

  static Future<void> setLanguage(String languageCode) async {
    try {
      await _flutterTts.setLanguage(languageCode);
    } catch (e) {
      log('TTS Language Error: $e');
    }
  }

  static Future<void> dispose() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      log('TTS Dispose Error: $e');
    }
  }
}