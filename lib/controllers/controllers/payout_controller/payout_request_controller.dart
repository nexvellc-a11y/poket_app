import 'package:flutter/material.dart';
import 'package:poketstore/controllers/model/payout_model/payout_request_model.dart';
import 'package:poketstore/controllers/service/payout_service/payout_request_service.dart';



class PayoutRequestController extends ChangeNotifier {
  final PayoutRequestService _service = PayoutRequestService();

  bool isLoading = false;

  PayoutRequestModel? payoutResponse;

  Future<bool> requestPayout({
    required String paymentMethod,
    required String accountHolderName,
    required String accountNumber,
    required String ifscCode,
    required String bankName,
  }) async {
    isLoading = true;
    notifyListeners();

    payoutResponse = await _service.requestPayout(
      paymentMethod: paymentMethod,
      accountHolderName: accountHolderName,
      accountNumber: accountNumber,
      ifscCode: ifscCode,
      bankName: bankName,
    );

    isLoading = false;
    notifyListeners();

    return payoutResponse?.success ?? false;
  }
}