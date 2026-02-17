// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:poketstore/controllers/cart_controller/cart_controller.dart';
import 'package:poketstore/controllers/my_shope_controller/add_product_controller.dart';
import 'package:poketstore/utilities/custom_app_bar.dart';
import 'package:provider/provider.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String productId;

  const ProductDetailsScreen({super.key, required this.productId});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _selectedQuantity = 1;
  final TextEditingController _quantityController = TextEditingController(
    text: '1',
  );
  final TextEditingController _kgController = TextEditingController();
  final TextEditingController _gramsController = TextEditingController();
  double _finalQuantity = 1.0;

  // Fixed aspect ratio for product images
  static const double _fixedAspectRatioWidth = 1.717;
  static const double _fixedAspectRatioHeight = 1.533;
  double get _fixedAspectRatio =>
      _fixedAspectRatioWidth / _fixedAspectRatioHeight;

  // Responsive breakpoints
  static const double _mobileBreakpoint = 600;
  static const double _tabletBreakpoint = 900;

  bool get _isMobile => MediaQuery.of(context).size.width < _mobileBreakpoint;
  bool get _isTablet =>
      MediaQuery.of(context).size.width >= _mobileBreakpoint &&
      MediaQuery.of(context).size.width < _tabletBreakpoint;
  bool get _isDesktop => MediaQuery.of(context).size.width >= _tabletBreakpoint;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProduct(widget.productId);
      context.read<CartController>().fetchCart();
    });
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _kgController.dispose();
    _gramsController.dispose();
    super.dispose();
  }

  void _updateSelectedQuantity(int kg, int grams) {
    final total = kg + (grams / 1000);
    setState(() {
      _finalQuantity = total;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: CustomAppBar(title: 'ProductDetails', showBackButton: true),
        body: Consumer<ProductProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final product = provider.product;
            if (product == null) {
              return const Center(child: Text('No product found'));
            }

            // Calculate image dimensions based on aspect ratio for mobile
            double imageWidth =
                _isMobile ? screenWidth * 0.9 : screenWidth * 0.8;
            double imageHeight =
                _isMobile
                    ? imageWidth /
                        _fixedAspectRatio // Height from aspect ratio
                    : 280; // Fixed height for tablets/desktop

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Image with responsive dimensions
                    Center(
                      child: Container(
                        width: imageWidth,
                        height: imageHeight,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            product.productImage,
                            width: imageWidth,
                            height: imageHeight,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    size: 50,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                    // Aspect ratio indicator for mobile
                    // if (_isMobile)
                    //   Padding(
                    //     padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                    //     child: Center(
                    //       child: Container(
                    //         padding: const EdgeInsets.symmetric(
                    //           horizontal: 12,
                    //           vertical: 4,
                    //         ),
                    //         // decoration: BoxDecoration(
                    //         //   color: Colors.blue[50],
                    //         //   borderRadius: BorderRadius.circular(20),
                    //         // ),
                    //         // child: Text(
                    //         //   'Image ratio: ${_fixedAspectRatioWidth.toStringAsFixed(3)} : ${_fixedAspectRatioHeight.toStringAsFixed(3)}',
                    //         //   style: TextStyle(
                    //         //     fontSize: 12,
                    //         //     color: Colors.blue[700],
                    //         //     fontWeight: FontWeight.w500,
                    //         //   ),
                    //         // ),
                    //       ),
                    //     ),
                    //   ),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: TextStyle(
                              fontSize: _isMobile ? 20 : 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Chip(label: Text(product.unitType)),
                        Text(
                          '₹${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: _isMobile ? 22 : 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        const Text(
                          'Available Stock:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 10),
                        Text(product.quantity.toString()),
                      ],
                    ),

                    const Divider(height: 30),

                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Text(
                      product.description ?? '',
                      style: TextStyle(
                        fontSize: _isMobile ? 14 : 15,
                        color: Colors.grey[700],
                      ),
                      textAlign: TextAlign.justify,
                    ),
                    const Divider(height: 30),
                    const Text(
                      'Enter Quantity:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    product.unitType.contains('nos')
                        ? Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                if (_selectedQuantity > 1) {
                                  setState(() {
                                    _selectedQuantity--;
                                    _quantityController.text =
                                        _selectedQuantity.toString();
                                  });
                                }
                              },
                              icon: const Icon(Icons.remove_circle),
                            ),
                            Expanded(
                              child: Text(
                                '$_selectedQuantity',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: _isMobile ? 16 : 18),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                if (_selectedQuantity < product.quantity) {
                                  setState(() {
                                    _selectedQuantity++;
                                    _quantityController.text =
                                        _selectedQuantity.toString();
                                  });
                                }
                              },
                              icon: const Icon(Icons.add_circle),
                            ),
                          ],
                        )
                        : Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _kgController,
                                decoration: const InputDecoration(
                                  labelText: 'Kg/Ltr',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                style: TextStyle(fontSize: _isMobile ? 14 : 16),
                                onChanged: (kgValue) {
                                  final kg = int.tryParse(kgValue) ?? 0;
                                  final g =
                                      int.tryParse(_gramsController.text) ?? 0;
                                  _updateSelectedQuantity(kg, g);
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _gramsController,
                                decoration: const InputDecoration(
                                  labelText: 'g/ml',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                style: TextStyle(fontSize: _isMobile ? 14 : 16),
                                onChanged: (gValue) {
                                  final kg =
                                      int.tryParse(_kgController.text) ?? 0;
                                  final g = int.tryParse(gValue) ?? 0;
                                  _updateSelectedQuantity(kg, g);
                                },
                              ),
                            ),
                          ],
                        ),

                    const SizedBox(height: 20),

                    // Total Amount Display
                    Consumer<ProductProvider>(
                      builder: (context, provider, _) {
                        final product = provider.product!;
                        final totalAmount =
                            product.unitType.contains('nos')
                                ? product.price * _selectedQuantity
                                : product.price * _finalQuantity;

                        return Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 16,
                          ),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Amount:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '₹${totalAmount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: _isMobile ? 16 : 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const Text(
                      'Delivery Info',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildInfoRow(
                      'Estimated Delivery',
                      product.estimatedTime ?? '',
                      Icons.access_time,
                      _isMobile,
                    ),
                    _buildInfoRow(
                      'Category',
                      product.category.toString(),
                      Icons.category,
                      _isMobile,
                    ),
                    _buildInfoRow(
                      'Product Type',
                      product.unitType,
                      Icons.shopping_bag,
                      _isMobile,
                    ),
                    _buildInfoRow(
                      'Delivery Option',
                      product.deliveryOption,
                      Icons.delivery_dining,
                      _isMobile,
                    ),

                    const SizedBox(height: 30),

                    Consumer<CartController>(
                      builder: (context, cartController, _) {
                        final inCart = cartController.isProductInCart(
                          product.id,
                        );
                        final currentQuantity =
                            cartController.getProductQuantity(product.id) ?? 0;

                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  inCart
                                      ? Colors.grey
                                      : const Color.fromARGB(255, 7, 3, 201),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed:
                                inCart || cartController.isAdding
                                    ? null
                                    : () async {
                                      final qty =
                                          product.unitType.contains('nos')
                                              ? _selectedQuantity.toDouble()
                                              : _finalQuantity;

                                      if (qty <= 0 || qty > product.quantity) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Please enter a valid quantity within available stock.',
                                            ),
                                          ),
                                        );
                                        return;
                                      }
                                      log(
                                        "🛒 Add to cart → Product ID: ${product.id}, Quantity: $qty",
                                      );
                                      final roundedQty = double.parse(
                                        qty.toStringAsFixed(2),
                                      );
                                      final success = await cartController
                                          .addToCart(product.id, roundedQty);

                                      final message =
                                          success
                                              ? 'Added ${roundedQty.toStringAsFixed(2)} to cart'
                                              : ' You cannot add your own shop’s product to the cart';

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text(message)),
                                      );
                                    },
                            child:
                                cartController.isAdding
                                    ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                    : Text(
                                      inCart
                                          ? 'Added (${currentQuantity.toStringAsFixed(2)})'
                                          : 'Add to Cart',
                                      style: TextStyle(
                                        fontSize: _isMobile ? 16 : 18,
                                        color: Colors.white,
                                      ),
                                    ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String title,
    String value,
    IconData icon,
    bool isMobile,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple, size: isMobile ? 18 : 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: isMobile ? 14 : 15,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.black87,
              fontSize: isMobile ? 14 : 15,
            ),
          ),
        ],
      ),
    );
  }
}
