import 'package:flutter/material.dart';
import 'package:poketstore/service/chatbot_service/chat_speak_service.dart';
import 'package:poketstore/service/chatbot_service/chatbot_service.dart';
import 'package:poketstore/utilities/chat_language.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:developer' as developer;

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final AudioRecorder _audioRecorder = AudioRecorder();
  
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  bool _isListening = false;
  bool _isRecording = false;
  bool _isPlayingPreview = false;
  String _lastRecognizedWords = '';
  bool _isSpeechAvailable = false;
  bool _isSpeechInitialized = false;
  int _retryCount = 0;
  static const int maxRetries = 3;
  
  // Flag to prevent duplicate sends
  bool _isProcessingSpeech = false;
  String _lastProcessedText = ''; // Store last processed text to prevent duplicates
  
  // Voice recording
  String? _recordingPath;
  Duration _recordingDuration = Duration.zero;
  Duration _playbackPosition = Duration.zero;
  
  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  
  // App download info
  bool _showAppButton = false;
  String _appLink = '';
  String _buttonText = '';

//Text to speak

bool _isSpeaking = false;
String? _speakingMessageId;
bool get isSpeaking => _isSpeaking;
String? get speakingMessageId => _speakingMessageId;


  // Getters
  List<Map<String, dynamic>> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isListening => _isListening;
  bool get isRecording => _isRecording;
  bool get isPlayingPreview => _isPlayingPreview;
  String get lastRecognizedWords => _lastRecognizedWords;
  bool get showAppButton => _showAppButton;
  String get appLink => _appLink;
  String get buttonText => _buttonText;
  stt.SpeechToText get speech => _speech;
  String? get recordingPath => _recordingPath;
  Duration get recordingDuration => _recordingDuration;
  Duration get playbackPosition => _playbackPosition;
  bool get isSpeechAvailable => _isSpeechAvailable;
  
  AppLanguage _currentLanguage = AppLanguage.english;
  AppLanguage get currentLanguage => _currentLanguage;


Future<void> speakMessage(String text, String messageId) async {
  try {
    // If already speaking the same message, stop it
    if (_isSpeaking && _speakingMessageId == messageId) {
      await TtsService.stop();
      _isSpeaking = false;
      _speakingMessageId = null;
      notifyListeners();
      return;
    }

    // If speaking a different message, stop current and start new
    if (_isSpeaking) {
      await TtsService.stop();
      _isSpeaking = false;
      _speakingMessageId = null;
    }

    // Clean the text before speaking
    String cleanText = _cleanTextForSpeech(text);
    
    // If after cleaning the text is empty, don't speak
    if (cleanText.isEmpty) {
      print('No text to speak after cleaning');
      return;
    }

    // Set language based on current language
    String languageCode = _getLanguageCode(_currentLanguage);
    await TtsService.setLanguage(languageCode);
    
    _isSpeaking = true;
    _speakingMessageId = messageId;
    notifyListeners();

    // Speak the cleaned text
    await TtsService.speak(cleanText);
    
    // Reset when done
    _isSpeaking = false;
    _speakingMessageId = null;
    notifyListeners();
  } catch (e) {
    print('Error speaking message: $e');
    _isSpeaking = false;
    _speakingMessageId = null;
    notifyListeners();
  }
}

// Helper method to clean text for TTS
String _cleanTextForSpeech(String text) {
  if (text.isEmpty) return '';
  
  // Remove emojis (all Unicode emoji characters)
  // This regex matches most emojis
  final emojiRegex = RegExp(
    r'[\u{1F600}-\u{1F64F}]' // Emoticons
    r'|[\u{1F300}-\u{1F5FF}]' // Symbols & pictographs
    r'|[\u{1F680}-\u{1F6FF}]' // Transport & map symbols
    r'|[\u{1F700}-\u{1F77F}]' // Alchemical symbols
    r'|[\u{1F780}-\u{1F7FF}]' // Geometric shapes
    r'|[\u{1F800}-\u{1F8FF}]' // Supplemental arrows
    r'|[\u{1F900}-\u{1F9FF}]' // Supplemental symbols
    r'|[\u{1FA00}-\u{1FA6F}]' // Chess symbols
    r'|[\u{1FA70}-\u{1FAFF}]' // Extended symbols
    r'|[\u{2600}-\u{26FF}]'   // Miscellaneous symbols
    r'|[\u{2700}-\u{27BF}]'   // Dingbats
    r'|[\u{FE00}-\u{FEFF}]'   // Variation selectors
    r'|[\u{1F1E6}-\u{1F1FF}]' // Regional indicators
    r'|[\u{1F004}-\u{1F0CF}]' // Mahjong tiles
    r'|[\u{1F170}-\u{1F251}]' // Enclosed characters
    r'|[\u{1F000}-\u{1F02F}]' // Mahjong tiles
    r'|[\u{1F0A0}-\u{1F0FF}]' // Playing cards
    r'|[\u{1F100}-\u{1F1AD}]' // Enclosed alphanumeric
    r'|[\u{1F200}-\u{1F251}]' // Enclosed ideographic
    r'|[\u{1F300}-\u{1F5FF}]' // Misc symbols and pictographs
    r'|[\u{1F600}-\u{1F636}]' // Emoticons
    r'|[\u{1F640}-\u{1F64F}]' // Emoticons
    r'|[\u{1F680}-\u{1F6C5}]' // Transport symbols
    r'|[\u{1F6CC}-\u{1F6D2}]' // Transport symbols
    r'|[\u{1F6D5}-\u{1F6D7}]' // Transport symbols
    r'|[\u{1F6E0}-\u{1F6EC}]' // Transport symbols
    r'|[\u{1F6F0}-\u{1F6F8}]' // Transport symbols
    r'|[\u{1F700}-\u{1F773}]' // Alchemical
    r'|[\u{1F780}-\u{1F7D8}]' // Geometric
    r'|[\u{1F7E0}-\u{1F7EB}]' // Geometric
    r'|[\u{1F800}-\u{1F80B}]' // Supplemental arrows
    r'|[\u{1F810}-\u{1F847}]' // Supplemental arrows
    r'|[\u{1F850}-\u{1F859}]' // Supplemental arrows
    r'|[\u{1F860}-\u{1F887}]' // Supplemental arrows
    r'|[\u{1F890}-\u{1F8AD}]' // Supplemental arrows
    r'|[\u{1F900}-\u{1F90B}]' // Supplemental symbols
    r'|[\u{1F910}-\u{1F978}]' // Supplemental symbols
    r'|[\u{1F980}-\u{1F9BF}]' // Supplemental symbols
    r'|[\u{1F9C0}-\u{1F9FF}]' // Supplemental symbols
    r'|[\u{1FA00}-\u{1FA53}]' // Chess symbols
    r'|[\u{1FA60}-\u{1FA6D}]' // Chess symbols
    r'|[\u{1FA70}-\u{1FA74}]' // Extended symbols
    r'|[\u{1FA78}-\u{1FA7A}]' // Extended symbols
    r'|[\u{1FA80}-\u{1FA86}]' // Extended symbols
    r'|[\u{1FA90}-\u{1FAA8}]' // Extended symbols
    r'|[\u{1FAB0}-\u{1FAB6}]' // Extended symbols
    r'|[\u{1FAC0}-\u{1FAC2}]' // Extended symbols
    r'|[\u{1FAD0}-\u{1FAD6}]' // Extended symbols
    r'|[\u{1FB00}-\u{1FB92}]', // Extended symbols
    unicode: true,
  );
  
  // Remove emojis
  String cleanedText = text.replaceAll(emojiRegex, '');
  
  // Remove special characters but keep letters, numbers, and basic punctuation
  // Keep: letters, numbers, spaces, period, comma, question mark, exclamation
  // cleanedText = cleanedText.replaceAll(RegExp(r'[^a-zA-Z0-9\s.,!?\'"()\-\u0D00-\u0D7F\u0B80-\u0BFF\u0900-\u097F]'), ' ');
  
  // // Remove multiple spaces
  // cleanedText = cleanedText.replaceAll(RegExp(r'\s+'), ' ');
  
  // Remove leading/trailing spaces
  cleanedText = cleanedText.trim();
  
  // If text is empty after cleaning, return empty
  if (cleanedText.isEmpty) {
    return '';
  }
  
  // Replace common abbreviations and symbols with words
  cleanedText = cleanedText
      .replaceAll('&', ' and ')
      .replaceAll('+', ' plus ')
      .replaceAll('@', ' at ')
      .replaceAll('%', ' percent ')
      // .replaceAll('$', ' dollars ')
      .replaceAll('£', ' pounds ')
      .replaceAll('€', ' euros ')
      .replaceAll('°', ' degrees ')
      .replaceAll('#', ' number ')
      .replaceAll('*', ' star ')
      .replaceAll('/', ' or ');
  
  // Clean up multiple spaces again
  cleanedText = cleanedText.replaceAll(RegExp(r'\s+'), ' ').trim();
  
  return cleanedText;
}

String _getLanguageCode(AppLanguage language) {
  switch (language) {
    case AppLanguage.english:
      return 'en-US';
    case AppLanguage.tamil:
      return 'ta-IN';
    case AppLanguage.malayalam:
      return 'ml-IN';
    case AppLanguage.hindi:
      return 'hi-IN';
  }
}


 void changeLanguage(AppLanguage language) {
  _currentLanguage = language;
  // Update TTS language
  TtsService.setLanguage(_getLanguageCode(language));
  notifyListeners();
}

  String get localeId {
    switch (_currentLanguage) {
      case AppLanguage.english:
        return "en_US";
      case AppLanguage.tamil:
        return "ta_IN";
      case AppLanguage.malayalam:
        return "ml_IN";
      case AppLanguage.hindi:
        return "hi_IN";
    }
  }

  ChatProvider() {
    _messages.add({
      'isUser': false,
      'text': 'Hello! 👋 I\'m your PoketStor assistant. How can I help you today?',
      'timestamp': DateTime.now(),
    });
    _initializeSpeech();
    _initializeRecorder();
  }

  // Filter response text - hide app download messages
 // Filter response text - hide app download messages
String _filterResponseText(String text) {
  // List of phrases to hide (exact matches)
  final List<String> phrasesToHide = [
    '📲 കൂടുതൽ വിവരങ്ങൾക്ക് പോക്കറ്റ്സ്റ്റോർ ആപ്പ് ഡൗൺലോഡ് ചെയ്യുക.',
    '📲 Explore the complete PoketStor experience!',
    'Download the PoketStor app to discover nearby shops, browse products, and enjoy a smarter local shopping experience.',
    'കൂടുതൽ വിവരങ്ങൾക്ക് ആപ്പ് സന്ദർശിക്കുക.',
    '📲 ഡൗൺലോഡ് പോക്കറ്റ്സ്റ്റോർ ആപ്പ്',
    '📲',
    'Download PoketStor App', // Add this line
    'Download App', // Add this line
    'PoketStor App', // Add this line
  ];
  
  // List of patterns to hide (regex patterns)
  final List<RegExp> patternsToHide = [
    // Malayalam patterns
    RegExp(r'📲\s*കൂടുതൽ\s*വിവരങ്ങൾക്ക്\s*പോക്കറ്റ്സ്റ്റോർ\s*ആപ്പ്\s*ഡൗൺലോഡ്\s*ചെയ്യുക\.?\s*', 
      caseSensitive: false),
    RegExp(r'📲\s*Explore\s*the\s*complete\s*PoketStor\s*experience!?\s*', 
      caseSensitive: false),
    RegExp(r'Download\s*the\s*PoketStor\s*app\s*to\s*discover\s*nearby\s*shops,\s*browse\s*products,\s*and\s*enjoy\s*a\s*smarter\s*local\s*shopping\s*experience\.?\s*', 
      caseSensitive: false),
    RegExp(r'കൂടുതൽ\s*വിവരങ്ങൾക്ക്\s*ആപ്പ്\s*സന്ദർശിക്കുക\.?\s*', 
      caseSensitive: false),
    RegExp(r'📲\s*ഡൗൺലോഡ്\s*പോക്കറ്റ്സ്റ്റോർ\s*ആപ്പ്\.?\s*', 
      caseSensitive: false),
    // English patterns for Download PoketStor App
    RegExp(r'Download\s+PoketStor\s+App\s*', 
      caseSensitive: false),
    RegExp(r'Download\s+App\s*', 
      caseSensitive: false),
    RegExp(r'PoketStor\s+App\s*', 
      caseSensitive: false),
    // Remove standalone emojis
    RegExp(r'📲\s*$', caseSensitive: false),
    RegExp(r'^📲\s*$', caseSensitive: false, multiLine: true),
    // Remove any line containing download-related text
    RegExp(r'^.*?(?:download|app|experience|ആപ്പ്|ഡൗൺലോഡ്|വിവരങ്ങൾ).*?$\n?', 
      caseSensitive: false,
      multiLine: true),
  ];
  
  String filteredText = text;
  
  // Remove exact phrases
  for (var phrase in phrasesToHide) {
    filteredText = filteredText.replaceAll(phrase, '');
    // Also remove with extra spaces
    filteredText = filteredText.replaceAll(' $phrase', '');
    filteredText = filteredText.replaceAll('$phrase ', '');
  }
  
  // Remove patterns
  for (var pattern in patternsToHide) {
    filteredText = filteredText.replaceAll(pattern, '');
  }
  
  // Remove lines that contain "Download" or "App" (case insensitive)
  final lines = filteredText.split('\n');
  final filteredLines = lines.where((line) {
    final lowerLine = line.toLowerCase();
    // Check if line contains download-related content
    if (lowerLine.contains('download') && lowerLine.contains('app')) {
      return false;
    }
    if (lowerLine.contains('poketstor') && lowerLine.contains('app')) {
      return false;
    }
    // Check for Malayalam download phrases
    if (lowerLine.contains('ഡൗൺലോഡ്') && lowerLine.contains('ആപ്പ്')) {
      return false;
    }
    // Check for emoji-only lines
    if (line.trim() == '📲') {
      return false;
    }
    return true;
  }).join('\n');
  
  filteredText = filteredLines;
  
  // Clean up extra newlines
  filteredText = filteredText.replaceAll(RegExp(r'\n{3,}'), '\n\n');
  filteredText = filteredText.trim();
  
  // If filtered text is empty, return a default message
  if (filteredText.isEmpty) {
    return 'Here is the information you requested.';
  }
  
  return filteredText;
}

  Future<void> _initializeSpeech() async {
    try {
      developer.log('Initializing speech recognition...', name: 'ChatProvider');
      
      bool available = await _speech.initialize(
        onStatus: (status) {
          developer.log('Speech status: $status', name: 'ChatProvider');
          
          if (status == 'done' || status == 'notListening') {
            _isListening = false;
            notifyListeners();
            
            // Only process if we have words and not already processing
            if (_lastRecognizedWords.isNotEmpty && 
                !_isProcessingSpeech && 
                _lastRecognizedWords != _lastProcessedText) {
              _handleSpeechResult();
            }
          }
        },
        onError: (error) {
          developer.log('Speech error: $error', name: 'ChatProvider', error: error);
          _isListening = false;
          _isProcessingSpeech = false;
          
          if (error.toString().contains('error_no_match')) {
            developer.log('No speech detected', name: 'ChatProvider');
            _showSnackBar('No speech detected. Please try speaking again.');
            _isSpeechAvailable = true;
          } else {
            _isSpeechAvailable = false;
            _showSnackBar('Voice recognition error. Please try again.');
          }
          notifyListeners();
        },
      );
      
      _isSpeechAvailable = available;
      _isSpeechInitialized = true;
      
      developer.log('Speech initialized: $available', name: 'ChatProvider');
      notifyListeners();
    } catch (e) {
      developer.log('Error initializing speech: $e', name: 'ChatProvider', error: e);
      _isSpeechAvailable = false;
      _isSpeechInitialized = true;
      notifyListeners();
    }
  }

  void _handleSpeechResult() {
    if (_isProcessingSpeech) {
      developer.log('Already processing speech, skipping', name: 'ChatProvider');
      return;
    }
    
    final recognizedText = _lastRecognizedWords.trim();
    if (recognizedText.isEmpty) {
      developer.log('Empty speech result, skipping', name: 'ChatProvider');
      _lastRecognizedWords = '';
      return;
    }
    
    // Check if this exact text was already processed
    if (recognizedText == _lastProcessedText) {
      developer.log('Duplicate text detected, skipping: $recognizedText', name: 'ChatProvider');
      _lastRecognizedWords = '';
      return;
    }
    
    developer.log('Processing speech: $recognizedText', name: 'ChatProvider');
    _isProcessingSpeech = true;
    _lastProcessedText = recognizedText;
    
    // Set the text in controller
    textController.text = recognizedText;
    _lastRecognizedWords = '';
    
    // Send message after a small delay
    Future.delayed(const Duration(milliseconds: 200), () {
      if (textController.text.isNotEmpty) {
        sendMessage();
      }
      // Reset processing flag after sending
      _isProcessingSpeech = false;
    });
  }

  Future<void> _initializeRecorder() async {
    try {
      var hasPermission = await _audioRecorder.hasPermission();
      developer.log('Audio recorder permission: $hasPermission', name: 'ChatProvider');
      
      if (!hasPermission) {
        var newPermission = await _audioRecorder.hasPermission();
        developer.log('Audio recorder permission after request: $newPermission', name: 'ChatProvider');
      }
    } catch (e) {
      developer.log('Error initializing recorder: $e', name: 'ChatProvider', error: e);
    }
  }

  // Voice Recording Methods
  Future<void> startRecording() async {
    try {
      developer.log('Starting recording...', name: 'ChatProvider');
      
      bool hasPermission = await _audioRecorder.hasPermission();
      if (!hasPermission) {
        developer.log('No permission to record', name: 'ChatProvider');
        _showSnackBar('Microphone permission is required for voice recording');
        return;
      }
      
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      
      await _audioRecorder.start(
        RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: path,
      );
      
      _isRecording = true;
      _recordingPath = path;
      _recordingDuration = Duration.zero;
      notifyListeners();
      
      _updateRecordingDuration();
      
      developer.log('Recording started: $path', name: 'ChatProvider');
    } catch (e) {
      developer.log('Error starting recording: $e', name: 'ChatProvider', error: e);
      _showSnackBar('Could not start recording: ${e.toString()}');
    }
  }

  void _updateRecordingDuration() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 500));
      if (_isRecording) {
        try {
          final amplitude = await _audioRecorder.getAmplitude();
          if (amplitude.current > 0) {
            _recordingDuration = Duration(milliseconds: (amplitude.current * 1000).round());
          } else {
            _recordingDuration += const Duration(milliseconds: 500);
          }
          notifyListeners();
        } catch (e) {
          _recordingDuration += const Duration(milliseconds: 500);
          notifyListeners();
        }
        return true;
      }
      return false;
    });
  }

  Future<void> stopRecording() async {
    if (_isRecording) {
      developer.log('Stopping recording...', name: 'ChatProvider');
      try {
        final path = await _audioRecorder.stop();
        _isRecording = false;
        if (path != null) {
          _recordingPath = path;
          developer.log('Recording stopped: $path', name: 'ChatProvider');
          final file = File(path);
          if (await file.exists()) {
            final size = await file.length();
            developer.log('Recording file size: $size bytes', name: 'ChatProvider');
            if (size < 1000) {
              _showSnackBar('Recording too short. Please try again.');
              await cancelRecording();
              return;
            }
          }
        }
      } catch (e) {
        developer.log('Error stopping recording: $e', name: 'ChatProvider', error: e);
        _isRecording = false;
        _showSnackBar('Error stopping recording');
      }
      notifyListeners();
    }
  }

  Future<void> cancelRecording() async {
    developer.log('Cancelling recording...', name: 'ChatProvider');
    
    if (_isRecording) {
      try {
        await _audioRecorder.stop();
      } catch (e) {
        developer.log('Error stopping recorder: $e', name: 'ChatProvider', error: e);
      }
      _isRecording = false;
    }
    
    if (_recordingPath != null) {
      try {
        final file = File(_recordingPath!);
        if (await file.exists()) {
          await file.delete();
          developer.log('Recording file deleted', name: 'ChatProvider');
        }
      } catch (e) {
        developer.log('Error deleting recording: $e', name: 'ChatProvider', error: e);
      }
      _recordingPath = null;
    }
    
    _recordingDuration = Duration.zero;
    _playbackPosition = Duration.zero;
    _isPlayingPreview = false;
    notifyListeners();
  }

  Future<void> playRecordingPreview() async {
    if (_recordingPath == null) {
      developer.log('No recording to preview', name: 'ChatProvider');
      return;
    }
    
    try {
      developer.log('Playing recording preview...', name: 'ChatProvider');
      _isPlayingPreview = true;
      _playbackPosition = Duration.zero;
      notifyListeners();
      
      final duration = _recordingDuration;
      final step = Duration(milliseconds: 100);
      
      for (var i = Duration.zero; i < duration; i += step) {
        if (!_isPlayingPreview) break;
        _playbackPosition = i;
        notifyListeners();
        await Future.delayed(step);
      }
      
      if (_isPlayingPreview) {
        _playbackPosition = duration;
        notifyListeners();
        await Future.delayed(const Duration(milliseconds: 500));
        _isPlayingPreview = false;
        _playbackPosition = Duration.zero;
        notifyListeners();
        developer.log('Preview playback complete', name: 'ChatProvider');
      }
    } catch (e) {
      developer.log('Error playing preview: $e', name: 'ChatProvider', error: e);
      _isPlayingPreview = false;
      _playbackPosition = Duration.zero;
      notifyListeners();
      _showSnackBar('Error playing preview');
    }
  }

  void stopPreview() {
    developer.log('Stopping preview playback', name: 'ChatProvider');
    _isPlayingPreview = false;
    _playbackPosition = Duration.zero;
    notifyListeners();
  }

  Future<void> sendVoiceMessage() async {
    if (_recordingPath == null || _recordingDuration == Duration.zero) {
      developer.log('No voice message to send', name: 'ChatProvider');
      return;
    }

    developer.log('Sending voice message...', name: 'ChatProvider');
    _isLoading = true;
    notifyListeners();

    try {
      _messages.add({
        'isUser': true,
        'isVoice': true,
        'voicePath': _recordingPath,
        'duration': _recordingDuration,
        'timestamp': DateTime.now(),
        'isPlaying': false,
        'progress': 0.0,
      });
      
      _recordingPath = null;
      _recordingDuration = Duration.zero;
      _playbackPosition = Duration.zero;
      _isPlayingPreview = false;
      
      final response = await _chatService.sendMessage('Voice message sent');
      
      _showAppButton = response.showAppButton;
      _appLink = response.appLink;
      _buttonText = response.buttonText;
      
      String filteredReply = _filterResponseText(response.reply);
      if (filteredReply.isEmpty) {
        filteredReply = 'Thank you for your voice message.';
      }
      
      _messages.add({
        'isUser': false,
        'text': filteredReply,
        'timestamp': DateTime.now(),
        'showAppButton': response.showAppButton,
        'appLink': response.appLink,
        'buttonText': response.buttonText,
      });
      
      developer.log('Voice message sent successfully', name: 'ChatProvider');
      
    } catch (e) {
      developer.log('Error sending voice message: $e', name: 'ChatProvider', error: e);
      _messages.add({
        'isUser': false,
        'text': 'Sorry, I encountered an error. Please try again later. 🙏',
        'timestamp': DateTime.now(),
        'isError': true,
      });
    } finally {
      _isLoading = false;
      notifyListeners();
      _scrollToBottom();
    }
  }

  // Speech to Text Methods
  void toggleListening() async {
    developer.log('Toggling listening...', name: 'ChatProvider');
    
    if (!_isSpeechInitialized) {
      developer.log('Speech not initialized, initializing...', name: 'ChatProvider');
      await _initializeSpeech();
    }
    
    if (!_isSpeechAvailable) {
      developer.log('Speech not available', name: 'ChatProvider');
      _showSnackBar('Speech recognition is not available. Please type your message.');
      return;
    }
    
    if (_isListening) {
      await _stopListening();
    } else {
      // Reset flags when starting new listening session
      _isProcessingSpeech = false;
      _lastProcessedText = '';
      _lastRecognizedWords = '';
      await _startListening();
    }
  }

  Future<void> _startListening() async {
    try {
      developer.log('Starting listening...', name: 'ChatProvider');
      
      _retryCount = 0;
      
      if (!_isSpeechInitialized) {
        await _initializeSpeech();
        if (!_isSpeechAvailable) {
          _showSnackBar('Speech recognition not available');
          return;
        }
      }
      
      _isProcessingSpeech = false;
      _isListening = true;
      _lastRecognizedWords = '';
      notifyListeners();
      
      await _speech.listen(
        onResult: (result) {
          _lastRecognizedWords = result.recognizedWords;
          if (result.recognizedWords.isNotEmpty) {
            textController.text = _lastRecognizedWords;
            textController.selection = TextSelection.fromPosition(
              TextPosition(offset: _lastRecognizedWords.length),
            );
            notifyListeners();
          }
        },
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        localeId: localeId,
        onSoundLevelChange: (level) {},
      );
      
      developer.log('Listening started successfully', name: 'ChatProvider');
      
    } catch (e) {
      developer.log('Error starting speech: $e', name: 'ChatProvider', error: e);
      _isListening = false;
      
      if (_retryCount < maxRetries) {
        _retryCount++;
        developer.log('Retrying speech recognition (${_retryCount}/$maxRetries)', name: 'ChatProvider');
        _showSnackBar('Retrying voice recognition...');
        await Future.delayed(const Duration(seconds: 1));
        await _startListening();
      } else {
        _isSpeechAvailable = false;
        _showSnackBar('Voice recognition failed multiple times. Please type your message.');
        notifyListeners();
      }
    }
  }

  Future<void> _stopListening() async {
    developer.log('Stopping listening...', name: 'ChatProvider');
    try {
      await _speech.stop();
    } catch (e) {
      developer.log('Error stopping speech: $e', name: 'ChatProvider', error: e);
    }
    _isListening = false;
    notifyListeners();
    
    // Don't send message here - handled by _handleSpeechResult
  }

  void sendMessage() async {
    // Prevent duplicate sends
    if (_isLoading) {
      developer.log('Already sending a message, ignoring duplicate', name: 'ChatProvider');
      return;
    }
    
    final message = textController.text.trim();
    if (message.isEmpty) {
      developer.log('Empty message, ignoring', name: 'ChatProvider');
      return;
    }

    developer.log('Sending message: $message', name: 'ChatProvider');

    if (_isListening) {
      await _speech.stop();
      _isListening = false;
      notifyListeners();
    }

    // Clear the text controller
    textController.clear();
    
    // Add user message
    _messages.add({
      'isUser': true,
      'text': message,
      'timestamp': DateTime.now(),
    });
    
    _isLoading = true;
    notifyListeners();
    _scrollToBottom();

    try {
      final response = await _chatService.sendMessage(message);
      
      _showAppButton = response.showAppButton;
      _appLink = response.appLink;
      _buttonText = response.buttonText;
      
      String filteredReply = _filterResponseText(response.reply);
      
      if (filteredReply.isEmpty) {
        filteredReply = 'Here is the information you requested.';
      }
      
      _messages.add({
        'isUser': false,
        'text': filteredReply,
        'timestamp': DateTime.now(),
        'showAppButton': response.showAppButton,
        'appLink': response.appLink,
        'buttonText': response.buttonText,
      });
      
      developer.log('Message sent successfully', name: 'ChatProvider');
      
    } catch (e) {
      developer.log('Error sending message: $e', name: 'ChatProvider', error: e);
      _messages.add({
        'isUser': false,
        'text': 'Sorry, I encountered an error. Please try again later. 🙏',
        'timestamp': DateTime.now(),
        'isError': true,
      });
    } finally {
      _isLoading = false;
      _lastRecognizedWords = '';
      _isProcessingSpeech = false;
      notifyListeners();
      _scrollToBottom();
    }
  }

  void clearMessages() {
    developer.log('Clearing messages', name: 'ChatProvider');
    _messages.clear();
    _messages.add({
      'isUser': false,
      'text': 'Hello! 👋 I\'m your PoketStor assistant. How can I help you today?',
      'timestamp': DateTime.now(),
    });
    _showAppButton = false;
    _appLink = '';
    _buttonText = '';
    _lastRecognizedWords = '';
    _lastProcessedText = '';
    _recordingPath = null;
    _recordingDuration = Duration.zero;
    _playbackPosition = Duration.zero;
    _isProcessingSpeech = false;
    if (_isListening) {
      _speech.stop();
      _isListening = false;
    }
    if (_isRecording) {
      _audioRecorder.stop();
      _isRecording = false;
    }
    textController.clear();
    notifyListeners();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showSnackBar(String message) {
    developer.log('SnackBar: $message', name: 'ChatProvider');
  }

  @override
  void dispose() {
    TtsService.stop();
    _speech.stop();
    _audioRecorder.dispose();
    textController.dispose();
    scrollController.dispose();
    super.dispose();
  }
}