import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  late final WebViewController controller;
  
  // Replace this with your actual chatbot URL
  final String _chatBotUrl = 'https://inspiring-trifle-71e9ae.netlify.app/'; // Change this to your actual URL

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Optional: Show loading progress
          },
          onPageStarted: (String url) {
            // Optional: Handle page start
          },
          onPageFinished: (String url) {
            // Optional: Handle page finish
          },
          onWebResourceError: (WebResourceError error) {
            // Handle errors
            debugPrint('WebView Error: ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) {
            // Allow all navigation
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(
        Uri.parse(_chatBotUrl),
      );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Chat Support',
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: const Color(0xFF0703C9),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () {
                controller.reload();
              },
            ),
          ],
        ),
        body: WebViewWidget(
          controller: controller,
        ),
      ),
    );
  }
}