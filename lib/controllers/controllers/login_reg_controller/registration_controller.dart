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
  final TextEditingController referredCodeController = TextEditingController();

  // Selected values for dropdowns
  String? _selectedState;
  String? _selectedDistrict;

  String? get selectedState => _selectedState;
  String? get selectedDistrict => _selectedDistrict;

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

  // Setter methods for dropdown values
  void setSelectedState(String? state) {
    _selectedState = state;
    notifyListeners();
  }

  void setSelectedDistrict(String? district) {
    _selectedDistrict = district;
    notifyListeners();
  }

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

  Future<bool> registerUser(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      log("Form validation failed for registration");
      return false;
    }

    // Validate state and district selection
    if (_selectedState == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select your State")),
      );
      return false;
    }

    if (_selectedDistrict == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select your District")),
      );
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
        "state": _selectedState!, // Use selected state from dropdown
        "district": _selectedDistrict!, // Use selected district from dropdown
        "password": passwordController.text.trim(),
        "fcmToken": fcmToken,
        "referredCode": referredCodeController.text.trim().isNotEmpty 
            ? referredCodeController.text.trim() 
            : null,
      };

      log("📤 Registration Request Body: ${userData.toString()}");

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
            content: Text("Registration successful! Welcome, ${registeredUser.name}."),
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
    await prefs.setString('district', user.district); // Save district
    await prefs.setString('email', user.email);
    if (user.fcmToken != null) {
      await prefs.setString('fcmToken', user.fcmToken!);
    }
    if (user.referredCode != null) {
      await prefs.setString('referredCode', user.referredCode!);
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
    referredCodeController.dispose();
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
    referredCodeController.clear();
    _selectedState = null;
    _selectedDistrict = null;
    notifyListeners();
  }
}