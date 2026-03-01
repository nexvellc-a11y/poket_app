class ServiceBookingRequest {
  final String serviceId;
  final String addressId;

  ServiceBookingRequest({required this.serviceId, required this.addressId});

  Map<String, dynamic> toJson() {
    return {"serviceId": serviceId, "addressId": addressId};
  }
}

class ServiceBookingResponse {
  final String message;
  final String orderId;
  final int totalAmount;
  final String status;

  ServiceBookingResponse({
    required this.message,
    required this.orderId,
    required this.totalAmount,
    required this.status,
  });

  factory ServiceBookingResponse.fromJson(Map<String, dynamic> json) {
    final order = json["order"];
    return ServiceBookingResponse(
      message: json["message"] ?? "",
      orderId: order["_id"] ?? "",
      totalAmount: order["totalCartAmount"] ?? 0,
      status: order["status"] ?? "",
    );
  }
}
