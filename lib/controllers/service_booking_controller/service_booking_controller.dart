import 'package:flutter/material.dart';
import 'package:poketstore/model/service_booking_model/service_booking_model.dart';
import 'package:poketstore/service/service_booking_service/service_booking_service.dart';

class ServiceBookingController extends ChangeNotifier {
  final ServiceBookingService _service = ServiceBookingService();

  bool isLoading = false;
  String? errorMessage;
  ServiceBookingResponse? bookingResponse;

  Future<bool> bookService({
    required String serviceId,
    required String addressId,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      bookingResponse = await _service.bookService(
        ServiceBookingRequest(serviceId: serviceId, addressId: addressId),
      );
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
