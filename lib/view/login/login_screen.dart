import 'package:flutter/material.dart';
import 'package:poketstore/controllers/login_reg_controller/login_controller.dart';
import 'package:provider/provider.dart';
import 'package:poketstore/view/forgote_password.dart/forgote_password.dart';
import 'package:poketstore/view/reg/registration.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _initialLoading = true;

  @override
  void initState() {
    super.initState();

    // 2-second delay on screen entry
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _initialLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final loginProvider = context.watch<LoginProvider>();

    return Scaffold(
      body:
          _initialLoading
              ? const Center(child: CircularProgressIndicator())
              : Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0703C9), Colors.white],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: SingleChildScrollView(
                    child: Form(
                      key: loginProvider.formKey,
                      child: Column(
                        children: [
                          const SizedBox(height: 20),

                          RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                fontSize: 60,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Poket',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Aparajita',
                                  ),
                                ),
                                TextSpan(
                                  text: 'Stor',
                                  style: TextStyle(
                                    color: Color(0xFFFFEA00),
                                    fontFamily: 'Aparajita',
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 5),
                          const Text(
                            'Welcome back!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.white70,
                            ),
                          ),

                          const SizedBox(height: 25),

                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 25,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 15,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                TextFormField(
                                  controller:
                                      loginProvider.mobileNumberController,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(Icons.phone_android),
                                    labelText: "Mobile Number",
                                    filled: true,
                                    fillColor: Colors.grey.shade100,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  validator:
                                      (value) =>
                                          value == null || value.trim().isEmpty
                                              ? 'Mobile number is required'
                                              : null,
                                ),

                                const SizedBox(height: 20),

                                TextFormField(
                                  controller: loginProvider.passwordController,
                                  obscureText: !loginProvider.isPasswordVisible,
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(
                                      Icons.lock_outline_rounded,
                                    ),
                                    labelText: "Password",
                                    filled: true,
                                    fillColor: Colors.grey.shade100,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        loginProvider.isPasswordVisible
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                      ),
                                      onPressed:
                                          loginProvider
                                              .togglePasswordVisibility,
                                    ),
                                  ),
                                  validator:
                                      (value) =>
                                          value == null || value.trim().isEmpty
                                              ? 'Password is required'
                                              : null,
                                ),

                                const SizedBox(height: 10),

                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) => ForgotPasswordScreen(),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Forgot Password?',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0703C9),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 10),

                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      loginProvider.login(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0703C9),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child:
                                        loginProvider.isLoading
                                            ? const CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                            )
                                            : const Text(
                                              'Login',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Don't have an account?",
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => RegistrationScreen(),
                                    ),
                                    (route) => false,
                                  );
                                },
                                child: const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0703C9),
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
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
