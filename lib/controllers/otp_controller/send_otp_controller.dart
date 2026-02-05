import 'package:flutter/material.dart';
import 'package:poketstore/model/otp_model/send_otp_model.dart';
import 'package:poketstore/service/otp_service/send_otp_service.dart';

class SendOtpController extends ChangeNotifier {
  final SendOtpService _service = SendOtpService();

  SendOtpResponse? otpResponse;
  bool isLoading = false;

  Future<void> sendOtp(String mobileNumber) async {
    isLoading = true;
    notifyListeners();

    otpResponse = await _service.sendOtp(mobileNumber);

    isLoading = false;
    notifyListeners();
  }
}
