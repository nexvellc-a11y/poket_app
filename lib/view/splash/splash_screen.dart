import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:poketstore/controllers/login_reg_controller/login_controller.dart';
import 'package:poketstore/view/bottombar/bottom_bar_screen.dart';
import 'package:poketstore/view/login/login_screen.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateBasedOnLogin();
    });
  }

  Future<void> _navigateBasedOnLogin() async {
    await Future.delayed(const Duration(seconds: 2));

    final loginProvider = Provider.of<LoginProvider>(context, listen: false);

    final isLoggedIn = await loginProvider.isUserLoggedIn();

    if (!mounted) return;

    if (isLoggedIn) {
      // ✅ Token exists → Go to Home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => BottomBarScreen()),
      );
    } else {
      // ❌ Token missing → Go to Login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
        body: Center(
          child: RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
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
        ),
      ),
    );
  }
}
