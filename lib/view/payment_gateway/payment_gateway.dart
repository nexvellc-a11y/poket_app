import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:poketstore/network/dio_network_service.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentScreen extends StatefulWidget {
  final int amount;
  final String orderId;
  final String name;
  final String duration;
  final VoidCallback onPaymentSuccess;

  const PaymentScreen({
    super.key,
    required this.amount,
    required this.orderId,
    required this.name,
    required this.duration,
    required this.onPaymentSuccess,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late Razorpay _razorpay;
  final Dio _dio = Dio();

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  // ----------------- PAYMENT HANDLERS -----------------
  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    log("✅ Payment Success Callback Triggered");

    log("🔑 Razorpay Payment ID: ${response.paymentId}");
    log("📦 Razorpay Order ID: ${response.orderId}");
    log("🖊️ Razorpay Signature: ${response.signature}");

    _showLoadingDialog();

    try {
      final requestData = {
        "razorpay_payment_id": response.paymentId,
        "razorpay_order_id": response.orderId,
        "razorpay_signature": response.signature,
      };

      log("📤 Sending to backend: $requestData");

      // ✅ Use centralized Dio
      final apiResponse = await DioNetworkService.dio.post(
        '/api/subscription/verify-payment',
        data: requestData,
      );

      _dismissLoadingDialog();

      log("📥 Backend Response: ${apiResponse.data}");

      if (apiResponse.statusCode == 200) {
        _showSnackBar(
          "Payment Successful! Subscription Activated 🎉",
          isError: false,
        );
        widget.onPaymentSuccess();
      } else {
        _showSnackBar("Payment verification failed. Please try again.");
      }
    } catch (e, stack) {
      _dismissLoadingDialog();
      log("❌ Verification Error: $e\nStack Trace: $stack");
      _showSnackBar("Payment verification failed.");
    }
  }

  void _handlePaymentError(dynamic response) {
    try {
      if (response is PaymentFailureResponse) {
        log("❌ Payment Failed: ${response.message}");
      } else {
        log("⚠️ Unexpected response: $response");
      }
    } catch (e) {
      log("⚠️ Payment error parsing failed: $e");
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    log("💳 External Wallet: ${response.walletName}");
  }

  // ----------------- CHECKOUT -----------------
  void _openCheckout() {
    final options = {
      'key': 'rzp_test_R72iZNqI9xkkIA',
      'amount': (widget.amount * 100).toInt(),
      'name': 'PoketStor',
      'description': 'Subscription Payment',
      'order_id': widget.orderId,
      'prefill': {'contact': '9400006000', 'email': 'nexvellc@gmail.com'},
      'timeout': 300,
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      log("❌ Error opening Razorpay: $e");
      _showSnackBar("Failed to open payment gateway.");
    }
  }

  // ----------------- HELPERS -----------------
  void _showLoadingDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => const Center(
            child: CircularProgressIndicator(color: Color(0xFF667EEA)),
          ),
    );
  }

  void _dismissLoadingDialog() {
    if (mounted && Navigator.canPop(context)) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  // ----------------- UI -----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Payment",
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _PaymentCard(name: widget.name, duration: widget.duration),
            const SizedBox(height: 32),
            _AmountSection(amount: widget.amount),
            const SizedBox(height: 32),
            _PayButton(onPressed: _openCheckout),
          ],
        ),
      ),
    );
  }
}

// ----------------- SUB-WIDGETS -----------------
class _PaymentCard extends StatelessWidget {
  final String name;
  final String duration;

  const _PaymentCard({required this.name, required this.duration});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.credit_card, color: Colors.white, size: 32),
              Text(
                "VISA",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          const Text(
            "**** **** **** 1234",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              letterSpacing: 2,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
              Text(
                "EXPIRES\n$duration",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AmountSection extends StatelessWidget {
  final int amount;

  const _AmountSection({required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "Total Amount",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            "₹${amount.toStringAsFixed(2)}",
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Inclusive of all taxes",
            style: TextStyle(color: Colors.green, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _PayButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _PayButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF667EEA),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
          // ignore: deprecated_member_use
          shadowColor: Colors.blue.withOpacity(0.3),
        ),
        child: const Text(
          "Confirm Payment",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
