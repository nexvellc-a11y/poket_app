import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:poketstore/controllers/cart_controller/cart_controller.dart';
import 'package:poketstore/model/cart_model/cart_model.dart';
import 'package:poketstore/utilities/no_data_warning.dart';
import 'package:provider/provider.dart';

import 'package:poketstore/controllers/address_controller/address_controller.dart';
import 'package:poketstore/utilities/checkout_all_item.dart';
import 'package:poketstore/utilities/custom_app_bar.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isProcessingAllOrder = false;
  final Map<String, TextEditingController> _kgControllers = {};
  final Map<String, TextEditingController> _gramControllers = {};
  final Map<String, TextEditingController> _unitControllers = {};

  @override
  void initState() {
    super.initState();
    Provider.of<DeliveryAddressController>(
      context,
      listen: false,
    ).fetchAddresses();
    Provider.of<CartController>(context, listen: false).fetchCart();
  }

  @override
  void dispose() {
    _kgControllers.forEach((_, controller) => controller.dispose());
    _gramControllers.forEach((_, controller) => controller.dispose());
    _unitControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  void _initializeControllers(CartItem item) {
    final id = item.id ?? '';
    final productType = item.product?.productType ?? 'nos';
    final quantity = item.quantity ?? 1.0;

    if (productType == 'nos') {
      _unitControllers.putIfAbsent(
        id,
        () => TextEditingController(text: quantity.toInt().toString()),
      );
    } else {
      _kgControllers.putIfAbsent(
        id,
        () => TextEditingController(text: quantity.floor().toString()),
      );
      _gramControllers.putIfAbsent(
        id,
        () => TextEditingController(
          text: ((quantity - quantity.floor()) * 1000).round().toString(),
        ),
      );
    }
  }

  double _getTotalQuantity(
    String? itemId,
    String? productType, {
    double? fallback,
  }) {
    if (itemId == null || productType == null) return fallback ?? 0.0;

    if (productType == 'nos') {
      final unitText = _unitControllers[itemId]?.text;
      return double.tryParse(unitText ?? '') ?? fallback ?? 1.0;
    } else {
      final kgText = _kgControllers[itemId]?.text;
      final gramText = _gramControllers[itemId]?.text;

      final kg = double.tryParse(kgText ?? '') ?? 0;
      final gram = double.tryParse(gramText ?? '') ?? 0;
      return kg + (gram / 1000);
    }
  }

  void _updateCartItemQuantity(CartItem item) {
    final product = item.product;
    if (product == null || item.id == null) return;

    final newQuantity = _getTotalQuantity(
      item.id,
      product.productType,
      fallback: item.quantity?.toDouble(),
    );

    if (newQuantity > 0) {
      Provider.of<CartController>(
        context,
        listen: false,
      ).updateQuantity(product.id!, newQuantity);
    }
  }

  void _purchaseAllItems() async {
    setState(() => _isProcessingAllOrder = true);
    try {
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (_) => const CheckoutAllBottomSheet(),
      );
    } catch (e) {
      log("Error opening purchase all sheet: $e");
      Fluttertoast.showToast(
        msg: "Error: $e",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _isProcessingAllOrder = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0703C9), Colors.white],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: CustomAppBar(title: "My Cart"),
        body: Consumer<CartController>(
          builder: (context, controller, _) {
            if (controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final cart = controller.cart;
            final items = cart?.items ?? [];
            if (items.isEmpty) {
              return const Center(
                child: AnimatedNoDataMessage(
                  titleText: "No items inside your cart !",
                  subtitleText: "Cart the needed items",
                ),
              );
            }

            // Initialize controllers for all items
            for (var item in items) {
              _initializeControllers(item);
            }

            final overallTotalPrice = items.fold<double>(0.0, (sum, item) {
              final product = item.product;
              if (product == null) return sum;

              final totalQty = _getTotalQuantity(
                item.id,
                product.productType,
                fallback: item.quantity?.toDouble(),
              );
              final price = product.price ?? 0.0;
              return sum + (price * totalQty);
            });

            return Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => controller.fetchCart(),
                    child: ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final product = item.product;

                        if (product == null) return const SizedBox.shrink();

                        final totalQty = _getTotalQuantity(
                          item.id,
                          product.productType,
                        );
                        final totalPrice = (product.price ?? 0.0) * totalQty;

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child:
                                          product.productImage != null
                                              ? Image.network(
                                                product.productImage!,
                                                width: 80,
                                                height: 80,
                                                fit: BoxFit.cover,
                                              )
                                              : Container(
                                                width: 80,
                                                height: 80,
                                                color: Colors.grey[200],
                                                child: const Icon(
                                                  Icons.image_not_supported,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product.name ?? '',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "₹${(product.price ?? 0.0).toStringAsFixed(2)} per ${product.productType == 'nos' ? 'nos' : 'kg'}",
                                            style: const TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            "Total: ₹${totalPrice.toStringAsFixed(2)}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () async {
                                        final confirmDelete = await showDialog<
                                          bool
                                        >(
                                          context: context,
                                          builder:
                                              (_) => AlertDialog(
                                                title: const Text(
                                                  "Remove from Cart",
                                                ),
                                                content: Text(
                                                  "Remove ${product.name} from your cart?",
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed:
                                                        () => Navigator.of(
                                                          context,
                                                        ).pop(false),
                                                    child: const Text("Cancel"),
                                                  ),
                                                  TextButton(
                                                    onPressed:
                                                        () => Navigator.of(
                                                          context,
                                                        ).pop(true),
                                                    child: const Text(
                                                      "Remove",
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                        );

                                        if (confirmDelete == true) {
                                          Provider.of<CartController>(
                                            // ignore: use_build_context_synchronously
                                            context,
                                            listen: false,
                                          ).removeItem(product.id!);
                                          setState(() {
                                            _kgControllers.remove(item.id);
                                            _gramControllers.remove(item.id);
                                            _unitControllers.remove(item.id);
                                          });
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                if (product.productType == 'nos')
                                  Row(
                                    children: [
                                      const Text(
                                        "Quantity:",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      IconButton(
                                        icon: const Icon(Icons.remove),
                                        onPressed: () {
                                          final controller =
                                              _unitControllers[item.id];
                                          if (controller == null) return;

                                          int currentValue =
                                              int.tryParse(controller.text) ??
                                              1;
                                          if (currentValue > 1) {
                                            controller.text =
                                                (currentValue - 1).toString();
                                            _updateCartItemQuantity(item);
                                            // setState(() {}); // update UI
                                          }
                                        },
                                      ),
                                      Container(
                                        width: 40,
                                        alignment: Alignment.center,
                                        child: Text(
                                          _unitControllers[item.id]?.text ??
                                              '1',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add),
                                        onPressed: () {
                                          final controller =
                                              _unitControllers[item.id];
                                          if (controller == null) return;

                                          int currentValue =
                                              int.tryParse(controller.text) ??
                                              1;
                                          controller.text =
                                              (currentValue + 1).toString();
                                          _updateCartItemQuantity(item);
                                          // setState(() {});
                                        },
                                      ),
                                    ],
                                  )
                                else
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Quantity:",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextField(
                                              controller:
                                                  _kgControllers[item.id],
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: InputDecoration(
                                                labelText: 'kg/liter',
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                isDense: true,
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 12,
                                                      horizontal: 12,
                                                    ),
                                              ),
                                              onChanged: (_) {
                                                // setState(() {});
                                                _updateCartItemQuantity(item);
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: TextField(
                                              controller:
                                                  _gramControllers[item.id],
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: InputDecoration(
                                                labelText: 'g/ml',
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                isDense: true,
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 12,
                                                      horizontal: 12,
                                                    ),
                                              ),
                                              onChanged: (_) {
                                                // setState(() {});
                                                _updateCartItemQuantity(item);
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 35),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total:",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "₹${overallTotalPrice.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed:
                              _isProcessingAllOrder ? null : _purchaseAllItems,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 84, 82, 204),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child:
                              _isProcessingAllOrder
                                  ? const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  )
                                  : const Text(
                                    "CHECKOUT",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
