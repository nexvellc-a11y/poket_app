import 'package:flutter/material.dart';
import 'package:poketstore/model/otp_model/verify_otp_model.dart';
import 'package:poketstore/service/otp_service/verify_otp_service.dart';

class VerifyOtpController extends ChangeNotifier {
  final VerifyOtpService _service = VerifyOtpService();

  VerifyOtpResponse? verifyOtpResponse;
  bool isLoading = false;

  Future<void> verifyOtp({
    required String mobileNumber,
    required String otp,
    required String verificationId,
  }) async {
    isLoading = true;
    notifyListeners();

    verifyOtpResponse = await _service.verifyOtp(
      mobileNumber: mobileNumber,
      otp: otp,
      verificationId: verificationId,
    );

    isLoading = false;
    notifyListeners();
  }
}
