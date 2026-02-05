import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 7, 3, 201),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: const Text(
              "Help & Support",
              style: TextStyle(color: Colors.white),
            ),
            iconTheme: IconThemeData(color: Colors.white),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: const [
            Text(
              '🆘 Help Center',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Need assistance? Here are some common topics that might help you get started with PocketStore.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 24),
            Text(
              '📦 How to Add Products?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Go to your shop section, tap "Add Product", fill in the product details and images, then save.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              '🏪 How to Register Your Shop?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Navigate to the "My Shop" tab and follow the steps to create and register your own store.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            // Text(
            //   '❤️ How to Add Favorites?',
            //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            // ),
            // Text(
            //   'Tap the heart icon on any product to save it to your favorites list.',
            //   style: TextStyle(fontSize: 16),
            // ),
            // SizedBox(height: 16),
            Text(
              '🏷 How to Use Promo Codes?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'During checkout, enter the promo code in the provided field to apply discounts.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              '📍 How to Save Delivery Addresses?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'In your profile section, go to "My Addresses" to add or manage delivery locations.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 24),
            Text(
              '💬 Still need help?\nContact our support team through the "Contact Us" section or email us at support@pocketstore.com.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
