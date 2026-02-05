import 'package:flutter/material.dart';
import 'package:poketstore/controllers/notification_controller.dart/notification_controller.dart';
import 'package:poketstore/controllers/reward_controller/reward_controller.dart';
import 'package:poketstore/model/notification_model/notification_model.dart';
import 'package:poketstore/view/notification/notification_details.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      // ignore: use_build_context_synchronously
      context.read<NotificationProvider>().loadNotificationsForCurrentUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationProvider = context.watch<NotificationProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 7, 3, 201),
        centerTitle: true,
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Chip(
              side: BorderSide.none,
              label: Text(
                'Unread: ${notificationProvider.unreadCount}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: const Color.fromARGB(255, 7, 3, 201),
            ),
          ),
        ],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: Builder(
              builder: (context) {
                if (notificationProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (notificationProvider.errorMessage != null &&
                    notificationProvider.notifications.isEmpty) {
                  return Center(
                    child: Text(notificationProvider.errorMessage!),
                  );
                }
                if (notificationProvider.notifications.isEmpty) {
                  return const Center(child: Text("No notifications yet."));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: notificationProvider.notifications.length,
                  itemBuilder: (context, index) {
                    final notification =
                        notificationProvider.notifications[index];
                    final isRead = notification.recipient.isRead;
                    final backgroundColor =
                        isRead
                            // ignore: deprecated_member_use
                            ? Colors.grey.withOpacity(0.2)
                            : const Color.fromARGB(255, 7, 3, 201);
                    final textColor = isRead ? Colors.black87 : Colors.white;

                    // Check if the notification is a new order alert
                    final String title = notification.title.toLowerCase();
                    final String titleUser =
                        notification.titleUser.toLowerCase();

                    final bool isNewOrderAlert =
                        title.contains('new order alert') ||
                        titleUser.contains('new order alert');

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                          child: Container(
                            decoration: BoxDecoration(
                              color: backgroundColor,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  // ignore: deprecated_member_use
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              border: Border.all(
                                // ignore: deprecated_member_use
                                color: Colors.blueAccent.withOpacity(0.5),
                                width: 1.2,
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              leading: CircleAvatar(
                                radius: 22,
                                backgroundColor:
                                    isRead
                                        ? Colors.blueGrey
                                        : Colors.blueAccent,
                                child: Icon(
                                  isNewOrderAlert
                                      ? Icons.shopping_cart
                                      : Icons.notifications_active,
                                  color: Colors.white,
                                ),
                              ),
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    notification.titleUser,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    notification.title,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      // ignore: deprecated_member_use
                                      color: textColor.withOpacity(
                                        0.8,
                                      ), // A slightly faded color
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    notification.bodyUser,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    notification.body,
                                    style: TextStyle(
                                      fontSize: 12,
                                      // ignore: deprecated_member_use
                                      color: textColor.withOpacity(0.7),
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  // Conditional button display
                                  if (isNewOrderAlert)
                                    Wrap(
                                      spacing: 10,
                                      runSpacing: 8,
                                      children: [
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blueAccent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          onPressed: () {
                                            notificationProvider.markAsRead(
                                              notification.id,
                                            );
                                          },
                                          child: const Text(
                                            "Read",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),

                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          onPressed: () {
                                            _handleConfirmOrder(notification);
                                          },
                                          child: const Text(
                                            "Confirm",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  else
                                    // Only show Read button for non-order notifications
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blueAccent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        onPressed: () {
                                          notificationProvider.markAsRead(
                                            notification.id,
                                          );
                                        },
                                        child: const Text(
                                          "Read",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${notification.createdAt.day}/${notification.createdAt.month}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                  Text(
                                    '${notification.createdAt.hour}:${notification.createdAt.minute.toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                  if (isNewOrderAlert)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.orange,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        "New Order",
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => NotificationDetailScreen(
                                          notification: notification,
                                        ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _handleConfirmOrder(NotificationModel notification) {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Confirm Order"),
            content: const Text("Are you sure you want to confirm this order?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () {
                  Navigator.pop(context);
                  _confirmOrderAction(notification);
                },
                child: const Text("Confirm Order"),
              ),
            ],
          ),
    );
  }

  Future<void> _confirmOrderAction(NotificationModel notification) async {
    final rewardController = context.read<RewardController>();

    // Optional: show loader
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final success = await rewardController.completeOrder(
      orderId: notification.data.orderId, // 🔴 MUST EXIST
      shopId: notification.data.shopId, // 🔴 MUST EXIST
    );

    Navigator.pop(context); // close loader

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "✅ ${rewardController.message}\n"
            "🎉 Reward: ${rewardController.rewardPoints} points",
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Mark notification as read
      context.read<NotificationProvider>().markAsRead(notification.id);

      // Refresh notifications
      context.read<NotificationProvider>().loadNotificationsForCurrentUser();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(rewardController.error ?? "Order confirmation failed"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
