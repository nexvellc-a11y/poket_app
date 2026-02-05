import 'package:flutter/material.dart';
import 'package:poketstore/model/notification_model/notification_model.dart';

class NotificationDetailScreen extends StatelessWidget {
  final NotificationModel notification;

  const NotificationDetailScreen({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 7, 3, 201),
        centerTitle: true,
        title: const Text(
          'Notification Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Main Notification Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildNotificationIcon(),
                      const SizedBox(height: 10),
                      Text(
                        notification.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        notification.body,
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 15),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          _formatDateTime(notification.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Additional Details based on notification type
              if (_hasAdditionalDetails())
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Additional Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ..._buildAdditionalDetails(),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon() {
    IconData icon;
    Color color;

    switch (notification.type) {
      case 'new_shop':
        icon = Icons.store;
        color = Colors.blue;
        break;
      case 'new_product':
        icon = Icons.inventory;
        color = Colors.green;
        break;
      case 'order':
        icon = Icons.shopping_cart;
        color = Colors.orange;
        break;
      case 'new_plan':
        icon = Icons.credit_card;
        color = Colors.purple;
        break;
      case 'subscription_activated':
        icon = Icons.verified;
        color = Colors.teal;
        break;
      default:
        icon = Icons.notifications;
        color = Colors.grey;
    }

    return Center(
      child: CircleAvatar(
        // ignore: deprecated_member_use
        backgroundColor: color.withOpacity(0.1),
        radius: 30,
        child: Icon(icon, size: 30, color: color),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  bool _hasAdditionalDetails() {
    final data = notification.data;

    // Check if any of the fields have meaningful data
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

    // Shop details
    // if (data.shopId.isNotEmpty) {
    //   details.add(_buildDetailRow('Shop ID', data.shopId));
    // }
    // if (data.shopName.isNotEmpty) {
    //   details.add(_buildDetailRow('Shop Name', data.shopName));
    // }

    // Product details
    if (data.productId.isNotEmpty) {
      details.add(_buildDetailRow('Product ID', data.productId));
    }
    if (data.productName.isNotEmpty) {
      details.add(_buildDetailRow('Product Name', data.productName));
    }

    // Order details
    // if (data.orderId.isNotEmpty) {
    //   details.add(_buildDetailRow('Order ID', data.orderId));
    // }
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

    // Full order details (for order notifications)
    if (data.fullDetails != null) {
      final fullDetails = data.fullDetails!;

      // Customer details
      if (fullDetails.customer != null) {
        details.add(const SizedBox(height: 10));
        details.add(
          const Text(
            'Customer Information',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        );
        details.add(_buildDetailRow('Name', fullDetails.customer!.name));
        // details.add(_buildDetailRow('Email', fullDetails.customer!.email));
        details.add(_buildDetailRow('Phone', fullDetails.customer!.phone));
      }

      // Address details
      if (fullDetails.address != null) {
        details.add(const SizedBox(height: 10));
        details.add(
          const Text(
            'Shipping Address',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
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
        details.add(const SizedBox(height: 10));
        details.add(
          const Text(
            'Order Items',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        );
        for (var item in fullDetails.items) {
          details.add(_buildOrderItem(item));
        }
      }

      // Total amount
      if (fullDetails.totalAmount != null) {
        details.add(const SizedBox(height: 10));
        details.add(
          _buildDetailRow(
            'Total Amount',
            '₹${fullDetails.totalAmount!.toStringAsFixed(2)}',
            isBold: true,
            textColor: Colors.green,
          ),
        );
      }
    }

    return details;
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isBold = false,
    Color? textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: textColor ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(OrderItem item) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Price: ₹${item.price}'),
                Text('Qty: ${item.quantity}'),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Subtotal: ₹${item.priceWithQuantity.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
