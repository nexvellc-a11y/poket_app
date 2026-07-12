import 'package:flutter/material.dart';
import 'package:poketstore/controllers/subscription_controller/start_plan_controller.dart';
import 'package:poketstore/model/subscription_model/subscription_model.dart';
import 'package:poketstore/utilities/custom_app_bar.dart';
import 'package:poketstore/utilities/no_data_warning.dart';
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
  Map<int, bool> _isMonthlySelected = {};

  final PageController _pageController = PageController(
    viewportFraction: 0.85,
    initialPage: 0,
  );

  Map<String, Map<String, Plan>> groupedPlans(List<Plan> plans) {
    Map<String, Map<String, Plan>> result = {};

    for (var plan in plans) {
      // Skip Beginner plan from grouping - we'll handle it separately
      if (_isBeginnerPlan(plan)) {
        // Store beginner plan in a special key
        result.putIfAbsent('beginner', () => {});
        result['beginner']!['trial'] = plan;
        continue;
      }

      final key = plan.productLimit.toString();
      
      // Handle null durationType safely
      final durationType = plan.durationType ?? 'unknown';
      
      result.putIfAbsent(key, () => {});
      result[key]![durationType] = plan;
    }

    return result;
  }

  // Helper method to check if a plan is beginner/free
  bool _isBeginnerPlan(Plan plan) {
    return plan.name?.toLowerCase() == 'beginner' || 
           plan.durationType?.toLowerCase() == 'trial' ||
           (plan.baseAmount == 0 && plan.totalAmount == 0);
  }

  // Helper method to check if a plan is free
  bool _isBeginner(Plan plan) {
    return _isBeginnerPlan(plan);
  }

  @override
  void initState() {
    super.initState();

    Future.microtask(
      () =>
          Provider.of<SubscriptionProvider>(context, listen: false).loadPlans(),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final startProvider = Provider.of<StartSubscriptionProvider>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0703C9), // Deep Blue
              Colors.white, // White
            ],
          ),
        ),
        child: SafeArea(
          child: Consumer<SubscriptionProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
                      style: const TextStyle(color: Colors.white, fontSize: 16),
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

              final grouped = groupedPlans(provider.plans);
              final keys = grouped.keys.toList();

              // Ensure Beginner plan is first
              if (keys.contains('beginner')) {
                keys.remove('beginner');
                keys.insert(0, 'beginner');
              }

              // Filter keys that have at least one valid plan
              final validKeys = keys.where((key) {
                final plans = grouped[key];
                return plans != null && plans.isNotEmpty;
              }).toList();

              if (validKeys.isEmpty) {
                return const Center(
                  child: AnimatedNoDataMessage(
                    titleText: "No valid plans available",
                    subtitleText: "Please try again later",
                  ),
                );
              }

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                        children: [
                          TextSpan(
                            text: 'Poket',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Aparajita',
                            ),
                          ),
                          TextSpan(
                            text: 'Stor',
                            style: TextStyle(
                              color: Color(0xFFFFEA00),
                              fontFamily: 'Aparajita',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          "Choose Your Plan",
                          style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                offset: const Offset(0, 2),
                                blurRadius: 4,
                                color: Colors.black.withOpacity(0.2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 520,
                      child: PageView.builder(
                        controller: _pageController,
                        scrollDirection: Axis.horizontal,
                        itemCount: validKeys.length,
                        itemBuilder: (context, index) {
                          final key = validKeys[index];
                          final plans = grouped[key]!;
                          
                          // Check if this is the beginner plan
                          final isBeginnerCard = key == 'beginner';
                          
                          Plan? selectedPlan;
                          bool isMonthly = true;
                          
                          if (isBeginnerCard) {
                            // Beginner plan - use the trial plan
                            selectedPlan = plans['trial'];
                            isMonthly = true;
                          } else {
                            // Regular paid plans
                            final monthlyPlan = plans["monthly"];
                            final yearlyPlan = plans["yearly"];
                            
                            isMonthly = _isMonthlySelected[index] ?? true;
                            selectedPlan = isMonthly ? monthlyPlan : yearlyPlan;
                            
                            // If selected plan is null, try the other option
                            if (selectedPlan == null) {
                              selectedPlan = monthlyPlan ?? yearlyPlan;
                              if (selectedPlan == monthlyPlan) {
                                isMonthly = true;
                              } else if (selectedPlan == yearlyPlan) {
                                isMonthly = false;
                              }
                            }
                          }

                          // If still no selected plan, skip this card
                          if (selectedPlan == null) {
                            return const SizedBox.shrink();
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: _buildPlanCard(
                              index: index,
                              plans: plans,
                              isBeginnerCard: isBeginnerCard,
                              isMonthly: isMonthly,
                              selectedPlan: selectedPlan,
                              onDurationChanged: (val) {
                                setState(() {
                                  _isMonthlySelected[index] = val;
                                });
                              },
                              startProvider: startProvider,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required int index,
    required Map<String, Plan> plans,
    required bool isBeginnerCard,
    required bool isMonthly,
    required Plan selectedPlan,
    required Function(bool) onDurationChanged,
    required StartSubscriptionProvider startProvider,
  }) {
    final productLimit = selectedPlan.productLimit ?? 0;
    final productText =
        productLimit == -1 ? "Unlimited" : productLimit.toString();

    // Get plans by duration type
    final monthlyPlan = plans["monthly"];
    final yearlyPlan = plans["yearly"];
    final trialPlan = plans["trial"];

    // Get total amount for payment (including GST and other charges)
    final monthlyTotalAmount = monthlyPlan?.totalAmount ?? 0;
    final yearlyTotalAmount = yearlyPlan?.totalAmount ?? 0;
    final trialTotalAmount = trialPlan?.totalAmount ?? 0;

    final isPopular = productLimit >= 300 && !isBeginnerCard;

    final yearlySavings =
        monthlyPlan != null && yearlyPlan != null
            ? (monthlyPlan.baseAmount ?? 0 * 12) - (yearlyPlan.baseAmount ?? 0)
            : 0;

    // Color scheme based on plan type
    Color primaryColor = const Color(0xFF0703C9);
    Color cardBackgroundColor = const Color.fromARGB(255, 239, 239, 240);
    Color borderColor = const Color.fromARGB(255, 199, 199, 201);
    Color textColor = Colors.black;
    Color priceColor = Colors.black;
    
    // Beginner plan color scheme - Use same as app theme
    if (isBeginnerCard) {
      primaryColor = const Color(0xFF0703C9);
      cardBackgroundColor = Colors.white;
      borderColor = const Color(0xFF0703C9);
      textColor = Colors.black;
      priceColor = const Color(0xFF0703C9);
    }

    // Get current amounts based on selection
    final currentDisplayAmount = isBeginnerCard 
        ? trialPlan?.baseAmount ?? 0
        : (isMonthly ? monthlyPlan?.baseAmount ?? 0 : yearlyPlan?.baseAmount ?? 0);
    final currentTotalAmount = isBeginnerCard 
        ? trialTotalAmount 
        : (isMonthly ? monthlyTotalAmount : yearlyTotalAmount);

    return Container(
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: borderColor,
          width: isBeginnerCard ? 2.5 : 2,
        ),
        boxShadow: isBeginnerCard ? [
          BoxShadow(
            color: const Color(0xFF0703C9).withOpacity(0.15),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ] : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // FREE Badge for beginner/free plans
          if (isBeginnerCard)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF0703C9),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Text(
                "✨ WELCOME ABOARD ",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            )
          else if (isPopular)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Text(
                "⭐ MOST POPULAR",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            )
          else
            const SizedBox(height: 36),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Plan Name
                Text(
                  selectedPlan.name ?? 'Standard',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                // Price - Display Base Amount
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      isBeginnerCard ? "FREE" : "₹$currentDisplayAmount",
                      style: TextStyle(
                        fontSize: isBeginnerCard ? 32 : 34,
                        fontWeight: FontWeight.bold,
                        color: priceColor,
                      ),
                    ),
                    if (!isBeginnerCard) ...[
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          isMonthly ? "/mo" : "/yr",
                          style: TextStyle(
                            fontSize: 14,
                            color: textColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                // GST exclusion text (hide for free plans)
                if (!isBeginnerCard)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      "*Excludes GST ",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                
                // Savings text for yearly plans
                if (!isBeginnerCard && !isMonthly && yearlySavings > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      "Save ₹$yearlySavings yearly!",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                
                const SizedBox(height: 20),
                
                // Duration Toggle - Hide for beginner cards
                if (!isBeginnerCard && monthlyPlan != null && yearlyPlan != null)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => onDurationChanged(true),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color:
                                    isMonthly
                                        ? primaryColor
                                        : Colors.transparent,
                                borderRadius: BorderRadius.circular(26),
                              ),
                              child: Text(
                                "Monthly",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color:
                                      isMonthly
                                          ? Colors.white
                                          : Colors.grey[600],
                                  fontWeight:
                                      isMonthly
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => onDurationChanged(false),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color:
                                    !isMonthly
                                        ? primaryColor
                                        : Colors.transparent,
                                borderRadius: BorderRadius.circular(26),
                              ),
                              child: Text(
                                "Yearly",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color:
                                      !isMonthly
                                          ? Colors.white
                                          : Colors.grey[600],
                                  fontWeight:
                                      !isMonthly
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else if (!isBeginnerCard && (monthlyPlan == null || yearlyPlan == null))
                  // Show a message if only one duration type is available
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        monthlyPlan != null ? "Monthly Plan" : "Yearly Plan",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  )
                else
                  // Show "Free Trial" message for beginner plans
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0703C9).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.verified_rounded,
                          color: const Color(0xFF0703C9),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          " Starter Plan",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0703C9),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                const SizedBox(height: 24),
                
                // Features with checkmarks
                ..._getAllFeatures(productLimit, isBeginnerCard).map(
                  (feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check,
                            size: 12,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            feature,
                            style: TextStyle(
                              fontSize: 13,
                              color: textColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Subscribe/Get Started Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (isBeginnerCard) {
                        // Handle free plan subscription - no payment required
                        _handleBeginnerSubscription(
                          selectedPlan,
                          startProvider,
                          selectedPlan.name ?? 'Free Trial',
                        );
                      } else {
                        _handlePaidSubscription(
                          selectedPlan,
                          startProvider,
                          currentTotalAmount,
                          selectedPlan.name ?? '$productText Products',
                          selectedPlan.durationType ?? "",
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isBeginnerCard ? const Color(0xFF0703C9) : primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: isBeginnerCard ? 4 : 2,
                      shadowColor: primaryColor.withOpacity(0.3),
                    ),
                    child: Text(
                      isBeginnerCard ? "Get Starter" : "Get ${selectedPlan.name ?? 'Standard'}",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Get all features with product limit as first point
 // Get all features with product limit as first point
List<String> _getAllFeatures(int productLimit, bool isBeginnerCard) {
  List<String> features = [];

  // Add product limit as first feature - ONLY for paid plans
  if (!isBeginnerCard) {
    features.add(_getProductLimitText(productLimit));
  }

  // Add common features
  features.addAll(_getCommonFeatures());

  // Add "No Payment Required" for free plans
  if (isBeginnerCard) {
    features.add('No Payment Required');
    features.add('No Renewal');
    // features.add('${selectedPlan?.durationInMonths ?? 3} Months Free Trial');
  }

  return features;
}

  // Common features for all plans
  List<String> _getCommonFeatures() {
    return ['24/7 Customer Support', 'Shop Management', 'Product Management'];
  }

  String _getProductLimitText(int productLimit) {
    if (productLimit == -1) return "Unlimited Products";
    return "$productLimit Products";
  }

  // Handle free plan subscription
  Future<void> _handleBeginnerSubscription(
    Plan plan,
    StartSubscriptionProvider startProvider,
    String productsText,
  ) async {
    if (widget.shopId == null || plan.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error: Missing Shop ID or Plan ID"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    startProvider.clearError();

    final result = await startProvider.startSubscription(
      subscriptionPlanId: plan.id!,
      shopId: widget.shopId!,
    );

    if (startProvider.errorMessage != null || result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            startProvider.errorMessage ?? "Failed to start subscription",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // For free plan, show success and navigate directly
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          "Free Trial activated successfully! 🎉",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 3),
      ),
    );

    // Navigate to bottom bar
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const BottomBarScreen()),
      (route) => false,
    );
  }

  // Handle paid subscription
  Future<void> _handlePaidSubscription(
    Plan plan,
    StartSubscriptionProvider startProvider,
    int totalAmount,
    String productsText,
    String durationType,
  ) async {
    if (widget.shopId == null || plan.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error: Missing Shop ID or Plan ID"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    startProvider.clearError();

    final result = await startProvider.startSubscription(
      subscriptionPlanId: plan.id!,
      shopId: widget.shopId!,
    );

    if (startProvider.errorMessage != null || result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            startProvider.errorMessage ?? "Failed to start subscription",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Navigate to payment screen with total amount
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => PaymentScreen(
              name: '$productsText Plan',
              duration: durationType,
              amount: totalAmount,
              orderId: result.orderId ?? '',
              onPaymentSuccess: () async {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const BottomBarScreen()),
                  (route) => false,
                );
              },
            ),
      ),
    );
  }
}