import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:poketstore/controllers/cart_controller/cart_controller.dart';
import 'package:poketstore/controllers/order_controller/order_list_details_controller.dart';
import 'package:poketstore/utilities/custom_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  String? userId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserIdAndFetchOrders();
  }

  Future<void> loadUserIdAndFetchOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      userId = prefs.getString('userId');

      if (userId != null) {
        log("🔍 Found userId: $userId. Fetching orders...");
        await Provider.of<OrderListController>(
          // ignore: use_build_context_synchronously
          context,
          listen: false,
        ).getOrders(userId!);
        final cartController = Provider.of<CartController>(
          // ignore: use_build_context_synchronously
          context,
          listen: false,
        );
        await cartController.fetchCart();
        log("✅ Orders successfully fetched for user: $userId");
      } else {
        log("⚠️ No userId found in SharedPreferences");
      }
    } catch (e, stack) {
      log("❌ Error loading orders: $e");
      log(stack.toString()); // optional, for debugging trace
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String formatDate(String isoDate) {
    final date = DateTime.parse(isoDate).toLocal();
    return DateFormat('dd MMM – hh:mm a').format(date);
  }

  // Helper function to truncate ID (keeping this as it's useful)
  // ignore: unused_element
  String _truncateId(String id, {int maxLength = 10}) {
    if (id.length <= maxLength) {
      return id;
    }
    return '${id.substring(0, maxLength)}...';
  }

  // New helper function to get product summary
  String _getProductSummary(List<dynamic> items) {
    // Changed to dynamic to be flexible with your actual item type
    if (items.isEmpty) {
      return "No products";
    }

    final firstProductName =
        items[0].name; // Accessing 'name' property of the first item
    if (items.length == 1) {
      return firstProductName;
    } else {
      return '$firstProductName +${items.length - 1} more';
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<OrderListController>(context);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Your Orders', showBackButton: true),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : controller.orders.isEmpty
              ? const Center(child: Text("No orders found."))
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.orders.length,
                itemBuilder: (context, index) {
                  final order = controller.orders[index];
                  return GestureDetector(
                    // onTap: () {
                    //   Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //       builder:
                    //           (_) => OrderDetailScreen(orderId: order.orderId),
                    //     ),
                    //   );
                    // },
                    child: Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //   children: [
                            //     Text(
                            //       "Order ID",
                            //       style: TextStyle(
                            //         fontWeight: FontWeight.w600,
                            //         fontSize: 14,
                            //         color: Colors.grey[700],
                            //       ),
                            //     ),
                            //     Text(
                            //       _truncateId(order.orderId, maxLength: 8),
                            //       style: const TextStyle(
                            //         fontWeight: FontWeight.bold,
                            //         fontSize: 16,
                            //       ),
                            //     ),
                            //   ],
                            // ),
                            const SizedBox(height: 8),
                            // New Row for Product Summary
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Products",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                Expanded(
                                  // Use Expanded to allow text to take available space and overflow
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      _getProductSummary(
                                        order.products,
                                      ), // Call the new helper here
                                      textAlign:
                                          TextAlign
                                              .right, // Align text to the right
                                      overflow:
                                          TextOverflow
                                              .ellipsis, // Add ellipsis if too long
                                      maxLines:
                                          1, // Ensure it stays on one line
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Total Amount",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  "₹${order.totalCartAmount}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Date",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  formatDate(order.createdAt),
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
