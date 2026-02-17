import 'package:flutter/material.dart';
import 'package:poketstore/controllers/shop_of_user_controller/shop_of_user_controller.dart';
import 'package:poketstore/model/add_shope_model/add_shop_model.dart';
import 'package:poketstore/model/shop_of_user_model/shop_of_user_model.dart';
import 'package:poketstore/utilities/custom_app_bar.dart';
import 'package:poketstore/view/add_shop/add_shop.dart';
import 'package:poketstore/view/add_shop/shop_under_product_screen.dart';
import 'package:poketstore/utilities/no_data_warning.dart';
import 'package:provider/provider.dart';

// Assuming ShopOfUser is a different model. If it has the same fields, we can map it.

class ShopListScreen extends StatefulWidget {
  const ShopListScreen({super.key});

  @override
  State<ShopListScreen> createState() => _ShopListScreenState();
}

class _ShopListScreenState extends State<ShopListScreen> {
  final ScrollController _scrollController = ScrollController();

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

  // Responsive sizing - INCREASED HEIGHT VALUES
  double get _cardHeight {
    if (_isSmallMobile) return 100.0; // Increased from 70 to 100
    if (_isMobile) return 120.0; // Increased from 80 to 120
    if (_isTablet) return 150.0; // Increased from 100 to 150
    return 180.0; // Increased from 120 to 180
  }

  double get _cardPadding {
    if (_isSmallMobile) return 8.0;
    if (_isMobile) return 12.0;
    if (_isTablet) return 16.0;
    return 20.0;
  }

  double get _iconSize {
    if (_isSmallMobile) return 32.0; // Increased from 24 to 32
    if (_isMobile) return 40.0; // Increased from 28 to 40
    if (_isTablet) return 50.0; // Increased from 36 to 50
    return 60.0; // Increased from 44 to 60
  }

  double get _titleFontSize {
    if (_isSmallMobile) return 16.0; // Increased from 14 to 16
    if (_isMobile) return 18.0; // Increased from 16 to 18
    if (_isTablet) return 20.0; // Increased from 18 to 20
    return 22.0; // Increased from 20 to 22
  }

  double get _subtitleFontSize {
    if (_isSmallMobile) return 12.0; // Increased from 11 to 12
    if (_isMobile) return 14.0; // Increased from 12 to 14
    if (_isTablet) return 16.0; // Increased from 14 to 16
    return 18.0; // Increased from 16 to 18
  }

  double get _buttonHeight {
    if (_isSmallMobile) return 55.0; // Increased from 45 to 55
    if (_isMobile) return 60.0; // Increased from 50 to 60
    if (_isTablet) return 70.0; // Increased from 55 to 70
    return 75.0; // Increased from 60 to 75
  }

  double get _buttonFontSize {
    if (_isSmallMobile) return 16.0; // Increased from 14 to 16
    if (_isMobile) return 18.0; // Increased from 16 to 18
    if (_isTablet) return 20.0; // Increased from 18 to 20
    return 22.0; // Increased from 20 to 22
  }

  double get _imageIconSize {
    if (_isSmallMobile) return 50.0; // New: specific size for empty state icon
    if (_isMobile) return 70.0;
    if (_isTablet) return 100.0;
    return 120.0;
  }

  double get _headerImageSize {
    if (_isSmallMobile) return 60.0;
    if (_isMobile) return 80.0;
    if (_isTablet) return 100.0;
    return 120.0;
  }

  EdgeInsets get _screenPadding {
    if (_isSmallMobile)
      return const EdgeInsets.symmetric(horizontal: 12.0); // Increased from 8
    if (_isMobile)
      return const EdgeInsets.symmetric(horizontal: 16.0); // Increased from 12
    if (_isTablet) return const EdgeInsets.symmetric(horizontal: 24.0);
    return const EdgeInsets.symmetric(horizontal: 32.0);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ShopOfUserProvider>(context, listen: false).fetchUserShops();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0703C9), Colors.white],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            "My Shops",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
          leading: Container(),
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Header stats
              if (!_isSmallMobile)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: _screenPadding.horizontal,
                    vertical:
                        _isMobile ? 12.0 : 16.0, // Increased vertical padding
                  ),
                  child: Consumer<ShopOfUserProvider>(
                    builder: (context, shopProvider, _) {
                      return Row(
                        children: [
                          _buildStatCard(
                            icon: Icons.storefront_outlined,
                            value: shopProvider.shopList.length.toString(),
                            label: "Shops",
                            color: Colors.blue,
                          ),
                          SizedBox(
                            width: _isMobile ? 12.0 : 16.0,
                          ), // Increased spacing
                          _buildStatCard(
                            icon: Icons.location_on_outlined,
                            value:
                                shopProvider.shopList
                                    .where((shop) => shop.place.isNotEmpty)
                                    .length
                                    .toString(),
                            label: "Locations",
                            color: Colors.green,
                          ),
                        ],
                      );
                    },
                  ),
                ),

              // Grid content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: _screenPadding.horizontal,
                  ),
                  child: Consumer<ShopOfUserProvider>(
                    builder: (context, shopProvider, _) {
                      if (shopProvider.isLoading) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                strokeWidth: 3.0, // Increased stroke width
                                color: colorScheme.primary,
                              ),
                              SizedBox(height: _cardPadding * 1.5),
                              Text(
                                "Loading shops...",
                                style: TextStyle(
                                  fontSize: _subtitleFontSize,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      if (shopProvider.shopList.isEmpty) {
                        return RefreshIndicator(
                          onRefresh: () => shopProvider.fetchUserShops(),
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height *
                                    0.15, // Increased from 0.1
                              ),
                              Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.store_mall_directory_outlined,
                                      size: _imageIconSize,
                                      color: Colors.blue.withOpacity(0.5),
                                    ),
                                    SizedBox(height: _cardPadding * 2),
                                    Text(
                                      "No shops available yet!",
                                      style: TextStyle(
                                        fontSize: _titleFontSize * 1.2,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: _cardPadding),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: _screenPadding.horizontal,
                                      ),
                                      child: Text(
                                        "Tap the button below to add your first shop",
                                        style: TextStyle(
                                          fontSize: _subtitleFontSize,
                                          color: Colors.grey[600],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    SizedBox(height: _cardPadding * 2),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: () => shopProvider.fetchUserShops(),
                        child: _buildShopList(shopProvider),
                      );
                    },
                  ),
                ),
              ),

              // Add Shop Button
              Padding(
                padding: EdgeInsets.all(
                  _cardPadding * 1.5,
                ), // Increased padding
                child: _buildAddShopButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(_isMobile ? 12.0 : 16.0), // Increased padding
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(_cardPadding),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(
                _isMobile ? 8.0 : 10.0,
              ), // Increased padding
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: _iconSize * 0.8,
                color: color,
              ), // Increased icon size
            ),
            SizedBox(width: _isMobile ? 10.0 : 12.0), // Increased spacing
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: _titleFontSize,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 2), // Added small spacing
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: _subtitleFontSize * 0.9,
                      color: Colors.grey[600],
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

  Widget _buildShopList(ShopOfUserProvider shopProvider) {
    return ListView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      itemCount: shopProvider.shopList.length,
      itemBuilder: (context, index) {
        final shop = shopProvider.shopList[index];
        return Padding(
          padding: EdgeInsets.only(
            bottom: _cardPadding * 1.2,
          ), // Increased bottom padding
          child: _buildShopCard(shop),
        );
      },
    );
  }

  Widget _buildShopCard(dynamic shop) {
    // Extract values safely - adjust field names based on your ShopOfUser model
    String shopName = '';
    String? headerImage;
    String? place;
    String? id;

    // Check if it's ShopOfUser model and extract fields
    if (shop is ShopOfUser) {
      shopName = shop.shopName ?? '';
      headerImage = shop.headerImage;
      place = shop.place;
      id = shop.id;
    } else if (shop is ShopModel) {
      shopName = shop.shopName ?? '';
      headerImage = shop.headerImage;
      place = shop.place;
      id = shop.id;
    }

    return InkWell(
      onTap: () async {
        if (id != null && id.isNotEmpty) {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => ShopDetailsWithProductsScreen(
                    shop: ShopModel(
                      id: id,
                      shopName: shopName,
                      headerImage: headerImage,
                      place: place,
                    ),
                  ),
            ),
          );
          if (result == true) {
            Provider.of<ShopOfUserProvider>(
              context,
              listen: false,
            ).fetchUserShops();
          }
        }
      },
      borderRadius: BorderRadius.circular(_cardPadding),
      child: Container(
        height: _cardHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_cardPadding),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Shop Image/Icon - with increased size
            Padding(
              padding: EdgeInsets.all(_cardPadding * 1.2), // Increased padding
              child: Container(
                width: _iconSize,
                height: _iconSize,
                decoration: BoxDecoration(
                  color: const Color(0xFF6750A4).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(_cardPadding),
                ),
                child:
                    headerImage != null && headerImage.isNotEmpty
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(
                            _cardPadding * 0.7,
                          ),
                          child: Image.network(
                            headerImage,
                            width: _iconSize,
                            height: _iconSize,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.storefront_outlined,
                                size: _iconSize * 0.7,
                                color: const Color(0xFF6750A4),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: const AlwaysStoppedAnimation(
                                    Color(0xFF6750A4),
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                        : Center(
                          child: Icon(
                            Icons.storefront_outlined,
                            size: _iconSize * 0.7,
                            color: const Color(0xFF6750A4),
                          ),
                        ),
              ),
            ),

            // Shop Details - with better spacing
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: _cardPadding,
                  horizontal: _cardPadding * 0.5,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      shopName.isNotEmpty ? shopName : 'Unnamed Shop',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: _titleFontSize,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: _cardPadding * 0.3), // Added spacing
                    // Location
                    if (place != null && place.isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: _iconSize * 0.5,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: _cardPadding * 0.25),
                          Expanded(
                            child: Text(
                              place,
                              style: TextStyle(
                                fontSize: _subtitleFontSize * 0.9,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                    if (!place.isNullOrEmpty)
                      SizedBox(
                        height: _cardPadding * 0.3,
                      ), // Conditional spacing
                    // Hint text
                    if (!_isSmallMobile)
                      Text(
                        "Tap to view products",
                        style: TextStyle(
                          fontSize: _subtitleFontSize * 0.8,
                          color: Colors.grey[500],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Arrow Indicator
            Padding(
              padding: EdgeInsets.only(right: _cardPadding * 1.2),
              child: Icon(
                Icons.chevron_right_rounded,
                size: _iconSize * 0.9,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddShopButton() {
    return GestureDetector(
      onTap: () async {
        final bool? didAddShop = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddShop()),
        );
        if (didAddShop == true) {
          Provider.of<ShopOfUserProvider>(
            context,
            listen: false,
          ).fetchUserShops();
        }
      },
      child: Container(
        height: _buttonHeight,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0703C9), Color(0xFF5452CC)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(_cardPadding * 1.2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0703C9).withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: Colors.white, size: _iconSize * 0.8),
            SizedBox(width: _cardPadding * 0.8),
            Text(
              'Add Shop',
              style: TextStyle(
                color: Colors.white,
                fontSize: _buttonFontSize,
                fontWeight: FontWeight.w600,
                letterSpacing:
                    0.5, // Added letter spacing for better readability
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Extension for null safety check
extension StringExtension on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
}
