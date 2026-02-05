import 'package:flutter/material.dart';
import 'package:poketstore/controllers/address_controller/address_controller.dart';
import 'package:poketstore/model/address_model/address_model.dart';
import 'package:provider/provider.dart';

class AddressForm extends StatefulWidget {
  final Address? address; // Optional Address object for editing

  const AddressForm({super.key, this.address});

  @override
  State<AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends State<AddressForm> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _houseController = TextEditingController();
  final _areaController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _townController = TextEditingController();
  final _stateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill form fields if editing an address
    if (widget.address != null) {
      _phoneController.text = widget.address!.phoneNumber ?? '';
      _houseController.text = widget.address!.houseNo ?? '';
      _areaController.text = widget.address!.area ?? '';
      _landmarkController.text = widget.address!.landmark ?? '';
      _pincodeController.text = widget.address!.pincode ?? '';
      _townController.text = widget.address!.town ?? '';
      _stateController.text = widget.address!.state ?? '';
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _houseController.dispose();
    _areaController.dispose();
    _landmarkController.dispose();
    _pincodeController.dispose();
    _townController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  void _submitAddress() async {
    if (_formKey.currentState!.validate()) {
      final address = Address(
        countryName: "India", // Default
        phoneNumber: _phoneController.text,
        houseNo: _houseController.text.isEmpty ? null : _houseController.text,
        area: _areaController.text,
        landmark:
            _landmarkController.text.isEmpty ? null : _landmarkController.text,
        pincode: _pincodeController.text,
        town: _townController.text,
        state: _stateController.text,
        id: widget.address?.id,
      );

      final controller = Provider.of<DeliveryAddressController>(
        context,
        listen: false,
      );

      if (widget.address == null) {
        await controller.submitAddress(address);
      } else {
        await controller.updateAddress(widget.address!.id!, address);
      }

      if (!mounted) return;

      if (controller.errorMessage != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(controller.errorMessage!)));
      } else {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.address == null
                  ? "Address added successfully"
                  : "Address updated successfully",
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<DeliveryAddressController>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.address == null ? "Add New Address" : "Edit Address",
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: "Phone Number"),
                keyboardType: TextInputType.phone,
                validator:
                    (val) => val == null || val.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _houseController,
                decoration: const InputDecoration(labelText: "House No/Name"),
                textCapitalization:
                    TextCapitalization.words, // ✅ Capitalize first letter
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _areaController,
                decoration: const InputDecoration(labelText: "Area"),
                textCapitalization: TextCapitalization.words, // ✅
                validator:
                    (val) => val == null || val.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _landmarkController,
                decoration: const InputDecoration(labelText: "Landmark"),
                textCapitalization: TextCapitalization.words, // ✅
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _pincodeController,
                decoration: const InputDecoration(labelText: "Pincode"),
                keyboardType: TextInputType.number,
                validator:
                    (val) => val == null || val.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _townController,
                decoration: const InputDecoration(labelText: "Town"),
                textCapitalization: TextCapitalization.words, // ✅
                validator:
                    (val) => val == null || val.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _stateController,
                decoration: const InputDecoration(labelText: "State"),
                textCapitalization: TextCapitalization.words, // ✅
                validator:
                    (val) => val == null || val.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 20),
              controller.loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: _submitAddress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      widget.address == null
                          ? "Save Address"
                          : "Update Address",
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
