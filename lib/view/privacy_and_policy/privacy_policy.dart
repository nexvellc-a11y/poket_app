import 'package:flutter/material.dart';
import 'package:poketstore/utilities/custom_app_bar.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Container(
        color: Colors.grey[100],
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Privacy Policy",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "PoketStor values user privacy and is committed to protecting personal data.\n\n"
                    "Information Collection: Basic details such as name, phone number, and location are collected to provide personalized services.\n\n"
                    "Usage: Location data is used only to display nearby shops and improve recommendations.\n\n"
                    "Data Protection: PoketStor does not sell, rent, or share user data with third parties.\n\n"
                    "Storage: User data is securely stored and used only for platform-related purposes.\n\n"
                    "Access & Control: Users can request account or data deletion anytime by contacting customer support.",
                    style: TextStyle(fontSize: 15, height: 1.5),
                  ),
                  SizedBox(height: 24),
                  Text(
                    "Refund Policy",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Subscription Fees: All subscription payments are non-refundable once activated.\n\n"
                    "Free Offer: Only first-time subscribers who purchase any plan are eligible for 2 months free as part of their first subscription. This offer is valid only once per account.\n\n"
                    "Customer Orders: Since PoketStor does not process customer payments, all refunds or disputes must be resolved directly between the customer and the shop owner.\n\n"
                    "PoketStor is not liable for losses, delays, or disputes related to transactions between users.",
                    style: TextStyle(fontSize: 15, height: 1.5),
                  ),
                  SizedBox(height: 24),
                  Text(
                    "Contact Us",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "For any queries, assistance, or to edit or update your details, you can do so directly within the application.\n\n"
                    "For additional support, please contact us at:\n"
                    "poketstormail@gmail.com",
                    style: TextStyle(fontSize: 15, height: 1.5),
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: Text(
                      "© 2025 PoketStor. All rights reserved.",
                      style: TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
