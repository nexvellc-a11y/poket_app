import 'package:flutter/material.dart';
import 'package:poketstore/model/notification_model/notification_model.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationDetailScreen extends StatelessWidget {
  final NotificationModel notification;

  const NotificationDetailScreen({super.key, required this.notification});

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(245, 247, 250, 1),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color.fromARGB(255, 7, 3, 201),
          centerTitle: true,
          title: const Text(
            'Notification Details',
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Hero Section - Main Notification Card
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.white, Colors.grey.shade50],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Icon and Type Chip Row
                          Row(
                            children: [
                              _buildNotificationIcon(),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildTypeChip(),
                                    const SizedBox(height: 8),
                                    Text(
                                      _formatDateTime(notification.createdAt),
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade500,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Title with custom decoration
                          Container(
                            padding: const EdgeInsets.only(left: 8),
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(
                                  color: _getTypeColor(),
                                  width: 4,
                                ),
                              ),
                            ),
                            child: Text(
                              notification.title,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                height: 1.3,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Body text
                          Text(
                            notification.body,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey.shade700,
                              height: 1.5,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Additional Details Section
                  if (_hasAdditionalDetails())
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section Header
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey.shade200,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: _getTypeColor().withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.info_outline_rounded,
                                    color: _getTypeColor(),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Additional Information',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Details Content
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _buildAdditionalDetails(),
                            ),
                          ),
                        ],
                      ),
                    ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor() {
    switch (notification.type) {
      case 'new_shop':
        return const Color(0xFF3B82F6);
      case 'new_product':
        return const Color(0xFF10B981);
      case 'order':
        return const Color(0xFFF59E0B);
      case 'new_plan':
        return const Color(0xFF8B5CF6);
      case 'subscription_activated':
        return const Color(0xFF14B8A6);
      default:
        return Colors.grey;
    }
  }

  Widget _buildTypeChip() {
    String typeText;
    switch (notification.type) {
      case 'new_shop':
        typeText = 'New Shop';
        break;
      case 'new_product':
        typeText = 'New Product';
        break;
      case 'order':
        typeText = 'Order Update';
        break;
      case 'new_plan':
        typeText = 'New Plan';
        break;
      case 'subscription_activated':
        typeText = 'Subscription';
        break;
      default:
        typeText = notification.type;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getTypeColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getTypeColor().withOpacity(0.2), width: 1),
      ),
      child: Text(
        typeText,
        style: TextStyle(
          color: _getTypeColor(),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildNotificationIcon() {
    IconData icon;
    switch (notification.type) {
      case 'new_shop':
        icon = Icons.storefront_rounded;
        break;
      case 'new_product':
        icon = Icons.inventory_2_rounded;
        break;
      case 'order':
        icon = Icons.shopping_bag_rounded;
        break;
      case 'new_plan':
        icon = Icons.credit_card_rounded;
        break;
      case 'subscription_activated':
        icon = Icons.verified_rounded;
        break;
      default:
        icon = Icons.notifications_rounded;
    }

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getTypeColor().withOpacity(0.2),
            _getTypeColor().withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(icon, size: 30, color: _getTypeColor()),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    }

    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  bool _hasAdditionalDetails() {
    final data = notification.data;
    return data.shopId.isNotEmpty ||
        data.shopName.isNotEmpty ||
        data.productId.isNotEmpty ||
        data.productName.isNotEmpty ||
        data.orderId.isNotEmpty ||
        data.userName.isNotEmpty ||
        data.planId.isNotEmpty ||
        data.planName.isNotEmpty ||
        data.amount != null ||
        data.subscriptionId.isNotEmpty ||
        data.durationDays != null ||
        data.startDate != null ||
        data.endDate != null ||
        (data.fullDetails != null && data.fullDetails!.items.isNotEmpty);
  }

  List<Widget> _buildAdditionalDetails() {
    final data = notification.data;
    final List<Widget> details = [];

    // Product details
    if (data.productId.isNotEmpty) {
      details.add(_buildDetailRow('Product ID', data.productId));
    }
    if (data.productName.isNotEmpty) {
      details.add(_buildDetailRow('Product Name', data.productName));
    }

    // Order details
    if (data.userName.isNotEmpty) {
      details.add(_buildDetailRow('Customer Name', data.userName));
    }
    if (data.orderTime != null) {
      details.add(
        _buildDetailRow('Order Time', _formatDateTime(data.orderTime!)),
      );
    }

    // Plan details
    if (data.planId.isNotEmpty) {
      details.add(_buildDetailRow('Plan ID', data.planId));
    }
    if (data.planName.isNotEmpty) {
      details.add(_buildDetailRow('Plan Name', data.planName));
    }
    if (data.amount != null) {
      details.add(_buildDetailRow('Amount', '₹${data.amount}'));
    }

    // Subscription details
    if (data.subscriptionId.isNotEmpty) {
      details.add(_buildDetailRow('Subscription ID', data.subscriptionId));
    }
    if (data.durationDays != null) {
      details.add(_buildDetailRow('Duration', '${data.durationDays} days'));
    }
    if (data.startDate != null) {
      details.add(
        _buildDetailRow('Start Date', _formatDateTime(data.startDate!)),
      );
    }
    if (data.endDate != null) {
      details.add(_buildDetailRow('End Date', _formatDateTime(data.endDate!)));
    }

    // Full order details
    if (data.fullDetails != null) {
      final fullDetails = data.fullDetails!;

      // Customer details
      if (fullDetails.customer != null) {
        details.add(const SizedBox(height: 16));
        details.add(
          _buildSectionHeader(
            'Customer Information',
            Icons.person_outline_rounded,
          ),
        );
        details.add(_buildDetailRow('Name', fullDetails.customer!.name));
        details.add(
          _buildDetailRow('Phone', fullDetails.customer!.phone, isPhone: true),
        );
      }

      // Address details
      if (fullDetails.address != null) {
        details.add(const SizedBox(height: 16));
        details.add(
          _buildSectionHeader('Shipping Address', Icons.location_on_outlined),
        );
        details.add(_buildDetailRow('House No', fullDetails.address!.houseNo));
        details.add(_buildDetailRow('Area', fullDetails.address!.area));
        details.add(_buildDetailRow('Town', fullDetails.address!.town));
        details.add(_buildDetailRow('State', fullDetails.address!.state));
        details.add(_buildDetailRow('Country', fullDetails.address!.country));
        details.add(_buildDetailRow('Pincode', fullDetails.address!.pincode));
        if (fullDetails.address!.landmark.isNotEmpty) {
          details.add(
            _buildDetailRow('Landmark', fullDetails.address!.landmark),
          );
        }
      }

      // Order items
      if (fullDetails.items.isNotEmpty) {
        details.add(const SizedBox(height: 16));
        details.add(
          _buildSectionHeader('Order Items', Icons.shopping_bag_outlined),
        );
        for (var item in fullDetails.items) {
          details.add(_buildOrderItem(item));
        }
      }

      // Total amount
      if (fullDetails.totalAmount != null) {
        details.add(const SizedBox(height: 16));
        details.add(_buildTotalAmount(fullDetails.totalAmount!));
      }
    }

    return details;
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: _getTypeColor()),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isBold = false,
    Color? textColor,
    bool isPhone = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
                      color: textColor ?? Colors.grey.shade900,
                    ),
                  ),
                ),
                if (isPhone)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.phone_rounded,
                        color: Colors.green.shade600,
                        size: 18,
                      ),
                      onPressed: () => _makePhoneCall(value),
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(OrderItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.name,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Price: ₹${item.price}',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Qty: ${item.quantity}',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.receipt_rounded,
                  size: 14,
                  color: Colors.green,
                ),
                const SizedBox(width: 4),
                Text(
                  'Subtotal: ₹${item.priceWithQuantity.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalAmount(double amount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade50, Colors.green.shade100],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total Amount',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.green.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
