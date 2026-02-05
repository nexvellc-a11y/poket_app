import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:poketstore/controllers/login_reg_controller/registration_controller.dart';
import 'package:poketstore/view/login/login_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RegistrationProvider>(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0703C9), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: provider.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          "Let's Get Started!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Create an account to get all features',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                        const SizedBox(height: 20),

                        // Input fields including the new email field
                        ..._buildInputFields(provider),

                        // Password fields (only visible before OTP is sent)
                        if (!provider.otpSent) ...[
                          _buildPasswordField(
                            label: "Password",
                            controller: provider.passwordController,
                            hidden: _hidePassword,
                            toggleVisibility:
                                () => setState(
                                  () => _hidePassword = !_hidePassword,
                                ),
                          ),
                          _buildPasswordField(
                            label: "Confirm Password",
                            controller: provider.confirmPasswordController,
                            hidden: _hideConfirmPassword,
                            toggleVisibility:
                                () => setState(
                                  () =>
                                      _hideConfirmPassword =
                                          !_hideConfirmPassword,
                                ),
                            validator: provider.validateConfirmPassword,
                          ),
                        ],

                        // OTP input field (visible after OTP is sent)
                        // if (provider.otpSent) ...[
                        //   Padding(
                        //     padding: const EdgeInsets.symmetric(vertical: 8.0),
                        //     child: TextFormField(
                        //       controller: provider.otpController,
                        //       keyboardType: TextInputType.number,
                        //       decoration: InputDecoration(
                        //         labelText: 'OTP',
                        //         prefixIcon: const Icon(Icons.dialpad),
                        //         border: OutlineInputBorder(
                        //           borderRadius: BorderRadius.circular(10),
                        //         ),
                        //       ),
                        //       validator: provider.validateOtp,
                        //     ),
                        //   ),
                        //   const SizedBox(height: 10),
                        //   Center(
                        //     child:
                        //         provider.otpTimerSeconds > 0
                        //             ? Text(
                        //               "Resend OTP in ${provider.otpTimerSeconds ~/ 60}:${(provider.otpTimerSeconds % 60).toString().padLeft(2, '0')}",
                        //               style: const TextStyle(
                        //                 fontSize: 14,
                        //                 color: Colors.grey,
                        //               ),
                        //             )
                        //             : TextButton(
                        //               onPressed:
                        //                   provider.isLoading
                        //                       ? null
                        //                       : () async {
                        //                         FocusScope.of(context).unfocus();
                        //                         await provider.sendOtp(context);
                        //                       },
                        //               child: const Text("Resend OTP"),
                        //             ),
                        //   ),
                        // ],
                        const SizedBox(height: 20),

                        // Register/Send OTP button
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade900,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed:
                                provider.isLoading
                                    ? null
                                    : () async {
                                      FocusScope.of(context).unfocus();
                                      final success = await provider
                                          .registerUser(context);
                                      if (success) {
                                        // Navigation handled in provider
                                      }
                                    },
                            child:
                                provider.isLoading
                                    ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                    : const Text(
                                      'Register',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Login link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Already have an account?",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => LoginScreen(),
                                  ),
                                  (route) => false,
                                );
                              },
                              child: const Text(
                                "Login here",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
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
          ),
        ),
      ),
    );
  }

  // Helper method to build common input fields
  List<Widget> _buildInputFields(RegistrationProvider provider) {
    // These fields are always visible
    final List<Map<String, dynamic>> alwaysVisibleFields = [
      {
        'label': 'Full Name',
        'icon': Icons.person,
        'controller': provider.nameController,
        'validator': (value) {
          if (value == null || value.isEmpty) {
            return "Please enter your Full Name";
          }
          if (value.length < 4) {
            return "Full Name must be at least 4 characters";
          }
          return null;
        },
      },
      {
        'label': 'Email',
        'icon': Icons.email,
        'controller': provider.emailController,
        'keyboardType': TextInputType.emailAddress,
        'validator': provider.validateEmail,
      },
      {
        'label': 'Mobile Number',
        'icon': Icons.phone_android,
        'controller': provider.mobileController,
        'keyboardType': TextInputType.number,
        'validator': (value) {
          if (value == null || value.isEmpty) {
            return "Please enter your Mobile Number";
          }
          if (value.length < 10) {
            return "Mobile Number must be at least 10 digits";
          }
          return null;
        },
      },
      // {
      //   'label': 'State',
      //   'icon': Icons.place_outlined,
      //   'controller': provider.stateController,
      //   'validator':
      //       (value) =>
      //           (value == null || value.isEmpty)
      //               ? "Please enter your State"
      //               : null,
      // },
      // {
      //   'label': 'District',
      //   'icon': Icons.map_outlined,
      //   'controller': provider.placeController,
      //   'validator':
      //       (value) =>
      //           (value == null || value.isEmpty)
      //               ? "Please enter your District"
      //               : null,
      // },
      // {
      //   'label': 'Locality / Area',
      //   'icon': Icons.location_city,
      //   'controller': provider.localityController,
      //   'validator':
      //       (value) =>
      //           (value == null || value.isEmpty)
      //               ? "Please enter your Locality / Area"
      //               : null,
      // },
      // {
      //   'label': 'Pin Code',
      //   'icon': Icons.pin_outlined,
      //   'controller': provider.pincodeController,
      //   'keyboardType': TextInputType.number,
      //   'validator':
      //       (value) =>
      //           (value == null || value.isEmpty)
      //               ? "Please enter your Pin Code"
      //               : null,
      // },
    ];

    return alwaysVisibleFields.map((field) {
      final FormFieldValidator<String>? customValidator =
          field['validator'] as FormFieldValidator<String>?;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: TextFormField(
          controller: field['controller'] as TextEditingController,
          keyboardType:
              field['keyboardType'] as TextInputType? ?? TextInputType.text,
          textCapitalization:
              (field['label'] == 'Email')
                  ? TextCapitalization.none
                  : TextCapitalization.words,
          decoration: InputDecoration(
            labelText: field['label'] as String,
            prefixIcon: Icon(field['icon'] as IconData),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          validator:
              customValidator ??
              (value) =>
                  (value == null || value.isEmpty)
                      ? "Please enter ${field['label']}"
                      : null,
          // Disable editing if OTP is sent, for all fields except OTP field itself
          readOnly: provider.otpSent && field['label'] != 'OTP',
        ),
      );
    }).toList();
  }

  // Helper method to build password fields
  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool hidden,
    required VoidCallback toggleVisibility,
    FormFieldValidator<String>? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: hidden,
        textCapitalization: TextCapitalization.none,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.lock_outline),
          suffixIcon: IconButton(
            icon: Icon(hidden ? Icons.visibility_off : Icons.visibility),
            onPressed: toggleVisibility,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator:
            validator ??
            (value) {
              if (value == null || value.isEmpty) return "Please enter $label";
              if (label == "Password" && value.length < 6) {
                return "Password must be at least 6 characters";
              }
              return null;
            },
      ),
    );
  }
}
