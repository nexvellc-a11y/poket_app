import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:poketstore/controllers/shop_nearby_controller/shop_product_nearby_controller.dart';
import 'package:poketstore/model/add_shope_model/add_shop_model.dart';
import 'package:poketstore/view/add_shop/shope_details_screen.dart';
import 'package:poketstore/view/my_products/add_product_screen.dart';
import 'package:poketstore/view/my_products/product_details_screen.dart';
import 'package:poketstore/view/subscription/subscription.dart'; // Import your subscription screen
import 'package:provider/provider.dart';

class ShopDetailsWithProductsScreen extends StatefulWidget {
  final ShopModel shop;

  const ShopDetailsWithProductsScreen({super.key, required this.shop});

  @override
  State<ShopDetailsWithProductsScreen> createState() =>
      _ShopDetailsWithProductsScreenState();
}

class _ShopDetailsWithProductsScreenState
    extends State<ShopDetailsWithProductsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final shopId = widget.shop.id;
      if (shopId != null && shopId.isNotEmpty) {
        Provider.of<ShopProductNearbyProductController>(
          context,
          listen: false,
        ).loadProducts(shopId);
      } else {
        log('Shop ID is null or empty, cannot load products.');
      }
    });

    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    Provider.of<ShopProductNearbyProductController>(
      context,
      listen: false,
    ).filterProducts(_searchController.text);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToSubscriptionPlans() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SubscriptionScreen(shopId: widget.shop.id ?? ''),
      ),
    );
  }

  void _navigateToEditShop() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ShopeDetailsScreen(shopId: widget.shop.id ?? ''),
      ),
    ).then((result) {
      if (result == true) {
        setState(() {});
      }
    });
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.black),
                title: const Text('Edit Shop '),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToEditShop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.credit_card, color: Colors.black),
                title: const Text('Renew Plan'),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToSubscriptionPlans();
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.close, color: Colors.grey),
                title: const Text('Cancel'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final shop = widget.shop;
    // final isSubscriptionActive = widget.shop.subscription?.isActive ?? false;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: Colors.black,
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                final percent = ((constraints.maxHeight - kToolbarHeight) / 260)
                    .clamp(0.0, 1.0);

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background Image
                    // Image.asset('assets/shop.jpeg', fit: BoxFit.cover),
                    Image.network(
                      shop.headerImage?.isNotEmpty == true
                          ? shop.headerImage!
                          : 'https://via.placeholder.com/400x200?text=No+Image',
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) => Container(
                            color: Colors.grey.shade300,
                            child: const Icon(
                              Icons.store,
                              size: 60,
                              color: Colors.grey,
                            ),
                          ),
                    ),

                    // Gradient Overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.6),
                            Colors.black.withOpacity(0.4),
                            Colors.black.withOpacity(0.2),
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),

                    // Glowing Circles (Soft Glows)
                    // Positioned(
                    //   top: -40,
                    //   left: -40,
                    //   child: _glowCircle(140, Colors.white.withOpacity(0.6)),
                    // ),
                    // Positioned(
                    //   bottom: -50,
                    //   right: -30,
                    //   child: _glowCircle(160, Colors.white.withOpacity(0.5)),
                    // ),

                    // Centered Shop Name
                    // Positioned(
                    //   left: 20,
                    //   bottom: 30,
                    //   child: Opacity(
                    //     opacity: percent,
                    //     child: Column(
                    //       mainAxisSize: MainAxisSize.min,
                    //       children: [
                    //         Text(
                    //           shop.shopName ?? "Shop Name",
                    //           style: const TextStyle(
                    //             color: Colors.white,
                    //             fontSize: 28,
                    //             fontWeight: FontWeight.w700,
                    //             shadows: [
                    //               Shadow(color: Colors.black87, blurRadius: 10),
                    //             ],
                    //           ),
                    //           textAlign: TextAlign.center,
                    //         ),
                    //         const SizedBox(height: 6),

                    //         if (shop.place?.isNotEmpty == true)
                    //           Text(
                    //             shop.place!,
                    //             style: const TextStyle(
                    //               color: Colors.white70,
                    //               fontSize: 14,
                    //             ),
                    //           ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                  ],
                );
              },
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Shop details section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          shop.shopName ?? 'Shop Name',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Three-dot menu button
                      IconButton(
                        icon: const Icon(Icons.more_vert, size: 24),
                        onPressed: () => _showMenu(context),
                        tooltip: 'Shop Options',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Subscription status badge (optional)
                  // _buildSubscriptionStatus(),
                  if (shop.place != null || shop.mobileNumber != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (shop.place != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  shop.place!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (shop.mobileNumber != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.phone,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  shop.mobileNumber!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),

                  const SizedBox(height: 16),
                  const Divider(),

                  // Search bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Text(
                    'Available Products',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // Products grid
          Consumer<ShopProductNearbyProductController>(
            builder: (context, controller, _) {
              if (controller.isLoading) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final bool isSearching = _searchController.text.isNotEmpty;

              final productsToDisplay =
                  isSearching
                      ? controller.filteredProducts
                      : controller.productData?.products;

              if (productsToDisplay == null || productsToDisplay.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Text(
                      _searchController.text.isNotEmpty
                          ? "No products found"
                          : "No products available in this shop.",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.7,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final product = productsToDisplay[index];
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => MyShopProductDetails(
                                  productId: product.id ?? '',
                                ),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product image
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                              child:
                                  product.productImage?.isNotEmpty == true
                                      ? Image.network(
                                        product.productImage!,
                                        height: 120,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (_, __, ___) => Container(
                                              height: 120,
                                              color: Colors.grey.shade200,
                                              child: const Icon(
                                                Icons.image_not_supported,
                                                color: Colors.grey,
                                              ),
                                            ),
                                      )
                                      : Container(
                                        height: 120,
                                        color: Colors.grey.shade200,
                                        child: const Icon(
                                          Icons.image_not_supported,
                                          color: Colors.grey,
                                        ),
                                      ),
                            ),

                            // Product details
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name ?? 'Product',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "₹${product.price?.toStringAsFixed(2) ?? 'N/A'}",
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }, childCount: productsToDisplay.length),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddProductScreen(shopId: widget.shop.id ?? ''),
            ),
          ).then((result) {
            if (result == true) {
              final shopId = widget.shop.id;
              if (shopId != null && shopId.isNotEmpty) {
                Provider.of<ShopProductNearbyProductController>(
                  // ignore: use_build_context_synchronously
                  context,
                  listen: false,
                ).loadProducts(shopId);
              }
            }
          });
        },
        backgroundColor: const Color.fromARGB(255, 7, 3, 201),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // Method to show subscription status badge
  // Widget _buildSubscriptionStatus() {
  //   // Example implementation - replace with your actual subscription data
  //   final subscriptionStatus = widget.shop.subscriptionStatus ?? 'inactive';
  //   final subscriptionEndDate = widget.shop.subscriptionEndDate;

  //   if (subscriptionStatus == 'active' && subscriptionEndDate != null) {
  //     return Container(
  //       margin: const EdgeInsets.only(bottom: 8),
  //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  //       decoration: BoxDecoration(
  //         color: Colors.green.withOpacity(0.1),
  //         borderRadius: BorderRadius.circular(12),
  //         border: Border.all(color: Colors.green, width: 1),
  //       ),
  //       child: Row(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           Icon(Icons.verified, size: 14, color: Colors.green[700]),
  //           const SizedBox(width: 4),
  //           Text(
  //             'Premium Plan • Valid until ${_formatDate(subscriptionEndDate)}',
  //             style: TextStyle(
  //               fontSize: 12,
  //               color: Colors.green[700],
  //               fontWeight: FontWeight.w500,
  //             ),
  //           ),
  //         ],
  //       ),
  //     );
  //   } else {
  //     return Container(
  //       margin: const EdgeInsets.only(bottom: 8),
  //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  //       decoration: BoxDecoration(
  //         color: Colors.orange.withOpacity(0.1),
  //         borderRadius: BorderRadius.circular(12),
  //         border: Border.all(color: Colors.orange, width: 1),
  //       ),
  //       child: Row(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           Icon(Icons.info_outline, size: 14, color: Colors.orange[700]),
  //           const SizedBox(width: 4),
  //           Text(
  //             'Free Plan • Upgrade for more features',
  //             style: TextStyle(
  //               fontSize: 12,
  //               color: Colors.orange[700],
  //               fontWeight: FontWeight.w500,
  //             ),
  //           ),
  //         ],
  //       ),
  //     );
  //   }
  // }

  // String _formatDate(String dateString) {
  //   try {
  //     final date = DateTime.parse(dateString);
  //     return '${date.day}/${date.month}/${date.year}';
  //   } catch (e) {
  //     return dateString;
  //   }
  // }

  Widget _glowCircle(double size, Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.25),
            blurRadius: 40,
            spreadRadius: 18,
          ),
        ],
      ),
    );
  }
}
