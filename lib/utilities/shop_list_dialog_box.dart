import 'package:flutter/material.dart';
import 'package:poketstore/controllers/subscription_controller/user_shop_list_controller.dart';
import 'package:provider/provider.dart';
import 'package:poketstore/model/subscription_model/user_shop_list_model.dart';

class SelectShopDialog extends StatefulWidget {
  const SelectShopDialog({super.key});

  @override
  State<SelectShopDialog> createState() => _SelectShopDialogState();
}

class _SelectShopDialogState extends State<SelectShopDialog> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<UserShopListController>().fetchUserShops();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        height: 400,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Consumer<UserShopListController>(
            builder: (context, controller, _) {
              if (controller.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.shops.isEmpty) {
                return const Center(child: Text("No shops found"));
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Select Shop",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.separated(
                      itemCount: controller.shops.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final UserShopListModel shop = controller.shops[index];

                        return ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              shop.headerImage ?? '',
                              width: 45,
                              height: 45,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (_, __, ___) => const Icon(Icons.store),
                            ),
                          ),
                          title: Text(shop.shopName ?? ''),
                          subtitle: Text("${shop.place}, ${shop.state}"),
                          onTap: () {
                            Navigator.pop(context, shop.id); // 🔥 return shopId
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
