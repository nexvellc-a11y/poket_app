import 'package:flutter/material.dart';
import 'package:poketstore/controllers/my_shope_controller/shope_details_controller.dart';
import 'package:poketstore/controllers/add_shop_controller/add_shop_controller.dart';
import 'package:poketstore/controllers/shop_of_user_controller/shop_of_user_controller.dart';
import 'package:poketstore/view/subscription/subscription.dart';
import 'package:provider/provider.dart';
import 'package:poketstore/view/add_shop/add_shop.dart';

class ShopeDetailsScreen extends StatelessWidget {
  final String shopId;

  const ShopeDetailsScreen({super.key, required this.shopId});

  // 🔔 Subscription expiry alert
  void _checkSubscriptionAlert(BuildContext context, int remainingDays) {
    if (remainingDays <= 5) {
      Future.delayed(Duration.zero, () {
        showDialog(
          context: context,
          builder:
              (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                title: const Text(
                  "Subscription Expiring",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                content: Text(
                  "Your subscription will expire soon "
                  // $remainingDays day(s).\n\n"
                  "Please renew your plan to avoid service interruption.",
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text("Later"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SubscriptionScreen(shopId: shopId),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 7, 3, 201),
                    ),
                    child: const Text("Renew Now"),
                  ),
                ],
              ),
        );
      });
    }
  }

  // 🗑 Delete confirmation
  Future<void> _confirmDelete(BuildContext context, String shopId) async {
    return showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: const Text(
              "Delete Shop",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text(
              "Are you sure you want to delete this shop? This action cannot be undone.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(ctx);

                  final shopProvider = Provider.of<ShopProvider>(
                    context,
                    listen: false,
                  );
                  final shopOfUserProvider = Provider.of<ShopOfUserProvider>(
                    context,
                    listen: false,
                  );

                  await shopProvider.deleteShop(shopId, context, () {
                    shopOfUserProvider.fetchUserShops();
                    Navigator.of(context).pop(true);
                  });

                  if (shopProvider.errorMessage.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(shopProvider.errorMessage),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Shop deleted successfully!"),
                        backgroundColor: Color.fromARGB(255, 7, 3, 201),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text("Delete"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ShopeDetailsProvider()..loadShopeDetails(shopId),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 7, 3, 201),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: const Text(
                "Shop Details",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              iconTheme: const IconThemeData(color: Colors.white),
              actions: [
                Consumer<ShopeDetailsProvider>(
                  builder: (context, detailsProvider, child) {
                    if (detailsProvider.shopDetails == null) {
                      return const SizedBox.shrink();
                    }

                    return PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      onSelected: (value) async {
                        if (value == 'edit') {
                          final updated = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => AddShop(
                                    shopToEdit: detailsProvider.shopDetails,
                                  ),
                            ),
                          );

                          if (updated == true) {
                            detailsProvider.refreshDetails(shopId);
                            Provider.of<ShopOfUserProvider>(
                              context,
                              listen: false,
                            ).fetchUserShops();
                          }
                        } else if (value == 'delete') {
                          _confirmDelete(context, shopId);
                        }
                      },
                      itemBuilder:
                          (_) => const [
                            PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit Shop'),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete Shop'),
                            ),
                          ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        body: Consumer<ShopeDetailsProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.shopDetails == null) {
              return const Center(child: Text("Shop details not found"));
            }

            final shop = provider.shopDetails!;

            // 📅 Remaining days logic
            int? remainingDays;

            if (shop.subscription?.remainingDays != null) {
              remainingDays = shop.subscription!.remainingDays;
            } else if (shop.subscription?.endDate != null) {
              final DateTime endDate = shop.subscription!.endDate!;
              remainingDays = endDate.difference(DateTime.now()).inDays;
            }

            if (remainingDays != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _checkSubscriptionAlert(context, remainingDays!);
              });
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (remainingDays != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            remainingDays <= 5
                                ? Colors.red.shade50
                                : Colors.green.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: remainingDays <= 5 ? Colors.red : Colors.green,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            color:
                                remainingDays <= 5 ? Colors.red : Colors.green,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Subscription valid for $remainingDays day(s)",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child:
                        shop.headerImage != null && shop.headerImage!.isNotEmpty
                            ? Image.network(
                              shop.headerImage!,
                              height: 220,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                            : Container(
                              height: 220,
                              color: Colors.grey.shade300,
                              child: const Center(
                                child: Text("No Image Available"),
                              ),
                            ),
                  ),
                  const SizedBox(height: 25),

                  Text(
                    shop.shopName ?? '',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(height: 30),

                  _buildDetailRow(
                    "Category",
                    shop.category?.join(', ') ?? 'N/A',
                  ),
                  _buildDetailRow("Seller Type", shop.sellerType ?? 'N/A'),
                  _buildDetailRow(
                    "Location",
                    "${shop.place}, ${shop.locality}, ${shop.state}",
                  ),
                  _buildDetailRow("Pincode", shop.pinCode ?? ''),
                  _buildDetailRow("Email", shop.email ?? ''),
                  _buildDetailRow("Mobile", shop.mobileNumber ?? ''),
                  _buildDetailRow("Landline", shop.landlineNumber ?? ''),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label: ", style: const TextStyle(fontSize: 16)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
