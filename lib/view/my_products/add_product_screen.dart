import 'dart:async'; // Add this import for Timer
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:poketstore/controllers/my_shope_controller/add_product_controller.dart';
import 'package:poketstore/controllers/shop_of_user_controller/shop_of_user_controller.dart';
import 'package:poketstore/controllers/category_controller/category_controller.dart';
import 'package:poketstore/utilities/image_crop_product.dart';
import 'package:poketstore/utilities/image_crop_screen_shop.dart';
import 'package:poketstore/view/subscription/subscription.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddProductScreen extends StatefulWidget {
  final String? shopId;
  const AddProductScreen({super.key, this.shopId});

  @override
  // ignore: library_private_types_in_public_api
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  File? _selectedImage;
  final _formKey = GlobalKey<FormState>();
  bool _showSubscriptionError = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _estimatedTimeController =
      TextEditingController();

  String? _selectedType;
  String? _selectedDeliveryOption;
  String? _selectedAvailability;
  String? _selectedItemType; // product or service
  final FocusNode _pageFocusNode = FocusNode();
  final List<String> _itemTypeOptions = ["Product", "Service"];
  final List<String> _selectedCategories = [];
  // String? _selectedShopId;
  final List<String> _typeOptions = ["nos", "kg", "liter", "per_service"];
  final List<String> _deliveryOptions = ["Home Delivery", "Store Pickup"];
  final List<String> _availabilityOptions = ["Available", "Out of Stock"];
  bool _pageLoading = true;
  bool get isService => _selectedItemType == "Service";
  Timer? _refreshTimer; // Add timer for auto-refresh

  @override
  void initState() {
    super.initState();
    widget.shopId;

    // Initial data load
    _loadInitialData();

    // Start auto-refresh timer
    _startAutoRefresh();
  }

  @override
  void dispose() {
    // Cancel timer when screen is disposed
    _refreshTimer?.cancel();
    _pageFocusNode.dispose();
    super.dispose();
  }

  void _startAutoRefresh() {
    // Refresh every 2 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        _refreshData();
      }
    });
  }

  Future<void> _loadInitialData() async {
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _refreshData();
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() {
          _pageLoading = false;
        });
      }
    });
  }

  Future<void> _refreshData() async {
    // Refresh shop data
    try {
      final shopProvider = Provider.of<ShopOfUserProvider>(
        context,
        listen: false,
      );
      await shopProvider.fetchUserShops();

      // Refresh categories
      final categoryProvider = Provider.of<CategoryController>(
        context,
        listen: false,
      );
      await categoryProvider.loadCategories();

      // If you need to refresh other data, add it here

      // Only update UI if data actually changed
      if (mounted) {
        setState(() {
          // Update any state variables if needed
        });
      }
    } catch (e) {
      print('Error refreshing data: $e');
      // You can show a snackbar or handle error silently
    }
  }

  Future<void> _pickImageFromGallery() async {
    final status = await Permission.photos.request();
    if (status.isGranted) {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        final croppedImage = await Navigator.push(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    CropImageScreenProduct(imageFile: File(pickedFile.path)),
          ),
        );
        if (croppedImage != null && croppedImage is File) {
          FocusScope.of(context).unfocus();
          setState(() {
            _selectedImage = croppedImage;
          });
        }
      }
    } else {
      // ignore: use_build_context_synchronously
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
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    CropImageScreenProduct(imageFile: File(pickedFile.path)),
          ),
        );
        if (croppedImage != null && croppedImage is File) {
          FocusScope.of(context).unfocus();
          setState(() {
            _selectedImage = croppedImage;
          });
        }
      }
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Camera permission denied!")),
      );
    }
  }

  Future<void> _submitProduct(BuildContext context) async {
    // Pause auto-refresh during form submission to avoid conflicts
    _refreshTimer?.cancel();

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("User not authenticated")));
      _startAutoRefresh(); // Resume auto-refresh
      return;
    }

    // Only validate required fields: name, price, quantity, type
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Product name is required")));
      _startAutoRefresh();
      return;
    }
    if (_selectedItemType == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Item type is required")));
      _startAutoRefresh();
      return;
    }
    if (_priceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Price is required")));
      _startAutoRefresh();
      return;
    }

    // if (_quantityController.text.trim().isEmpty) {
    //   ScaffoldMessenger.of(
    //     context,
    //   ).showSnackBar(const SnackBar(content: Text("Quantity is required")));
    //   _startAutoRefresh();
    //   return;
    // }

    if (_selectedType == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Unit type is required")));
      _startAutoRefresh();
      return;
    }

    // Validate numeric fields
    final price = int.tryParse(_priceController.text.trim());
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Invalid price")));
      _startAutoRefresh();
      return;
    }

    int? quantity;

    if (!isService) {
      quantity = int.tryParse(_quantityController.text.trim());
      if (quantity == null || quantity <= 0) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Invalid stock quantity")));
        _startAutoRefresh();
        return;
      }
    }

    final provider = Provider.of<ProductProvider>(context, listen: false);

    await provider.createProduct(
      userId: userId,
      shopId: widget.shopId!,
      name: _nameController.text.trim(),
      description:
          _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(), // Optional
      productImage: _selectedImage, // Optional
      price: price,
      quantity: isService ? null : quantity,
      estimatedTime:
          _estimatedTimeController.text.trim().isEmpty
              ? null
              : _estimatedTimeController.text.trim(), // Optional
      unitType: _selectedType, // Required
      itemType: _selectedItemType!.toLowerCase(),
      deliveryOption: _selectedDeliveryOption, // Optional
    );

    // ✅ SUCCESS
    if (provider.product != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Product added successfully")),
      );
      Navigator.pop(context, true);
    }
    // ❌ NORMAL ERROR (not subscription)
    else if (!provider.subscriptionRequired) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? "Failed to create product"),
        ),
      );
    }

    _startAutoRefresh(); // Resume auto-refresh after submission
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    Provider.of<ShopOfUserProvider>(context);
    Provider.of<CategoryController>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 7, 3, 201),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Add Product",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(25),
            bottomRight: Radius.circular(25),
          ),
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [_buildSubscriptionErrorSection(productProvider)],
                ),
              ),
              Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Shop ID display (read-only)
                      // Container(
                      //   width: double.infinity,
                      //   padding: const EdgeInsets.all(16),
                      //   margin: const EdgeInsets.only(bottom: 15),
                      //   decoration: BoxDecoration(
                      //     color: Colors.grey.shade100,
                      //     borderRadius: BorderRadius.circular(10),
                      //     border: Border.all(color: Colors.grey.shade300),
                      //   ),
                      //   child: Column(
                      //     crossAxisAlignment: CrossAxisAlignment.start,
                      //     children: [
                      //       const Text(
                      //         "Shop ID",
                      //         style: TextStyle(
                      //           fontSize: 14,
                      //           fontWeight: FontWeight.bold,
                      //           color: Colors.black54,
                      //         ),
                      //       ),
                      //       const SizedBox(height: 4),
                      //       Text(
                      //         widget.shopId ?? "No shop selected",
                      //         style: const TextStyle(
                      //           fontSize: 16,
                      //           fontWeight: FontWeight.w500,
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      _buildRequiredDropdownField(
                        "Item Type *",
                        _selectedItemType,
                        _itemTypeOptions,
                        (value) {
                          setState(() {
                            _selectedItemType = value;
                          });
                        },
                      ),
                      // Required fields with asterisk
                      _buildRequiredTextField(
                        "Name *",
                        _nameController,
                        hintText:
                            isService
                                ? "e.g., Home Cleaning"
                                : "e.g., Organic Apples",
                      ),

                      _buildRequiredDropdownField(
                        " Unit Type *",
                        _selectedType,
                        _typeOptions,
                        (value) => setState(() => _selectedType = value),
                      ),

                      _buildRequiredTextField(
                        "Price *",
                        _priceController,
                        isNumber: true,
                        hintText: "e.g., 250",
                      ),

                      if (!isService)
                        _buildRequiredTextField(
                          "Stock Quantity *",
                          _quantityController,
                          isNumber: true,
                          hintText: "e.g., 100",
                        ),

                      // Optional fields (no asterisk, no validation)
                      if (!isService)
                        _buildTextField(
                          "Description (Optional)",
                          _descriptionController,
                          isDescription: true,
                        ),

                      const SizedBox(height: 15),

                      if (!isService)
                        _buildDropdownField(
                          "Delivery Option (Optional)",
                          _selectedDeliveryOption,
                          _deliveryOptions,
                          (value) =>
                              setState(() => _selectedDeliveryOption = value),
                        ),

                      if (!isService)
                        _buildTextField(
                          "Estimated Delivery Time (Optional)",
                          _estimatedTimeController,
                        ),

                      // _buildDropdownField(
                      //   "Availability Status (Optional)",
                      //   _selectedAvailability,
                      //   _availabilityOptions,
                      //   (value) => setState(() => _selectedAvailability = value),
                      // ),
                      const SizedBox(height: 15),

                      // Image picker (optional)
                      _buildImagePicker(),

                      const SizedBox(height: 25),

                      // productProvider.isLoading
                      //     ? const Center(child: CircularProgressIndicator())
                      //     : SizedBox(
                      //       width: double.infinity,
                      //       child: ElevatedButton(
                      //         onPressed: () => _submitProduct(context),
                      //         style: ElevatedButton.styleFrom(
                      //           backgroundColor: const Color.fromARGB(
                      //             255,
                      //             7,
                      //             3,
                      //             201,
                      //           ),
                      //           foregroundColor: Colors.white,
                      //           padding: const EdgeInsets.symmetric(vertical: 16),
                      //           shape: RoundedRectangleBorder(
                      //             borderRadius: BorderRadius.circular(10),
                      //           ),
                      //           elevation: 5,
                      //         ),
                      //         child: Text(
                      //           isService ? 'Add Service' : 'Add Product',
                      //           style: const TextStyle(
                      //             fontSize: 18,
                      //             fontWeight: FontWeight.bold,
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child:
              productProvider.isLoading
                  ? const SizedBox(
                    height: 56,
                    child: Center(child: CircularProgressIndicator()),
                  )
                  : SizedBox(
                    height: 56,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _submitProduct(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 7, 3, 201),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 6,
                      ),
                      child: Text(
                        isService ? 'Add Service' : 'Add Product',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
    String? hintText,
    bool isDescription = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.multiline,
        textCapitalization: TextCapitalization.sentences,
        maxLines: isDescription ? null : 1,
        minLines: isDescription ? 5 : 1,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          alignLabelWithHint: isDescription,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 7, 3, 201),
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        // No validator for optional fields
      ),
    );
  }

  Widget _buildRequiredTextField(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
    String? hintText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 7, 3, 201),
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        // Simple validation for required fields
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'This field is required';
          }
          if (isNumber && int.tryParse(value) == null) {
            return 'Enter a valid number';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    String? selectedValue,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
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
        value: selectedValue,
        hint: Text("Select $label"),
        items:
            options.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value[0].toUpperCase() + value.substring(1)),
              );
            }).toList(),
        onChanged: onChanged,
        // No validator for optional dropdowns
      ),
    );
  }

  Widget _buildRequiredDropdownField(
    String label,
    String? selectedValue,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
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
        value: selectedValue,
        hint: Text("Select $label"),
        items:
            options.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value[0].toUpperCase() + value.substring(1)),
              );
            }).toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? "Please select unit type" : null,
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Image (Optional)",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child:
                  _selectedImage != null
                      ? Image.file(
                        _selectedImage!,
                        height: 280,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                      : Container(
                        height: 280,
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: const Center(
                          child: Text(
                            "No image selected",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
            ),
          ),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _pickImageFromCamera,
                icon: const Icon(Icons.camera_alt),
                label: const Text("Camera"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _pickImageFromGallery,
                icon: const Icon(Icons.photo_library),
                label: const Text("Gallery"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubscriptionErrorSection(ProductProvider provider) {
    if (!provider.subscriptionRequired) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.warning, color: Colors.red.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              provider.errorMessage ??
                  "Subscription is not active. Please subscribe",
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _refreshTimer?.cancel(); // Pause auto-refresh when navigating
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SubscriptionScreen(shopId: widget.shopId!),
                ),
              ).then((_) {
                _startAutoRefresh(); // Resume auto-refresh when returning
              });
            },
            child: const Text("Subscribe"),
          ),
        ],
      ),
    );
  }
}
