import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:poketstore/controllers/subscription_controller/start_plan_controller.dart';
import 'package:poketstore/utilities/custom_app_bar.dart';
import 'package:poketstore/utilities/no_data_warning.dart';
import 'package:poketstore/utilities/shop_list_dialog_box.dart';
import 'package:poketstore/view/add_shop/shope_list_screen.dart';
import 'package:poketstore/view/bottombar/bottom_bar_screen.dart';
import 'package:poketstore/view/payment_gateway/payment_gateway.dart';
import 'package:provider/provider.dart';
import 'package:poketstore/controllers/subscription_controller/subscription_controller.dart';

class SubscriptionUserScreen extends StatefulWidget {
  final String? shopId;

  const SubscriptionUserScreen({super.key, this.shopId});

  @override
  State<SubscriptionUserScreen> createState() => _SubscriptionUserScreenState();
}

class _SubscriptionUserScreenState extends State<SubscriptionUserScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () =>
          // ignore: use_build_context_synchronously
          Provider.of<SubscriptionProvider>(context, listen: false).loadPlans(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final startProvider = Provider.of<StartSubscriptionProvider>(context);

    return Scaffold(
      appBar: CustomAppBar(title: 'Subscription Plan', showBackButton: true),
      body: Consumer<SubscriptionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
              ),
            );
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  provider.errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            );
          }

          if (provider.plans.isEmpty) {
            return const Center(
              child: AnimatedNoDataMessage(
                titleText: "No plans available",
                subtitleText: "Waiting for plans .....",
              ),
            );
          }

          return Column(
            children: [
              // const Padding(
              //   padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
              //   child: Text(
              //     "Choose the perfect plan for your business",
              //     textAlign: TextAlign.center,
              //     style: TextStyle(
              //       fontSize: 18,
              //       fontWeight: FontWeight.w500,
              //       color: Colors.black87,
              //     ),
              //   ),
              // ),
              SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: provider.plans.length,
                  itemBuilder: (context, index) {
                    final plan = provider.plans[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromARGB(255, 7, 3, 201),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    plan.name ?? "",
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 7, 3, 201),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 7, 3, 201),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    plan.durationType?.toUpperCase() ?? "",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              plan.description ?? "",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "PRICE",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "₹${plan.baseAmount ?? 0}",
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      "GST: ₹${plan.gstAmount ?? 0}",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Total: ₹${plan.totalAmount ?? 0}",
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    log('🔹 Get Started clicked');

                                    // 🔹 Open shop selection popup
                                    final selectedShopId =
                                        await showDialog<String>(
                                          context: context,
                                          barrierDismissible: true,
                                          builder:
                                              (_) => const SelectShopDialog(),
                                        );

                                    if (selectedShopId == null) {
                                      log('❌ Shop selection cancelled');
                                      return;
                                    }

                                    log('🏪 Selected Shop ID: $selectedShopId');

                                    // Clear previous errors
                                    startProvider.clearError();

                                    final result = await startProvider
                                        .startSubscription(
                                          subscriptionPlanId: plan.id!,
                                          shopId: selectedShopId,
                                        );

                                    if (startProvider.errorMessage != null ||
                                        result == null) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            startProvider.errorMessage ??
                                                "Failed to start subscription",
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => PaymentScreen(
                                              name: plan.name ?? '',
                                              duration: plan.durationType ?? '',
                                              amount: plan.totalAmount ?? 0,
                                              orderId: result.orderId ?? '',
                                              onPaymentSuccess: () {
                                                Navigator.pushAndRemoveUntil(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (_) =>
                                                            const BottomBarScreen(),
                                                  ),
                                                  (route) => false,
                                                );
                                              },
                                            ),
                                      ),
                                    );
                                  },

                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(
                                      255,
                                      7,
                                      3,
                                      201,
                                    ),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                  ),
                                  child: Text(
                                    (startProvider
                                                .subscriptionResponse
                                                ?.subscription
                                                ?.isActive ==
                                            true)
                                        ? "Renew Plan"
                                        : "Get Started",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
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
            ],
          );
        },
      ),
    );
  }
}
