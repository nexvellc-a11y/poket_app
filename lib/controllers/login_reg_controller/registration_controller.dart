import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:poketstore/model/login_reg_model/reg_model.dart';
import 'package:poketstore/service/login_reg_service.dart/reg_service.dart';
import 'package:poketstore/service/notification(fcm)_service.dart/notification(fcm)_service.dart';
import 'package:poketstore/view/bottombar/bottom_bar_screen.dart';
import 'package:poketstore/view/login/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegistrationProvider extends ChangeNotifier {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController placeController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController localityController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController otpController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final bool _otpSent = false;
  bool get otpSent => _otpSent;

  final int _otpTimerSeconds = 0;
  int get otpTimerSeconds => _otpTimerSeconds;

  Timer? _timer;

  final RegistrationService _registrationService = RegistrationService();
  final FirebasePushService _firebasePushService = FirebasePushService();

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Please confirm your password";
    }
    if (value != passwordController.text) {
      return "Passwords do not match";
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your Email";
    }
    final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegExp.hasMatch(value)) {
      return "Please enter a valid email address";
    }
    return null;
  }

  String? validateOtp(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter the OTP";
    }
    if (value.length != 6) {
      return "OTP must be 6 digits";
    }
    return null;
  }

  // void startOtpTimer() {
  //   _otpTimerSeconds = 300; // 5 minutes
  //   _timer?.cancel(); // Cancel any existing timer
  //   _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
  //     if (_otpTimerSeconds > 0) {
  //       _otpTimerSeconds--;
  //       notifyListeners();
  //     } else {
  //       _timer?.cancel();
  //       _otpSent = false; // Allow re-sending OTP
  //       notifyListeners();
  //     }
  //   });
  //   notifyListeners();
  // }

  // Future<bool> sendOtp(BuildContext context) async {
  //   // Validate only relevant fields for sending OTP
  //   // For now, let's assume all fields are validated.
  //   // If you want to validate only email before sending OTP,
  //   // you might need a separate form key or manual validation for email.
  //   if (!formKey.currentState!.validate()) {
  //     log("Form validation failed for sending OTP");
  //     return false;
  //   }

  //   _isLoading = true;
  //   notifyListeners();
  //   log("Attempting to send OTP for registration...");

  //   try {
  //     await _firebasePushService.init(context);
  //     String? fcmToken = await _firebasePushService.getToken();
  //     log("Retrieved FCM Token for registration: $fcmToken");

  //     final Map<String, dynamic> userData = {
  //       "name": nameController.text.trim(),
  //       "mobileNumber": mobileController.text.trim(),
  //       "email": emailController.text.trim(),
  //       // "state": stateController.text.trim(),
  //       // "place": placeController.text.trim(),
  //       "pincode": pincodeController.text.trim(),
  //       // "locality": localityController.text.trim(),
  //       "password": passwordController.text.trim(),
  //       "fcmToken": fcmToken,
  //     };

  //     // Call the existing registerUser method, which now returns void
  //     await _registrationService.registerUser(userData);

  //     log("OTP sent successfully to: ${emailController.text.trim()}");
  //     _otpSent = true;
  //     startOtpTimer(); // Start the timer after OTP is sent

  //     if (context.mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(
  //             "OTP sent to ${emailController.text.trim()}. Please check your email.",
  //           ),
  //           backgroundColor: Colors.green,
  //         ),
  //       );
  //     }
  //     return true;
  //   } catch (e) {
  //     _otpSent = false; // Reset if sending fails
  //     log("Send OTP Error: $e");
  //     if (context.mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(
  //             "Failed to send OTP. Please try again. Error: ${e.toString()}",
  //           ),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //     return false;
  //   } finally {
  //     _isLoading = false;
  //     notifyListeners();
  //   }
  // }

  // Future<bool> verifyOtpAndRegister(BuildContext context) async {
  //   // Validate only OTP field for verification
  //   if (otpController.text.isEmpty || validateOtp(otpController.text) != null) {
  //     log("OTP validation failed.");
  //     // Manually show error for OTP field if needed, or rely on TextFormField validator
  //     return false;
  //   }

  //   _isLoading = true;
  //   notifyListeners();
  //   log("Attempting to verify OTP and complete registration...");

  //   try {
  //     final String email = emailController.text.trim();
  //     final String otp = otpController.text.trim();

  //     // This method (verifyOtp) is expected to return a map containing user data and token
  //     final Map<String, dynamic> responseData = await _registrationService
  //         .verifyOtp(email, otp);

  //     log("OTP verification successful: $responseData");

  //     // Now, parse the responseData into RegistrationModel
  //     final RegistrationModel registeredUser = RegistrationModel.fromJson(
  //       responseData,
  //     );

  //     await _saveUserData(registeredUser);

  //     _timer?.cancel(); // Cancel the timer on successful registration
  //     _otpSent = false; // Reset OTP state

  //     if (context.mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(
  //             "Registration successful! Welcome, ${registeredUser.name}.",
  //           ),
  //           backgroundColor: Colors.green,
  //         ),
  //       );
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (context) => BottomBarScreen()),
  //       );
  //     }
  //     return true;
  //   } catch (e) {
  //     log("Verify OTP and Registration Error: $e");
  //     if (context.mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(
  //             "OTP verification failed. Please try again. Error: ${e.toString()}",
  //           ),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //     return false;
  //   } finally {
  //     _isLoading = false;
  //     notifyListeners();
  //   }
  // }

  Future<bool> registerUser(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      log("Form validation failed for registration");
      return false;
    }

    _isLoading = true;
    notifyListeners();
    log("Attempting to register user...");

    try {
      await _firebasePushService.init(context);
      String? fcmToken = await _firebasePushService.getToken();
      log("Retrieved FCM Token for registration: $fcmToken");

      final Map<String, dynamic> userData = {
        "name": nameController.text.trim(),
        "mobileNumber": mobileController.text.trim(),
        "email": emailController.text.trim(),
        // "pincode": pincodeController.text.trim(),
        "password": passwordController.text.trim(),
        "fcmToken": fcmToken,
      };

      // Directly register user (no OTP)
      final Map<String, dynamic> responseData = await _registrationService
          .registerUser(userData);

      log("Registration successful: $responseData");

      final RegistrationModel registeredUser = RegistrationModel.fromJson(
        responseData,
      );

      await _saveUserData(registeredUser);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Registration successful! , ${registeredUser.name}."),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
      return true;
    } catch (e) {
      log("Registration Error: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Registration failed. Please try again. Error: ${e.toString()}",
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveUserData(RegistrationModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', user.token);
    await prefs.setString('userId', user.id);
    await prefs.setString('name', user.name);
    await prefs.setString('mobileNumber', user.mobileNumber);
    await prefs.setString('state', user.state);
    await prefs.setString('place', user.place);
    await prefs.setString('email', user.email);
    // await prefs.setString('pincode', user.pincode);
    await prefs.setString('locality', user.locality);
    if (user.fcmToken != null) {
      await prefs.setString('fcmToken', user.fcmToken!);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    nameController.dispose();
    mobileController.dispose();
    stateController.dispose();
    placeController.dispose();
    pincodeController.dispose();
    passwordController.dispose();
    emailController.dispose();
    localityController.dispose();
    confirmPasswordController.dispose();
    otpController.dispose();
    super.dispose();
  }

  void clearTextFields() {
    emailController.clear();
    nameController.clear();
    mobileController.clear();
    stateController.clear();
    placeController.clear();
    localityController.clear();
    pincodeController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    otpController.clear();
  }
}
