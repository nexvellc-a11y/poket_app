import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:poketstore/model/login_reg_model/login_model.dart';
import 'package:poketstore/service/login_reg_service.dart/login_service.dart';
import 'package:poketstore/view/bottombar/bottom_bar_screen.dart';
import 'package:poketstore/view/splash/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginProvider extends ChangeNotifier {
  final TextEditingController mobileNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _isInitialLoading = false;

  bool get isPasswordVisible => _isPasswordVisible;
  bool get isLoading => _isLoading;
  bool get isInitialLoading => _isInitialLoading;

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    return token != null && token.isNotEmpty;
  }

  /// 🔥 Called when LoginScreen opens
  Future<void> initLogin(BuildContext context) async {
    _isInitialLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      if (token != null && token.isNotEmpty) {
        log("User already logged in");

        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => BottomBarScreen()),
        );
      }
    } catch (e) {
      log("Init login error: $e");
    } finally {
      _isInitialLoading = false;
      notifyListeners();
    }
  }

  /// ✅ Login User
  Future<void> login(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    _isLoading = true;
    notifyListeners();

    try {
      final loginService = LoginService();

      final response = await loginService.loginUser(
        mobileNumberController.text.trim(),
        passwordController.text.trim(),
      );

      final loginModel = LoginModel.fromJson(response);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', loginModel.accessToken);
      await prefs.setString('refreshToken', loginModel.refreshToken);
      await prefs.setString('userId', loginModel.user.id);
      await prefs.setString('role', loginModel.user.role);

      mobileNumberController.clear();
      passwordController.clear();

      _isLoading = false;
      notifyListeners();

      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => BottomBarScreen()),
      );

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Login successful!")));
    } catch (e) {
      _isLoading = false;
      notifyListeners();

      log("Login Error: $e");

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login failed. Please try again.")),
      );
    }
  }

  /// 🔓 Logout
  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    notifyListeners();

    log("User logged out");

    // ignore: use_build_context_synchronously
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => SplashScreen()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    mobileNumberController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
