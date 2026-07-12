// // lib/view/login_reg/otp_verification_screen.dart

// import 'package:flutter/material.dart';
// import 'package:poketstore/controllers/login_reg_controller/reg_otp_verification_controller.dart';
// import 'package:provider/provider.dart';
// import 'package:poketstore/view/login/login_screen.dart'; // Assuming you have a login screen

// class OtpVerificationScreen extends StatefulWidget {
//   final String?
//   email; // Optional: To pre-fill email if passed from registration

//   const OtpVerificationScreen({super.key, this.email});

//   @override
//   State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
// }

// class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
//   @override
//   void initState() {
//     super.initState();
//     // Pre-fill email if provided
//     if (widget.email != null) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         Provider.of<OtpVerificationProvider>(context, listen: false)
//             .emailController
//             .text = widget.email!;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<OtpVerificationProvider>(context);

//     return Scaffold(
//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(20),
//             child: Card(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               elevation: 8,
//               child: Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: Form(
//                   key: provider.formKey,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.stretch,
//                     children: [
//                       const Text(
//                         "Verify Your Account",
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontSize: 22,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 5),
//                       const Text(
//                         'Enter the OTP sent to your email address',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(fontSize: 14, color: Colors.black54),
//                       ),
//                       const SizedBox(height: 20),

//                       // Email Input
//                       Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 8.0),
//                         child: TextFormField(
//                           controller: provider.emailController,
//                           keyboardType: TextInputType.emailAddress,
//                           decoration: InputDecoration(
//                             labelText: "Email",
//                             prefixIcon: const Icon(Icons.email),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                           ),
//                           validator: provider.validateEmail,
//                         ),
//                       ),

//                       // OTP Input
//                       Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 8.0),
//                         child: TextFormField(
//                           controller: provider.otpController,
//                           keyboardType: TextInputType.number,
//                           decoration: InputDecoration(
//                             labelText: "OTP",
//                             prefixIcon: const Icon(Icons.dialpad),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                           ),
//                           validator: provider.validateOtp,
//                         ),
//                       ),

//                       const SizedBox(height: 20),

//                       // Verify OTP button
//                       SizedBox(
//                         height: 50,
//                         child: ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.blue.shade900,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                           ),
//                           onPressed:
//                               provider.isLoading
//                                   ? null
//                                   : () {
//                                     FocusScope.of(context).unfocus();
//                                     provider.verifyOtp(context);
//                                   },
//                           child:
//                               provider.isLoading
//                                   ? const CircularProgressIndicator(
//                                     color: Colors.white,
//                                   )
//                                   : const Text(
//                                     'Verify OTP',
//                                     style: TextStyle(
//                                       fontSize: 18,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                         ),
//                       ),

//                       const SizedBox(height: 20),

//                       // Back to Login link
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           const Text(
//                             "Remembered your password?",
//                             style: TextStyle(fontWeight: FontWeight.w600),
//                           ),
//                           TextButton(
//                             onPressed: () {
//                               Navigator.pushAndRemoveUntil(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (_) => LoginScreen(),
//                                 ),
//                                 (route) => false,
//                               );
//                             },
//                             child: const Text(
//                               "Login here",
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.blue,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
