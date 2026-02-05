import 'package:flutter/material.dart';
import 'package:poketstore/controllers/bottom_bar_controller/bottombar_controller.dart';
import 'package:poketstore/view/add_shop/shope_list_screen.dart';
import 'package:provider/provider.dart';
import 'package:poketstore/view/cart_screen/cart_screen.dart';
import 'package:poketstore/view/home/view/home_screen/home_screen.dart';
import 'package:poketstore/view/profile/profile_screen.dart';

class BottomBarScreen extends StatefulWidget {
  const BottomBarScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BottomBarScreenState createState() => _BottomBarScreenState();
}

class _BottomBarScreenState extends State<BottomBarScreen> {
  final List<Widget> _screens = [
    const HomeScreen(),
    ShopListScreen(),
    CartScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomBarProvider = Provider.of<BottomBarProvider>(context);

    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        if (bottomBarProvider.selectedIndex != 0) {
          bottomBarProvider.changeTab(0);
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white, // Entire screen background white

        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder:
              (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
          child: _screens[bottomBarProvider.selectedIndex],
        ),

        // 🔥 Redesigned Bottom Bar
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: BottomNavigationBar(
              backgroundColor: Colors.white,
              currentIndex: bottomBarProvider.selectedIndex,
              onTap: (index) => bottomBarProvider.changeTab(index),

              type: BottomNavigationBarType.fixed,

              selectedItemColor: Color(0xFF7A5AF8), // Your theme purple
              unselectedItemColor: Colors.grey.shade500,

              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              unselectedLabelStyle: const TextStyle(fontSize: 12),

              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_rounded),
                  label: "Home",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.storefront_rounded),
                  label: "My Shop",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_cart_rounded),
                  label: "Cart",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_rounded),
                  label: "Account",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
