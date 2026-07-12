import 'package:flutter/material.dart';
import 'package:poketstore/controllers/forgot_password_controller/forgot_password_controller.dart';
import 'package:poketstore/view/login/login_screen.dart';
import 'package:provider/provider.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

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
          child: Consumer<ForgotPasswordProvider>(
            builder: (context, provider, _) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Form(
                  key: provider.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),

                      const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        "Enter your registered email address. We’ll send you a code.",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 30),

                      /// EMAIL FIELD
                      TextFormField(
                        controller: provider.emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: provider.validateEmail,
                        decoration: _inputDecoration(
                          "Enter your email",
                          Icons.email,
                        ),
                      ),

                      const SizedBox(height: 30),

                      /// SEND LINK BUTTON
                      GestureDetector(
                        onTap:
                            provider.isLoading
                                ? null
                                : () => provider.sendResetLink(context),
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
                                      "Reset code send to your Email",
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
                          const Text("Remember password? "),
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

  static InputDecoration _inputDecoration(String text, IconData icon) {
    return InputDecoration(
      labelText: text,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
