import 'package:flutter/material.dart';
import 'package:poketstore/model/forgot_password_model/forgot_password_model.dart';
import 'package:poketstore/service/forgot_password_service/forgot_password_service.dart';
import 'package:poketstore/view/forgote_password.dart/reset_password.dart';

class ForgotPasswordProvider extends ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final ForgotPasswordService _service = ForgotPasswordService();

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Email is required";
    }
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!regex.hasMatch(value)) {
      return "Enter a valid email";
    }
    return null;
  }

  Future<void> sendResetLink(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    _isLoading = true;
    notifyListeners();

    try {
      final ForgotPasswordModel response = await _service.forgotPassword(
        emailController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor: Colors.green,
        ),
      );

      emailController.clear();

      /// ✅ Navigate to Reset Password screen AFTER success
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ResetPasswordScreen()),
        );
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
    emailController.dispose();
    super.dispose();
  }
}
