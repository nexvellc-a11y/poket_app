import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:poketstore/controllers/my_shope_controller/add_product_controller.dart';
import 'package:poketstore/controllers/my_shope_controller/my_shop_list_user_controller.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyShopProductDetails extends StatefulWidget {
  final String productId;

  const MyShopProductDetails({super.key, required this.productId});

  @override
  State<MyShopProductDetails> createState() => _MyShopProductDetailsState();
}

class _MyShopProductDetailsState extends State<MyShopProductDetails> {
  File? _selectedImageForEdit;
  final ImagePicker _picker = ImagePicker();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _quantityController;
  late TextEditingController _categoryController;
  late TextEditingController _estimatedTimeController;
  late TextEditingController _unitTypeController;
  late TextEditingController _deliveryOptionController;

  // Fixed aspect ratio for product images
  static const double _fixedAspectRatioWidth = 1.717;
  static const double _fixedAspectRatioHeight = 1.533;
  double get _fixedAspectRatio =>
      _fixedAspectRatioWidth / _fixedAspectRatioHeight;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _priceController = TextEditingController();
    _quantityController = TextEditingController();
    _categoryController = TextEditingController();
    _estimatedTimeController = TextEditingController();
    _unitTypeController = TextEditingController();
    _deliveryOptionController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(
        context,
        listen: false,
      ).fetchProduct(widget.productId);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _categoryController.dispose();
    _estimatedTimeController.dispose();
    _unitTypeController.dispose();
    _deliveryOptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImageForEdit(StateSetter setState) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImageForEdit = File(image.path);
        log('New image selected: ${_selectedImageForEdit?.path}');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;

    // Calculate responsive image dimensions with fixed aspect ratio for mobile
    final imageWidth =
        isTablet
            ? screenWidth *
                0.75 // Tablets use percentage-based width
            : screenWidth * 0.9; // Mobile uses 90% of screen width

    final imageHeight =
        isTablet
            ? screenHeight *
                0.45 // Tablets use height-based
            : imageWidth /
                _fixedAspectRatio; // Mobile uses aspect ratio to calculate height

    final horizontalPadding = screenWidth * 0.05; // 5% padding on each side

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.black54,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context, true),
          ),
        ),
        title: const Text(
          "Product Details",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          Consumer<ProductProvider>(
            builder: (context, provider, child) {
              if (provider.product != null && !provider.isLoading) {
                return Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.edit_rounded,
                          color: Colors.blue[700],
                          size: 22,
                        ),
                        onPressed:
                            () => _showEditDialog(context, widget.productId),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.delete_rounded,
                          color: Colors.red[700],
                          size: 22,
                        ),
                        onPressed:
                            () => _confirmDelete(context, widget.productId),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.blue[700]!,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading Product...',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            );
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(horizontalPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Icon(
                        Icons.error_outline_rounded,
                        color: Colors.red[400],
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Oops!',
                      style: TextStyle(
                        fontSize: isTablet ? 28 : 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: isTablet ? 18 : 16,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 48,
                      width: isTablet ? 200 : 150,
                      child: ElevatedButton(
                        onPressed:
                            () => provider.fetchProduct(widget.productId),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Try Again',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (provider.product == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_rounded,
                    size: 60,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Product Not Found',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: isTablet ? 20 : 18,
                    ),
                  ),
                ],
              ),
            );
          }

          final product = provider.product!;
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center, // Center children
              children: [
                // Product Image with fixed aspect ratio for mobile
                Container(
                  width: imageWidth,
                  height: imageHeight,
                  margin: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Stack(
                      children: [
                        Image.network(
                          product.productImage.isNotEmpty
                              ? product.productImage
                              : 'https://via.placeholder.com/300',
                          width: imageWidth,
                          height: imageHeight,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: Icon(
                                Icons.inventory_2_rounded,
                                size: 60,
                                color: Colors.grey[400],
                              ),
                            );
                          },
                        ),
                        // Gradient overlay
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.1),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Aspect ratio indicator for mobile
                // if (!isTablet)
                //   Padding(
                //     padding: const EdgeInsets.only(bottom: 8.0),
                //     child: Container(
                //       padding: const EdgeInsets.symmetric(
                //         horizontal: 12,
                //         vertical: 4,
                //       ),
                //       decoration: BoxDecoration(
                //         color: Colors.blue[50],
                //         borderRadius: BorderRadius.circular(20),
                //       ),
                //       child: Text(
                //         'Aspect ratio: ${_fixedAspectRatioWidth.toStringAsFixed(3)} : ${_fixedAspectRatioHeight.toStringAsFixed(3)}',
                //         style: TextStyle(
                //           fontSize: 12,
                //           color: Colors.blue[700],
                //           fontWeight: FontWeight.w500,
                //         ),
                //       ),
                //     ),
                //   ),

                // Product Info Card with responsive width
                Container(
                  width: screenWidth * 0.95,
                  margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  padding: EdgeInsets.all(isTablet ? 24 : 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: TextStyle(
                                    fontSize: isTablet ? 28 : 24,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  product.unitType.isNotEmpty
                                      ? product.unitType
                                      : 'N/A',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: isTablet ? 18 : 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Qty: ${product.quantity}',
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w600,
                                fontSize: isTablet ? 16 : 14,
                              ),
                            ),
                          ),
                          Text(
                            '₹${product.price}',
                            style: TextStyle(
                              fontSize: isTablet ? 32 : 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Description Card with responsive width
                Container(
                  width: screenWidth * 0.95,
                  margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  padding: EdgeInsets.all(isTablet ? 24 : 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.purple[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.description_rounded,
                              color: Colors.purple[600],
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Product Description',
                            style: TextStyle(
                              fontSize: isTablet ? 20 : 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        product.description ??
                            'No description available for this product.',
                        style: TextStyle(
                          fontSize: isTablet ? 16 : 15,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Additional Details with responsive width
                Container(
                  width: screenWidth * 0.95,
                  margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  padding: EdgeInsets.all(isTablet ? 24 : 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.info_outline_rounded,
                              color: Colors.orange[600],
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Product Details',
                            style: TextStyle(
                              fontSize: isTablet ? 20 : 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildModernDetailRow(
                        'Estimated Delivery',
                        product.estimatedTime ?? 'N/A',
                        Icons.schedule_rounded,
                        Colors.blue,
                        isTablet,
                      ),
                      const SizedBox(height: 12),
                      _buildModernDetailRow(
                        'Category',
                        product.category.isNotEmpty ? product.category : 'N/A',
                        Icons.category_rounded,
                        Colors.green,
                        isTablet,
                      ),
                      const SizedBox(height: 12),
                      _buildModernDetailRow(
                        'Product Type',
                        product.unitType.isNotEmpty ? product.unitType : 'N/A',
                        Icons.inventory_2_rounded,
                        Colors.purple,
                        isTablet,
                      ),
                      const SizedBox(height: 12),
                      _buildModernDetailRow(
                        'Delivery Option',
                        product.deliveryOption.isNotEmpty
                            ? product.deliveryOption
                            : 'N/A',
                        Icons.local_shipping_rounded,
                        Colors.orange,
                        isTablet,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildModernDetailRow(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isTablet,
  ) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: isTablet ? 24 : 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: isTablet ? 15 : 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: isTablet ? 18 : 16,
            color: Colors.grey[400],
          ),
        ],
      ),
    );
  }

  // Edit Dialog with responsive design
  void _showEditDialog(BuildContext context, String productId) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );
    final currentProduct = productProvider.product;

    if (currentProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product data not loaded. Cannot edit.')),
      );
      return;
    }

    _nameController.text = currentProduct.name;
    _descriptionController.text = currentProduct.description ?? '';
    _priceController.text = currentProduct.price.toString();
    _quantityController.text = currentProduct.quantity.toString();
    _categoryController.text = currentProduct.category;
    _estimatedTimeController.text = currentProduct.estimatedTime ?? '';
    _unitTypeController.text = currentProduct.unitType;
    _deliveryOptionController.text = currentProduct.deliveryOption;
    _selectedImageForEdit = null;

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Container(
              width: isTablet ? 600 : screenWidth * 0.95,
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(isTablet ? 32 : 24),
                  child: StatefulBuilder(
                    builder: (
                      BuildContext context,
                      StateSetter dialogSetState,
                    ) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Edit Product",
                                style: TextStyle(
                                  fontSize: isTablet ? 26 : 22,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: Icon(
                                  Icons.close_rounded,
                                  color: Colors.grey[600],
                                  size: isTablet ? 28 : 24,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: GestureDetector(
                              onTap: () => _pickImageForEdit(dialogSetState),
                              child: Container(
                                width: isTablet ? 150 : 120,
                                height: isTablet ? 150 : 120,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.grey[300]!,
                                    width: 2,
                                  ),
                                  color: Colors.grey[50],
                                ),
                                child:
                                    _selectedImageForEdit != null
                                        ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                          child: Image.file(
                                            _selectedImageForEdit!,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                        : currentProduct.productImage.isNotEmpty
                                        ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                          child: Image.network(
                                            currentProduct.productImage,
                                            fit: BoxFit.cover,
                                            errorBuilder: (
                                              context,
                                              error,
                                              stackTrace,
                                            ) {
                                              return Icon(
                                                Icons.camera_alt_rounded,
                                                color: Colors.grey[400],
                                                size: isTablet ? 50 : 40,
                                              );
                                            },
                                          ),
                                        )
                                        : Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.camera_alt_rounded,
                                              color: Colors.grey[400],
                                              size: isTablet ? 50 : 40,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Add Image',
                                              style: TextStyle(
                                                color: Colors.grey[500],
                                                fontSize: isTablet ? 14 : 12,
                                              ),
                                            ),
                                          ],
                                        ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildModernTextField(
                            _nameController,
                            "Product Name",
                            Icons.title_rounded,
                            isTablet,
                          ),
                          _buildModernTextField(
                            _descriptionController,
                            "Description",
                            Icons.description_rounded,
                            isTablet,
                            maxLines: 3,
                          ),
                          _buildModernTextField(
                            _priceController,
                            "Price",
                            Icons.attach_money_rounded,
                            isTablet,
                            keyboardType: TextInputType.number,
                          ),
                          _buildModernTextField(
                            _quantityController,
                            "Quantity",
                            Icons.format_list_numbered_rounded,
                            isTablet,
                            keyboardType: TextInputType.number,
                          ),
                          _buildModernTextField(
                            _categoryController,
                            "Category",
                            Icons.category_rounded,
                            isTablet,
                          ),
                          _buildModernTextField(
                            _estimatedTimeController,
                            "Estimated Time",
                            Icons.schedule_rounded,
                            isTablet,
                          ),
                          _buildModernTextField(
                            _unitTypeController,
                            "Product Type",
                            Icons.inventory_2_rounded,
                            isTablet,
                          ),
                          _buildModernTextField(
                            _deliveryOptionController,
                            "Delivery Option",
                            Icons.local_shipping_rounded,
                            isTablet,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: OutlinedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                      vertical: isTablet ? 18 : 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    side: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.w600,
                                      fontSize: isTablet ? 16 : 14,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder:
                                          (context) => Center(
                                            child: Container(
                                              padding: const EdgeInsets.all(20),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              child: CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(Colors.blue[700]!),
                                              ),
                                            ),
                                          ),
                                    );

                                    final List<String> categories =
                                        _categoryController.text
                                            .trim()
                                            .split(',')
                                            .map((e) => e.trim())
                                            .where((e) => e.isNotEmpty)
                                            .toList();

                                    final bool success = await productProvider
                                        .updateProduct(
                                          productId,
                                          productImage: _selectedImageForEdit,
                                          name: _nameController.text.trim(),
                                          description:
                                              _descriptionController.text
                                                  .trim(),
                                          price: int.tryParse(
                                            _priceController.text.trim(),
                                          ),
                                          quantity: int.tryParse(
                                            _quantityController.text.trim(),
                                          ),
                                          category:
                                              categories.isEmpty
                                                  ? null
                                                  : categories,
                                          estimatedTime:
                                              _estimatedTimeController.text
                                                  .trim(),
                                          unitType:
                                              _unitTypeController.text.trim(),
                                          deliveryOption:
                                              _deliveryOptionController.text
                                                  .trim(),
                                        );

                                    if (!mounted) return;
                                    Navigator.pop(context);

                                    if (success) {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: const Text(
                                            'Product updated successfully!',
                                          ),
                                          backgroundColor: Colors.green[400],
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                      );

                                      final myShopListProvider =
                                          Provider.of<MyShopListUserProvider>(
                                            context,
                                            listen: false,
                                          );
                                      final prefs =
                                          await SharedPreferences.getInstance();
                                      final userId = prefs.getString('userId');
                                      if (userId != null) {
                                        await myShopListProvider
                                            .fetchUserShopList(userId);
                                      }
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            productProvider.errorMessage ??
                                                'Failed to update product.',
                                          ),
                                          backgroundColor: Colors.red[400],
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue[700],
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      vertical: isTablet ? 18 : 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    'Update',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: isTablet ? 16 : 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildModernTextField(
    TextEditingController controller,
    String labelText,
    IconData icon,
    bool isTablet, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: TextStyle(fontSize: isTablet ? 16 : 14),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(fontSize: isTablet ? 15 : 14),
          prefixIcon: Icon(
            icon,
            color: Colors.grey[600],
            size: isTablet ? 24 : 20,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: EdgeInsets.symmetric(
            horizontal: isTablet ? 20 : 16,
            vertical: isTablet ? 16 : 14,
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String productId) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Container(
              width: isTablet ? 500 : screenWidth * 0.95,
              padding: EdgeInsets.all(isTablet ? 32 : 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: isTablet ? 100 : 80,
                    height: isTablet ? 100 : 80,
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(isTablet ? 50 : 40),
                    ),
                    child: Icon(
                      Icons.delete_forever_rounded,
                      color: Colors.red[400],
                      size: isTablet ? 50 : 40,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Delete Product?",
                    style: TextStyle(
                      fontSize: isTablet ? 26 : 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "This action cannot be undone and the product will be permanently removed from your shop.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: isTablet ? 16 : 15,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: isTablet ? 16 : 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(color: Colors.grey[300]!),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600,
                              fontSize: isTablet ? 16 : 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder:
                                  (context) => Center(
                                    child: Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.red[400]!,
                                            ),
                                      ),
                                    ),
                                  ),
                            );

                            final productProvider =
                                Provider.of<ProductProvider>(
                                  context,
                                  listen: false,
                                );
                            final myShopListProvider =
                                Provider.of<MyShopListUserProvider>(
                                  context,
                                  listen: false,
                                );

                            bool deleteSuccess = await productProvider
                                .deleteProduct(productId);

                            if (!mounted) return;
                            Navigator.pop(context);

                            if (deleteSuccess) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'Product deleted successfully!',
                                  ),
                                  backgroundColor: Colors.green[400],
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              );

                              final prefs =
                                  await SharedPreferences.getInstance();
                              final userId = prefs.getString('userId');
                              if (userId != null) {
                                await myShopListProvider.fetchUserShopList(
                                  userId,
                                );
                              }
                              Navigator.pop(context, true);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    productProvider.errorMessage ??
                                        'Failed to delete product.',
                                  ),
                                  backgroundColor: Colors.red[400],
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[600],
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              vertical: isTablet ? 16 : 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Delete',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: isTablet ? 16 : 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
