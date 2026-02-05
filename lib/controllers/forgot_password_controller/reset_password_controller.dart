import 'package:flutter/material.dart';
import 'package:poketstore/model/forgot_password_model/reset_password_model.dart';
import 'package:poketstore/service/forgot_password_service/reset_password_service.dart';

class ResetPasswordProvider extends ChangeNotifier {
  final TextEditingController tokenController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final ResetPasswordService _service = ResetPasswordService();
  bool _isPasswordVisible = false;
  bool get isPasswordVisible => _isPasswordVisible;

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  String? validateToken(String? value) {
    if (value == null || value.isEmpty) {
      return "Token is required";
    }
    if (value.length < 4) {
      return "Invalid token";
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Password is required";
    }
    if (value.length < 6) {
      return "Password must be at least 6 characters";
    }
    return null;
  }

  Future<void> submit(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    _isLoading = true;
    notifyListeners();

    try {
      final ResetPasswordModel response = await _service.resetPassword(
        token: tokenController.text.trim(),
        newPassword: passwordController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor: Colors.green,
        ),
      );

      tokenController.clear();
      passwordController.clear();

      Future.delayed(const Duration(seconds: 2), () {
        Navigator.popUntil(context, (route) => route.isFirst);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    tokenController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
