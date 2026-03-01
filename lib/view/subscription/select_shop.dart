import 'package:flutter/material.dart';
import 'package:poketstore/controllers/subscription_controller/user_shop_list_controller.dart';
import 'package:poketstore/utilities/custom_app_bar.dart';
import 'package:poketstore/view/subscription/shop_list_scren.dart';
import 'package:poketstore/view/subscription/subscription_user.dart';
import 'package:provider/provider.dart';

class SelectShopScreen extends StatefulWidget {
  const SelectShopScreen({super.key});

  @override
  State<SelectShopScreen> createState() => _SelectShopScreenState();
}

class _SelectShopScreenState extends State<SelectShopScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<UserShopListController>(
        context,
        listen: false,
      ).fetchUserShops();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Select Shop', showBackButton: true),
      body: Consumer<UserShopListController>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // ✅ FIXED HERE
          if (provider.shops.isEmpty) {
            return const Center(child: Text('No shops found'));
          }

          return ShopListScreen(
            shops: provider.shops, // ✅ FIXED HERE
            onShopSelected: (shopId) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SubscriptionUserScreen(shopId: shopId),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
