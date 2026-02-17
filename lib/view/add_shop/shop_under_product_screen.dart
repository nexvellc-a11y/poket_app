import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:poketstore/controllers/shop_nearby_controller/shop_product_nearby_controller.dart';
import 'package:poketstore/model/add_shope_model/add_shop_model.dart';
import 'package:poketstore/view/add_shop/shope_details_screen.dart';
import 'package:poketstore/view/my_products/add_product_screen.dart';
import 'package:poketstore/view/my_products/product_details_screen.dart';
import 'package:poketstore/view/subscription/subscription.dart';
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
  final ScrollController _scrollController = ScrollController();

  // Fixed aspect ratio for shop header images
  static const double _fixedAspectRatioWidth = 3.103;
  static const double _fixedAspectRatioHeight = 1.353;
  double get _fixedAspectRatio =>
      _fixedAspectRatioWidth / _fixedAspectRatioHeight;

  // Responsive breakpoints
  static const double _mobileBreakpoint = 600;
  static const double _tabletBreakpoint = 900;
  static const double _desktopBreakpoint = 1200;

  bool get _isSmallMobile => MediaQuery.of(context).size.width < 375;
  bool get _isMobile => MediaQuery.of(context).size.width < _mobileBreakpoint;
  bool get _isTablet =>
      MediaQuery.of(context).size.width >= _mobileBreakpoint &&
      MediaQuery.of(context).size.width < _tabletBreakpoint;
  bool get _isLargeTablet =>
      MediaQuery.of(context).size.width >= _tabletBreakpoint &&
      MediaQuery.of(context).size.width < _desktopBreakpoint;
  bool get _isDesktop =>
      MediaQuery.of(context).size.width >= _desktopBreakpoint;

  // Get screen dimensions for header
  double get _headerWidth => MediaQuery.of(context).size.width;

  // Calculate header height based on aspect ratio for mobile, fixed for tablets
  double get _headerHeight {
    if (_isMobile || _isSmallMobile) {
      // For mobile, height is calculated from width using aspect ratio
      return _headerWidth / _fixedAspectRatio;
    } else {
      // For tablets and larger, use fixed height
      return 260.0;
    }
  }

  double get _headerAspectRatio => _headerWidth / _headerHeight;

  // Responsive sizing
  double get _appBarHeight => _headerHeight + 56.0; // Add AppBar height

  double get _headerIconSize {
    if (_isSmallMobile) return 50.0;
    if (_isMobile) return 60.0;
    if (_isTablet) return 70.0;
    return 80.0;
  }

  double get _titleFontSize {
    if (_isSmallMobile) return 20.0;
    if (_isMobile) return 22.0;
    if (_isTablet) return 24.0;
    return 26.0;
  }

  double get _bodyFontSize {
    if (_isSmallMobile) return 12.0;
    if (_isMobile) return 14.0;
    if (_isTablet) return 15.0;
    return 16.0;
  }

  double get _subtitleFontSize {
    if (_isSmallMobile) return 11.0;
    if (_isMobile) return 12.0;
    if (_isTablet) return 13.0;
    return 14.0;
  }

  double get _fabSize {
    if (_isSmallMobile) return 56.0;
    if (_isMobile) return 60.0;
    if (_isTablet) return 64.0;
    return 68.0;
  }

  double get _fabIconSize {
    if (_isSmallMobile) return 24.0;
    if (_isMobile) return 26.0;
    if (_isTablet) return 28.0;
    return 30.0;
  }

  EdgeInsets get _screenPadding {
    if (_isSmallMobile) return const EdgeInsets.symmetric(horizontal: 12.0);
    if (_isMobile) return const EdgeInsets.symmetric(horizontal: 16.0);
    if (_isTablet) return const EdgeInsets.symmetric(horizontal: 24.0);
    return const EdgeInsets.symmetric(horizontal: 32.0);
  }

  double get _cardBorderRadius {
    if (_isSmallMobile) return 10.0;
    if (_isMobile) return 12.0;
    if (_isTablet) return 16.0;
    return 20.0;
  }

  int get _gridCrossAxisCount {
    if (_isSmallMobile) return 2;
    if (_isMobile) return 2;
    if (_isTablet) return 3;
    return 4;
  }

  double get _gridChildAspectRatio {
    if (_isSmallMobile) return 0.75;
    if (_isMobile) return 0.7;
    if (_isTablet) return 0.89;
    return 0.75;
  }

  double get _productImageHeight {
    if (_isSmallMobile) return 100.0;
    if (_isMobile) return 120.0;
    if (_isTablet) return 140.0;
    return 160.0;
  }

  double get _productCardPadding {
    if (_isSmallMobile) return 8.0;
    if (_isMobile) return 10.0;
    if (_isTablet) return 12.0;
    return 14.0;
  }

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
    _scrollController.dispose();
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(_cardBorderRadius),
        ),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: EdgeInsets.all(_isMobile ? 16.0 : 20.0),
                child: Text(
                  'Shop Options',
                  style: TextStyle(
                    fontSize: _isMobile ? 18.0 : 20.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // Divider
              const Divider(height: 1),

              // Options
              ListTile(
                leading: Icon(
                  Icons.edit,
                  size: _isMobile ? 24.0 : 28.0,
                  color: Colors.blue,
                ),
                title: Text(
                  'Edit Shop',
                  style: TextStyle(fontSize: _isMobile ? 16.0 : 18.0),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToEditShop();
                },
              ),

              ListTile(
                leading: Icon(
                  Icons.credit_card,
                  size: _isMobile ? 24.0 : 28.0,
                  color: Colors.green,
                ),
                title: Text(
                  'Renew Plan',
                  style: TextStyle(fontSize: _isMobile ? 16.0 : 18.0),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToSubscriptionPlans();
                },
              ),

              // Divider
              const Divider(height: 1),

              // Cancel
              ListTile(
                leading: Icon(
                  Icons.close,
                  size: _isMobile ? 24.0 : 28.0,
                  color: Colors.grey,
                ),
                title: Text(
                  'Cancel',
                  style: TextStyle(fontSize: _isMobile ? 16.0 : 18.0),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),

              // Extra bottom padding for safe area
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final shop = widget.shop;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App Bar with Shop Header - with fixed aspect ratio on mobile
          SliverAppBar(
            expandedHeight: _appBarHeight,
            pinned: true,
            backgroundColor: colorScheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: _buildAppBarBackground(shop, colorScheme),
              titlePadding: EdgeInsets.only(
                left: _screenPadding.left,
                bottom: _isMobile ? 12.0 : 16.0,
              ),
              title: _buildShopTitle(shop),
            ),
            leading: _buildBackButton(colorScheme),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.more_vert,
                  size: _isMobile ? 24.0 : 28.0,
                  color: Colors.white,
                ),
                onPressed: () => _showMenu(context),
                tooltip: 'Shop Options',
              ),
            ],
          ),

          // Aspect ratio indicator for mobile
          // if (_isMobile || _isSmallMobile)
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

          // Shop Details Section
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(_screenPadding.horizontal),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  Container(
                    margin: EdgeInsets.only(bottom: _isMobile ? 16.0 : 20.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search products...',
                        hintStyle: TextStyle(
                          fontSize: _bodyFontSize,
                          color: Colors.grey[500],
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          size: _isMobile ? 20.0 : 24.0,
                          color: colorScheme.primary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            _cardBorderRadius,
                          ),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: _isMobile ? 16.0 : 20.0,
                          vertical: _isMobile ? 14.0 : 18.0,
                        ),
                        suffixIcon:
                            _searchController.text.isNotEmpty
                                ? IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    size: _isMobile ? 20.0 : 24.0,
                                    color: Colors.grey[500],
                                  ),
                                  onPressed: () => _searchController.clear(),
                                )
                                : null,
                      ),
                      style: TextStyle(fontSize: _bodyFontSize),
                    ),
                  ),

                  // Products Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Available Products',
                        style: TextStyle(
                          fontSize: _isMobile ? 18.0 : 20.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Consumer<ShopProductNearbyProductController>(
                        builder: (context, controller, _) {
                          final count =
                              _searchController.text.isNotEmpty
                                  ? controller.filteredProducts.length
                                  : controller.productData?.products?.length ??
                                      0;
                          return Text(
                            '($count items)',
                            style: TextStyle(
                              fontSize: _subtitleFontSize,
                              color: Colors.grey[600],
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  SizedBox(height: _isMobile ? 8.0 : 12.0),
                ],
              ),
            ),
          ),

          // Products Grid
          Consumer<ShopProductNearbyProductController>(
            builder: (context, controller, _) {
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
                        SizedBox(height: _isMobile ? 16.0 : 20.0),
                        Text(
                          'Loading products...',
                          style: TextStyle(
                            fontSize: _bodyFontSize,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isSearching
                              ? Icons.search_off_rounded
                              : Icons.inventory_2_outlined,
                          size: _headerIconSize * 1.5,
                          color: Colors.grey[300],
                        ),
                        SizedBox(height: _isMobile ? 16.0 : 20.0),
                        Text(
                          isSearching
                              ? "No products found for '${_searchController.text}'"
                              : "No products available in this shop.",
                          style: TextStyle(
                            fontSize: _bodyFontSize,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: _isMobile ? 8.0 : 12.0),
                        if (!isSearching)
                          Text(
                            'Tap the + button to add your first product',
                            style: TextStyle(
                              fontSize: _subtitleFontSize,
                              color: Colors.grey[500],
                            ),
                            textAlign: TextAlign.center,
                          ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: EdgeInsets.only(
                  left: _screenPadding.left,
                  right: _screenPadding.right,
                  bottom: _isMobile ? 16.0 : 24.0,
                ),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _gridCrossAxisCount,
                    crossAxisSpacing: _isMobile ? 12.0 : 16.0,
                    mainAxisSpacing: _isMobile ? 12.0 : 16.0,
                    childAspectRatio: _gridChildAspectRatio,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final product = productsToDisplay[index];
                    return _buildProductCard(product, colorScheme);
                  }, childCount: productsToDisplay.length),
                ),
              );
            },
          ),
        ],
      ),

      // Floating Action Button
      floatingActionButton: SizedBox(
        width: _fabSize,
        height: _fabSize,
        child: FloatingActionButton(
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
                    context,
                    listen: false,
                  ).loadProducts(shopId);
                }
              }
            });
          },
          backgroundColor: const Color.fromARGB(255, 7, 3, 201),
          child: Icon(Icons.add, size: _fabIconSize, color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_fabSize / 2),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

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
                              .cover, // Changed from BoxFit.fill to BoxFit.cover
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

  Widget _buildShopTitle(ShopModel shop) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.7,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            shop.shopName ?? "Shop Name",
            style: TextStyle(
              fontSize: _titleFontSize,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(1, 1),
                ),
              ],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (shop.place?.isNotEmpty == true)
            Padding(
              padding: EdgeInsets.only(top: _isMobile ? 4.0 : 6.0),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    size: _isMobile ? 14.0 : 16.0,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  SizedBox(width: _isMobile ? 4.0 : 6.0),
                  Expanded(
                    child: Text(
                      shop.place!,
                      style: TextStyle(
                        fontSize: _subtitleFontSize,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBackButton(ColorScheme colorScheme) {
    return IconButton(
      icon: Container(
        padding: EdgeInsets.all(_isMobile ? 6.0 : 8.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(_isMobile ? 10.0 : 12.0),
        ),
        child: Icon(
          Icons.arrow_back_rounded,
          size: _isMobile ? 20.0 : 24.0,
          color: Colors.white,
        ),
      ),
      onPressed: () => Navigator.pop(context),
    );
  }

  Widget _buildProductCard(dynamic product, ColorScheme colorScheme) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MyShopProductDetails(productId: product.id ?? ''),
          ),
        );
      },
      borderRadius: BorderRadius.circular(_cardBorderRadius),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_cardBorderRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(_cardBorderRadius),
              ),
              child: Container(
                height: _productImageHeight,
                width: double.infinity,
                color: Colors.grey[100],
                child:
                    product.productImage?.isNotEmpty == true
                        ? Image.network(
                          product.productImage!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                Icons.broken_image,
                                size: _isMobile ? 32.0 : 40.0,
                                color: Colors.grey[400],
                              ),
                            );
                          },
                        )
                        : Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: _isMobile ? 32.0 : 40.0,
                            color: Colors.grey[400],
                          ),
                        ),
              ),
            ),

            // Product Details
            Padding(
              padding: EdgeInsets.all(_productCardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Product Name
                  Text(
                    product.name ?? 'Product',
                    style: TextStyle(
                      fontSize: _bodyFontSize,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Price and arrow
                  Padding(
                    padding: EdgeInsets.only(top: _isMobile ? 6.0 : 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "₹${product.price?.toStringAsFixed(2) ?? 'N/A'}",
                            style: TextStyle(
                              fontSize: _bodyFontSize,
                              fontWeight: FontWeight.w700,
                              color: Colors.green[700],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(_isMobile ? 4.0 : 6.0),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: _isMobile ? 10.0 : 12.0,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
