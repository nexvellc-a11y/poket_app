import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:poketstore/controllers/fcm_controller/fcm_controller.dart';
import 'package:poketstore/controllers/home_product_controller/home_product_controller.dart';
import 'package:poketstore/controllers/location_controller/location_controller.dart';
import 'package:poketstore/controllers/shop_nearby_controller/shop_nearby_controller.dart';
import 'package:poketstore/model/add_shope_model/add_shop_model.dart';
import 'package:poketstore/model/shop_nearby_model/shop_nearby_model.dart';
import 'package:poketstore/utilities/custom_app_bar.dart';
import 'package:poketstore/utilities/home_search_bar.dart';
import 'package:poketstore/utilities/search_bar.dart';
import 'package:poketstore/utilities/search_page.dart';
import 'package:poketstore/view/home/view/home_screen/shop_product_screen/shop_product_screen.dart';
import 'package:poketstore/view/home/widgets/advertisment_slider.dart';
import 'package:poketstore/utilities/no_data_warning.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoadingInitialData = true;
  String? _initialErrorMessage;
  String? _userId;
  bool _showAllStores = false;
  bool _isDataLoaded = false;
  String? _currentAddress;
  Position? _currentPosition;

  late LocationMapController _locationMapController;
  late HomeProductController _homeProductController;

  // Responsive breakpoints
  static const double _mobileBreakpoint = 600;
  static const double _tabletBreakpoint = 900;
  static const double _desktopBreakpoint = 1200;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FCMProvider>(
        context,
        listen: false,
      ).registerFcmToken(context);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isDataLoaded) {
      _locationMapController = Provider.of<LocationMapController>(
        context,
        listen: false,
      );
      _homeProductController = Provider.of<HomeProductController>(
        context,
        listen: false,
      );
      _loadInitialData();
      _isDataLoaded = true;
    }
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoadingInitialData = true;
      _initialErrorMessage = null;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      _userId = prefs.getString('userId');

      if (_userId == null) {
        throw Exception("User ID not found in SharedPreferences");
      }

      await _getCurrentLocation();

      await Future.wait([
        _locationMapController.loadCurrentUserLocation(),
        Provider.of<ShopNearbyController>(
          context,
          listen: false,
        ).loadNearbyShops(),
      ]);

      setState(() {});
    } catch (error) {
      setState(() {
        log("Failed to load initial data: $error");
        _initialErrorMessage = "Failed to load initial data: $error";
      });
    } finally {
      setState(() {
        _isLoadingInitialData = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _currentAddress = "Location services are disabled.";
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _currentAddress = "Location permission denied.";
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _currentAddress =
            "Location permissions are permanently denied. Please enable from settings.";
      });
      return;
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentPosition = position;
    });

    await _getAddressFromLatLng(position);
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      Placemark place = placemarks[0];
      setState(() {
        _currentAddress =
            "${place.locality}, ${place.administrativeArea} - ${place.postalCode}";
      });
    } catch (e) {
      setState(() {
        _currentAddress = "Unable to get address";
      });
    }
  }

  // Helper methods for responsive design
  bool get _isMobile => MediaQuery.of(context).size.width < _mobileBreakpoint;
  bool get _isTablet =>
      MediaQuery.of(context).size.width >= _mobileBreakpoint &&
      MediaQuery.of(context).size.width < _tabletBreakpoint;
  bool get _isDesktop =>
      MediaQuery.of(context).size.width >= _desktopBreakpoint;
  double get _screenWidth => MediaQuery.of(context).size.width;
  double get _screenHeight => MediaQuery.of(context).size.height;

  // Responsive padding
  double get _horizontalPadding {
    if (_isMobile) return 13.0;
    if (_isTablet) return 10.0;
    return 32.0;
  }

  // Responsive spacing
  double get _sectionSpacing {
    if (_isMobile) return 20.0;
    if (_isTablet) return 24.0;
    return 32.0;
  }

  // Responsive store list item height
  double get _storeItemHeight {
    if (_isMobile) return 80.0;
    if (_isTablet) return 100.0;
    return 120.0;
  }

  @override
  Widget build(BuildContext context) {
    final shopNearbyController = Provider.of<ShopNearbyController>(context);

    List<ShopNearbyModel> allActiveShops =
        shopNearbyController.shops
            .where((shop) => shop.subscription?.isActive == true)
            .toList();

    final displayedStores =
        _showAllStores
            ? allActiveShops
            : allActiveShops.take(_getStoresToShow()).toList();

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
        appBar: const CustomAppBar(),
        body: SafeArea(
          child:
              _isLoadingInitialData
                  ? const Center(child: CircularProgressIndicator())
                  : _initialErrorMessage != null
                  ? Center(child: Text(_initialErrorMessage!))
                  : _buildMainContent(
                    shopNearbyController,
                    displayedStores,
                    allActiveShops,
                  ),
        ),
      ),
    );
  }

  Widget _buildMainContent(
    ShopNearbyController shopNearbyController,
    List<ShopNearbyModel> displayedStores,
    List<ShopNearbyModel> allActiveShops,
  ) {
    return CustomScrollView(
      slivers: [
        // Top content that's not scrollable
        SliverToBoxAdapter(
          child: _buildTopContent(shopNearbyController, allActiveShops),
        ),

        // Stores list
        _buildStoresSliver(
          shopNearbyController,
          displayedStores,
          allActiveShops,
        ),

        // Bottom padding
        SliverToBoxAdapter(child: SizedBox(height: _sectionSpacing)),
      ],
    );
  }

  Widget _buildTopContent(
    ShopNearbyController shopNearbyController,
    List<ShopNearbyModel> allActiveShops,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: _sectionSpacing * 0.8),

            // Responsive search bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: _horizontalPadding),
              child: HomeSearchBar(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SearchPage()),
                  );
                },
              ),
            ),

            SizedBox(height: _sectionSpacing),

            // Advertisement carousel with responsive height
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: _horizontalPadding * 0.5,
              ),
              child: SizedBox(
                // height: _getCarouselHeight(),
                child: const AdvertisementCarousel(),
              ),
            ),

            SizedBox(height: _sectionSpacing),

            // Stores section title
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: _horizontalPadding,
                vertical: _sectionSpacing * 0.5,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Stores",
                    style: TextStyle(
                      fontSize: _getFontSize(scale: 1.2),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (!(_showAllStores ||
                      allActiveShops.length <= _getStoresToShow()))
                    InkWell(
                      onTap:
                          () =>
                              setState(() => _showAllStores = !_showAllStores),
                      child: Text(
                        "See all",
                        style: TextStyle(
                          fontSize: _getFontSize(scale: 1.0),
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            SizedBox(height: _sectionSpacing * 0.5),
          ],
        );
      },
    );
  }

  // Responsive stores display - SliverList for mobile, SliverGrid for tablet/desktop
  Widget _buildStoresSliver(
    ShopNearbyController shopNearbyController,
    List<ShopNearbyModel> displayedStores,
    List<ShopNearbyModel> allActiveShops,
  ) {
    if (shopNearbyController.isLoading) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: 200,
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
            ),
          ),
        ),
      );
    }

    if (allActiveShops.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(_horizontalPadding),
          child: const AnimatedNoDataMessage(
            titleText: "No active shops available at this location!",
            subtitleText: "Change your location and continue shopping 🚀",
          ),
        ),
      );
    }

    if (_isMobile) {
      return _buildMobileStoresSliver(displayedStores);
    } else {
      return _buildGridStoresSliver(displayedStores);
    }
  }

  Widget _buildMobileStoresSliver(List<ShopNearbyModel> stores) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final shop = stores[index];
        return Padding(
          padding: EdgeInsets.only(
            left: _horizontalPadding,
            right: _horizontalPadding,
            bottom: _sectionSpacing * 0.5,
            top: index == 0 ? 0 : _sectionSpacing * 0.5,
          ),
          child: _buildStoreListItem(shop),
        );
      }, childCount: stores.length),
    );
  }

  Widget _buildGridStoresSliver(List<ShopNearbyModel> stores) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _getGridCrossAxisCount(),
        crossAxisSpacing: _sectionSpacing * 0.8,
        mainAxisSpacing: _sectionSpacing * 0.8,
        childAspectRatio: _getGridChildAspectRatio(),
      ),
      delegate: SliverChildBuilderDelegate((context, index) {
        final shop = stores[index];
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: _horizontalPadding * 0.5,
            vertical: _sectionSpacing * 0.4,
          ),
          child: _buildStoreGridItem(shop),
        );
      }, childCount: stores.length),
    );
  }

  Widget _buildStoreListItem(ShopNearbyModel shop) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ShopProductsScreen(
                  shop: ShopModel(
                    id: shop.id ?? '',
                    shopName: shop.shopName ?? '',
                    headerImage: shop.headerImage,
                    mobileNumber: shop.mobileNumber ?? '',
                    place: shop.place ?? '',
                  ),
                ),
          ),
        );
      },
      child: Container(
        height: _storeItemHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_getBorderRadius()),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(_getGridItemPadding()),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Image container - FIXED: Use Container with explicit constraints
              Container(
                width: _storeItemHeight * 0.9,
                height: _storeItemHeight * 0.8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(_getBorderRadius() * 0.7),
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade50, Colors.orange.shade100],
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(_getBorderRadius() * 0.7),
                  child:
                      shop.headerImage != null && shop.headerImage!.isNotEmpty
                          ? Image.network(
                            shop.headerImage!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return _buildImageLoadingShimmer();
                            },
                            errorBuilder:
                                (context, error, stackTrace) =>
                                    _buildElegantPlaceholder(),
                          )
                          : _buildElegantPlaceholder(),
                ),
              ),

              SizedBox(width: _sectionSpacing * 0.8),

              // Content - FIXED: Use Expanded with constraints
              Expanded(
                child: Container(
                  height: double.infinity,
                  constraints: BoxConstraints(
                    maxHeight: _storeItemHeight - (_getGridItemPadding() * 2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Shop name with constrained height
                      Container(
                        constraints: BoxConstraints(
                          maxHeight: _getFontSize() * 1.2,
                        ),
                        child: Text(
                          shop.shopName ?? '',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: _getFontSize(),
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      SizedBox(
                        height: _sectionSpacing * 0.1,
                      ), // Reduced spacing
                      // Category badge with fixed height
                      Container(
                        constraints: BoxConstraints(
                          maxHeight: _getFontSize(scale: 1.2),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: _getGridItemPadding() * 0.2,
                          vertical:
                              _getGridItemPadding() *
                              0.1, // Reduced vertical padding
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          (shop.category ?? []).join(", "),
                          style: TextStyle(
                            fontSize: _getFontSize(
                              scale: 0.7,
                            ), // Reduced font size
                            color: Colors.orange.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      SizedBox(
                        height: _sectionSpacing * 0.1,
                      ), // Reduced spacing
                      // Location row with fixed height
                      Container(
                        constraints: BoxConstraints(
                          maxHeight: _getFontSize(scale: 1.2),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              size: _getFontSize(
                                scale: 0.8,
                              ), // Reduced icon size
                              color: Colors.grey.shade600,
                            ),
                            SizedBox(
                              width: _sectionSpacing * 0.1,
                            ), // Reduced spacing
                            Expanded(
                              child: Text(
                                shop.locality?.isNotEmpty == true
                                    ? shop.locality.toString()
                                    : 'Location not available',
                                style: TextStyle(
                                  fontSize: _getFontSize(
                                    scale: 0.7,
                                  ), // Reduced font size
                                  color: Colors.grey.shade600,
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
                ),
              ),

              SizedBox(width: _sectionSpacing * 0.3),

              // Distance + Arrow - FIXED: Use Container with height constraints
              Container(
                height: _storeItemHeight - (_getGridItemPadding() * 2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Text(
                    //   "1.2 km",
                    //   style: TextStyle(
                    //     color: Colors.grey.shade600,
                    //     fontSize: _getFontSize(scale: 0.7), // Reduced font size
                    //     fontWeight: FontWeight.w500,
                    //   ),
                    // ),
                    SizedBox(height: _sectionSpacing * 0.2), // Reduced spacing
                    Container(
                      width: _getIconSize() * 0.7, // Reduced size
                      height: _getIconSize() * 0.7, // Reduced size
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: _getIconSize() * 0.25, // Reduced size
                        color: Colors.orange.shade700,
                      ),
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

  Widget _buildStoreGridItem(ShopNearbyModel shop) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_getBorderRadius()),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ShopProductsScreen(
                    shop: ShopModel(
                      id: shop.id ?? '',
                      shopName: shop.shopName ?? '',
                      headerImage: shop.headerImage,
                      mobileNumber: shop.mobileNumber ?? '',
                      place: shop.place ?? '',
                    ),
                  ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(_getBorderRadius()),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_getBorderRadius()),
            color: Colors.white,
          ),
          child: Padding(
            padding: EdgeInsets.all(_getGridItemPadding()),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image section
                Expanded(
                  flex: _isTablet ? 2 : 3,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        _getBorderRadius() * 0.8,
                      ),
                      gradient: LinearGradient(
                        colors: [Colors.orange.shade50, Colors.orange.shade100],
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        _getBorderRadius() * 0.8,
                      ),
                      child:
                          shop.headerImage != null &&
                                  shop.headerImage!.isNotEmpty
                              ? Image.network(
                                shop.headerImage!,
                                fit: BoxFit.cover,
                                loadingBuilder: (
                                  context,
                                  child,
                                  loadingProgress,
                                ) {
                                  if (loadingProgress == null) return child;
                                  return _buildImageLoadingShimmer();
                                },
                                errorBuilder:
                                    (context, error, stackTrace) =>
                                        _buildElegantPlaceholder(),
                              )
                              : _buildElegantPlaceholder(),
                    ),
                  ),
                ),

                SizedBox(height: _sectionSpacing * 0.5),

                // Content section
                Expanded(
                  flex: _isTablet ? 3 : 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        shop.shopName ?? '',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: _getFontSize(scale: 1.0),
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: _getGridItemPadding() * 0.5,
                          vertical: _getGridItemPadding() * 0.3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          (shop.category ?? []).join(", "),
                          style: TextStyle(
                            fontSize: _getFontSize(scale: 0.8),
                            color: Colors.orange.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: _getFontSize(scale: 0.9),
                            color: Colors.grey.shade600,
                          ),
                          SizedBox(width: _getGridItemPadding() * 0.3),
                          Expanded(
                            child: Text(
                              shop.locality?.isNotEmpty == true
                                  ? shop.locality.toString()
                                  : 'Location not available',
                              style: TextStyle(
                                fontSize: _getFontSize(scale: 0.8),
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Text(
                          //   "1.2 km",
                          //   style: TextStyle(
                          //     color: Colors.grey.shade600,
                          //     fontSize: _getFontSize(scale: 0.8),
                          //     fontWeight: FontWeight.w500,
                          //   ),
                          // ),
                          Container(
                            width: _getIconSize(),
                            height: _getIconSize(),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: _getIconSize() * 0.4,
                              color: Colors.orange.shade700,
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
      ),
    );
  }

  // Responsive configuration methods
  int _getStoresToShow() {
    if (_isMobile) return 6;
    if (_isTablet) return 8;
    return 12;
  }

  double _getCarouselHeight() {
    if (_isMobile) return 180.0;
    if (_isTablet) return 220.0; // Reduced from 250 for better fit
    return 260.0; // Reduced from 300 for better fit
  }

  int _getGridCrossAxisCount() {
    if (_screenWidth < _tabletBreakpoint) return 2;
    if (_screenWidth < _desktopBreakpoint) return 3;
    return 4;
  }

  double _getGridChildAspectRatio() {
    if (_isTablet) return 0.9;
    return 0.85;
  }

  double _getBorderRadius() {
    if (_isMobile) return 14.0;
    if (_isTablet) return 16.0;
    return 18.0;
  }

  double _getGridItemPadding() {
    if (_isMobile) return 12.0;
    if (_isTablet) return 16.0;
    return 20.0;
  }

  double _getFontSize({double scale = 1.0}) {
    double baseSize;
    if (_isMobile) {
      baseSize = 14.0;
    } else if (_isTablet) {
      baseSize = 16.0;
    } else {
      baseSize = 18.0;
    }
    return baseSize * scale;
  }

  double _getIconSize() {
    if (_isMobile) return 28.0;
    if (_isTablet) return 32.0;
    return 36.0;
  }

  Widget _buildElegantPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_getBorderRadius() * 0.7),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.orange.shade100, Colors.orange.shade200],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.store_mall_directory_rounded,
            size: _getIconSize(),
            color: Colors.orange.shade600,
          ),
          SizedBox(height: _sectionSpacing * 0.2),
          Text(
            'Shop',
            style: TextStyle(
              fontSize: _getFontSize(scale: 0.7),
              color: Colors.orange.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageLoadingShimmer() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_getBorderRadius() * 0.7),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.grey.shade200,
            Colors.grey.shade300,
            Colors.grey.shade200,
          ],
        ),
      ),
      child: Center(
        child: SizedBox(
          width: _getIconSize() * 0.6,
          height: _getIconSize() * 0.6,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepOrange),
          ),
        ),
      ),
    );
  }
}
