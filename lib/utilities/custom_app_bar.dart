import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:poketstore/controllers/cart_controller/cart_controller.dart';
import 'package:poketstore/controllers/notification_controller.dart/notification_controller.dart';
import 'package:poketstore/view/add_shop/shope_list_screen.dart';
import 'package:poketstore/view/bottombar/bottom_bar_screen.dart';
import 'package:poketstore/view/cart_screen/cart_screen.dart';
import 'package:poketstore/view/notification/notification.dart';
import 'package:provider/provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBackButton;
  final String? title;

  const CustomAppBar({super.key, this.showBackButton = false, this.title});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(
      context,
      listen: true,
    );
    final cartController = Provider.of<CartController>(context, listen: true);

    final unreadCount = notificationProvider.unreadCount;
    final cartItemCount = cartController.itemCount;

    return AppBar(
      automaticallyImplyLeading: showBackButton,
      leading:
          showBackButton
              ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.of(context).pop(),
              )
              : null,
      backgroundColor: Colors.transparent,
      elevation: 0,

      // 🎨 Gradient applied here
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0703C9), Color.fromARGB(255, 114, 169, 240)],
          ),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      title:
          title != null
              ? Text(
                title!,
                style: GoogleFonts.poppins(
                  color: Colors.white, // #0B63CE color
                  fontSize: 20,
                  fontWeight: FontWeight.w700, // 700 weight
                ),
              )
              : RichText(
                text: TextSpan(
                  style: GoogleFonts.poppins(
                    fontSize: 23,
                    fontWeight: FontWeight.w700,
                  ),
                  children: [
                    TextSpan(
                      text: 'Poket',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(
                      text: 'Stor',
                      style: GoogleFonts.poppins(
                        color: Color(0xFFFFEA00),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      actions: [
        // --- Cart Icon with Badge ---
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(
                Icons.shopping_cart_outlined,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                );
              },
            ),
            if (cartItemCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    cartItemCount > 9 ? '9+' : cartItemCount.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),

        // --- Shop Icon ---
        IconButton(
          icon: const Icon(Icons.add_business_outlined, color: Colors.white),
          onPressed:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ShopListScreen()),
              ),
        ),

        // --- Notifications Icon with Badge ---
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(
                Icons.notifications_none_sharp,
                color: Colors.white,
              ),
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationScreen(),
                    ),
                  ),
            ),
            if (unreadCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    unreadCount > 9 ? '9+' : unreadCount.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
