import 'package:flutter/material.dart';
import 'package:poketstore/utilities/custom_app_bar.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(title: "About", showBackButton: false),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: const [
              _Heading(text: '📱 PocketStore'),
              SizedBox(height: 16),
              _BodyText(
                'PocketStore is your personalized online marketplace where every user can become a seller and a shopper. '
                'Whether you\'re managing your own shop or browsing products from others, PocketStore brings convenience, '
                'control, and community all in one place.',
              ),
              SizedBox(height: 24),
              _SubHeading(text: '🔑 Key Features:'),
              SizedBox(height: 16),
              _BodyText(
                '🛍 Register and Manage Your Own Shop\n'
                'Set up your store easily and manage your product listings directly from the app.\n\n'
                '📦 Add and Showcase Products\n'
                'Upload products with details and images to attract potential buyers.\n\n'
                '❤️ Favorites List\n'
                'Save your favorite products for quick access and future purchases.\n\n'
                '🏷 Promo Codes & Subscriptions\n'
                'Use promo codes for special offers and enjoy exclusive deals through subscriptions.\n\n'
                '📍 Save Delivery Addresses\n'
                'Store and manage multiple delivery addresses for faster checkout.\n\n'
                '👥 Community-Based Marketplace\n'
                'Explore shops from other users, support local businesses, and build your own customer base.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Custom AppBar ----------
  // PreferredSize _buildCustomAppBar() {
  //   return PreferredSize(
  //     preferredSize: const Size.fromHeight(60),
  //     child: Container(
  //       decoration: const BoxDecoration(
  //         color: Color.fromARGB(255, 7, 3, 201),
  //         borderRadius: BorderRadius.only(
  //           bottomLeft: Radius.circular(25),
  //           bottomRight: Radius.circular(25),
  //         ),
  //       ),
  //       child: AppBar(
  //         backgroundColor: Colors.transparent,
  //         elevation: 0,
  //         centerTitle: true,
  //         title: const Text(
  //           "About PoketStor",
  //           style: TextStyle(color: Colors.white),
  //         ),
  //       ),
  //     ),
  //   );
  // }
}

// ---------- Reusable Text Widgets ----------
class _Heading extends StatelessWidget {
  final String text;
  const _Heading({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    );
  }
}

class _SubHeading extends StatelessWidget {
  final String text;
  const _SubHeading({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }
}

class _BodyText extends StatelessWidget {
  final String text;
  const _BodyText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontSize: 16));
  }
}
