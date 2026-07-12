import 'package:flutter/material.dart';
import 'package:poketstore/controllers/chatbot_controller/chatbot_controller.dart';
import 'package:poketstore/utilities/chat_language.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:developer' as developer;

/// Shared theme tokens for the chat screen — a modern indigo/violet palette
/// with soft neutrals, used consistently across bubbles, app bar and input.
class ChatColors {
  static const Color primary = Color(0xFF4338CA); // indigo
  static const Color primaryDark = Color(0xFF312E81);
  static const Color primaryLight = Color(0xFF6366F1);
  static const Color background = Color(0xFFF6F7FB);
  static const Color bubbleBot = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1E1B2E);
  static const Color textMuted = Color(0xFF8B8AA0);
  static const Color error = Color(0xFFDC2626);
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  // Logger methods
  void _logInfo(String message, {Map<String, dynamic>? data}) {
    developer.log(
      '📱 CHAT: $message',
      name: 'ChatScreen',
      time: DateTime.now(),
      error: data,
    );
  }

  void _logError(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(
      '❌ CHAT ERROR: $message',
      name: 'ChatScreen',
      time: DateTime.now(),
      error: error,
      stackTrace: stackTrace,
    );
  }

  void _logMicAction(String action, {Map<String, dynamic>? details}) {
    developer.log(
      '🎙️ MIC: $action',
      name: 'ChatScreen-Mic',
      time: DateTime.now(),
      error: details,
    );
  }

  @override
  void initState() {
    super.initState();
    _logInfo('ChatScreen initialized');

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _logInfo('ChatScreen disposed');
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _logInfo('Building ChatScreen UI');
    return SafeArea(
      child: Scaffold(
        backgroundColor: ChatColors.background,
        appBar: _buildAppBar(context),
        body: Consumer<ChatProvider>(
          builder: (context, chatProvider, child) {
            // Stack lets the language button float as a fixed element on
            // the chat screen — pinned just above the mic — regardless of
            // whichever input bar state (default / recording / preview) is
            // currently showing below it.
            return Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: chatProvider.messages.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              controller: chatProvider.scrollController,
                              padding: const EdgeInsets.fromLTRB(14, 18, 14, 10),
                              itemCount: chatProvider.messages.length,
                              itemBuilder: (context, index) {
                               final message = chatProvider.messages[index];
  final isUser = message['isUser'] as bool;
  final messageId = 'msg_$index'; // Unique ID for each message
  
                                // Check if it's a voice message
                                 if (message['isVoice'] == true) {
    _logInfo('Rendering voice message at index $index',
        data: {'isUser': isUser, 'duration': message['duration']});
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildVoiceMessageBubble(message, isUser),
        const SizedBox(height: 6),
      ],
    );
  }

                               return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      MessageBubble(
        text: message['text'] as String,
        isUser: isUser,
        timestamp: message['timestamp'] as DateTime,
        isError: message['isError'] as bool? ?? false,
        // TTS props
        isSpeaking: chatProvider.isSpeaking && chatProvider.speakingMessageId == messageId,
        onSpeak: !isUser ? () {
          final text = message['text'] as String;
          chatProvider.speakMessage(text, messageId);
        } : null,
      ),
   
                                    const SizedBox(height: 6),
                                  ],
                                );
                              },
                            ),
                    ),
                    if (chatProvider.isLoading) const _TypingIndicator(),
                    _buildInputBar(chatProvider),
                  ],
                ),
                // Fixed language switcher, floating above the mic button in
                // the bottom-right corner of the chat screen at all times.
                Positioned(
                  left: 16,
                  bottom: _languageButtonBottomOffset(chatProvider),
                  child: _buildLanguageButton(chatProvider),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Keeps the floating language button sitting right above the mic no
  /// matter which input bar layout (default / recording / preview) is
  /// currently shown, since each has a different height.
  double _languageButtonBottomOffset(ChatProvider chatProvider) {
    if (chatProvider.isRecording) return 118;
    if (chatProvider.recordingPath != null && !chatProvider.isRecording) return 96;
    return 78;
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      centerTitle: false,
      toolbarHeight: 68,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [ChatColors.primary, ChatColors.primaryDark],
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        onPressed: () {
          _logInfo('Back button pressed');
          Navigator.pop(context);
        },
      ),
      title: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'PoketStor Assistant',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(radius: 3.5, backgroundColor: Color(0xFF4ADE80)),
                    SizedBox(width: 5),
                    Text(
                      'Online',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // "End Chat" replaces the old refresh/reload icon with a clear text
        // action. The language switcher now floats above the mic button
        // instead of living in the app bar.
        TextButton(
          onPressed: () {
            _logInfo('End chat button pressed');
            context.read<ChatProvider>().clearMessages();
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            minimumSize: const Size(0, 36),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'End Chat',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: ChatColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(ChatColors.primary),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Starting conversation…',
            style: TextStyle(
              color: ChatColors.textMuted,
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(ChatProvider chatProvider) {
    // Show voice recording UI when recording
    if (chatProvider.isRecording) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: _buildVoiceRecordingWidget(chatProvider),
      );
    }

    // Show voice preview UI when there's a recording but not recording
    if (chatProvider.recordingPath != null && !chatProvider.isRecording) {
      return Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ChatColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.mic_rounded,
                color: ChatColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Voice message (${_formatDuration(chatProvider.recordingDuration)})',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          chatProvider.isPlayingPreview
                              ? Icons.stop_circle_rounded
                              : Icons.play_circle_rounded,
                          color: ChatColors.primary,
                          size: 28,
                        ),
                        onPressed: () {
                          if (chatProvider.isPlayingPreview) {
                            _logMicAction('Stop preview');
                            chatProvider.stopPreview();
                          } else {
                            _logMicAction('Play preview',
                                details: {'duration': chatProvider.recordingDuration});
                            chatProvider.playRecordingPreview();
                          }
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: chatProvider.isPlayingPreview
                              ? chatProvider.playbackPosition.inMilliseconds /
                                  chatProvider.recordingDuration.inMilliseconds
                              : 0,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            ChatColors.primary,
                          ),
                          minHeight: 4,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.grey,
                          size: 20,
                        ),
                        onPressed: () {
                          _logMicAction('Cancel recording');
                          chatProvider.cancelRecording();
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(
                Icons.send_rounded,
                color: ChatColors.primary,
                size: 24,
              ),
              onPressed: chatProvider.recordingDuration > const Duration(seconds: 1)
                  ? () {
                      _logMicAction('Send voice message',
                          details: {'duration': chatProvider.recordingDuration});
                      chatProvider.sendVoiceMessage();
                    }
                  : null,
            ),
          ],
        ),
      );
    }

    // Default input bar
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildMicButton(chatProvider),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: chatProvider.isListening
                    ? const Color(0xFFFEE2E2)
                    : const Color(0xFFF1F1F6),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: chatProvider.textController,
                decoration: InputDecoration(
                  hintText: chatProvider.isListening
                      ? 'Listening…'
                      : 'Type Your Message....',
                  hintStyle: const TextStyle(
                    color: ChatColors.textMuted,
                    fontSize: 14.5,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 13,
                  ),
                  suffixIcon: chatProvider.isListening
                      ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: SizedBox(
                            height: 14,
                            width: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(ChatColors.error),
                            ),
                          ),
                        )
                      : null,
                ),
                style: const TextStyle(fontSize: 14.5, color: ChatColors.textDark),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) {
                  _logInfo('Message submitted via keyboard');
                  chatProvider.sendMessage();
                },
                enabled: !chatProvider.isListening,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _buildSendButton(chatProvider),
        ],
      ),
    );
  }

  /// Language switcher — now a fixed, floating button pinned above the mic
  /// (see the Positioned/Stack wiring in build()) instead of sitting inline
  /// in the input row, so it stays visible across every input bar state.
  Widget _buildLanguageButton(ChatProvider chatProvider) {
    return Container(
      width: 27,
      height: 25,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: ChatColors.primary.withOpacity(0.15)),
      ),
      child: PopupMenuButton<AppLanguage>(
        icon: const Icon(
          Icons.keyboard_arrow_down_outlined,
          color: ChatColors.primary,
          size: 25,
        ),
        tooltip: 'Change language',
        padding: EdgeInsets.zero,
        onSelected: (lang) {
          _logInfo('Language changed', data: {'language': lang.toString()});
          chatProvider.changeLanguage(lang);
        },
        itemBuilder: (context) => const [
          PopupMenuItem(
            value: AppLanguage.english,
            child: Text("English"),
          ),
          PopupMenuItem(
            value: AppLanguage.tamil,
            child: Text("தமிழ்"),
          ),
          PopupMenuItem(
            value: AppLanguage.malayalam,
            child: Text("മലയാളം"),
          ),
          PopupMenuItem(
            value: AppLanguage.hindi,
            child: Text("हिन्दी"),
          ),
        ],
      ),
    );
  }

  Widget _buildMicButton(ChatProvider chatProvider) {
    if (chatProvider.isListening) {
      return AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return GestureDetector(
            onTap: () {
              _logMicAction('Toggle listening (stop)');
              chatProvider.toggleListening();
            },
            child: Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ChatColors.error,
                  boxShadow: [
                    BoxShadow(
                      color: ChatColors.error.withOpacity(0.4),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Icon(Icons.mic_rounded, color: Colors.white, size: 22),
              ),
            ),
          );
        },
      );
    }

    // Long press for voice recording
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: ChatColors.primary.withOpacity(0.08),
        shape: BoxShape.circle,
      ),
      child: GestureDetector(
        onLongPress: () {
          if (!chatProvider.isLoading && !chatProvider.isListening) {
            _logMicAction('Long press started - starting recording');
            chatProvider.startRecording();
          } else {
            _logMicAction('Long press ignored',
                details: {
                  'isLoading': chatProvider.isLoading,
                  'isListening': chatProvider.isListening
                });
          }
        },
        onLongPressUp: () {
          if (chatProvider.isRecording) {
            _logMicAction('Long press ended - stopping recording',
                details: {'duration': chatProvider.recordingDuration});
            chatProvider.stopRecording();
          } else {
            _logMicAction('Long press ended - not recording');
          }
        },
        onTap: () {
          if (!chatProvider.isLoading && !chatProvider.isRecording) {
            _logMicAction('Single tap - toggling listening');
            chatProvider.toggleListening();
          } else {
            _logMicAction('Single tap ignored',
                details: {
                  'isLoading': chatProvider.isLoading,
                  'isRecording': chatProvider.isRecording
                });
          }
        },
        child: Icon(
          chatProvider.isRecording ? Icons.mic_off_rounded : Icons.mic_rounded,
          color: chatProvider.isRecording ? Colors.red : ChatColors.primary,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildSendButton(ChatProvider chatProvider) {
    final bool enabled = !chatProvider.isLoading && !chatProvider.isListening;
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: enabled
              ? [ChatColors.primaryLight, ChatColors.primary]
              : [Colors.grey.shade300, Colors.grey.shade400],
        ),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: ChatColors.primary.withOpacity(0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : [],
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 20),
        onPressed: enabled ? () {
          _logInfo('Send button pressed');
          chatProvider.sendMessage();
        } : null,
        padding: EdgeInsets.zero,
      ),
    );
  }

  // Voice Message Bubble
  Widget _buildVoiceMessageBubble(Map<String, dynamic> message, bool isUser) {
    final duration = message['duration'] as Duration;
    final isPlaying = message['isPlaying'] ?? false;
    final progress = message['progress'] ?? 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.74,
      ),
      decoration: BoxDecoration(
        color: isUser ? ChatColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(18).copyWith(
          bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(18),
          bottomLeft: isUser ? const Radius.circular(18) : const Radius.circular(4),
        ),
        border: !isUser ? Border.all(color: const Color(0xFFEDEDF4), width: 1) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(
                  isPlaying ? Icons.pause_circle_rounded : Icons.play_circle_rounded,
                  color: isUser ? Colors.white : ChatColors.primary,
                  size: 32,
                ),
                onPressed: () {
                  // Handle play/pause
                  _logMicAction('Voice message play/pause',
                      details: {'isPlaying': isPlaying, 'isUser': isUser});
                  _toggleVoicePlayback(message);
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              Expanded(
                child: Column(
                  children: [
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: isUser
                          ? Colors.white.withOpacity(0.3)
                          : Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isUser ? Colors.white : ChatColors.primary,
                      ),
                      minHeight: 4,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(duration),
                          style: TextStyle(
                            fontSize: 11,
                            color: isUser
                                ? Colors.white.withOpacity(0.8)
                                : ChatColors.textMuted,
                          ),
                        ),
                        Icon(
                          Icons.mic_rounded,
                          size: 14,
                          color: isUser ? Colors.white70 : Colors.grey,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Timestamp
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              _formatTime(message['timestamp'] as DateTime),
              style: TextStyle(
                fontSize: 10.5,
                color: isUser ? Colors.white.withOpacity(0.75) : ChatColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleVoicePlayback(Map<String, dynamic> message) {
    // Implement voice playback logic
    // This would use audioplayers package to play the audio file
    _logMicAction('Toggle voice playback');
    print('Toggle playback for voice message');
  }

  // Voice Recording Widget
  Widget _buildVoiceRecordingWidget(ChatProvider chatProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recording indicator
          Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.5),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Recording ${_formatDuration(chatProvider.recordingDuration)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              // Cancel button
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.grey),
                onPressed: () {
                  _logMicAction('Cancel recording from widget');
                  chatProvider.cancelRecording();
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Voice waveform animation (simplified)
          Row(
            children: List.generate(
              20,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: _getWaveHeight(chatProvider.recordingDuration, index),
                width: 3,
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  color: ChatColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Play preview button
              ElevatedButton.icon(
                onPressed: chatProvider.isPlayingPreview
                    ? () {
                        _logMicAction('Stop preview from widget');
                        chatProvider.stopPreview();
                      }
                    : () {
                        _logMicAction('Play preview from widget',
                            details: {'duration': chatProvider.recordingDuration});
                        chatProvider.playRecordingPreview();
                      },
                icon: Icon(
                  chatProvider.isPlayingPreview
                      ? Icons.stop_rounded
                      : Icons.play_arrow_rounded,
                  size: 18,
                ),
                label: Text(
                  chatProvider.isPlayingPreview
                      ? 'Stop'
                      : 'Preview',
                  style: const TextStyle(fontSize: 13),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: chatProvider.isPlayingPreview
                      ? Colors.orange
                      : Colors.grey.shade200,
                  foregroundColor: chatProvider.isPlayingPreview
                      ? Colors.white
                      : Colors.black87,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              // Send button
              ElevatedButton.icon(
                onPressed: chatProvider.recordingDuration > const Duration(seconds: 1)
                    ? () {
                        _logMicAction('Send voice message from widget',
                            details: {'duration': chatProvider.recordingDuration});
                        chatProvider.sendVoiceMessage();
                      }
                    : null,
                icon: const Icon(Icons.send_rounded, size: 18),
                label: const Text(
                  'Send',
                  style: TextStyle(fontSize: 13),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ChatColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
          if (chatProvider.isPlayingPreview)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: LinearProgressIndicator(
                value: chatProvider.playbackPosition.inMilliseconds /
                    chatProvider.recordingDuration.inMilliseconds,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(ChatColors.primary),
                minHeight: 4,
              ),
            ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  double _getWaveHeight(Duration duration, int index) {
    // Simple wave animation based on duration
    final baseHeight = 8.0;
    final maxHeight = 20.0;
    final time = duration.inMilliseconds / 1000;
    final height = baseHeight + ((maxHeight - baseHeight) *
        (0.5 + 0.5 * (1 - (index / 20)) * (0.5 + 0.5 * (1 + (time * 2).sign))));
    return height;
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 18, bottom: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16).copyWith(
                bottomLeft: const Radius.circular(4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(ChatColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DownloadAppButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _DownloadAppButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.download_rounded, size: 18),
        label: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF16A34A),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isError;
  final bool isSpeaking;
  final VoidCallback? onSpeak;

  const MessageBubble({
    super.key,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isError = false,
    this.isSpeaking = false,
    this.onSpeak,
  });

  @override
  Widget build(BuildContext context) {
    final bubble = Container(
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.74,
      ),
      decoration: BoxDecoration(
        gradient: isUser
            ? const LinearGradient(
                colors: [ChatColors.primaryLight, ChatColors.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isUser
            ? null
            : (isError ? const Color(0xFFFEF2F2) : ChatColors.bubbleBot),
        borderRadius: BorderRadius.circular(18).copyWith(
          bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(18),
          bottomLeft: isUser ? const Radius.circular(18) : const Radius.circular(4),
        ),
        border: !isUser && !isError
            ? Border.all(color: const Color(0xFFEDEDF4), width: 1)
            : null,
        boxShadow: [
          BoxShadow(
            color: isUser
                ? ChatColors.primary.withOpacity(0.22)
                : Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: TextStyle(
              color: isUser
                  ? Colors.white
                  : (isError ? ChatColors.error : ChatColors.textDark),
              fontSize: 14.5,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.spaceBetween,
            children: [
              // Show speaker icon only for bot messages
              if (!isUser && onSpeak != null) ...[
                GestureDetector(
                  onTap: onSpeak,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isSpeaking 
                          ? ChatColors.primary.withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isSpeaking 
                          ? Icons.stop_circle_rounded 
                          : Icons.volume_up_rounded,
                      size: 18,
                      color: isSpeaking 
                          ? ChatColors.primary 
                          : ChatColors.textMuted,
                    ),
                  ),
                ),
              ],
              // Timestamp
              Text(
                _formatTime(timestamp),
                style: TextStyle(
                  fontSize: 10.5,
                  color: isUser 
                      ? Colors.white.withOpacity(0.75) 
                      : ChatColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (isUser) {
      return Align(alignment: Alignment.centerRight, child: bubble);
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 26,
            height: 26,
            margin: const EdgeInsets.only(right: 6, bottom: 4),
            decoration: BoxDecoration(
              color: isError
                  ? ChatColors.error.withOpacity(0.12)
                  : ChatColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isError ? Icons.error_outline_rounded : Icons.support_agent_rounded,
              size: 14,
              color: isError ? ChatColors.error : ChatColors.primary,
            ),
          ),
          Flexible(child: bubble),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}