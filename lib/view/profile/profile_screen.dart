import 'package:flutter/material.dart';
import 'package:poketstore/controllers/shop_of_user_controller/shop_of_user_controller.dart';
import 'package:poketstore/utilities/custom_app_bar.dart';
import 'package:poketstore/utilities/web_url.dart';
import 'package:poketstore/view/about_app/about_app.dart';
import 'package:poketstore/view/help/help.dart';
import 'package:poketstore/view/privacy_and_policy/privacy_policy.dart';
import 'package:poketstore/view/profile/pocket_coins.dart';
import 'package:poketstore/view/subscription/subscription_user.dart';
import 'package:poketstore/view/web_view/web_view.dart';
import 'package:provider/provider.dart';
import 'package:poketstore/controllers/login_reg_controller/login_controller.dart';
import 'package:poketstore/controllers/user_profile_controller/user_profile_controller.dart';

import 'package:poketstore/view/order_screen/order_screen.dart';
import 'package:poketstore/view/subscription/subscription.dart';
import 'package:poketstore/view/user_profile/user_profile.dart';
import 'package:poketstore/controllers/bottom_bar_controller/bottombar_controller.dart'; // Import BottomBarProvider

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();

    /// Load user profile once screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProfileController>().loadUserProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loginProvider = context.watch<LoginProvider>();
    context.watch<UserProfileController>();
    final shopProvider = context.watch<ShopOfUserProvider>();
    final bottomBarProvider = Provider.of<BottomBarProvider>(
      context,
      listen: false,
    ); // Get BottomBarProvider instance.  Use listen: false, as we don't want to rebuild this widget when the bottom bar changes.

    void showPocketCoinsPopup(BuildContext context) {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Row(
              children: const [
                Icon(Icons.monetization_on, color: Colors.amber),
                SizedBox(width: 8),
                Text("PocketCoins"),
              ],
            ),
            content: const Text(
              "When you make a purchase, you will earn PocketCoins which can be used for future benefits.",
              style: TextStyle(fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0703C9), Colors.white],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: CustomAppBar(),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Highlighted PocketCoins Card
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.amber.shade600, Colors.orange.shade700],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.4),
                        blurRadius: 15,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        final userProfileController =
                            context.read<UserProfileController>();

                        final userProfile = userProfileController.userProfile;

                        if (userProfile == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('User data not loaded'),
                            ),
                          );
                          return;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    PocketCoinsScreen(userProfile: userProfile),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.monetization_on,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "PocketCoins",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 2,
                                          offset: const Offset(1, 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  // Text(
                                  //   "Earn coins on every purchase!",
                                  //   style: TextStyle(
                                  //     fontSize: 14,
                                  //     color: Colors.white.withOpacity(0.9),
                                  //   ),
                                  // ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.info_outline,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          "Tap to learn more",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Rest of the menu items
              buildMenuItem(Icons.shopping_bag_outlined, "Orders", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OrderListScreen()),
                );
              }),
              buildMenuItem(Icons.person_outline, "My Details", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserProfileScreen(),
                  ),
                );
              }),
              if (shopProvider.shopList.isNotEmpty)
                buildMenuItem(Icons.subscriptions_outlined, "Subscription", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SubscriptionUserScreen(),
                    ),
                  );
                }),

              buildMenuItem(Icons.help_outline, "Help", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HelpScreen()),
                );
              }),

              buildMenuItem(
                Icons.label_important_outline,
                "Terms And Conditions",
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => WebViewScreen(
                            title: "Terms & Conditions",
                            url: termsUrl,
                          ),
                    ),
                  );
                },
              ),
              buildMenuItem(Icons.help_outline, "PrivacyAndPolicy", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => WebViewScreen(
                          title: "Privacy Policy",
                          url: privacyUrl,
                        ),
                  ),
                );
              }),
              buildMenuItem(Icons.info_outline, "About", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AboutAppScreen(),
                  ),
                );
              }),

              const SizedBox(height: 20),

              // Logout Button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Confirm Logout"),
                          content: const Text(
                            "Are you sure you want to log out?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Close dialog
                              },
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Close dialog
                                loginProvider.logout(context);
                                bottomBarProvider.changeTab(
                                  0,
                                ); // Change bottom tab
                              },
                              child: const Text("Logout"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 84, 82, 204),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        "Log Out",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable menu item builder
  Widget buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.white,
        ),
        onTap: onTap,
      ),
    );
  }
}
