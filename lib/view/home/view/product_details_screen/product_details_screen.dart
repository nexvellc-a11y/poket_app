// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:poketstore/controllers/cart_controller/cart_controller.dart';
import 'package:poketstore/controllers/my_shope_controller/add_product_controller.dart';
import 'package:poketstore/utilities/custom_app_bar.dart';
import 'package:poketstore/utilities/service_booking_bottom_sheet.dart';
import 'package:provider/provider.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String productId;

  const ProductDetailsScreen({super.key, required this.productId});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _selectedQuantity = 1;
  final TextEditingController _kgController = TextEditingController();
  final TextEditingController _gramsController = TextEditingController();
  double _finalQuantity = 1.0;

  bool isService(String unitType) => unitType == "per_service";

  static const double _mobileBreakpoint = 600;
  bool get _isMobile => MediaQuery.of(context).size.width < _mobileBreakpoint;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProduct(widget.productId);
      context.read<CartController>().fetchCart();
    });
  }

  void _updateSelectedQuantity(int kg, int grams) {
    setState(() => _finalQuantity = kg + (grams / 1000));
  }

  String capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: CustomAppBar(title: 'Product Details', showBackButton: true),

        /// 🔽 BODY
        body: Consumer<ProductProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final product = provider.product;
            if (product == null) {
              return const Center(child: Text('No product found'));
            }

            final bool service = isService(product.unitType);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// IMAGE
                  AspectRatio(
                    aspectRatio: 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        product.productImage,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) =>
                                const Icon(Icons.broken_image, size: 60),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// NAME
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: _isMobile ? 20 : 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// PRICE + UNIT
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Chip(label: Text(capitalize(product.unitType))),
                      Text(
                        '₹${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),

                  /// STOCK
                  if (!service) ...[
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
                  ],

                  const Divider(height: 30),

                  /// DESCRIPTION
                  if (product.description?.isNotEmpty ?? false) ...[
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(product.description!),
                    const Divider(height: 30),
                  ],

                  /// QUANTITY (PRODUCT ONLY)
                  if (!service) ...[
                    const Text(
                      'Enter Quantity',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    product.unitType.contains('nos')
                        ? Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle),
                              onPressed: () {
                                if (_selectedQuantity > 1) {
                                  setState(() => _selectedQuantity--);
                                }
                              },
                            ),
                            Expanded(
                              child: Text(
                                '$_selectedQuantity',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle),
                              onPressed: () {
                                if (_selectedQuantity < product.quantity) {
                                  setState(() => _selectedQuantity++);
                                }
                              },
                            ),
                          ],
                        )
                        : Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _kgController,
                                decoration: const InputDecoration(
                                  labelText: 'Kg / Ltr',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (v) {
                                  _updateSelectedQuantity(
                                    int.tryParse(v) ?? 0,
                                    int.tryParse(_gramsController.text) ?? 0,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _gramsController,
                                decoration: const InputDecoration(
                                  labelText: 'g / ml',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (v) {
                                  _updateSelectedQuantity(
                                    int.tryParse(_kgController.text) ?? 0,
                                    int.tryParse(v) ?? 0,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),

                    const SizedBox(height: 20),

                    /// TOTAL
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Amount:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '₹${(product.unitType.contains("nos") ? product.price * _selectedQuantity : product.price * _finalQuantity).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 80), // space for bottom button
                ],
              ),
            );
          },
        ),

        /// 🔽 FIXED BOTTOM BUTTON
        bottomNavigationBar: Consumer<ProductProvider>(
          builder: (context, provider, _) {
            final product = provider.product;
            if (product == null) return const SizedBox.shrink();

            final service = isService(product.unitType);

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: SizedBox(
                  height: 56,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 7, 3, 201),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () async {
                      if (service) {
                        await showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder:
                              (_) => _BottomSheetSafeWrapper(
                                child: ServiceBookingBottomSheet(
                                  serviceId: product.id,
                                ),
                              ),
                        );
                      } else {
                        final qty =
                            product.unitType.contains('nos')
                                ? _selectedQuantity.toDouble()
                                : _finalQuantity;

                        if (qty <= 0 || qty > product.quantity) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Invalid quantity')),
                          );
                          return;
                        }

                        final success = await context
                            .read<CartController>()
                            .addToCart(product.id, qty);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              success
                                  ? 'Added to cart'
                                  : 'Cannot add your own product',
                            ),
                          ),
                        );
                      }
                    },
                    child: Text(
                      service ? 'Book Service' : 'Add to Cart',
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// ✅ SAFEAREA FIX FOR BOTTOM SHEET
class _BottomSheetSafeWrapper extends StatelessWidget {
  final Widget child;
  const _BottomSheetSafeWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: child,
      ),
    );
  }
}
