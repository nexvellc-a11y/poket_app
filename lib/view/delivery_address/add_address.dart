import 'package:flutter/material.dart';
import 'package:poketstore/controllers/address_controller/address_controller.dart';
import 'package:poketstore/model/address_model/address_model.dart';
import 'package:provider/provider.dart';

class AddressForm extends StatefulWidget {
  final Address? address;

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
        countryName: "India",
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(controller.errorMessage!),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } else {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.address == null
                  ? "Address added successfully"
                  : "Address updated successfully",
            ),
            backgroundColor: Colors.green.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<DeliveryAddressController>(context);
    final isEditing = widget.address != null;

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: const Color(0xFF1E293B),
          title: Text(
            isEditing ? "Edit Address" : "Add New Address",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          centerTitle: false,
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.close_rounded, size: 22),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Header Card with Icon
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.deepPurple.shade400,
                        Colors.deepPurple.shade700,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurple.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.location_on_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        isEditing
                            ? "Update Your Address"
                            : "Enter Delivery Address",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Please fill in your complete address details",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Form Card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Contact Information Section
                          _buildSectionTitle(
                            "Contact Information",
                            Icons.phone_rounded,
                          ),
                          const SizedBox(height: 16),
                          _buildAnimatedTextField(
                            controller: _phoneController,
                            label: "Phone Number",
                            icon: Icons.phone_rounded,
                            keyboardType: TextInputType.phone,
                            validator:
                                (val) =>
                                    val == null || val.isEmpty
                                        ? "Phone number is required"
                                        : null,
                          ),

                          const SizedBox(height: 24),

                          // Address Details Section
                          _buildSectionTitle(
                            "Address Details",
                            Icons.home_rounded,
                          ),
                          const SizedBox(height: 16),

                          _buildAnimatedTextField(
                            controller: _houseController,
                            label: "House No. / Building Name",
                            icon: Icons.house_rounded,
                            textCapitalization: TextCapitalization.words,
                          ),

                          const SizedBox(height: 16),

                          _buildAnimatedTextField(
                            controller: _areaController,
                            label: "Area / Street",
                            icon: Icons.streetview_rounded,
                            textCapitalization: TextCapitalization.words,
                            validator:
                                (val) =>
                                    val == null || val.isEmpty
                                        ? "Area is required"
                                        : null,
                          ),

                          const SizedBox(height: 16),

                          _buildAnimatedTextField(
                            controller: _landmarkController,
                            label: "Landmark (Optional)",
                            icon: Icons.landscape_rounded,
                            textCapitalization: TextCapitalization.words,
                          ),

                          const SizedBox(height: 24),

                          // Location Section
                          _buildSectionTitle(
                            "Location",
                            Icons.pin_drop_rounded,
                          ),
                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: _buildAnimatedTextField(
                                  controller: _pincodeController,
                                  label: "Pincode",
                                  icon: Icons.pin_rounded,
                                  keyboardType: TextInputType.number,
                                  validator:
                                      (val) =>
                                          val == null || val.isEmpty
                                              ? "Required"
                                              : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 3,
                                child: _buildAnimatedTextField(
                                  controller: _townController,
                                  label: "Town / City",
                                  icon: Icons.location_city_rounded,
                                  textCapitalization: TextCapitalization.words,
                                  validator:
                                      (val) =>
                                          val == null || val.isEmpty
                                              ? "Required"
                                              : null,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          _buildAnimatedTextField(
                            controller: _stateController,
                            label: "State",
                            icon: Icons.map_rounded,
                            textCapitalization: TextCapitalization.words,
                            validator:
                                (val) =>
                                    val == null || val.isEmpty
                                        ? "State is required"
                                        : null,
                          ),

                          const SizedBox(height: 32),

                          // Submit Button
                          if (controller.loading)
                            const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.deepPurple,
                                ),
                              ),
                            )
                          else
                            Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.deepPurple.shade400,
                                    Colors.deepPurple.shade700,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.deepPurple.withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _submitAddress,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      isEditing
                                          ? Icons.update_rounded
                                          : Icons.save_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      isEditing
                                          ? "Update Address"
                                          : "Save Address",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.deepPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: Colors.deepPurple),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        validator: validator,
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: Colors.deepPurple),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.deepPurple.shade400, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.red.shade300, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.red.shade400, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
