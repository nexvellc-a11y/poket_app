import 'dart:developer';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:poketstore/controllers/shop_nearby_controller/shop_product_nearby_controller.dart';
import 'package:poketstore/model/add_shope_model/add_shop_model.dart';
import 'package:poketstore/view/home/view/product_details_screen/product_details_screen.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ShopProductsScreen extends StatefulWidget {
  final ShopModel shop;

  const ShopProductsScreen({super.key, required this.shop});

  @override
  State<ShopProductsScreen> createState() => _ShopProductsScreenState();
}

class _ShopProductsScreenState extends State<ShopProductsScreen> {
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

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    Provider.of<ShopProductNearbyProductController>(
      context,
      listen: false,
    ).filterProducts(_searchController.text);
  }

  void _showCallConfirmation(BuildContext context, String phone) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.phone_in_talk, size: 40, color: Colors.green),
              const SizedBox(height: 16),
              Text("Call Shop?", style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                "Do you want to call this shop now?",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 20),

              // Call Button
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _makePhoneCall(phone);
                },
                icon: const Icon(Icons.call),
                label: Text("Call $phone"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      log("Could not launch call to $phoneNumber");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      // backgroundColor: Colors.white70,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Modern SliverAppBar with gradient
          SliverAppBar(
            expandedHeight: 240.0,
            floating: true,
            pinned: true,
            snap: false,
            elevation: 0,
            backgroundColor: colorScheme.primary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: _buildAppBarBackground(colorScheme),
              titlePadding: const EdgeInsets.only(left: 16.0, bottom: 12.0),
              title: _buildShopInfo(),
            ),
            leading: _buildBackButton(colorScheme),
            // actions: [
            //   IconButton(
            //     icon: const Icon(Icons.share_outlined),
            //     onPressed: () {},
            //     color: Colors.white,
            //   ),
            //   IconButton(
            //     icon: const Icon(Icons.more_vert_outlined),
            //     onPressed: () {},
            //     color: Colors.white,
            //   ),
            // ],
          ),

          // Search Bar
          SliverPersistentHeader(
            pinned: true,
            delegate: _SearchBarDelegate(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: colorScheme.primary,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      suffixIcon:
                          _searchController.text.isNotEmpty
                              ? IconButton(
                                icon: Icon(
                                  Icons.clear_rounded,
                                  color: Colors.grey[500],
                                ),
                                onPressed: () => _searchController.clear(),
                              )
                              : null,
                    ),
                    style: textTheme.bodyLarge,
                  ),
                ),
              ),
            ),
          ),

          // Products Grid
          Consumer<ShopProductNearbyProductController>(
            builder: (context, controller, child) {
              if (controller.isLoading) {
                return SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: colorScheme.primary,
                    ),
                  ),
                );
              }

              final productsToDisplay =
                  controller.filteredProducts.isEmpty &&
                          _searchController.text.isEmpty
                      ? controller.productData?.products
                      : controller.filteredProducts;

              if (productsToDisplay == null || productsToDisplay.isEmpty) {
                return SliverFillRemaining(
                  child: _buildEmptyState(_searchController.text.isNotEmpty),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.7,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final product = productsToDisplay[index];
                    return _buildProductCard(
                      product,
                      colorScheme,
                      textTheme,
                      context,
                    );
                  }, childCount: productsToDisplay.length),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Method now accepts colorScheme as parameter
  Widget _buildAppBarBackground(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            widget.shop.headerImage?.isNotEmpty == true
                ? Colors.transparent
                : colorScheme.primary,
            colorScheme.primary.withOpacity(0.9),
          ],
        ),
      ),
      child:
      // Image.asset('assets/shop.jpeg', fit: BoxFit.cover),
      Image.network(
        widget.shop.headerImage?.isNotEmpty == true
            ? widget.shop.headerImage!
            : 'https://via.placeholder.com/400x200?text=No+Image',
        fit: BoxFit.cover,
        errorBuilder:
            (_, __, ___) => Container(
              color: Colors.grey.shade300,
              child: const Icon(Icons.store, size: 60, color: Colors.grey),
            ),
      ),
      // Image.asset(
      //   'assets/shop.jpeg',
      //   fit: BoxFit.cover,
      //   color: colorScheme.primary.withOpacity(0.4),
      //   colorBlendMode: BlendMode.multiply,
      // ),
      // widget.shop.headerImage?.isNotEmpty == true
      //     ? Image.network(
      //       widget.shop.headerImage!,
      //       fit: BoxFit.cover,
      //       color: colorScheme.primary.withOpacity(0.4),
      //       colorBlendMode: BlendMode.multiply,
      //     )
      //     : null,
    );
  }
  // Replace your previous _buildAppBarBackground with this:
  // Widget _buildAppBarBackground(ColorScheme colorScheme) {
  //   return AnimatedContainer(
  //     duration: const Duration(milliseconds: 600),
  //     curve: Curves.easeInOut,
  //     decoration: BoxDecoration(
  //       gradient: LinearGradient(
  //         colors: [
  //           colorScheme.primary.withOpacity(0.95),
  //           colorScheme.primary.withOpacity(0.85),
  //         ],
  //         begin: Alignment.topCenter,
  //         end: Alignment.bottomCenter,
  //       ),
  //     ),
  //     child: Stack(
  //       alignment: Alignment.center,
  //       children: [
  //         // Soft glowing background circles
  //         Positioned(
  //           top: -20,
  //           left: -20,
  //           child: _glowCircle(120, colorScheme.primary),
  //         ),
  //         Positioned(
  //           bottom: -30,
  //           right: -20,
  //           child: _glowCircle(150, colorScheme.primary),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Replace your previous _glowCircle with this (uses BoxShadow properly)
  // Widget _glowCircle(double size, Color color) {
  //   return AnimatedContainer(
  //     duration: const Duration(milliseconds: 800),
  //     width: size,
  //     height: size,
  //     decoration: BoxDecoration(
  //       shape: BoxShape.circle,
  //       color: color.withOpacity(0.18),
  //       boxShadow: [
  //         BoxShadow(
  //           color: color.withOpacity(0.22),
  //           blurRadius: 30,
  //           spreadRadius: 10,
  //           offset: const Offset(0, 8),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildShopInfo() {
  //   return Container(
  //     constraints: const BoxConstraints(maxWidth: 300),
  //     child: Column(
  //       mainAxisSize: MainAxisSize.min,
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           widget.shop.shopName ?? 'Shop Name N/A',
  //           style: const TextStyle(
  //             fontSize: 20,
  //             fontWeight: FontWeight.w700,
  //             color: Colors.white,
  //             shadows: [
  //               Shadow(
  //                 blurRadius: 8,
  //                 color: Colors.black26,
  //                 offset: Offset(1, 1),
  //               ),
  //             ],
  //           ),
  //           maxLines: 2,
  //           overflow: TextOverflow.ellipsis,
  //         ),
  //         const SizedBox(height: 4),
  //         if (widget.shop.mobileNumber?.isNotEmpty == true)
  //           Row(
  //             children: [
  //               Icon(Icons.phone_rounded, size: 14, color: Colors.white70),
  //               const SizedBox(width: 4),
  //               Text(
  //                 widget.shop.mobileNumber!,
  //                 style: TextStyle(
  //                   fontSize: 12,
  //                   color: Colors.white.withOpacity(0.9),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         if (widget.shop.place?.isNotEmpty == true)
  //           Row(
  //             children: [
  //               Icon(
  //                 Icons.location_on_rounded,
  //                 size: 14,
  //                 color: Colors.white70,
  //               ),
  //               const SizedBox(width: 4),
  //               Expanded(
  //                 child: Text(
  //                   widget.shop.place!,
  //                   style: TextStyle(
  //                     fontSize: 12,
  //                     color: Colors.white.withOpacity(0.9),
  //                   ),
  //                   maxLines: 1,
  //                   overflow: TextOverflow.ellipsis,
  //                 ),
  //               ),
  //             ],
  //           ),
  //       ],
  //     ),
  //   );
  // }
  Widget _buildShopInfo() {
    return Align(
      alignment: Alignment.bottomLeft, // ⬅️ Move everything to bottom-left
      child: Padding(
        padding: const EdgeInsets.only(left: 20, bottom: 24), // spacing
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start, // ⬅️ Align text left
          children: [
            // Shop Name
            Text(
              widget.shop.shopName ?? "Shop Name",
              textAlign: TextAlign.left,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.1,
                shadows: [
                  Shadow(
                    blurRadius: 10,
                    color: Colors.black54,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 10),

            // Phone + Tap to Call
            if (widget.shop.mobileNumber?.isNotEmpty == true)
              InkWell(
                onTap:
                    () => _showCallConfirmation(
                      context,
                      widget.shop.mobileNumber!,
                    ),
                borderRadius: BorderRadius.circular(6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.phone, size: 14, color: Colors.white70),
                    const SizedBox(width: 6),
                    Text(
                      "${widget.shop.mobileNumber!}  •  Tap to Call",
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 5),

            // Location
            if (widget.shop.place?.isNotEmpty == true)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 14,
                    color: Colors.white70,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    widget.shop.place!,
                    style: const TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton(ColorScheme colorScheme) {
    return IconButton(
      icon: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.arrow_back_rounded, size: 20),
      ),
      onPressed: () => Navigator.pop(context),
    );
  }

  Widget _buildEmptyState(bool isSearching) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          isSearching ? Icons.search_off_rounded : Icons.inventory_2_outlined,
          size: 80,
          color: Colors.grey[300],
        ),
        const SizedBox(height: 20),
        Text(
          isSearching
              ? "No results for '${_searchController.text}'"
              : "No products available",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isSearching
              ? "Try searching with different keywords"
              : "Check back later for new arrivals",
          style: TextStyle(fontSize: 14, color: Colors.grey[500]),
        ),
      ],
    );
  }

  // Method now accepts colorScheme, textTheme, and context as parameters
  Widget _buildProductCard(
    dynamic product,
    ColorScheme colorScheme,
    TextTheme textTheme,
    BuildContext context,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      ProductDetailsScreen(productId: product.id ?? ''),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Container(
                  height: 130,
                  width: double.infinity,
                  color: Colors.grey[100],
                  child:
                      product.productImage?.isNotEmpty == true
                          ? ExtendedImage.network(
                            // Use product.productImage instead of widget.shop.headerImage
                            product.productImage!, // Now this is safe
                            fit: BoxFit.cover,
                            cache: true,
                            enableLoadState: false,
                            loadStateChanged: (ExtendedImageState state) {
                              switch (state.extendedImageLoadState) {
                                case LoadState.loading:
                                  return Container(
                                    color: Colors.grey[100],
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                  );
                                case LoadState.completed:
                                  return state.completedWidget;
                                case LoadState.failed:
                                  return _buildPlaceholderImage();
                              }
                            },
                          )
                          : _buildPlaceholderImage(),
                ),
              ),

              // Product Details
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name ?? 'Unknown Product',
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          product.price != null && product.price! > 0
                              ? '₹${product.price!.toStringAsFixed(0)}'
                              : '₹ N/A',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.primary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.shopping_bag_outlined,
                            size: 16,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Center(
      child: Icon(Icons.image_outlined, size: 50, color: Colors.grey[300]),
    );
  }
}

// Custom delegate for sticky search bar
class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _SearchBarDelegate({required this.child});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(
      color: Colors.transparent,
      elevation: shrinkOffset > 0 ? 2 : 0,
      child: child,
    );
  }

  @override
  double get maxExtent => 72;

  @override
  double get minExtent => 72;

  @override
  bool shouldRebuild(covariant _SearchBarDelegate oldDelegate) {
    return child != oldDelegate.child;
  }
}
