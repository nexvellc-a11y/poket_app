import 'package:flutter/material.dart';
import 'package:poketstore/controllers/forgot_password_controller/reset_password_controller.dart';
import 'package:poketstore/view/login/login_screen.dart';
import 'package:provider/provider.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF0703C9)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0703C9), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Consumer<ResetPasswordProvider>(
            builder: (context, provider, _) {
              return SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 25,
                  right: 25,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                child: Form(
                  key: provider.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      const Text(
                        'Reset Password',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Enter the token you received and set a new password.",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      const SizedBox(height: 30),

                      /// TOKEN
                      TextFormField(
                        controller: provider.tokenController,
                        keyboardType: TextInputType.number,
                        validator: provider.validateToken,
                        decoration: _input("Enter token", Icons.vpn_key),
                      ),

                      const SizedBox(height: 20),

                      /// PASSWORD WITH VISIBILITY
                      TextFormField(
                        controller: provider.passwordController,
                        obscureText: !provider.isPasswordVisible,
                        validator: provider.validatePassword,
                        decoration: _input(
                          "New password",
                          Icons.lock,
                          suffixIcon: IconButton(
                            icon: Icon(
                              provider.isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: provider.togglePasswordVisibility,
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      /// SUBMIT BUTTON
                      GestureDetector(
                        onTap:
                            provider.isLoading
                                ? null
                                : () => provider.submit(context),
                        child: Container(
                          height: 55,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color:
                                provider.isLoading
                                    ? Colors.grey
                                    : const Color(0xFF0703C9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child:
                                provider.isLoading
                                    ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                    : const Text(
                                      "Reset Password",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      /// LOGIN REDIRECT
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Back to "),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => LoginScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              "Login",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0703C9),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  static InputDecoration _input(
    String text,
    IconData icon, {
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: text,
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
