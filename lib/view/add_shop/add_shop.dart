import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:poketstore/controllers/add_shop_controller/add_shop_controller.dart';
import 'package:poketstore/controllers/add_shop_controller/all_shop_controller.dart';
import 'package:poketstore/controllers/category_controller/category_controller.dart';
import 'package:poketstore/controllers/otp_controller/send_otp_controller.dart';
import 'package:poketstore/controllers/otp_controller/verify_otp_controller.dart';
import 'package:poketstore/controllers/product_search_controller/district_search_controller.dart';
import 'package:poketstore/controllers/product_search_controller/state_search_controller.dart';
import 'package:poketstore/model/add_shope_model/add_shop_model.dart';
import 'package:poketstore/model/my_shope_model/shope_details_model.dart';
import 'package:poketstore/utilities/image_crop_screen_shop.dart';
import 'package:poketstore/view/add_shop/widget/capitalization.dart';
import 'package:poketstore/view/subscription/subscription.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../../controllers/home_product_controller/home_product_controller.dart';
import '../../controllers/shop_of_user_controller/shop_of_user_controller.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class AddShop extends StatefulWidget {
  final ShopeDetailsModel? shopToEdit;

  const AddShop({super.key, this.shopToEdit});

  @override
  State<AddShop> createState() => _AddShopState();
}

class _AddShopState extends State<AddShop> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _shopNameController =
      CapitalizingTextController();
  final TextEditingController _placeController = CapitalizingTextController();
  final TextEditingController _pinCodeController = TextEditingController();
  final TextEditingController _localityController =
      CapitalizingTextController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _landlineNumberController =
      TextEditingController();
  final TextEditingController _agentCodeController = TextEditingController();

  final List<String> sellerTypes = ["Manufacturer", "Wholesaler", "Retailer"];

  String? _selectedSellerType;
  String? _selectedState;
  String? _selectedDistrict;
  String? _selectedCategory;
  File? _headerImage;
  String? _existingHeaderImageUrl;
  bool get isEditing => widget.shopToEdit != null;
  bool _isGstRegistered = false;
  final TextEditingController _gstNumberController = TextEditingController();
  bool _acceptTerms = false;

  // Track original mobile number for edit mode
  String? _originalMobileNumber;

  @override
  void initState() {
    super.initState();
    SmsAutoFill().listenForCode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CategoryController>(context, listen: false).loadCategories();
      Provider.of<StateController>(context, listen: false).fetchStates();
      Provider.of<AllShopController>(context, listen: false).loadShops();

      if (isEditing) {
        final shop = widget.shopToEdit!;
        _shopNameController.text = _capitalizeFirst(shop.shopName ?? '');
        _placeController.text = _capitalizeFirst(shop.place ?? '');
        _pinCodeController.text = shop.pinCode ?? '';
        _localityController.text = _capitalizeFirst(shop.locality ?? '');
        _selectedSellerType = shop.sellerType;
        _agentCodeController.text = shop.agentCode ?? '';
        _selectedState = shop.state;
        _selectedDistrict = shop.district;
        _isGstRegistered = shop.isGstRegistered ?? false;
        _gstNumberController.text = shop.gstNumber ?? '';

        // Store original mobile number
        _originalMobileNumber = shop.mobileNumber ?? '';
        _mobileNumberController.text = _originalMobileNumber!;

        if (_selectedState != null) {
          Provider.of<DistrictController>(
            context,
            listen: false,
          ).fetchDistricts(_selectedState!);
        }

        if (shop.category!.isNotEmpty) {
          _selectedCategory = shop.category?.first;
        }
        _existingHeaderImageUrl = shop.headerImage;
        _emailController.text = shop.email ?? '';
        _landlineNumberController.text = shop.landlineNumber ?? '';
      }
    });
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _placeController.dispose();
    _pinCodeController.dispose();
    _localityController.dispose();
    _emailController.dispose();
    _mobileNumberController.dispose();
    _landlineNumberController.dispose();
    _agentCodeController.dispose();
    _gstNumberController.dispose();
    SmsAutoFill().unregisterListener();
    super.dispose();
  }

  // ====================================
  // NEW SHOP REGISTRATION (WITH OTP)
  // ====================================
  void _addNewShopWithOtp() async {
    log(
      "🟢 _addNewShopWithOtp() called - Adding new shop with OTP verification",
    );

    if (!_acceptTerms) {
      _showSnackbar(
        "Please accept the Terms & Conditions to proceed.",
        isError: true,
      );
      return;
    }

    if (_mobileNumberController.text.isEmpty) {
      log("❌ Mobile number is empty");
      _showSnackbar("Please enter mobile number.", isError: true);
      return;
    }

    final mobile = _mobileNumberController.text.trim();
    log("📞 Sending OTP to: $mobile");

    final sendOtpController = Provider.of<SendOtpController>(
      context,
      listen: false,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    await sendOtpController.sendOtp(mobile);

    Navigator.of(context).pop();

    if (sendOtpController.otpResponse != null &&
        sendOtpController.otpResponse!.success == true) {
      log(
        "✅ OTP sent successfully. Verification ID: ${sendOtpController.otpResponse!.verificationId}",
      );
      _showOtpDialogForNewShop(
        mobile,
        sendOtpController.otpResponse!.verificationId,
      );
    } else {
      log("❌ Failed to send OTP. Response: ${sendOtpController.otpResponse}");
      _showSnackbar("Failed to send OTP. Please try again.", isError: true);
    }
  }

  void _showOtpDialogForNewShop(String mobile, String verificationId) {
    final TextEditingController otpController = TextEditingController();
    final verifyOtpController = Provider.of<VerifyOtpController>(
      context,
      listen: false,
    );

    log("📩 Showing OTP dialog for NEW SHOP registration");

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock, size: 40, color: Colors.blue),
                const SizedBox(height: 12),
                const Text(
                  "Verify OTP for New Shop",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text("Enter the OTP sent to $mobile"),
                const SizedBox(height: 16),
                PinFieldAutoFill(
                  controller: otpController,
                  codeLength: 4,
                  keyboardType: TextInputType.number,
                  decoration: UnderlineDecoration(
                    textStyle: const TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    colorBuilder: FixedColorBuilder(Colors.grey),
                  ),
                  onCodeChanged: (code) async {
                    if (code != null && code.length == 4) {
                      log("📥 OTP auto-filled: $code");
                    }
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        log("ℹ️ OTP dialog cancelled by user");
                        Navigator.of(context).pop();
                      },
                      child: const Text("Cancel"),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final otp = otpController.text.trim();
                        if (otp.isEmpty) {
                          log("❌ OTP field is empty");
                          _showSnackbar("Please enter OTP", isError: true);
                          return;
                        }

                        log("📤 Verifying OTP for new shop registration");

                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder:
                              (_) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                        );

                        await verifyOtpController.verifyOtp(
                          mobileNumber: mobile,
                          otp: otp,
                          verificationId: verificationId,
                        );

                        Navigator.of(context).pop();

                        if (verifyOtpController.verifyOtpResponse != null &&
                            verifyOtpController.verifyOtpResponse!.success ==
                                true) {
                          log("✅ OTP verified successfully for new shop");
                          Navigator.of(context).pop();
                          _registerNewShop();
                        } else {
                          log(
                            "❌ OTP verification failed. Response: ${verifyOtpController.verifyOtpResponse}",
                          );
                          _showSnackbar(
                            "Invalid OTP. Please try again.",
                            isError: true,
                          );
                        }
                      },
                      icon: const Icon(Icons.check_circle),
                      label: const Text("Verify "),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _registerNewShop() async {
    log("🆕 Registering new shop...");

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null || userId.isEmpty) {
      log("❌ User ID not found in SharedPreferences");
      _showSnackbar("User ID not found. Please login again.", isError: true);
      return;
    }

    final newShop = ShopModel(
      shopName: _shopNameController.text.trim(),
      category: [_selectedCategory!],
      sellerType: _selectedSellerType!,
      state: _selectedState!,
      place:
          _placeController.text.trim().isEmpty
              ? null
              : _placeController.text.trim(),
      pinCode: _pinCodeController.text.trim(),
      locality:
          _localityController.text.trim().isEmpty
              ? null
              : _localityController.text.trim(),
      email:
          _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
      mobileNumber:
          _mobileNumberController.text.trim().isEmpty
              ? null
              : _mobileNumberController.text.trim(),
      landlineNumber:
          _landlineNumberController.text.trim().isEmpty
              ? null
              : _landlineNumberController.text.trim(),
      agentCode:
          _agentCodeController.text.trim().isEmpty
              ? null
              : _agentCodeController.text.trim(),
      district: _selectedDistrict,
      isGstRegistered: _isGstRegistered,
      gstNumber: _isGstRegistered ? _gstNumberController.text.trim() : null,
    );

    final shopProvider = Provider.of<ShopProvider>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final createShop = await shopProvider.addShop(newShop, _headerImage);

    Navigator.of(context).pop();

    if (createShop != null) {
      log("✅ Shop registered successfully with ID: $createShop");
      _showSnackbar('Shop registered successfully!');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => SubscriptionScreen(shopId: createShop),
        ),
      );
      return;
    } else {
      log("❌ Shop registration failed");
      _showSnackbar(
        "Failed to register shop. Please try again.",
        isError: true,
      );
    }
  }

  // ====================================
  // UPDATE EXISTING SHOP (WITH OTP ONLY IF MOBILE CHANGED)
  // ====================================
  void _updateExistingShop() async {
    log("✏️ _updateExistingShop() called - Updating shop");

    // Check if mobile number is changed
    final currentMobile = _mobileNumberController.text.trim();
    final isMobileChanged = currentMobile != _originalMobileNumber;

    if (isMobileChanged && currentMobile.isNotEmpty) {
      log(
        "📱 Mobile number changed from $_originalMobileNumber to $currentMobile - OTP required",
      );
      _verifyMobileWithOtpForUpdate();
    } else {
      log("📱 Mobile number not changed or empty - proceeding without OTP");
      _performShopUpdate();
    }
  }

  void _verifyMobileWithOtpForUpdate() async {
    final mobile = _mobileNumberController.text.trim();
    log("📞 Sending OTP for mobile verification: $mobile");

    final sendOtpController = Provider.of<SendOtpController>(
      context,
      listen: false,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    await sendOtpController.sendOtp(mobile);

    Navigator.of(context).pop();

    if (sendOtpController.otpResponse != null &&
        sendOtpController.otpResponse!.success == true) {
      log("✅ OTP sent successfully for mobile update");
      _showOtpDialogForMobileUpdate(
        mobile,
        sendOtpController.otpResponse!.verificationId,
      );
    } else {
      log("❌ Failed to send OTP for mobile update");
      _showSnackbar("Failed to send OTP. Please try again.", isError: true);
    }
  }

  void _showOtpDialogForMobileUpdate(String mobile, String verificationId) {
    final TextEditingController otpController = TextEditingController();
    final verifyOtpController = Provider.of<VerifyOtpController>(
      context,
      listen: false,
    );

    log("📩 Showing OTP dialog for MOBILE UPDATE");

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.phone_android, size: 40, color: Colors.blue),
                const SizedBox(height: 12),
                const Text(
                  "Verify Mobile Number",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text("Enter OTP sent to $mobile to verify new mobile number"),
                const SizedBox(height: 16),
                PinFieldAutoFill(
                  controller: otpController,
                  codeLength: 4,
                  keyboardType: TextInputType.number,
                  decoration: UnderlineDecoration(
                    textStyle: const TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    colorBuilder: FixedColorBuilder(Colors.grey),
                  ),
                  onCodeChanged: (code) async {
                    if (code != null && code.length == 4) {
                      log("📥 OTP auto-filled: $code");
                    }
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        log("ℹ️ OTP dialog cancelled by user");
                        Navigator.of(context).pop();
                      },
                      child: const Text("Cancel"),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final otp = otpController.text.trim();
                        if (otp.isEmpty) {
                          log("❌ OTP field is empty");
                          _showSnackbar("Please enter OTP", isError: true);
                          return;
                        }

                        log("📤 Verifying OTP for mobile update");

                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder:
                              (_) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                        );

                        await verifyOtpController.verifyOtp(
                          mobileNumber: mobile,
                          otp: otp,
                          verificationId: verificationId,
                        );

                        Navigator.of(context).pop();

                        if (verifyOtpController.verifyOtpResponse != null &&
                            verifyOtpController.verifyOtpResponse!.success ==
                                true) {
                          log("✅ OTP verified successfully for mobile update");
                          Navigator.of(context).pop();
                          _performShopUpdate();
                        } else {
                          log("❌ OTP verification failed for mobile update");
                          _showSnackbar(
                            "Invalid OTP. Please try again.",
                            isError: true,
                          );
                        }
                      },
                      icon: const Icon(Icons.check_circle),
                      label: const Text("Verify & Update"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _performShopUpdate() async {
    log("🔄 Performing shop update...");

    // Validate GST number if provided
    if (_isGstRegistered && _gstNumberController.text.isNotEmpty) {
      if (!_isValidGstNumber(_gstNumberController.text.trim())) {
        _showSnackbar(
          "Please enter a valid 15-digit GST number.",
          isError: true,
        );
        return;
      }
    }

    final updatedShopDetails = ShopeDetailsModel(
      id: widget.shopToEdit!.id,
      shopName:
          _shopNameController.text.trim().isEmpty
              ? widget.shopToEdit!.shopName
              : _shopNameController.text.trim(),
      category:
          _selectedCategory != null
              ? [_selectedCategory!]
              : widget.shopToEdit!.category,
      sellerType: _selectedSellerType ?? widget.shopToEdit!.sellerType,
      state: _selectedState ?? widget.shopToEdit!.state,
      place:
          _placeController.text.trim().isEmpty
              ? widget.shopToEdit!.place
              : _placeController.text.trim(),
      pinCode:
          _pinCodeController.text.trim().isEmpty
              ? widget.shopToEdit!.pinCode
              : _pinCodeController.text.trim(),
      locality:
          _localityController.text.trim().isEmpty
              ? widget.shopToEdit!.locality
              : _localityController.text.trim(),
      email:
          _emailController.text.trim().isEmpty
              ? widget.shopToEdit!.email
              : _emailController.text.trim(),
      agentCode:
          _agentCodeController.text.trim().isEmpty
              ? widget.shopToEdit!.agentCode
              : _agentCodeController.text.trim(),
      mobileNumber:
          _mobileNumberController.text.trim().isEmpty
              ? widget.shopToEdit!.mobileNumber
              : _mobileNumberController.text.trim(),
      landlineNumber:
          _landlineNumberController.text.trim().isEmpty
              ? widget.shopToEdit!.landlineNumber
              : _landlineNumberController.text.trim(),
      isGstRegistered: _isGstRegistered,
      gstNumber: _isGstRegistered ? _gstNumberController.text.trim() : null,
    );

    final shopProvider = Provider.of<ShopProvider>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    await shopProvider.updateShop(updatedShopDetails, _headerImage);

    Navigator.of(context).pop();

    if (shopProvider.errorMessage.isNotEmpty) {
      log("❌ Shop update failed. Error: ${shopProvider.errorMessage}");
      _showSnackbar(shopProvider.errorMessage, isError: true);
    } else {
      log("✅ Shop updated successfully");
      _showSnackbar("Shop updated successfully!");

      // Refresh related data
      Provider.of<HomeProductController>(context, listen: false).loadProducts();
      Provider.of<ShopProvider>(context, listen: false).fetchShops();
      Provider.of<ShopOfUserProvider>(context, listen: false).fetchUserShops();

      Navigator.of(context).pop(true);
    }
  }

  // ====================================
  // SUBMIT HANDLER
  // ====================================
  void _handleSubmit() {
    if (isEditing) {
      // Edit mode - update (OTP only if mobile changed)
      _updateExistingShop();
    } else {
      // Add mode - validate and send OTP
      if (_formKey.currentState?.validate() ?? false) {
        if (!_acceptTerms) {
          _showSnackbar(
            "Please accept the Terms & Conditions to proceed.",
            isError: true,
          );
          return;
        }
        _addNewShopWithOtp();
      } else {
        _showSnackbar(
          "Please fill all required fields correctly.",
          isError: true,
        );
      }
    }
  }

  // ====================================
  // VALIDATORS FOR EDIT MODE (OPTIONAL)
  // ====================================
  String? _editModeValidator(
    String? value,
    String fieldName, {
    bool isNumeric = false,
    bool isEmail = false,
  }) {
    if (isEditing) {
      // In edit mode, all fields are optional
      if (value == null || value.isEmpty) {
        return null; // Allow empty values
      }

      if (isNumeric && int.tryParse(value) == null) {
        return "Please enter a valid number";
      }

      if (isEmail && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
        return "Please enter a valid email";
      }

      return null;
    } else {
      // In add mode, use original validation
      if (value == null || value.isEmpty) {
        return "$fieldName is required";
      }

      if (isNumeric && int.tryParse(value) == null) {
        return "Please enter a valid number";
      }

      if (isEmail && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
        return "Please enter a valid email";
      }

      return null;
    }
  }

  String? _mobileValidator(String? value) {
    if (isEditing) {
      // In edit mode, mobile is optional
      if (value == null || value.isEmpty) {
        return null;
      }

      if (!RegExp(r'^\d+$').hasMatch(value)) {
        return "Only numbers allowed";
      }

      if (value.length != 10) {
        return "Mobile number must be 10 digits";
      }

      // Check if mobile exists (excluding current shop's mobile)
      final shopController = Provider.of<AllShopController>(
        context,
        listen: false,
      );
      if (value != _originalMobileNumber &&
          shopController.isMobileExists(value)) {
        return "This number is already registered";
      }

      return null;
    } else {
      // In add mode, mobile is required
      if (value == null || value.isEmpty) {
        return "Mobile number is required";
      }

      if (!RegExp(r'^\d+$').hasMatch(value)) {
        return "Only numbers allowed";
      }

      if (value.length != 10) {
        return "Mobile number must be 10 digits";
      }

      // Check if mobile exists
      final shopController = Provider.of<AllShopController>(
        context,
        listen: false,
      );
      if (shopController.isMobileExists(value)) {
        return "This number is already registered";
      }

      return null;
    }
  }

  // ====================================
  // REST OF THE CODE REMAINS THE SAME
  // ====================================

  Future<bool> _showLocationDisclosureDialog() async {
    bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Colors.blue,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Location Access Required",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const Text(
                  "Why we need your location:",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 12),
                _buildDisclosurePoint(
                  Icons.place,
                  "Auto-fill shop address",
                  "To automatically fill your shop's place, state, and PIN code for accurate registration.",
                ),
                const SizedBox(height: 12),
                _buildDisclosurePoint(
                  Icons.pin_drop,
                  "Better search visibility",
                  "To help customers find your shop easily when searching by location.",
                ),
                const SizedBox(height: 12),
                _buildDisclosurePoint(
                  Icons.share_location,
                  "Local business discovery",
                  "To showcase your shop to potential customers in your area.",
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Colors.blue,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "Your privacy is protected:",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "• We only access location when you tap the 'Use Your Current Location' button\n"
                        "• Location data is used only to auto-fill address fields\n"
                        "• We don't track your location continuously\n"
                        "• Location data is securely stored with your shop information",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade700,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text("Don't Allow", style: TextStyle(fontSize: 16)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text(
                "Allow Access",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
          actionsPadding: const EdgeInsets.only(
            right: 24,
            left: 24,
            bottom: 16,
            top: 8,
          ),
        );
      },
    );

    return result ?? false;
  }

  Widget _buildDisclosurePoint(
    IconData icon,
    String title,
    String description,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.blue, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showTermsAndConditions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 7, 3, 201),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Terms & Conditions ",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          "PoketStor Application",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Center(
                        child: Text(
                          "Last Updated: 23 / 12 / 2025",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "By registering, listing products, or using the PoketStor application as a shop owner, you agree to comply with and be bound by the following Terms & Conditions (\"Terms\").",
                        style: TextStyle(fontSize: 14, height: 1.5),
                      ),
                      const SizedBox(height: 24),

                      _buildTermSection(
                        "1. Eligibility",
                        "Shop owners must be at least 18 years of age.\n\nAccurate and complete business and contact information must be provided.\n\nPoketStor reserves the right to approve, reject, suspend, or remove any shop at its discretion.",
                      ),

                      _buildTermSection(
                        "2. Platform Role",
                        "PoketStor is a technology platform only.\n\nPoketStor does not sell products, does not own inventory, and does not process customer payments.\n\nThe platform is used solely to list shops or products and to send order notifications to shop owners.",
                      ),

                      _buildTermSection(
                        "3. Shop Owner Responsibilities",
                        "Shop owners agree to:\n\n• Provide accurate product information, pricing, and availability.\n• Comply with all applicable local, state, and national laws.\n• Manage orders, delivery, customer communication, and after-sales support.\n• Handle refunds, returns, and customer complaints directly with customers.",
                      ),

                      _buildTermSection(
                        "4. Order Notifications",
                        "When a customer places an order, PoketStor sends a notification only to the shop owner.\n\nOrder confirmation, fulfillment, and customer communication are entirely the responsibility of the shop owner.\n\nPoketStor is not responsible for missed, delayed, or failed notifications.",
                      ),

                      _buildTermSection(
                        "5. Direct Sales & Payments (Important)",
                        "All sales and payments are conducted directly between customers and shop owners.\n\nPoketStor does not collect, hold, process, or transfer payments.\n\nPayment methods are decided solely by the shop owner.\n\nPoketStor is not a party to any transaction and bears no liability for payment disputes.",
                      ),

                      _buildTermSection(
                        "6. Refunds & Cancellations (Customer Orders)",
                        "PoketStor does not issue customer refunds.\n\nAll refund or cancellation requests must be handled exclusively by the shop owner.\n\nPoketStor will not intervene in disputes between customers and shop owners.",
                      ),

                      _buildTermSection(
                        "7. Subscription Plans & Duration",
                        "PoketStor offers the following subscription plans:\n\n• Monthly Subscription\n• Yearly Subscription\n\nShop owners may choose a plan at the time of purchase.\n\nSubscription validity is based on the selected plan duration.",
                      ),

                      _buildTermSection(
                        "8. Free Trial Offer",
                        "PoketStor may provide a free trial period of two (2) months during initial registration.\n\nThe free trial is available only once per new shop registration.\n\nFree trial benefits do not apply to renewals or re-subscriptions.",
                      ),

                      _buildTermSection(
                        "9. Subscription Fees – Non-Refundable",
                        "All subscription fees are strictly non-refundable.\n\nOnce a subscription is activated, no refunds or credits will be issued for:\n\n• Partial usage\n• Shop inactivity\n• No or low sales\n• Business closure\n• Accidental or incorrect purchase\n• Server downtime or technical issues\n\nSubscription cancellation prevents future renewals only.",
                      ),

                      _buildTermSection(
                        "10. Technical Issues & No-Refund Policy",
                        "PoketStor may experience temporary server downtime, maintenance, or technical issues.\n\nSuch events do not qualify for refunds, compensation, or subscription extensions.\n\nShop owners agree to use the platform at their own risk.",
                      ),

                      _buildTermSection(
                        "11. Invoice Policy",
                        "Subscription invoices will be sent to the registered shop email address.\n\nIf an invoice is not received, shop owners must contact PoketStor Support within 60 days of payment.\n\nAfter 60 days, invoices will no longer be available through support.",
                      ),

                      _buildTermSection(
                        "12. Prohibited Activities",
                        "Shop owners must not:\n\n• Sell illegal, banned, or counterfeit products.\n• Upload false, misleading, or offensive content.\n• Manipulate reviews, pricing, or platform features.\n• Attempt to bypass security, subscriptions, or platform rules.",
                      ),

                      _buildTermSection(
                        "13. Suspension or Termination",
                        "PoketStor may suspend or terminate a shop without prior notice if:\n\n• These Terms are violated\n• Fraudulent or illegal activity is detected\n• Repeated customer complaints occur\n• Required by legal or regulatory authorities",
                      ),

                      _buildTermSection(
                        "14. Intellectual Property",
                        "Shop owners retain ownership of their content.\n\nBy uploading content, shop owners grant PoketStor the right to display and promote such content on the platform.\n\nPoketStor branding may not be used without prior permission.",
                      ),

                      _buildTermSection(
                        "15. Data & Account Security",
                        "Shop owners are responsible for maintaining account security.\n\nPoketStor is not liable for losses resulting from unauthorized access due to negligence.\n\nAll data is handled in accordance with PoketStor's Privacy Policy.",
                      ),

                      _buildTermSection(
                        "16. Limitation of Liability",
                        "PoketStor is provided on an \"as is\" basis.\n\nPoketStor is not liable for business losses, payment disputes, missed orders, delivery failures, or technical interruptions.\n\nMaximum liability is limited to the subscription fee paid.",
                      ),

                      _buildTermSection(
                        "17. Modification of Terms",
                        "PoketStor may update these Terms at any time.\n\nContinued use of the platform constitutes acceptance of the updated Terms.",
                      ),

                      _buildTermSection(
                        "18. Governing Law",
                        "These Terms are governed by the laws of India.\n\nAll disputes are subject to Indian jurisdiction.",
                      ),

                      _buildTermSection(
                        "19. Contact Information",
                        "📧 Email: poketstormail@gmail.com\n\n📱 PoketStor Support Team",
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTermSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 7, 3, 201),
          ),
        ),
        const SizedBox(height: 8),
        Text(content, style: const TextStyle(fontSize: 14, height: 1.5)),
        const SizedBox(height: 20),
      ],
    );
  }

  Future<void> _pickImageFromGallery() async {
    final hasPermission = await _requestGalleryPermission();
    if (hasPermission) {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        final croppedImage = await Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    CropImageScreenShop(imageFile: File(pickedFile.path)),
          ),
        );
        if (croppedImage != null && croppedImage is File) {
          setState(() {
            _headerImage = croppedImage;
          });
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gallery permission denied!")),
      );
    }
  }

  Future<void> _pickImageFromCamera() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.camera,
      );
      if (pickedFile != null) {
        final croppedImage = await Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    CropImageScreenShop(imageFile: File(pickedFile.path)),
          ),
        );
        if (croppedImage != null && croppedImage is File) {
          setState(() {
            _headerImage = croppedImage;
          });
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Camera permission denied!")),
      );
    }
  }

  Future<bool> _requestGalleryPermission() async {
    if (Platform.isAndroid) {
      if (await Permission.storage.isGranted) {
        return true;
      }

      if (Platform.isAndroid && (await Permission.storage.isDenied)) {
        if (await Permission.storage.request().isGranted) {
          return true;
        }
      }

      if (await Permission.photos.isGranted) {
        return true;
      }
      if (await Permission.photos.request().isGranted) {
        return true;
      }

      if (await Permission.mediaLibrary.isGranted) {
        return true;
      }
    } else if (Platform.isIOS) {
      var status = await Permission.photos.request();
      return status.isGranted || status.isLimited;
    }
    return false;
  }

  Future<void> _handleLocationAccess() async {
    try {
      log("📍 Starting location fetch process...");

      final userConsent = await _showLocationDisclosureDialog();

      if (!userConsent) {
        log("❌ User declined location access from disclosure dialog");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              "Location access is required to auto-fill address",
            ),
            action: SnackBarAction(
              label: 'Try Again',
              onPressed: _handleLocationAccess,
              textColor: Colors.white,
            ),
          ),
        );
        return;
      }

      log("✅ User consented to location access");

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      log("📍 Location service enabled: $serviceEnabled");

      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Please enable location services"),
            action: SnackBarAction(
              label: 'Settings',
              textColor: Colors.white,
              onPressed: () => openAppSettings(),
            ),
          ),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      log("📍 Current permission status: $permission");

      if (permission == LocationPermission.denied) {
        log("📋 Requesting location permission...");
        permission = await Geolocator.requestPermission();
        log("📍 New permission status: $permission");

        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Location permission is required to auto-fill address",
              ),
            ),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              "Location permissions are permanently denied. Enable them in settings.",
            ),
            action: SnackBarAction(
              label: 'Settings',
              textColor: Colors.white,
              onPressed: () => openAppSettings(),
            ),
          ),
        );
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Getting your location...",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "This may take a few seconds",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
      );

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 15),
      );

      log("📍 Position obtained:");
      log("   • Latitude: ${position.latitude}");
      log("   • Longitude: ${position.longitude}");
      log("   • Accuracy: ${position.accuracy} meters");

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      log("📍 Found ${placemarks.length} placemark(s)");

      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        final stateController = Provider.of<StateController>(
          context,
          listen: false,
        );

        setState(() {
          _placeController.text = place.subAdministrativeArea ?? '';
          _pinCodeController.text = place.postalCode ?? '';
          _localityController.text = place.locality ?? '';
          _selectedState = place.administrativeArea ?? _selectedState;

          if (place.administrativeArea != null &&
              stateController.statesList.contains(place.administrativeArea)) {
            _selectedState = place.administrativeArea;
          } else {
            _selectedState = null;
          }

          _selectedDistrict = null;
        });

        if (_selectedState != null) {
          Provider.of<DistrictController>(
            context,
            listen: false,
          ).fetchDistricts(_selectedState!);
        } else {
          Provider.of<DistrictController>(context, listen: false).clear();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green.shade100,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text("Location detected successfully!"),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      } else {
        log("❌ No placemarks found for coordinates");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Unable to get address details"),
            backgroundColor: Colors.orange,
          ),
        );
      }

      log("✅ Location fetch process completed successfully");
    } catch (e, stackTrace) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      log("❌ Error fetching location: $e");
      log("📋 Stack trace: $stackTrace");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red.shade100, size: 20),
              const SizedBox(width: 8),
              Text("Failed to get location: ${e.toString()}"),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? Colors.red : const Color.fromARGB(255, 7, 3, 201),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  bool _isValidGstNumber(String gstNumber) {
    if (gstNumber.length != 15) return false;

    final regex = RegExp(
      r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[A-Z0-9]{1}Z[0-9A-Z]{1}$',
    );
    return regex.hasMatch(gstNumber.toUpperCase());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: AppBar(
            automaticallyImplyLeading: true,
            backgroundColor: const Color.fromARGB(255, 7, 3, 201),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            title: Text(
              isEditing ? "Edit Shop" : "Add Shop",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
        ),
        backgroundColor: Colors.white,
        body: Consumer<ShopProvider>(
          builder: (context, shopProvider, child) {
            return Consumer<CategoryController>(
              builder: (context, categoryController, _) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Shop Name${isEditing ? '' : ' *'}"),
                        _buildTextField(
                          _shopNameController,
                          "Enter shop name",
                          textCapitalization: TextCapitalization.words,
                          isRequired: !isEditing, // Required only for new shop
                          validator:
                              (value) => _editModeValidator(value, "Shop name"),
                        ),

                        _buildLabel("Category${isEditing ? '' : ' *'}"),
                        categoryController.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : _buildDropdown<String>(
                              "Select Category",
                              _selectedCategory,
                              categoryController.categoryList,
                              (value) =>
                                  setState(() => _selectedCategory = value),
                              isRequired:
                                  !isEditing, // Required only for new shop
                            ),

                        _buildLabel("Seller Type${isEditing ? '' : ' *'}"),
                        _buildDropdown(
                          "Select seller type",
                          _selectedSellerType,
                          sellerTypes,
                          (value) =>
                              setState(() => _selectedSellerType = value),
                          isRequired: !isEditing, // Required only for new shop
                        ),
                        const SizedBox(height: 20),

                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.blue.shade100,
                              width: 1.5,
                            ),
                            color: Colors.blue.shade50,
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () async {
                                await _handleLocationAccess();
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade100,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.my_location,
                                        color: Colors.blue.shade800,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Use Your Current Location",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.blue.shade800,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "Auto-fill using GPS",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.blue.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.chevron_right,
                                      color: Colors.blue.shade600,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        _buildLabel("Place${isEditing ? '' : ' *'}"),
                        _buildTextField(
                          _localityController,
                          "Enter Place",
                          textCapitalization: TextCapitalization.words,
                          isRequired: !isEditing, // Required only for new shop
                          validator:
                              (value) => _editModeValidator(value, "Place"),
                        ),

                        _buildLabel("Pin Code${isEditing ? '' : ' *'}"),
                        _buildTextField(
                          _pinCodeController,
                          "Enter pin code",
                          isNumeric: true,
                          isRequired: !isEditing, // Required only for new shop
                          validator:
                              (value) => _editModeValidator(
                                value,
                                "Pin code",
                                isNumeric: true,
                              ),
                        ),
                        _buildLabel("State${isEditing ? '' : ' *'}"),
                        Consumer<StateController>(
                          builder: (context, stateController, _) {
                            return stateController.isLoading
                                ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                                : _buildDropdown<String>(
                                  "Select State",
                                  _selectedState,
                                  stateController.statesList,
                                  (value) {
                                    setState(() {
                                      _selectedState = value;
                                      _selectedDistrict = null;
                                    });
                                    if (value != null) {
                                      Provider.of<DistrictController>(
                                        context,
                                        listen: false,
                                      ).fetchDistricts(value);
                                    } else {
                                      Provider.of<DistrictController>(
                                        context,
                                        listen: false,
                                      ).clear();
                                    }
                                  },
                                  isRequired:
                                      !isEditing, // Required only for new shop
                                );
                          },
                        ),

                        _buildLabel("District${isEditing ? '' : ' *'}"),
                        Consumer<DistrictController>(
                          builder: (context, districtController, _) {
                            if (_selectedState == null) {
                              return _buildDropdown<String>(
                                "Select State First",
                                null,
                                [],
                                (value) {},
                                isEnabled: false,
                                isRequired: !isEditing,
                              );
                            }

                            return districtController.isLoading
                                ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                                : _buildDropdown<String>(
                                  "Select District",
                                  _selectedDistrict,
                                  districtController.districtList,
                                  (value) {
                                    setState(() {
                                      _selectedDistrict = value;
                                      if (value != null) {
                                        _placeController.text = value;
                                      }
                                    });
                                  },
                                  isRequired:
                                      !isEditing, // Required only for new shop
                                );
                          },
                        ),

                        const SizedBox(height: 20),
                        _buildLabel("Agent Code"),
                        _buildTextField(
                          _agentCodeController,
                          "Enter agent code",
                          isOptional: true,
                        ),

                        _buildLabel("Email${isEditing ? '' : ' *'}"),
                        _buildTextField(
                          _emailController,
                          "Enter email address",
                          isEmail: true,
                          isRequired: !isEditing, // Required only for new shop
                          validator:
                              (value) => _editModeValidator(
                                value,
                                "Email",
                                isEmail: true,
                              ),
                        ),

                        _buildLabel("Mobile Number${isEditing ? '' : ' *'}"),
                        Consumer<AllShopController>(
                          builder: (context, shopController, _) {
                            return StatefulBuilder(
                              builder: (context, setState) {
                                return TextFormField(
                                  controller: _mobileNumberController,
                                  keyboardType: TextInputType.phone,
                                  maxLength: 10,
                                  validator: _mobileValidator,
                                  decoration: InputDecoration(
                                    counterText: "",
                                    hintText: "Enter mobile number",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Color.fromARGB(255, 7, 3, 201),
                                        width: 2,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                  onChanged: (value) {
                                    setState(() {});
                                  },
                                );
                              },
                            );
                          },
                        ),

                        _buildLabel("Landline Number"),
                        _buildTextField(
                          _landlineNumberController,
                          "Enter landline number",
                          isNumeric: true,
                          isOptional: true,
                        ),
                        _buildLabel("GST Registration"),
                        const SizedBox(height: 8),

                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                            color: Colors.white,
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _isGstRegistered = !_isGstRegistered;
                                  if (!_isGstRegistered) {
                                    _gstNumberController.clear();
                                  }
                                });
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color:
                                              _isGstRegistered
                                                  ? Colors.green
                                                  : Colors.grey,
                                          width: 2,
                                        ),
                                      ),
                                      child:
                                          _isGstRegistered
                                              ? const Icon(
                                                Icons.check,
                                                size: 16,
                                                color: Colors.green,
                                              )
                                              : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        "This shop is GST registered",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color:
                                              _isGstRegistered
                                                  ? Colors.green
                                                  : Colors.grey.shade700,
                                        ),
                                      ),
                                    ),
                                    Switch(
                                      value: _isGstRegistered,
                                      onChanged: (value) {
                                        setState(() {
                                          _isGstRegistered = value;
                                          if (!_isGstRegistered) {
                                            _gstNumberController.clear();
                                          }
                                        });
                                      },
                                      activeColor: Colors.green,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        if (_isGstRegistered) ...[
                          _buildLabel("GST Number"),
                          TextFormField(
                            controller: _gstNumberController,
                            decoration: InputDecoration(
                              hintText: "Enter 15-digit GST number",
                              prefixIcon: const Icon(Icons.receipt),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.green,
                                  width: 2,
                                ),
                              ),
                              errorText:
                                  _gstNumberController.text.isNotEmpty &&
                                          !_isValidGstNumber(
                                            _gstNumberController.text.trim(),
                                          )
                                      ? "Invalid GST number format"
                                      : null,
                            ),
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                final cursorPos =
                                    _gstNumberController.selection.base.offset;
                                _gstNumberController.text = value.toUpperCase();
                                _gstNumberController.selection =
                                    TextSelection.collapsed(offset: cursorPos);
                              }
                              setState(() {});
                            },
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Format: 22AAAAA0000A1Z5",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        const SizedBox(height: 20),

                        _buildLabel("Shop Image"),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 0,
                            vertical: 4,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () => _pickImageFromCamera(),
                                    icon: const Icon(
                                      Icons.photo_camera,
                                      color: Color.fromARGB(255, 7, 3, 201),
                                    ),
                                    label: const Text(
                                      "Camera",
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 7, 3, 201),
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        side: const BorderSide(
                                          color: Color.fromARGB(255, 7, 3, 201),
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  ElevatedButton.icon(
                                    onPressed: () => _pickImageFromGallery(),
                                    icon: const Icon(
                                      Icons.photo_library,
                                      color: Color.fromARGB(255, 7, 3, 201),
                                    ),
                                    label: const Text(
                                      "Gallery",
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 7, 3, 201),
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        side: const BorderSide(
                                          color: Color.fromARGB(255, 7, 3, 201),
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              if (_headerImage != null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    _headerImage!,
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              else if (_existingHeaderImageUrl != null &&
                                  _existingHeaderImageUrl!.isNotEmpty)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    _existingHeaderImageUrl!,
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                              height: 100,
                                              width: 100,
                                              color: Colors.grey.shade300,
                                              child: const Icon(
                                                Icons.broken_image,
                                                size: 40,
                                                color: Colors.grey,
                                              ),
                                            ),
                                  ),
                                )
                              else
                                Container(
                                  height: 100,
                                  width: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      "No image selected",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        if (!isEditing) ...[
                          const SizedBox(height: 20),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                              color: Colors.grey.shade50,
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Transform.scale(
                                  scale: 1.2,
                                  child: Checkbox(
                                    value: _acceptTerms,
                                    onChanged: (value) {
                                      setState(() {
                                        _acceptTerms = value ?? false;
                                      });
                                    },
                                    activeColor: const Color.fromARGB(
                                      255,
                                      7,
                                      3,
                                      201,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                        onTap: _showTermsAndConditions,
                                        child: RichText(
                                          text: TextSpan(
                                            text:
                                                "I have read and agree to the ",
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black87,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: "Terms & Conditions",
                                                style: const TextStyle(
                                                  color: Color.fromARGB(
                                                    255,
                                                    7,
                                                    3,
                                                    201,
                                                  ),
                                                  fontWeight: FontWeight.bold,
                                                  decoration:
                                                      TextDecoration.underline,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "* Required to proceed with shop registration",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],

                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                                shopProvider.isLoading ? null : _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0XFF094497),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child:
                                shopProvider.isLoading
                                    ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                    : Text(
                                      isEditing ? "Update Shop" : "Send OTP",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                    ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildDropdown<T>(
    String hint,
    T? selectedValue,
    List<T> items,
    void Function(T?) onChanged, {
    bool isEnabled = true,
    bool isRequired = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: DropdownButtonFormField<T>(
        value: selectedValue,
        isExpanded: true,
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 7, 3, 201),
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          filled: !isEnabled,
          fillColor: Colors.grey.shade100,
        ),
        hint: Text(hint),
        items:
            items
                .map(
                  (item) => DropdownMenuItem<T>(
                    value: item,
                    child: Text(item.toString()),
                  ),
                )
                .toList(),
        onChanged: isEnabled ? onChanged : null,
        validator:
            isRequired
                ? (value) => value == null ? "This field is required" : null
                : null,
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hintText, {
    bool isNumeric = false,
    bool isEmail = false,
    bool isOptional = false,
    bool isRequired = false,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextFormField(
        controller: controller,
        keyboardType:
            isNumeric
                ? TextInputType.number
                : (isEmail ? TextInputType.emailAddress : TextInputType.text),
        textCapitalization: textCapitalization,
        validator:
            validator ??
            (value) {
              if (isRequired && (value == null || value.isEmpty)) {
                return "This field is required";
              }
              if (isNumeric &&
                  value!.isNotEmpty &&
                  int.tryParse(value) == null) {
                return "Please enter a valid number";
              }
              if (isEmail &&
                  value!.isNotEmpty &&
                  !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                return "Please enter a valid email";
              }
              return null;
            },
        decoration: InputDecoration(
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 7, 3, 201),
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}
