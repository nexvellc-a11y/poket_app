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
  final ScrollController _scrollController = ScrollController();

  // Fixed aspect ratio for shop header images
  static const double _fixedAspectRatioWidth = 3.103;
  static const double _fixedAspectRatioHeight = 1.353;
  double get _fixedAspectRatio =>
      _fixedAspectRatioWidth / _fixedAspectRatioHeight;
  bool get _isSmallMobile => MediaQuery.of(context).size.width < 375;
  // Responsive breakpoints
  static const double _mobileBreakpoint = 600;
  static const double _tabletBreakpoint = 900;
  static const double _desktopBreakpoint = 1200;

  bool get _isMobile => MediaQuery.of(context).size.width < _mobileBreakpoint;
  bool get _isTablet =>
      MediaQuery.of(context).size.width >= _mobileBreakpoint &&
      MediaQuery.of(context).size.width < _tabletBreakpoint;
  bool get _isDesktop =>
      MediaQuery.of(context).size.width >= _desktopBreakpoint;

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
    _scrollController.dispose();
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Phone icon with background
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.phone_in_talk,
                  size: 40,
                  color: Colors.green,
                ),
              ),

              const SizedBox(height: 20),

              // Title
              Text(
                "Call Shop?",
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),

              const SizedBox(height: 8),

              // Description
              Text(
                "Do you want to call this shop now?",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 20),

              // Phone number display
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.phone_rounded,
                      size: 20,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      phone,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // Action buttons
              Row(
                children: [
                  // Cancel button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      child: Text(
                        "Cancel",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Call button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _makePhoneCall(phone);
                      },
                      icon: const Icon(Icons.call, size: 20),
                      label: Text(
                        "Call",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
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
    final screenWidth = MediaQuery.of(context).size.width;
    final shop = widget.shop;

    return SafeArea(
      child: Scaffold(
        body: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // SliverAppBar with responsive expanded height based on aspect ratio
            SliverAppBar(
              expandedHeight: _getAppBarHeight(),
              floating: true,
              pinned: true,
              snap: false,
              elevation: 0,
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.white,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                background: _buildAppBarBackground(shop, colorScheme),
                titlePadding: const EdgeInsets.only(left: 12.0, bottom: 6.0),
                title: _buildShopInfo(),
              ),
              leading: _buildBackButton(colorScheme),
            ),

            // Aspect ratio indicator for mobile
            // if (_isMobile)
            //   SliverToBoxAdapter(
            //     child: Padding(
            //       padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
            //       child: Center(
            //         child: Container(
            //           padding: const EdgeInsets.symmetric(
            //             horizontal: 12,
            //             vertical: 4,
            //           ),
            //           decoration: BoxDecoration(
            //             color: Colors.blue[50],
            //             borderRadius: BorderRadius.circular(20),
            //           ),
            //           child: Text(
            //             'Header ratio: ${_fixedAspectRatioWidth.toStringAsFixed(3)} : ${_fixedAspectRatioHeight.toStringAsFixed(3)}',
            //             style: TextStyle(
            //               fontSize: 12,
            //               color: Colors.blue[700],
            //               fontWeight: FontWeight.w500,
            //             ),
            //           ),
            //         ),
            //       ),
            //     ),
            //   ),

            // Search Bar
            SliverPersistentHeader(
              pinned: true,
              delegate: _SearchBarDelegate(
                maxHeight: _getSearchBarHeight(),
                minHeight: _getSearchBarHeight(),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    _isMobile ? 16 : 24,
                    16,
                    _isMobile ? 16 : 24,
                    8,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(_getBorderRadius()),
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
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: _isMobile ? 20 : 24,
                          vertical: _isMobile ? 16 : 20,
                        ),
                        suffixIcon:
                            _searchController.text.isNotEmpty
                                ? IconButton(
                                  icon: Icon(
                                    Icons.clear_rounded,
                                    color: Colors.grey[500],
                                    size: _isMobile ? 20 : 24,
                                  ),
                                  onPressed: () => _searchController.clear(),
                                )
                                : null,
                      ),
                      style: textTheme.bodyLarge?.copyWith(
                        fontSize: _isMobile ? 16 : 18,
                      ),
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Loading products...",
                            style: textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
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
                  padding: EdgeInsets.symmetric(
                    horizontal: _isMobile ? 16 : 24,
                    vertical: 8,
                  ),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _getCrossAxisCount(),
                      crossAxisSpacing: _isMobile ? 16 : 20,
                      mainAxisSpacing: _isMobile ? 16 : 20,
                      childAspectRatio: _getChildAspectRatio(),
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
      ),
    );
  }

  // Responsive app bar height with fixed aspect ratio for mobile
  double _getAppBarHeight() {
    final screenWidth = MediaQuery.of(context).size.width;

    // Use aspect ratio for mobile & tablet
    if (_isMobile || _isTablet) {
      return screenWidth / _fixedAspectRatio;
    }

    // Desktop can be taller
    return screenWidth / _fixedAspectRatio * 0.9;
  }

  // Responsive search bar height
  double _getSearchBarHeight() {
    if (_isMobile) return 80.0;
    return 88.0;
  }

  // Responsive border radius
  double _getBorderRadius() {
    if (_isMobile) return 16.0;
    if (_isTablet) return 18.0;
    return 20.0;
  }

  // Responsive grid columns
  int _getCrossAxisCount() {
    if (_isMobile) return 2;
    if (_isTablet) return 3;
    return 4;
  }

  // Responsive card aspect ratio
  double _getChildAspectRatio() {
    if (_isMobile) return 0.87;
    if (_isTablet) return 0.75;
    return 0.8;
  }

  double get _headerIconSize {
    if (_isSmallMobile) return 50.0;
    if (_isMobile) return 60.0;
    if (_isTablet) return 70.0;
    return 80.0;
  }

  double get _headerHeight {
    if (_isMobile || _isSmallMobile) {
      // For mobile, height is calculated from width using aspect ratio
      return _headerWidth / (_fixedAspectRatio * 1.6);
    } else {
      // For tablets and larger, use fixed height
      return 200.0;
    }
  }

  double get _headerWidth => MediaQuery.of(context).size.width;

  Widget _buildAppBarBackground(ShopModel shop, ColorScheme colorScheme) {
    return Container(
      width: _headerWidth,
      height: _headerHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colorScheme.primary.withOpacity(0.9),
            colorScheme.primary.withOpacity(0.7),
          ],
        ),
      ),
      child:
          shop.headerImage?.isNotEmpty == true
              ? Stack(
                children: [
                  // Background image - using BoxFit.cover to maintain aspect ratio
                  Positioned.fill(
                    child: Image.network(
                      shop.headerImage!,
                      fit:
                          BoxFit
                              .contain, // Changed from BoxFit.fill to BoxFit.cover
                      errorBuilder:
                          (_, __, ___) => Container(
                            color: colorScheme.primary,
                            child: Center(
                              child: Icon(
                                Icons.store,
                                size: _headerIconSize,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ),
                    ),
                  ),
                  // Gradient overlay for better text visibility
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.3),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
              : Container(
                color: colorScheme.primary,
                child: Center(
                  child: Icon(
                    Icons.store,
                    size: _headerIconSize,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
    );
  }

  // Widget _buildAppBarBackground(ColorScheme colorScheme) {
  //   return Container(
  //     color: colorScheme.primary,
  //     child: Center(
  //       child: AspectRatio(
  //         aspectRatio: _fixedAspectRatio,
  //         child: Image.network(
  //           widget.shop.headerImage?.isNotEmpty == true
  //               ? widget.shop.headerImage!
  //               : 'https://via.placeholder.com/400x200?text=No+Image',
  //           fit: BoxFit.contain, // ✅ SHOW FULL IMAGE
  //           alignment: Alignment.center,
  //           errorBuilder:
  //               (_, __, ___) => Container(
  //                 color: Colors.grey.shade300,
  //                 child: Icon(
  //                   Icons.store_mall_directory_rounded,
  //                   size: _isMobile ? 60 : 80,
  //                   color: Colors.grey.shade400,
  //                 ),
  //               ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildShopInfo() {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: EdgeInsets.only(
          left: _isMobile ? 16 : 24,
          bottom: _isMobile ? 14 : 18,
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shop Name
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              child: Text(
                widget.shop.shopName ?? "Shop Name",
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: _isMobile ? 18 : 20,
                  height: 1.0,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  shadows: const [
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
            ),

            const SizedBox(height: 12),

            // Contact and Location Info
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Phone Number
                if (widget.shop.mobileNumber?.isNotEmpty == true)
                  InkWell(
                    onTap:
                        () => _showCallConfirmation(
                          context,
                          widget.shop.mobileNumber!,
                        ),
                    borderRadius: BorderRadius.circular(8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.phone_rounded,
                          size: _isMobile ? 14 : 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "${widget.shop.mobileNumber!}  •  Tap to Call",
                          style: TextStyle(
                            fontSize: _isMobile ? 12 : 13,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),

                if (widget.shop.mobileNumber?.isNotEmpty == true &&
                    widget.shop.place?.isNotEmpty == true)
                  const SizedBox(height: 2),

                // Location
                if (widget.shop.place?.isNotEmpty == true)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: _isMobile ? 16 : 18,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.6,
                        ),
                        child: Text(
                          widget.shop.place!,
                          style: TextStyle(
                            fontSize: _isMobile ? 13 : 15,
                            color: Colors.white.withOpacity(0.9),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
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
        padding: EdgeInsets.all(_isMobile ? 6 : 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.arrow_back_rounded, size: _isMobile ? 20 : 24),
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
          size: _isMobile ? 80 : 100,
          color: Colors.grey[300],
        ),
        const SizedBox(height: 20),
        Text(
          isSearching
              ? "No results for '${_searchController.text}'"
              : "No products available",
          style: TextStyle(
            fontSize: _isMobile ? 16 : 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: _isMobile ? 32 : 48),
          child: Text(
            isSearching
                ? "Try searching with different keywords"
                : "Check back later for new arrivals",
            style: TextStyle(
              fontSize: _isMobile ? 14 : 16,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ),
        if (!isSearching) ...[
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed:
                () => _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                ),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text("Refresh"),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProductCard(
    dynamic product,
    ColorScheme colorScheme,
    TextTheme textTheme,
    BuildContext context,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_getBorderRadius()),
      ),
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
        borderRadius: BorderRadius.circular(_getBorderRadius()),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_getBorderRadius()),
            border: Border.all(
              color: Colors.grey[200]!,
              width: _isMobile ? 0.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(_getBorderRadius()),
                ),
                child: Container(
                  height: _getProductImageHeight(),
                  width: double.infinity,
                  color: Colors.grey[50],
                  child:
                      product.productImage?.isNotEmpty == true
                          ? ExtendedImage.network(
                            product.productImage!,
                            fit: BoxFit.cover,
                            cache: true,
                            enableLoadState: false,
                            loadStateChanged: (ExtendedImageState state) {
                              switch (state.extendedImageLoadState) {
                                case LoadState.loading:
                                  return Container(
                                    color: Colors.grey[50],
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

              // Product Details - REDUCED HEIGHT AND SPACING
              Padding(
                padding: EdgeInsets.all(_isMobile ? 8 : 12), // Reduced padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // Minimize height
                  children: [
                    // Product Name
                    Text(
                      product.name ?? 'Unknown Product',
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: _isMobile ? 13 : 15, // Slightly smaller font
                        height: 1.2, // Tighter line height
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Reduced spacing between name and price
                    const SizedBox(height: 4), // Reduced from 8 to 4
                    // Price and Action
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Price
                        Expanded(
                          child: Text(
                            product.price != null && product.price! > 0
                                ? '₹${product.price!.toStringAsFixed(0)}'
                                : '₹ N/A',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: _isMobile ? 14 : 16, // Slightly smaller
                              color: colorScheme.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        // View Icon - More compact
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: _isMobile ? 6 : 8, // Reduced horizontal
                            vertical: _isMobile ? 2 : 4, // Reduced vertical
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                              6,
                            ), // Slightly smaller radius
                          ),
                          child: Icon(
                            Icons.visibility_outlined,
                            size: _isMobile ? 14 : 16, // Smaller icon
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

  // Also update the product image height to be slightly smaller
  double _getProductImageHeight() {
    if (_isMobile) return 110; // Reduced from 130
    if (_isTablet) return 130; // Reduced from 150
    return 160; // Reduced from 180
  }

  Widget _buildPlaceholderImage() {
    return Center(
      child: Icon(
        Icons.image_outlined,
        size: _isMobile ? 50 : 60,
        color: Colors.grey[300],
      ),
    );
  }
}

// Enhanced custom delegate for sticky search bar
class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double maxHeight;
  final double minHeight;

  _SearchBarDelegate({
    required this.child,
    required this.maxHeight,
    required this.minHeight,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(
      color: Colors.transparent,
      elevation: shrinkOffset > 0 ? 2 : 0,
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: child,
      ),
    );
  }

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(covariant _SearchBarDelegate oldDelegate) {
    return child != oldDelegate.child ||
        maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight;
  }
}
