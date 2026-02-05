import 'package:flutter/material.dart';
import 'package:poketstore/controllers/address_controller/address_controller.dart';
import 'package:poketstore/model/address_model/address_model.dart';
import 'package:poketstore/view/delivery_address/add_address.dart';
import 'package:provider/provider.dart';

class DeliveryAddressBottomSheet extends StatefulWidget {
  const DeliveryAddressBottomSheet({super.key});

  @override
  State<DeliveryAddressBottomSheet> createState() =>
      _DeliveryAddressBottomSheetState();
}

class _DeliveryAddressBottomSheetState
    extends State<DeliveryAddressBottomSheet> {
  String? selectedAddressId;
  Address? currentlySelectedAddress;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DeliveryAddressController>(
        context,
        listen: false,
      ).fetchAddresses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<DeliveryAddressController>(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: SafeArea(
        child: Column(
          children: [
            const Text(
              "Select Delivery Address",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            /// Loader / Error / Empty / List
            Expanded(
              child:
                  controller.loading
                      ? const Center(child: CircularProgressIndicator())
                      : controller.errorMessage != null
                      ? Center(
                        child: Text(
                          // "Error: ${controller.errorMessage}",
                          'No Address Found',
                          style: const TextStyle(color: Colors.red),
                        ),
                      )
                      : controller.addresses.isEmpty
                      ? const Center(
                        child: Text(
                          "No addresses found. Please add a new one.",
                        ),
                      )
                      : ListView.separated(
                        itemCount: controller.addresses.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final address = controller.addresses[index];

                          final label = [
                            if (address.houseNo?.isNotEmpty ?? false)
                              address.houseNo,
                            if (address.area?.isNotEmpty ?? false) address.area,
                            if (address.town?.isNotEmpty ?? false) address.town,
                            if (address.state?.isNotEmpty ?? false)
                              address.state,
                            if (address.pincode?.isNotEmpty ?? false)
                              address.pincode,
                          ].whereType<String>().join(', ');

                          final subtitleParts = <String>[];
                          if (address.phoneNumber?.isNotEmpty ?? false) {
                            subtitleParts.add(address.phoneNumber!);
                          }
                          if (address.landmark?.isNotEmpty ?? false) {
                            subtitleParts.add(address.landmark!);
                          }
                          final subtitle = subtitleParts.join(' • ');

                          return Card(
                            elevation: selectedAddressId == address.id ? 4 : 1,
                            margin: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color:
                                    selectedAddressId == address.id
                                        ? Colors.deepPurple
                                        : Colors.grey.shade300,
                                width: selectedAddressId == address.id ? 2 : 1,
                              ),
                            ),
                            color:
                                selectedAddressId == address.id
                                    ? Colors.deepPurple.shade50
                                    : Theme.of(context).cardColor,
                            child: RadioListTile<String>(
                              value: address.id!,
                              groupValue: selectedAddressId,
                              onChanged: (value) {
                                setState(() {
                                  selectedAddressId = value;
                                  currentlySelectedAddress = address;
                                });
                              },
                              title: Text(
                                label,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle:
                                  subtitle.isNotEmpty
                                      ? Text(
                                        subtitle,
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                        ),
                                      )
                                      : null,
                              activeColor: Colors.deepPurple,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              secondary: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () async {
                                      await Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder:
                                              (_) =>
                                                  AddressForm(address: address),
                                        ),
                                      );
                                      if (mounted) {
                                        Provider.of<DeliveryAddressController>(
                                          // ignore: use_build_context_synchronously
                                          context,
                                          listen: false,
                                        ).fetchAddresses();
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () async {
                                      final confirmDelete =
                                          await showDialog<bool>(
                                            context: context,
                                            builder:
                                                (_) => AlertDialog(
                                                  title: const Text(
                                                    "Confirm Deletion",
                                                  ),
                                                  content: const Text(
                                                    "Are you sure you want to delete this address?",
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed:
                                                          () => Navigator.of(
                                                            context,
                                                          ).pop(false),
                                                      child: const Text(
                                                        "Cancel",
                                                      ),
                                                    ),
                                                    TextButton(
                                                      onPressed:
                                                          () => Navigator.of(
                                                            context,
                                                          ).pop(true),
                                                      child: const Text(
                                                        "Delete",
                                                        style: TextStyle(
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                          ) ??
                                          false;

                                      if (confirmDelete && address.id != null) {
                                        await controller.deleteAddress(
                                          address.id!,
                                        );
                                        if (mounted) {
                                          controller.fetchAddresses();
                                        }
                                        if (controller.errorMessage != null &&
                                            mounted) {
                                          ScaffoldMessenger.of(
                                            // ignore: use_build_context_synchronously
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                controller.errorMessage!,
                                              ),
                                            ),
                                          );
                                        } else if (mounted) {
                                          ScaffoldMessenger.of(
                                            // ignore: use_build_context_synchronously
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                "Address deleted successfully",
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),

            const SizedBox(height: 16),

            /// Add New Address
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AddressForm()),
                      );
                      if (mounted) {
                        Provider.of<DeliveryAddressController>(
                          // ignore: use_build_context_synchronously
                          context,
                          listen: false,
                        ).fetchAddresses();
                      }
                    },
                    icon: const Icon(Icons.add, color: Colors.deepPurple),
                    label: const Text(
                      "Add New Address",
                      style: TextStyle(color: Colors.deepPurple),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.deepPurple),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// Confirm Selection
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    selectedAddressId != null
                        ? () {
                          Navigator.pop(context, currentlySelectedAddress?.id);
                        }
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 7, 3, 201),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Confirm Selection",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 8),

            /// Close
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close", style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }
}
