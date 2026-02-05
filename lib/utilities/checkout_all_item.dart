import 'package:flutter/material.dart';
import 'package:poketstore/controllers/address_controller/address_controller.dart';
import 'package:poketstore/controllers/cart_controller/cart_controller.dart';
import 'package:poketstore/controllers/order_controller/order_controller.dart';
import 'package:poketstore/model/cart_model/cart_model.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:poketstore/model/order_model/order_model.dart';
import 'package:poketstore/model/address_model/address_model.dart';
import 'package:poketstore/view/order_screen/order_screen.dart';
import 'package:poketstore/view/delivery_address/delivery_address.dart';

class CheckoutAllBottomSheet extends StatefulWidget {
  const CheckoutAllBottomSheet({super.key});

  @override
  State<CheckoutAllBottomSheet> createState() => _CheckoutAllBottomSheetState();
}

class _CheckoutAllBottomSheetState extends State<CheckoutAllBottomSheet> {
  Address? _selectedDeliveryAddress;
  final Map<String, double> _kgQuantities = {};
  final Map<String, double> _gramQuantities = {};
  final Map<String, double> _unitQuantities = {};
  final Map<String, TextEditingController> _kgControllers = {};
  final Map<String, TextEditingController> _gramControllers = {};
  final Map<String, TextEditingController> _unitControllers = {};

  @override
  void initState() {
    super.initState();
    final cartItems =
        Provider.of<CartController>(context, listen: false).cart?.items ?? [];

    // When initializing maps
    for (var item in cartItems) {
      final itemId = item.id ?? UniqueKey().toString(); // fallback id
      final product = item.product;

      if (product?.productType == 'nos') {
        final initialUnits = item.quantity?.toInt() ?? 1;
        _unitQuantities[itemId] = initialUnits.toDouble();
        _unitControllers[itemId] = TextEditingController(
          text: initialUnits.toString(),
        );
        _unitControllers[itemId]!.addListener(
          () => _updateUnit(itemId, _unitControllers[itemId]!.text),
        );
      } else {
        final initialTotalKg = item.quantity?.toDouble() ?? 0.0;
        final initialKgPart = initialTotalKg.floor();
        final initialGramPart =
            ((initialTotalKg - initialKgPart) * 1000).round();

        _kgQuantities[itemId] = initialKgPart.toDouble();
        _gramQuantities[itemId] = initialGramPart.toDouble();

        _kgControllers[itemId] = TextEditingController(
          text: initialKgPart.toString(),
        );
        _gramControllers[itemId] = TextEditingController(
          text: initialGramPart.toString(),
        );

        _kgControllers[itemId]!.addListener(
          () => _updateKg(itemId, _kgControllers[itemId]!.text),
        );
        _gramControllers[itemId]!.addListener(
          () => _updateGram(itemId, _gramControllers[itemId]!.text),
        );
      }
    }
  }

  void _updateKg(String itemId, String text) {
    final parsed = double.tryParse(text);
    if (parsed != null && parsed >= 0) {
      setState(() => _kgQuantities[itemId] = parsed);
    }
  }

  void _updateGram(String itemId, String text) {
    final parsed = double.tryParse(text);
    if (parsed != null && parsed >= 0 && parsed < 1000) {
      setState(() => _gramQuantities[itemId] = parsed);
    } else if (parsed != null && parsed >= 1000) {
      final kgToAdd = (parsed / 1000).floor();
      final remainingGrams = parsed % 1000;
      setState(() {
        _kgQuantities[itemId] = (_kgQuantities[itemId] ?? 0) + kgToAdd;
        _gramQuantities[itemId] = remainingGrams;
        _kgControllers[itemId]!.text = _kgQuantities[itemId]!.toStringAsFixed(
          0,
        );
        _gramControllers[itemId]!.text = remainingGrams.toStringAsFixed(0);
      });
    }
  }

  void _updateUnit(String itemId, String text) {
    final parsed = double.tryParse(text);
    if (parsed != null && parsed >= 0) {
      setState(() => _unitQuantities[itemId] = parsed);
    }
  }

  @override
  void dispose() {
    _kgControllers.forEach((_, controller) => controller.dispose());
    _gramControllers.forEach((_, controller) => controller.dispose());
    _unitControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  double _calculateTotal() {
    double total = 0;
    final cartItems =
        Provider.of<CartController>(context, listen: false).cart?.items ?? [];

    for (var item in cartItems) {
      if (item.product?.productType == 'nos') {
        final units = _unitQuantities[item.id] ?? 1.0;
        final price = item.product?.price?.toDouble() ?? 0.0;
        total += price * units;
      } else {
        final kg = _kgQuantities[item.id] ?? 0.0;
        final g = _gramQuantities[item.id] ?? 0.0;
        final totalQty = kg + (g / 1000);
        final price = item.product?.price?.toDouble() ?? 0.0;
        total += price * totalQty;
      }
    }
    return total;
  }

  String _getFormattedAddress(Address? address) {
    if (address == null) return "No address selected.";
    final parts = <String>[];
    if (address.houseNo?.isNotEmpty == true) parts.add(address.houseNo!);
    if (address.area?.isNotEmpty == true) parts.add(address.area!);
    if (address.landmark?.isNotEmpty == true) parts.add(address.landmark!);
    parts.addAll([
      address.town ?? '',
      address.state ?? '',
      address.pincode ?? '',
    ]);
    return parts.where((p) => p.isNotEmpty).join(', ');
  }

  Future<void> _selectAddress() async {
    final selectedId = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      builder:
          (_) => const Padding(
            padding: EdgeInsets.all(16),
            child: DeliveryAddressBottomSheet(),
          ),
    );

    if (selectedId != null) {
      final controller = Provider.of<DeliveryAddressController>(
        // ignore: use_build_context_synchronously
        context,
        listen: false,
      );
      try {
        final address = controller.addresses.firstWhere(
          (a) => a.id == selectedId,
        );
        setState(() => _selectedDeliveryAddress = address);
        Fluttertoast.showToast(
          msg: "Address selected: ${address.area}, ${address.town}",
          backgroundColor: Colors.blue,
          textColor: Colors.white,
        );
      } catch (_) {
        Fluttertoast.showToast(
          msg: "Selected address not found",
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    }
  }

  Future<void> _placeOrder() async {
    if (_selectedDeliveryAddress == null) {
      Fluttertoast.showToast(
        msg: "Please select an address",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    final cartController = Provider.of<CartController>(context, listen: false);
    final orderController = Provider.of<OrderController>(
      context,
      listen: false,
    );
    final cartItems = cartController.cart?.items ?? [];

    final Map<String, Item> productMap = {};

    for (var item in cartItems) {
      double totalQty;
      double totalPrice;

      if (item.product?.productType == 'nos') {
        totalQty = _unitQuantities[item.id] ?? 1.0;
        final price = item.product?.price?.toDouble() ?? 0.0;
        totalPrice = price * totalQty;
      } else {
        final kg = _kgQuantities[item.id] ?? 0.0;
        final g = _gramQuantities[item.id] ?? 0.0;
        totalQty = kg + (g / 1000);
        final price = item.product?.price?.toDouble() ?? 0.0;
        totalPrice = price * totalQty;
      }
      final productId = item.product?.id;
      if (productId == null || totalQty <= 0) continue;

      if (productMap.containsKey(productId)) {
        final existing = productMap[productId]!;
        existing.quantity = (existing.quantity ?? 0.0) + totalQty;
        existing.priceWithQuantity =
            (existing.priceWithQuantity ?? 0.0) + totalPrice;
      } else {
        productMap[productId] = Item(
          productId: productId,
          name: item.product?.name ?? "Unknown Product",
          price: item.product?.price ?? 0,
          quantity: totalQty,
          priceWithQuantity: totalPrice,
        );
      }
    }

    final List<Item> orderItems =
        productMap.values.map((item) {
          return Item(
            productId: item.productId,
            name: item.name,
            price: item.price,
            quantity: item.quantity,
            priceWithQuantity: item.priceWithQuantity,
          );
        }).toList();

    double finalOverallTotal = 0.0;
    for (var item in orderItems) {
      finalOverallTotal += (item.priceWithQuantity ?? 0.0);
    }

    final orderItemModel = OrderItemModel(
      items: orderItems,
      addressId: _selectedDeliveryAddress?.id ?? "",
      totalCartAmount: finalOverallTotal.ceil(),
    );
    if (_selectedDeliveryAddress == null) {
      Fluttertoast.showToast(
        msg: "Please select an address",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }
    await orderController.placeOrder(orderItemModel);

    if (orderController.placedOrder != null) {
      Fluttertoast.showToast(
        msg: "Order placed successfully",
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
      if (context.mounted) {
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
        Navigator.push(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (_) => const OrderListScreen()),
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: orderController.message ?? "Order failed. Please try again.",
        backgroundColor: Colors.red,
        textColor: Colors.white,
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
      ).updateQuantity(product.id ?? "", newQuantity);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartController>(context).cart;
    final items = cart?.items ?? [];
    final orderController = Provider.of<OrderController>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...items.map((item) {
            double itemCalculatedPrice;
            Widget quantityInput;

            if (item.product?.productType == 'nos') {
              final units = _unitQuantities[item.id] ?? 1.0;
              final price = item.product?.price?.toDouble() ?? 0.0;
              itemCalculatedPrice = price * units;

              quantityInput = Row(
                children: [
                  const Text(
                    "Quantity:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      final controller = _unitControllers[item.id];
                      if (controller == null) return;

                      int currentValue = int.tryParse(controller.text) ?? 1;
                      if (currentValue > 1) {
                        controller.text = (currentValue - 1).toString();
                        _updateCartItemQuantity(item);
                        // setState(() {}); // update UI
                      }
                    },
                  ),
                  Expanded(
                    child: Container(
                      width: 40,
                      alignment: Alignment.center,
                      child: Text(
                        _unitControllers[item.id]?.text ?? '1',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      final controller = _unitControllers[item.id];
                      if (controller == null) return;

                      int currentValue = int.tryParse(controller.text) ?? 1;
                      controller.text = (currentValue + 1).toString();
                      _updateCartItemQuantity(item);
                      // setState(() {});
                    },
                  ),
                ],
              );
            } else {
              final kg = _kgQuantities[item.id] ?? 0.0;
              final g = _gramQuantities[item.id] ?? 0.0;
              final totalQty = kg + (g / 1000);
              itemCalculatedPrice =
                  (item.product?.price?.toDouble() ?? 0.0) * totalQty;

              quantityInput = Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _kgControllers[item.id],
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: false,
                      ),
                      decoration: const InputDecoration(
                        labelText: "Kg",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _gramControllers[item.id],
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: false,
                      ),
                      decoration: const InputDecoration(
                        labelText: "Gram",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item.product?.productImage ?? '',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        item.product?.name ?? "Unknown Product",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Price: ₹${item.product?.price ?? 0}"),
                          const SizedBox(height: 4),
                          quantityInput,
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Item Total:",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            "₹${itemCalculatedPrice.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
            // ignore: unnecessary_to_list_in_spreads
          }).toList(),

          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Colors.deepPurple),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Delivery Address:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _selectedDeliveryAddress == null
                            ? "Please select an address."
                            : _getFormattedAddress(_selectedDeliveryAddress),
                        style: TextStyle(
                          color:
                              _selectedDeliveryAddress == null
                                  ? Colors.red
                                  : Colors.black87,
                          fontStyle:
                              _selectedDeliveryAddress == null
                                  ? FontStyle.italic
                                  : FontStyle.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: _selectAddress,
                  child: Text(
                    _selectedDeliveryAddress == null ? "Select" : "Change",
                    style: const TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Overall Total:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                "₹${_calculateTotal()}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: orderController.isLoading ? null : _placeOrder,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color.fromARGB(255, 7, 3, 201),
              ),
              child:
                  orderController.isLoading
                      ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                      : const Text(
                        "Place Order",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
            ),
          ),
        ],
      ),
    );
  }
}
