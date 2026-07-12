// import 'dart:developer';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:poketstore/controllers/add_shop_controller/add_shop_controller.dart';
// import 'package:poketstore/controllers/add_shop_controller/all_shop_controller.dart';
// import 'package:poketstore/controllers/category_controller/category_controller.dart';
// import 'package:poketstore/controllers/otp_controller/send_otp_controller.dart';
// import 'package:poketstore/controllers/otp_controller/verify_otp_controller.dart';
// import 'package:poketstore/model/add_shope_model/add_shop_model.dart';
// import 'package:poketstore/model/my_shope_model/shope_details_model.dart';
// import 'package:poketstore/utilities/image_crop_screen.dart';
// import 'package:poketstore/view/add_shop/widget/capitalization.dart';
// import 'package:poketstore/view/subscription/subscription.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import '../../controllers/home_product_controller/home_product_controller.dart';
// import '../../controllers/shop_of_user_controller/shop_of_user_controller.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';

// class AddShop extends StatefulWidget {
//   final ShopeDetailsModel? shopToEdit;

//   const AddShop({super.key, this.shopToEdit});

//   @override
//   State<AddShop> createState() => _AddShopState();
// }

// class _AddShopState extends State<AddShop> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _shopNameController =
//       CapitalizingTextController();
//   final TextEditingController _placeController = CapitalizingTextController();
//   final TextEditingController _pinCodeController = TextEditingController();
//   final TextEditingController _localityController =
//       CapitalizingTextController();
//   // New controllers for the new fields
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _mobileNumberController = TextEditingController();
//   final TextEditingController _landlineNumberController =
//       TextEditingController();
//   final TextEditingController _agentCodeController = TextEditingController();

//   final List<String> sellerTypes = ["Producer", "Trader"];
//   final List<String> states = [
//     "Andhra Pradesh",
//     "Arunachal Pradesh",
//     "Assam",
//     "Bihar",
//     "Chhattisgarh",
//     "Goa",
//     "Gujarat",
//     "Haryana",
//     "Himachal Pradesh",
//     "Jharkhand",
//     "Karnataka",
//     "Kerala",
//     "Madhya Pradesh",
//     "Maharashtra",
//     "Manipur",
//     "Meghalaya",
//     "Mizoram",
//     "Nagaland",
//     "Odisha",
//     "Punjab",
//     "Rajasthan",
//     "Sikkim",
//     "Tamil Nadu",
//     "Telangana",
//     "Tripura",
//     "Uttar Pradesh",
//     "Uttarakhand",
//     "West Bengal",
//   ];

//   String? _selectedSellerType;
//   String? _selectedState;
//   String? _selectedCategory;
//   File? _headerImage; // This will now store the *cropped* image file
//   String? _existingHeaderImageUrl;
//   // File? _selectedImage; // This variable is no longer needed
//   bool get isEditing => widget.shopToEdit != null;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       // load categories
//       Provider.of<CategoryController>(context, listen: false).loadCategories();

//       // load shops so we can check mobile number existence
//       Provider.of<AllShopController>(context, listen: false).loadShops();

//       if (isEditing) {
//         final shop = widget.shopToEdit!;
//         // Capitalize the first letter when pre-filling the text field
//         _shopNameController.text = _capitalizeFirst(shop.shopName ?? '');
//         _placeController.text = _capitalizeFirst(shop.place ?? '');
//         _pinCodeController.text = shop.pinCode ?? '';
//         _localityController.text = _capitalizeFirst(shop.locality ?? '');
//         _selectedSellerType = shop.sellerType;
//         _agentCodeController.text = shop.agentCode ?? '';
//         _selectedState = shop.state;
//         if (shop.category!.isNotEmpty) {
//           _selectedCategory = shop.category?.first;
//         }
//         _existingHeaderImageUrl = shop.headerImage;
//         _emailController.text = shop.email ?? '';
//         _mobileNumberController.text = shop.mobileNumber ?? '';
//         _landlineNumberController.text = shop.landlineNumber ?? '';
//       }
//     });
//   }

//   // Helper function to capitalize the first letter
//   String _capitalizeFirst(String text) {
//     if (text.isEmpty) return text;
//     return text[0].toUpperCase() + text.substring(1);
//   }

//   @override
//   void dispose() {
//     _shopNameController.dispose();
//     _placeController.dispose();
//     _pinCodeController.dispose();
//     _localityController.dispose();
//     // Dispose new controllers
//     _emailController.dispose();
//     _mobileNumberController.dispose();
//     _landlineNumberController.dispose();
//     _agentCodeController.dispose();
//     super.dispose();
//   }

//   Future<void> _pickImageFromGallery() async {
//     final hasPermission = await _requestGalleryPermission();
//     if (hasPermission) {
//       final pickedFile = await ImagePicker().pickImage(
//         source: ImageSource.gallery,
//       );
//       if (pickedFile != null) {
//         final croppedImage = await Navigator.push(
//           // ignore: use_build_context_synchronously
//           context,
//           MaterialPageRoute(
//             builder:
//                 (context) => CropImageScreen(imageFile: File(pickedFile.path)),
//           ),
//         );
//         if (croppedImage != null && croppedImage is File) {
//           setState(() {
//             _headerImage = croppedImage;
//           });
//         }
//       }
//     } else {
//       // ignore: use_build_context_synchronously
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Gallery permission denied!")),
//       );
//     }
//   }

//   Future<void> _pickImageFromCamera() async {
//     final status = await Permission.camera.request();
//     if (status.isGranted) {
//       final pickedFile = await ImagePicker().pickImage(
//         source: ImageSource.camera,
//       );
//       if (pickedFile != null) {
//         final croppedImage = await Navigator.push(
//           // ignore: use_build_context_synchronously
//           context,
//           MaterialPageRoute(
//             builder:
//                 (context) => CropImageScreen(imageFile: File(pickedFile.path)),
//           ),
//         );
//         if (croppedImage != null && croppedImage is File) {
//           setState(() {
//             _headerImage =
//                 croppedImage; // Set the cropped image to _headerImage
//           });
//         }
//       }
//     } else {
//       // ignore: use_build_context_synchronously
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Camera permission denied!")),
//       );
//     }
//   }

//   Future<bool> _requestGalleryPermission() async {
//     if (Platform.isAndroid) {
//       if (await Permission.storage.isGranted) {
//         return true;
//       }

//       if (Platform.isAndroid && (await Permission.storage.isDenied)) {
//         if (await Permission.storage.request().isGranted) {
//           return true;
//         }
//       }

//       // Handle Android 13+ specific permissions
//       if (await Permission.photos.isGranted) {
//         return true;
//       }
//       if (await Permission.photos.request().isGranted) {
//         return true;
//       }

//       if (await Permission.mediaLibrary.isGranted) {
//         return true;
//       }
//     } else if (Platform.isIOS) {
//       var status = await Permission.photos.request();
//       return status.isGranted || status.isLimited; // Limited access also valid
//     }
//     return false;
//   }

//   void _submitShop() async {
//     log("🟢 _submitShop() called");

//     if (_mobileNumberController.text.isEmpty) {
//       log("❌ Mobile number is empty");
//       _showSnackbar("Please enter mobile number.", isError: true);
//       return;
//     }

//     final mobile = _mobileNumberController.text.trim();
//     log("📞 Sending OTP to: $mobile");

//     final sendOtpController = Provider.of<SendOtpController>(
//       context,
//       listen: false,
//     );

//     // Show loading dialog
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => const Center(child: CircularProgressIndicator()),
//     );

//     await sendOtpController.sendOtp(mobile);

//     // ignore: use_build_context_synchronously
//     Navigator.of(context).pop(); // remove loader

//     if (sendOtpController.otpResponse != null &&
//         sendOtpController.otpResponse!.success == true) {
//       log(
//         "✅ OTP sent successfully. Verification ID: ${sendOtpController.otpResponse!.verificationId}",
//       );
//       _showOtpDialog(mobile, sendOtpController.otpResponse!.verificationId);
//     } else {
//       log("❌ Failed to send OTP. Response: ${sendOtpController.otpResponse}");
//       _showSnackbar("Failed to send OTP. Please try again.", isError: true);
//     }
//   }

//   void _showOtpDialog(String mobile, String verificationId) {
//     final TextEditingController otpController = TextEditingController();
//     final verifyOtpController = Provider.of<VerifyOtpController>(
//       context,
//       listen: false,
//     );

//     log("📩 Showing OTP dialog for mobile: $mobile");

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) {
//         return Dialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Icon(Icons.lock, size: 40, color: Colors.blue),
//                 const SizedBox(height: 12),
//                 Text(
//                   "Verify OTP",
//                   style: Theme.of(context).textTheme.titleLarge,
//                 ),
//                 const SizedBox(height: 8),
//                 Text("Enter the OTP sent to $mobile"),
//                 const SizedBox(height: 16),
//                 TextField(
//                   controller: otpController,
//                   textAlign: TextAlign.center,
//                   maxLength: 6,
//                   keyboardType: TextInputType.number,
//                   decoration: InputDecoration(
//                     counterText: "",
//                     hintText: "------",
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   style: const TextStyle(
//                     letterSpacing: 8,
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     TextButton(
//                       onPressed: () {
//                         log("ℹ️ OTP dialog cancelled by user");
//                         Navigator.of(context).pop();
//                       },
//                       child: const Text("Cancel"),
//                     ),
//                     const SizedBox(width: 8),
//                     ElevatedButton.icon(
//                       onPressed: () async {
//                         final otp = otpController.text.trim();
//                         if (otp.isEmpty) {
//                           log("❌ OTP field is empty");
//                           _showSnackbar("Please enter OTP", isError: true);
//                           return;
//                         }

//                         log("📤 Verifying OTP: $otp for $mobile");

//                         // Show loader while verifying
//                         showDialog(
//                           context: context,
//                           barrierDismissible: false,
//                           builder:
//                               (_) => const Center(
//                                 child: CircularProgressIndicator(),
//                               ),
//                         );

//                         await verifyOtpController.verifyOtp(
//                           mobileNumber: mobile,
//                           otp: otp,
//                           verificationId: verificationId,
//                         );

//                         // ignore: use_build_context_synchronously
//                         Navigator.of(context).pop(); // close loader

//                         if (verifyOtpController.verifyOtpResponse != null &&
//                             verifyOtpController.verifyOtpResponse!.success ==
//                                 true) {
//                           log("✅ OTP verified successfully");
//                           // ignore: use_build_context_synchronously
//                           Navigator.of(context).pop(); // close OTP dialog
//                           _registerOrUpdateShop();
//                         } else {
//                           log(
//                             "❌ OTP verification failed. Response: ${verifyOtpController.verifyOtpResponse}",
//                           );
//                           _showSnackbar(
//                             "Invalid OTP. Please try again.",
//                             isError: true,
//                           );
//                         }
//                       },
//                       icon: const Icon(Icons.check_circle),
//                       label: const Text("Verify"),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   void _registerOrUpdateShop() async {
//     log("🟢 _registerOrUpdateShop() called");

//     final prefs = await SharedPreferences.getInstance();
//     final userId = prefs.getString('userId');

//     if (userId == null || userId.isEmpty) {
//       log("❌ User ID not found in SharedPreferences");
//       _showSnackbar("User ID not found. Please login again.", isError: true);
//       return;
//     }

//     // ignore: use_build_context_synchronously
//     final shopProvider = Provider.of<ShopProvider>(context, listen: false);

//     if (isEditing) {
//       log("✏️ Updating existing shop: ${widget.shopToEdit!.id}");
//       final updatedShopDetails = ShopeDetailsModel(
//         id: widget.shopToEdit!.id,
//         shopName: _shopNameController.text.trim(),
//         category: [_selectedCategory!],
//         sellerType: _selectedSellerType!,
//         state: _selectedState!,
//         place:
//             _placeController.text.trim().isEmpty
//                 ? null
//                 : _placeController.text.trim(),
//         pinCode: _pinCodeController.text.trim(),
//         locality:
//             _localityController.text.trim().isEmpty
//                 ? null
//                 : _localityController.text.trim(),
//         headerImage: _existingHeaderImageUrl ?? '',
//         email:
//             _emailController.text.trim().isEmpty
//                 ? null
//                 : _emailController.text.trim(),
//         agentCode:
//             _agentCodeController.text.trim().isEmpty
//                 ? null
//                 : _agentCodeController.text.trim(),
//         mobileNumber:
//             _mobileNumberController.text.trim().isEmpty
//                 ? null
//                 : _mobileNumberController.text.trim(),
//         landlineNumber:
//             _landlineNumberController.text.trim().isEmpty
//                 ? null
//                 : _landlineNumberController.text.trim(),
//       );
//       await shopProvider.updateShop(updatedShopDetails, _headerImage);
//     } else {
//       log("🆕 Registering new shop...");
//       final newShop = ShopModel(
//         shopName: _shopNameController.text.trim(),
//         category: [_selectedCategory!],
//         sellerType: _selectedSellerType!,
//         state: _selectedState!,
//         place:
//             _placeController.text.trim().isEmpty
//                 ? null
//                 : _placeController.text.trim(),
//         pinCode: _pinCodeController.text.trim(),
//         locality:
//             _localityController.text.trim().isEmpty
//                 ? null
//                 : _localityController.text.trim(),
//         headerImage: "",
//         email:
//             _emailController.text.trim().isEmpty
//                 ? null
//                 : _emailController.text.trim(),
//         mobileNumber:
//             _mobileNumberController.text.trim().isEmpty
//                 ? null
//                 : _mobileNumberController.text.trim(),
//         landlineNumber:
//             _landlineNumberController.text.trim().isEmpty
//                 ? null
//                 : _landlineNumberController.text.trim(),
//         agentCode:
//             _agentCodeController.text.trim().isEmpty
//                 ? null
//                 : _agentCodeController.text.trim(),
//       );

//       final createShop = await shopProvider.addShop(newShop, _headerImage);
//       if (createShop != null) {
//         log("✅ Shop registered successfully with ID: $createShop");
//         _showSnackbar('Shop registered successfully!');
//         // ignore: use_build_context_synchronously
//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(
//             builder: (context) => SubscriptionScreen(shopId: createShop),
//           ),
//         );
//         return;
//       } else {
//         log("❌ Shop registration failed. Provider returned null");
//       }
//     }

//     if (shopProvider.errorMessage.isNotEmpty) {
//       log("❌ Shop operation failed. Error: ${shopProvider.errorMessage}");
//       _showSnackbar(shopProvider.errorMessage, isError: true);
//     } else {
//       log(
//         isEditing
//             ? "✅ Shop updated successfully"
//             : "✅ Shop registered successfully",
//       );
//       _showSnackbar(
//         isEditing
//             ? "Shop updated successfully!"
//             : "Shop registered successfully!",
//       );

//       log("🔄 Refreshing related data...");
//       // ignore: use_build_context_synchronously
//       Provider.of<HomeProductController>(context, listen: false).loadProducts();
//       // ignore: use_build_context_synchronously
//       Provider.of<ShopProvider>(context, listen: false).fetchShops();
//       // ignore: use_build_context_synchronously
//       Provider.of<ShopOfUserProvider>(context, listen: false).fetchUserShops();

//       // ignore: use_build_context_synchronously
//       Navigator.of(context).pop(true);
//     }
//   }

//   void _showSnackbar(String message, {bool isError = false}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor:
//             isError ? Colors.red : const Color.fromARGB(255, 7, 3, 201),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         margin: const EdgeInsets.all(10),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         appBar: PreferredSize(
//           preferredSize: const Size.fromHeight(60),
//           child: AppBar(
//             automaticallyImplyLeading: true,
//             backgroundColor: const Color.fromARGB(255, 7, 3, 201),
//             shape: const RoundedRectangleBorder(
//               borderRadius: BorderRadius.only(
//                 bottomLeft: Radius.circular(25),
//                 bottomRight: Radius.circular(25),
//               ),
//             ),
//             title: Text(
//               isEditing ? "Edit Shop" : "Add Shop",
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             iconTheme: const IconThemeData(color: Colors.white),
//           ),
//         ),
//         backgroundColor: Colors.white,
//         body: Consumer<ShopProvider>(
//           builder: (context, shopProvider, child) {
//             return Consumer<CategoryController>(
//               builder: (context, categoryController, _) {
//                 return SingleChildScrollView(
//                   padding: const EdgeInsets.all(16),
//                   child: Form(
//                     key: _formKey,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         _buildLabel("Shop Name"),
//                         _buildTextField(
//                           _shopNameController,
//                           "Enter shop name",
//                           textCapitalization: TextCapitalization.words,
//                         ),
//                         _buildLabel("Category"),
//                         categoryController.isLoading
//                             ? const Center(child: CircularProgressIndicator())
//                             : _buildDropdown<String>(
//                               "Select Category",
//                               _selectedCategory,
//                               categoryController.categoryList,
//                               (value) =>
//                                   setState(() => _selectedCategory = value),
//                             ),
//                         _buildLabel("Seller Type"),
//                         _buildDropdown(
//                           "Select seller type",
//                           _selectedSellerType,
//                           sellerTypes,
//                           (value) =>
//                               setState(() => _selectedSellerType = value),
//                         ),
//                         _buildLabel("State"),
//                         _buildDropdown(
//                           "Select state",
//                           _selectedState,
//                           states,
//                           (value) => setState(() => _selectedState = value),
//                         ),
//                         _buildLabel("District"),
//                         // _buildTextField(
//                         //   // _localityController
//                         //   _placeController,
//                         //   "Enter District",
//                         //   textCapitalization: TextCapitalization.words,
//                         // ),
//                         _buildLabel("Place"),
//                         _buildTextField(
//                           // _placeController
//                           _localityController,
//                           "Enter Place",
//                           textCapitalization: TextCapitalization.words,
//                         ),
//                         _buildLabel("Pin Code"),
//                         _buildTextField(
//                           _pinCodeController,
//                           "Enter pin code",
//                           isNumeric: true,
//                         ),
//                         const SizedBox(height: 20),

//                         // Location Button with better UX
//                         Container(
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(12),
//                             border: Border.all(
//                               color: Colors.blue.shade100,
//                               width: 1.5,
//                             ),
//                             color: Colors.blue.shade50,
//                           ),
//                           child: Material(
//                             color: Colors.transparent,
//                             child: InkWell(
//                               onTap: () async {
//                                 try {
//                                   log("📍 Starting location fetch process...");

//                                   // Show loading state

//                                   // ✅ Step 1: Check if location service is enabled
//                                   log(
//                                     "🔍 Checking if location services are enabled...",
//                                   );
//                                   bool serviceEnabled =
//                                       await Geolocator.isLocationServiceEnabled();
//                                   log(
//                                     "📍 Location service enabled: $serviceEnabled",
//                                   );

//                                   if (!serviceEnabled) {
//                                     log("❌ Location services are disabled");
//                                     // ignore: use_build_context_synchronously
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       SnackBar(
//                                         content: const Text(
//                                           "Please enable location services",
//                                         ),
//                                         action: SnackBarAction(
//                                           label: 'Settings',
//                                           textColor: Colors.white,
//                                           onPressed: () => openAppSettings(),
//                                         ),
//                                       ),
//                                     );
//                                     return;
//                                   }

//                                   // ✅ Step 2: Check permissions
//                                   log("🔍 Checking location permissions...");
//                                   LocationPermission permission =
//                                       await Geolocator.checkPermission();
//                                   log(
//                                     "📍 Current permission status: $permission",
//                                   );

//                                   if (permission == LocationPermission.denied) {
//                                     log("📋 Requesting location permission...");
//                                     permission =
//                                         await Geolocator.requestPermission();
//                                     log(
//                                       "📍 New permission status: $permission",
//                                     );

//                                     if (permission ==
//                                         LocationPermission.denied) {
//                                       log(
//                                         "❌ Location permission denied by user",
//                                       );
//                                       ScaffoldMessenger.of(
//                                         // ignore: use_build_context_synchronously
//                                         context,
//                                       ).showSnackBar(
//                                         const SnackBar(
//                                           content: Text(
//                                             "Location permission denied",
//                                           ),
//                                         ),
//                                       );
//                                       return;
//                                     }
//                                   }

//                                   if (permission ==
//                                       LocationPermission.deniedForever) {
//                                     log(
//                                       "❌ Location permissions permanently denied",
//                                     );
//                                     // ignore: use_build_context_synchronously
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       SnackBar(
//                                         content: const Text(
//                                           "Location permissions are permanently denied. Enable them in settings.",
//                                         ),
//                                         action: SnackBarAction(
//                                           label: 'Settings',
//                                           textColor: Colors.white,
//                                           onPressed: () => openAppSettings(),
//                                         ),
//                                       ),
//                                     );
//                                     return;
//                                   }

//                                   // Show loading indicator
//                                   showDialog(
//                                     // ignore: use_build_context_synchronously
//                                     context: context,
//                                     barrierDismissible: false,
//                                     builder:
//                                         (context) => AlertDialog(
//                                           backgroundColor: Colors.white,
//                                           shape: RoundedRectangleBorder(
//                                             borderRadius: BorderRadius.circular(
//                                               16,
//                                             ),
//                                           ),
//                                           content: Column(
//                                             mainAxisSize: MainAxisSize.min,
//                                             children: [
//                                               const CircularProgressIndicator(
//                                                 valueColor:
//                                                     AlwaysStoppedAnimation<
//                                                       Color
//                                                     >(Colors.blue),
//                                               ),
//                                               const SizedBox(height: 16),
//                                               Text(
//                                                 "Getting your location...",
//                                                 style: TextStyle(
//                                                   fontSize: 16,
//                                                   fontWeight: FontWeight.w500,
//                                                   color: Colors.grey.shade700,
//                                                 ),
//                                               ),
//                                               const SizedBox(height: 8),
//                                               Text(
//                                                 "This may take a few seconds",
//                                                 style: TextStyle(
//                                                   fontSize: 12,
//                                                   color: Colors.grey.shade500,
//                                                 ),
//                                                 textAlign: TextAlign.center,
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                   );

//                                   // ✅ Step 3: Get current position
//                                   log("🎯 Fetching current position...");
//                                   Position position =
//                                       await Geolocator.getCurrentPosition(
//                                         // ignore: deprecated_member_use
//                                         desiredAccuracy: LocationAccuracy.best,
//                                         // ignore: deprecated_member_use
//                                         timeLimit: const Duration(seconds: 15),
//                                       );

//                                   log("📍 Position obtained:");
//                                   log("   • Latitude: ${position.latitude}");
//                                   log("   • Longitude: ${position.longitude}");
//                                   log(
//                                     "   • Accuracy: ${position.accuracy} meters",
//                                   );

//                                   // ✅ Step 4: Reverse geocode to get address details
//                                   log("🏠 Reverse geocoding coordinates...");
//                                   List<Placemark> placemarks =
//                                       await placemarkFromCoordinates(
//                                         position.latitude,
//                                         position.longitude,
//                                       );

//                                   log(
//                                     "📍 Found ${placemarks.length} placemark(s)",
//                                   );

//                                   // Close loading dialog
//                                   // ignore: use_build_context_synchronously
//                                   if (Navigator.of(context).canPop()) {
//                                     // ignore: use_build_context_synchronously
//                                     Navigator.of(context).pop();
//                                   }

//                                   if (placemarks.isNotEmpty) {
//                                     final place = placemarks.first;

//                                     log("🏠 Address details:");
//                                     log("   • Country: ${place.country}");
//                                     log(
//                                       "   • Administrative Area: ${place.administrativeArea}",
//                                     );
//                                     log(
//                                       "   • Sub-Administrative Area: ${place.subAdministrativeArea}",
//                                     );
//                                     log("   • Locality: ${place.locality}");
//                                     log(
//                                       "   • Postal Code: ${place.postalCode}",
//                                     );

//                                     setState(() {
//                                       _placeController.text =
//                                           place.subAdministrativeArea ?? '';
//                                       _pinCodeController.text =
//                                           place.postalCode ?? '';
//                                       _localityController.text =
//                                           place.locality ?? '';
//                                       _selectedState =
//                                           place.administrativeArea ??
//                                           _selectedState;
//                                     });

//                                     log("✅ Address fields populated:");
//                                     log(
//                                       "   • District: ${place.subAdministrativeArea}",
//                                     );
//                                     log("   • Pin Code: ${place.postalCode}");
//                                     log("   • Place: ${place.locality}");
//                                     log(
//                                       "   • State: ${place.administrativeArea}",
//                                     );

//                                     // Show success feedback
//                                     // ignore: use_build_context_synchronously
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       SnackBar(
//                                         content: Row(
//                                           children: [
//                                             Icon(
//                                               Icons.check_circle,
//                                               color: Colors.green.shade100,
//                                               size: 20,
//                                             ),
//                                             const SizedBox(width: 8),
//                                             const Text(
//                                               "Location detected successfully!",
//                                             ),
//                                           ],
//                                         ),
//                                         backgroundColor: Colors.green.shade600,
//                                         behavior: SnackBarBehavior.floating,
//                                         shape: RoundedRectangleBorder(
//                                           borderRadius: BorderRadius.circular(
//                                             8,
//                                           ),
//                                         ),
//                                       ),
//                                     );
//                                   } else {
//                                     log(
//                                       "❌ No placemarks found for coordinates",
//                                     );
//                                     // ignore: use_build_context_synchronously
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       const SnackBar(
//                                         content: Text(
//                                           "Unable to get address details",
//                                         ),
//                                         backgroundColor: Colors.orange,
//                                       ),
//                                     );
//                                   }

//                                   log(
//                                     "✅ Location fetch process completed successfully",
//                                   );
//                                 } catch (e, stackTrace) {
//                                   // Close loading dialog if still open
//                                   // ignore: use_build_context_synchronously
//                                   if (Navigator.of(context).canPop()) {
//                                     // ignore: use_build_context_synchronously
//                                     Navigator.of(context).pop();
//                                   }

//                                   log("❌ Error fetching location: $e");
//                                   log("📋 Stack trace: $stackTrace");

//                                   // ignore: use_build_context_synchronously
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     SnackBar(
//                                       content: Row(
//                                         children: [
//                                           Icon(
//                                             Icons.error_outline,
//                                             color: Colors.red.shade100,
//                                             size: 20,
//                                           ),
//                                           const SizedBox(width: 8),
//                                           Text(
//                                             "Failed to get location: ${e.toString()}",
//                                           ),
//                                         ],
//                                       ),
//                                       backgroundColor: Colors.red.shade600,
//                                       behavior: SnackBarBehavior.floating,
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(8),
//                                       ),
//                                     ),
//                                   );
//                                 }
//                               },
//                               borderRadius: BorderRadius.circular(12),
//                               child: Container(
//                                 padding: const EdgeInsets.all(16),
//                                 child: Row(
//                                   children: [
//                                     Container(
//                                       padding: const EdgeInsets.all(12),
//                                       decoration: BoxDecoration(
//                                         color: Colors.blue.shade100,
//                                         shape: BoxShape.circle,
//                                       ),
//                                       child: Icon(
//                                         Icons.my_location,
//                                         color: Colors.blue.shade800,
//                                         size: 24,
//                                       ),
//                                     ),
//                                     const SizedBox(width: 16),
//                                     Expanded(
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           Text(
//                                             "Use Your Current Location",
//                                             style: TextStyle(
//                                               fontSize: 16,
//                                               fontWeight: FontWeight.w600,
//                                               color: Colors.blue.shade800,
//                                             ),
//                                           ),
//                                           const SizedBox(height: 4),
//                                           Text(
//                                             "Auto-fill  using GPS",
//                                             style: TextStyle(
//                                               fontSize: 12,
//                                               color: Colors.blue.shade600,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                     Icon(
//                                       Icons.chevron_right,
//                                       color: Colors.blue.shade600,
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 20),
//                         _buildTextField(
//                           // _localityController
//                           _placeController,
//                           "Enter District",
//                           textCapitalization: TextCapitalization.words,
//                         ),
//                         _buildLabel("Agent Code"),
//                         _buildTextField(
//                           _agentCodeController,
//                           "Enter agent code",
//                         ),
//                         // New fields
//                         _buildLabel("Email"),
//                         _buildTextField(
//                           _emailController,
//                           "Enter email address",
//                           isEmail: true,
//                         ),
//                         _buildLabel("Mobile Number"),
//                         Consumer<AllShopController>(
//                           builder: (context, shopController, _) {
//                             return StatefulBuilder(
//                               builder: (context, setState) {
//                                 return TextFormField(
//                                   controller: _mobileNumberController,
//                                   keyboardType: TextInputType.phone,
//                                   decoration: InputDecoration(
//                                     hintText: "Enter mobile number",
//                                     errorText:
//                                         _mobileNumberController
//                                                     .text
//                                                     .isNotEmpty &&
//                                                 shopController.isMobileExists(
//                                                   _mobileNumberController.text
//                                                       .trim(),
//                                                 )
//                                             ? "This number is already registered"
//                                             : null,
//                                     border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(
//                                         12,
//                                       ), // ✅ curved edges
//                                       borderSide: const BorderSide(
//                                         color: Colors.grey,
//                                       ),
//                                     ),
//                                     enabledBorder: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(
//                                         12,
//                                       ), // ✅ curved edges
//                                       borderSide: BorderSide(
//                                         color: Colors.grey.shade400,
//                                       ),
//                                     ),
//                                     focusedBorder: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(
//                                         12,
//                                       ), // ✅ curved edges
//                                       borderSide: const BorderSide(
//                                         color: Color.fromARGB(255, 7, 3, 201),
//                                         width: 2,
//                                       ),
//                                     ),
//                                     contentPadding: const EdgeInsets.symmetric(
//                                       horizontal: 16,
//                                       vertical: 12,
//                                     ),
//                                   ),
//                                   onChanged: (value) {
//                                     setState(() {}); // rebuild on typing
//                                   },
//                                 );
//                               },
//                             );
//                           },
//                         ),

//                         _buildLabel("Landline Number (Optional)"),
//                         _buildTextField(
//                           _landlineNumberController,
//                           "Enter landline number",
//                           isNumeric: true,
//                           isOptional: true, // Mark as optional
//                         ),

//                         const SizedBox(height: 20),
//                         _buildLabel("Shop Image"),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 0,
//                             vertical: 4,
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 children: [
//                                   // Camera button
//                                   ElevatedButton.icon(
//                                     onPressed: () => _pickImageFromCamera(),
//                                     icon: const Icon(
//                                       Icons.photo_camera,
//                                       color: Color.fromARGB(255, 7, 3, 201),
//                                     ),
//                                     label: const Text(
//                                       "Camera",
//                                       style: TextStyle(
//                                         color: Color.fromARGB(255, 7, 3, 201),
//                                       ),
//                                     ),
//                                     style: ElevatedButton.styleFrom(
//                                       backgroundColor: Colors.white,
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(8),
//                                         side: const BorderSide(
//                                           color: Color.fromARGB(255, 7, 3, 201),
//                                         ),
//                                       ),
//                                       padding: const EdgeInsets.symmetric(
//                                         horizontal: 16,
//                                         vertical: 12,
//                                       ),
//                                     ),
//                                   ),
//                                   const SizedBox(width: 10),

//                                   // Gallery button
//                                   ElevatedButton.icon(
//                                     onPressed: () => _pickImageFromGallery(),
//                                     icon: const Icon(
//                                       Icons.photo_library,
//                                       color: Color.fromARGB(255, 7, 3, 201),
//                                     ),
//                                     label: const Text(
//                                       "Gallery",
//                                       style: TextStyle(
//                                         color: Color.fromARGB(255, 7, 3, 201),
//                                       ),
//                                     ),
//                                     style: ElevatedButton.styleFrom(
//                                       backgroundColor: Colors.white,
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(8),
//                                         side: const BorderSide(
//                                           color: Color.fromARGB(255, 7, 3, 201),
//                                         ),
//                                       ),
//                                       padding: const EdgeInsets.symmetric(
//                                         horizontal: 16,
//                                         vertical: 12,
//                                       ),
//                                     ),
//                                   ),

//                                   const SizedBox(width: 10),
//                                 ],
//                               ),

//                               const SizedBox(height: 10),
//                               if (_headerImage != null)
//                                 ClipRRect(
//                                   borderRadius: BorderRadius.circular(8),
//                                   child: Image.file(
//                                     _headerImage!, // Use _headerImage for display
//                                     height: 100,
//                                     width: 100,
//                                     fit: BoxFit.cover,
//                                   ),
//                                 )
//                               else if (_existingHeaderImageUrl != null &&
//                                   _existingHeaderImageUrl!.isNotEmpty)
//                                 ClipRRect(
//                                   borderRadius: BorderRadius.circular(8),
//                                   child: Image.network(
//                                     // Use Image.network for existing URLs
//                                     _existingHeaderImageUrl!,
//                                     height: 100,
//                                     width: 100,
//                                     fit: BoxFit.cover,
//                                     errorBuilder:
//                                         (context, error, stackTrace) =>
//                                             Container(
//                                               height: 100,
//                                               width: 100,
//                                               color: Colors.grey.shade300,
//                                               child: const Icon(
//                                                 Icons.broken_image,
//                                                 size: 40,
//                                                 color: Colors.grey,
//                                               ),
//                                             ),
//                                   ),
//                                 )
//                               else
//                                 Container(
//                                   height: 100,
//                                   width: 100,
//                                   decoration: BoxDecoration(
//                                     color: Colors.grey.shade200,
//                                     borderRadius: BorderRadius.circular(8),
//                                     border: Border.all(
//                                       color: Colors.grey.shade400,
//                                     ),
//                                   ),
//                                   child: const Center(
//                                     child: Text(
//                                       "No image selected",
//                                       textAlign: TextAlign.center,
//                                       style: TextStyle(color: Colors.grey),
//                                     ),
//                                   ),
//                                 ),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(height: 20),

//                         // ElevatedButton.icon(
//                         //   onPressed: () async {
//                         //     try {
//                         //       log("📍 Starting location fetch process...");

//                         //       // ✅ Step 1: Check if location service is enabled
//                         //       log(
//                         //         "🔍 Checking if location services are enabled...",
//                         //       );
//                         //       bool serviceEnabled =
//                         //           await Geolocator.isLocationServiceEnabled();
//                         //       log(
//                         //         "📍 Location service enabled: $serviceEnabled",
//                         //       );

//                         //       if (!serviceEnabled) {
//                         //         log("❌ Location services are disabled");
//                         //         ScaffoldMessenger.of(context).showSnackBar(
//                         //           const SnackBar(
//                         //             content: Text(
//                         //               "Please enable location services",
//                         //             ),
//                         //           ),
//                         //         );
//                         //         return;
//                         //       }

//                         //       // ✅ Step 2: Check permissions
//                         //       log("🔍 Checking location permissions...");
//                         //       LocationPermission permission =
//                         //           await Geolocator.checkPermission();
//                         //       log("📍 Current permission status: $permission");

//                         //       if (permission == LocationPermission.denied) {
//                         //         log("📋 Requesting location permission...");
//                         //         permission =
//                         //             await Geolocator.requestPermission();
//                         //         log("📍 New permission status: $permission");

//                         //         if (permission == LocationPermission.denied) {
//                         //           log("❌ Location permission denied by user");
//                         //           ScaffoldMessenger.of(context).showSnackBar(
//                         //             const SnackBar(
//                         //               content: Text(
//                         //                 "Location permission denied",
//                         //               ),
//                         //             ),
//                         //           );
//                         //           return;
//                         //         }
//                         //       }

//                         //       if (permission ==
//                         //           LocationPermission.deniedForever) {
//                         //         log(
//                         //           "❌ Location permissions permanently denied",
//                         //         );
//                         //         ScaffoldMessenger.of(context).showSnackBar(
//                         //           const SnackBar(
//                         //             content: Text(
//                         //               "Location permissions are permanently denied. Enable them in settings.",
//                         //             ),
//                         //           ),
//                         //         );
//                         //         return;
//                         //       }

//                         //       // ✅ Step 3: Get current position
//                         //       log("🎯 Fetching current position...");
//                         //       Position position =
//                         //           await Geolocator.getCurrentPosition(
//                         //             desiredAccuracy: LocationAccuracy.high,
//                         //           );

//                         //       log("📍 Position obtained:");
//                         //       log("   • Latitude: ${position.latitude}");
//                         //       log("   • Longitude: ${position.longitude}");
//                         //       log("   • Accuracy: ${position.accuracy} meters");
//                         //       log("   • Altitude: ${position.altitude} meters");
//                         //       log("   • Speed: ${position.speed} m/s");
//                         //       log("   • Heading: ${position.heading}°");
//                         //       log("   • Timestamp: ${position.timestamp}");

//                         //       // ✅ Step 4: Reverse geocode to get address details
//                         //       log("🏠 Reverse geocoding coordinates...");
//                         //       List<Placemark> placemarks =
//                         //           await placemarkFromCoordinates(
//                         //             position.latitude,
//                         //             position.longitude,
//                         //           );

//                         //       log("📍 Found ${placemarks.length} placemark(s)");

//                         //       if (placemarks.isNotEmpty) {
//                         //         final place = placemarks.first;

//                         //         log("🏠 Address details:");
//                         //         log("   • Country: ${place.country}");
//                         //         log(
//                         //           "   • Administrative Area: ${place.administrativeArea}",
//                         //         );
//                         //         log(
//                         //           "   • Sub-Administrative Area: ${place.subAdministrativeArea}",
//                         //         );
//                         //         log("   • Locality: ${place.locality}");
//                         //         log("   • Sub-Locality: ${place.subLocality}");
//                         //         log("   • Thoroughfare: ${place.thoroughfare}");
//                         //         log(
//                         //           "   • Sub-Thoroughfare: ${place.subThoroughfare}",
//                         //         );
//                         //         log("   • Postal Code: ${place.postalCode}");
//                         //         log(
//                         //           "   • ISO Country Code: ${place.isoCountryCode}",
//                         //         );

//                         //         setState(() {
//                         //           _placeController.text =
//                         //               place.subAdministrativeArea ?? '';
//                         //           _pinCodeController.text =
//                         //               place.postalCode ?? '';
//                         //           _localityController.text =
//                         //               place.locality ?? '';
//                         //           _selectedState =
//                         //               place.administrativeArea ??
//                         //               _selectedState;
//                         //         });

//                         //         log("✅ Address fields populated:");
//                         //         log(
//                         //           "   • District (subAdministrativeArea): ${place.subAdministrativeArea}",
//                         //         );
//                         //         log("   • Pin Code: ${place.postalCode}");
//                         //         log("   • Place (locality): ${place.locality}");
//                         //         log("   • State: ${place.administrativeArea}");
//                         //       } else {
//                         //         log("❌ No placemarks found for coordinates");
//                         //         ScaffoldMessenger.of(context).showSnackBar(
//                         //           const SnackBar(
//                         //             content: Text(
//                         //               "Unable to get address details",
//                         //             ),
//                         //           ),
//                         //         );
//                         //       }

//                         //       log(
//                         //         "✅ Location fetch process completed successfully",
//                         //       );
//                         //     } catch (e, stackTrace) {
//                         //       log("❌ Error fetching location: $e");
//                         //       log("📋 Stack trace: $stackTrace");
//                         //       ScaffoldMessenger.of(context).showSnackBar(
//                         //         SnackBar(
//                         //           content: Text("Error fetching location: $e"),
//                         //         ),
//                         //       );
//                         //     }
//                         //   },
//                         //   style: ElevatedButton.styleFrom(
//                         //     backgroundColor: Colors.blue.shade700,
//                         //     foregroundColor: Colors.white,
//                         //     minimumSize: const Size(double.infinity, 50),
//                         //     shape: RoundedRectangleBorder(
//                         //       borderRadius: BorderRadius.circular(12),
//                         //     ),
//                         //   ),
//                         //   icon: const Icon(Icons.my_location),
//                         //   label: const Text(
//                         //     "Use Your Location",
//                         //     style: TextStyle(color: Colors.white, fontSize: 18),
//                         //   ),
//                         // ),
//                         // const SizedBox(height: 20),
//                         SizedBox(
//                           width: double.infinity,
//                           child: ElevatedButton(
//                             onPressed:
//                                 shopProvider.isLoading ? null : _submitShop,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: const Color(0XFF094497),
//                               padding: const EdgeInsets.symmetric(vertical: 14),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                             ),
//                             child:
//                                 shopProvider.isLoading
//                                     ? const CircularProgressIndicator(
//                                       color: Colors.white,
//                                     )
//                                     : Text(
//                                       isEditing ? "Update Shop" : "Send OTP",
//                                       style: const TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 18,
//                                       ),
//                                     ),
//                           ),
//                         ),
//                         const SizedBox(height: 20), // Add some bottom padding
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }

//   // --- Reusable Widgets (made private to this class) ---

//   Widget _buildLabel(String text) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
//       child: Text(
//         text,
//         style: const TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.bold,
//           color: Colors.black,
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField(
//     TextEditingController controller,
//     String hintText, {
//     bool isNumeric = false,
//     bool isEmail = false,
//     bool isOptional = false,
//     TextCapitalization textCapitalization =
//         TextCapitalization.none, // Added new parameter
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: TextFormField(
//         controller: controller,
//         keyboardType:
//             isNumeric
//                 ? TextInputType.number
//                 : (isEmail ? TextInputType.emailAddress : TextInputType.text),
//         textCapitalization: textCapitalization, // Applied the new parameter
//         validator: (value) {
//           if (!isOptional && (value == null || value.isEmpty)) {
//             return "This field is required";
//           }
//           if (isNumeric && value!.isNotEmpty && int.tryParse(value) == null) {
//             return "Please enter a valid number";
//           }
//           if (isEmail &&
//               value!.isNotEmpty &&
//               !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
//             return "Please enter a valid email";
//           }
//           return null;
//         },
//         decoration: InputDecoration(
//           hintText: hintText,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: const BorderSide(color: Colors.grey),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: Colors.grey.shade400),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: const BorderSide(
//               color: Color.fromARGB(255, 7, 3, 201),
//               width: 2,
//             ),
//           ),
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 16,
//             vertical: 12,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildDropdown<T>(
//     String hint,
//     T? selectedValue,
//     List<T> items,
//     void Function(T?) onChanged,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: DropdownButtonFormField<T>(
//         value: selectedValue,
//         isExpanded: true,
//         decoration: InputDecoration(
//           hintText: hint,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: const BorderSide(color: Colors.grey),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: Colors.grey.shade400),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: const BorderSide(
//               color: Color.fromARGB(255, 7, 3, 201),
//               width: 2,
//             ),
//           ),
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 16,
//             vertical: 12,
//           ),
//         ),
//         hint: Text(hint),
//         items:
//             items
//                 .map(
//                   (item) => DropdownMenuItem<T>(
//                     value: item,
//                     child: Text(item.toString()),
//                   ),
//                 )
//                 .toList(),
//         onChanged: onChanged,
//         validator: (value) => value == null ? "Please select an option" : null,
//       ),
//     );
//   }
// }
