import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:poketstore/controllers/model/payout_model/payout_request_model.dart';
import 'package:poketstore/network/dio_network_service.dart';

class PayoutRequestService {
  Future<PayoutRequestModel> requestPayout({
    required String paymentMethod,
    required String accountHolderName,
    required String accountNumber,
    required String ifscCode,
    required String bankName,
  }) async {
    try {
      final response = await DioNetworkService.dio.post(
        "https://api.poketstor.com/api/user/payout/request",
        data: {
          "paymentMethod": paymentMethod,
          "accountHolderName": accountHolderName,
          "accountNumber": accountNumber,
          "ifscCode": ifscCode,
          "bankName": bankName,
        },
      );

      log(response.data.toString());

      return PayoutRequestModel.fromJson(response.data);
    } on DioException catch (e) {
      log(e.response?.data.toString() ?? e.toString());

      if (e.response != null) {
        return PayoutRequestModel.fromJson(e.response!.data);
      }

      return PayoutRequestModel(
        success: false,
        message: "Something went wrong",
      );
    } catch (e) {
      log(e.toString());

      return PayoutRequestModel(
        success: false,
        message: e.toString(),
      );
    }
  }
}