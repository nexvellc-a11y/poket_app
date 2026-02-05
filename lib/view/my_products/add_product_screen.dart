import 'dart:async'; // Add this import for Timer
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:poketstore/controllers/my_shope_controller/add_product_controller.dart';
import 'package:poketstore/controllers/shop_of_user_controller/shop_of_user_controller.dart';
import 'package:poketstore/controllers/category_controller/category_controller.dart';
import 'package:poketstore/utilities/image_crop_screen.dart';
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
  final List<String> _selectedCategories = [];
  // String? _selectedShopId;
  final List<String> _typeOptions = ["nos", "kg", "liter"];
  final List<String> _deliveryOptions = ["Home Delivery", "Store Pickup"];
  final List<String> _availabilityOptions = ["Available", "Out of Stock"];
  bool _pageLoading = true;
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
                (context) => CropImageScreen(imageFile: File(pickedFile.path)),
          ),
        );
        if (croppedImage != null && croppedImage is File) {
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
                (context) => CropImageScreen(imageFile: File(pickedFile.path)),
          ),
        );
        if (croppedImage != null && croppedImage is File) {
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

    if (!_formKey.currentState!.validate() || _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Fill all required fields & select an image"),
        ),
      );
      _startAutoRefresh(); // Resume auto-refresh
      return;
    }

    final quantity = int.tryParse(_quantityController.text.trim());
    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Invalid stock quantity")));
      _startAutoRefresh(); // Resume auto-refresh
      return;
    }

    final provider = Provider.of<ProductProvider>(context, listen: false);

    await provider.createProduct(
      userId: userId,
      shopId: widget.shopId!,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      productImage: _selectedImage,
      price: int.parse(_priceController.text.trim()),
      quantity: quantity,
      estimatedTime: _estimatedTimeController.text.trim(),
      unitType: _selectedType,
      deliveryOption: _selectedDeliveryOption,
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // _buildSubscriptionWarning(),
                  // SizedBox(height: 10),
                  _buildSubscriptionErrorSection(
                    productProvider,
                  ), // Add this line
                ],
              ),
            ),
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(
                      "Product Name",
                      _nameController,
                      hintText: "e.g., Organic Apples",
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Product name is required'
                                  : null,
                    ),
                    _buildDropdownField(
                      "Select Type",
                      _selectedType,
                      _typeOptions,
                      (value) => setState(() => _selectedType = value),
                    ),
                    _buildTextField(
                      "Price",
                      _priceController,
                      isNumber: true,
                      hintText: "e.g., 250",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Price is required';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Enter a valid number';
                        }
                        return null;
                      },
                    ),
                    _buildTextField(
                      "Stock Quantity",
                      _quantityController,
                      isNumber: true,
                      hintText: "e.g., 100",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Quantity is required';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Enter a valid number';
                        }
                        return null;
                      },
                    ),
                    // Description field - not required
                    _buildTextField(
                      "Description (Optional)",
                      _descriptionController,
                      hintText: "Provide a detailed description of the product",
                      validator: null,
                      isDescription: true,
                      // No validation
                    ),
                    const SizedBox(height: 15),
                    _buildDropdownField(
                      "Delivery Option",
                      _selectedDeliveryOption,
                      _deliveryOptions,
                      (value) =>
                          setState(() => _selectedDeliveryOption = value),
                    ),
                    _buildTextField(
                      "Estimated Delivery Time (Days)",
                      _estimatedTimeController,
                      hintText: "e.g., 3-4 business days",
                    ),
                    _buildDropdownField(
                      "Availability Status",
                      _selectedAvailability,
                      _availabilityOptions,
                      (value) => setState(() => _selectedAvailability = value),
                    ),
                    const SizedBox(height: 15),
                    _buildImagePicker(),
                    const SizedBox(height: 25),
                    productProvider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _submitProduct(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                7,
                                3,
                                201,
                              ),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 5,
                            ),
                            child: const Text(
                              'Add Product',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
    String? hintText,
    String? Function(String?)? validator,
    bool isDescription = false, // Add this parameter
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType:
            isNumber
                ? TextInputType.number
                : TextInputType.multiline, // Use multiline for description
        textCapitalization: TextCapitalization.sentences,
        maxLines:
            isDescription
                ? null
                : 1, // Unlimited lines for description, single line for others
        minLines: isDescription ? 5 : 1, // Minimum 5 lines for description
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          alignLabelWithHint:
              isDescription, // Align label properly for multiline
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
            vertical: 16, // Increased vertical padding for better appearance
          ),
        ),
        validator: validator,
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
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? "Please select $label" : null,
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Product Image",
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
