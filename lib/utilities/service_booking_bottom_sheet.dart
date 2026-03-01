import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:poketstore/controllers/service_booking_controller/service_booking_controller.dart';
import 'package:provider/provider.dart';
import 'package:poketstore/controllers/address_controller/address_controller.dart';
import 'package:poketstore/model/address_model/address_model.dart';
import 'package:poketstore/view/delivery_address/delivery_address.dart';

class ServiceBookingBottomSheet extends StatefulWidget {
  final String serviceId;

  const ServiceBookingBottomSheet({super.key, required this.serviceId});

  @override
  State<ServiceBookingBottomSheet> createState() =>
      _ServiceBookingBottomSheetState();
}

class _ServiceBookingBottomSheetState extends State<ServiceBookingBottomSheet> {
  Address? _selectedDeliveryAddress;

  String _getFormattedAddress(Address? address) {
    if (address == null) return "No address selected.";
    final parts = <String>[];
    if (address.houseNo?.isNotEmpty == true) parts.add(address.houseNo!);
    if (address.area?.isNotEmpty == true) parts.add(address.area!);
    if (address.landmark?.isNotEmpty == true) parts.add(address.landmark!);
    parts.addAll([
      address.town ?? '',
      address.state ?? '',
      address.pincode ?? '',
    ]);
    return parts.where((p) => p.isNotEmpty).join(', ');
  }

  Future<void> _selectAddress() async {
    final selectedId = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      builder:
          (_) => const Padding(
            padding: EdgeInsets.all(16),
            child: DeliveryAddressBottomSheet(),
          ),
    );

    if (selectedId != null) {
      final controller = Provider.of<DeliveryAddressController>(
        context,
        listen: false,
      );

      try {
        final address = controller.addresses.firstWhere(
          (a) => a.id == selectedId,
        );
        setState(() => _selectedDeliveryAddress = address);
      } catch (_) {
        Fluttertoast.showToast(msg: "Address not found");
      }
    }
  }

  Future<void> _bookService() async {
    if (_selectedDeliveryAddress == null) {
      Fluttertoast.showToast(msg: "Please select an address");
      return;
    }

    final controller = context.read<ServiceBookingController>();

    final success = await controller.bookService(
      serviceId: widget.serviceId,
      addressId: _selectedDeliveryAddress!.id!,
    );

    if (success) {
      Fluttertoast.showToast(
        msg:
            controller.bookingResponse?.message ??
            "Service booked successfully",
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
      if (mounted) Navigator.pop(context);
    } else {
      Fluttertoast.showToast(
        msg: controller.errorMessage ?? "Service booking failed",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ServiceBookingController>(
      builder: (context, controller, _) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// 🔹 Drag Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              /// 📍 ADDRESS CARD
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.deepPurple),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Delivery Address",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedDeliveryAddress == null
                                ? "Please select an address."
                                : _getFormattedAddress(
                                  _selectedDeliveryAddress,
                                ),
                            style: TextStyle(
                              color:
                                  _selectedDeliveryAddress == null
                                      ? Colors.red
                                      : Colors.black87,
                              fontStyle:
                                  _selectedDeliveryAddress == null
                                      ? FontStyle.italic
                                      : FontStyle.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: _selectAddress,
                      child: Text(
                        _selectedDeliveryAddress == null ? "Select" : "Change",
                        style: const TextStyle(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// 🛒 BOOK SERVICE BUTTON
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: controller.isLoading ? null : _bookService,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      controller.isLoading
                          ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Text(
                            "Book Service",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
