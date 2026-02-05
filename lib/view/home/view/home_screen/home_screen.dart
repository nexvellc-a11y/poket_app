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
  // ignore: unused_field
  Position? _currentPosition;

  late LocationMapController _locationMapController;
  // ignore: unused_field
  late HomeProductController _homeProductController;

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

      // ✅ Get current location first
      await _getCurrentLocation();

      await Future.wait([
        _locationMapController.loadCurrentUserLocation(),
        Provider.of<ShopNearbyController>(
          // ignore: use_build_context_synchronously
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

  /// ✅ Get current location using Geolocator
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _currentAddress = "Location services are disabled.";
      });
      return;
    }

    // Check permission
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

    // Get position
    final position = await Geolocator.getCurrentPosition(
      // ignore: deprecated_member_use
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentPosition = position;
    });

    // Reverse geocode the coordinates
    await _getAddressFromLatLng(position);
  }

  /// ✅ Convert coordinates to human-readable address
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

  @override
  Widget build(BuildContext context) {
    final shopNearbyController = Provider.of<ShopNearbyController>(context);

    List<ShopNearbyModel> allActiveShops =
        shopNearbyController.shops
            .where((shop) => shop.subscription?.isActive == true)
            .toList();

    final displayedStores =
        _showAllStores ? allActiveShops : allActiveShops.take(6).toList();

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
        body: Container(
          // decoration: const BoxDecoration(
          //   gradient: LinearGradient(
          //     begin: Alignment.topCenter,
          //     end: Alignment.bottomCenter,
          //     colors: [Color(0xFF696FDD), Color(0xFF8F75FF)],
          //   ),
          // ),
          child: SafeArea(
            child:
                _isLoadingInitialData
                    ? const Center(child: CircularProgressIndicator())
                    : _initialErrorMessage != null
                    ? Center(child: Text(_initialErrorMessage!))
                    : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 20),

                          HomeSearchBar(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => SearchPage()),
                              );
                            },
                          ),

                          // const SearchWidget(),
                          SizedBox(height: 20),
                          const AdvertisementCarousel(),
                          SizedBox(height: 10),

                          // Padding(
                          //   padding: const EdgeInsets.symmetric(
                          //     horizontal: 16,
                          //     vertical: 8,
                          //   ),
                          //   child: _buildLocationWidget(),
                          // ),
                          buildSectionTitle(
                            "Stores",
                            _showAllStores || allActiveShops.length <= 6
                                ? ""
                                : "See all",
                            () => setState(
                              () => _showAllStores = !_showAllStores,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child:
                                shopNearbyController.isLoading
                                    ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                    : allActiveShops.isEmpty
                                    ? const Center(
                                      child: AnimatedNoDataMessage(
                                        titleText:
                                            "No active shops available at this location!",
                                        subtitleText:
                                            "Change your location and continue shopping 🚀",
                                      ),
                                    )
                                    : // Inside your Padding widget where GridView.builder is
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 2.0,
                                      ),
                                      child:
                                          shopNearbyController.isLoading
                                              ? const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              )
                                              : allActiveShops.isEmpty
                                              ? const Center(
                                                child: AnimatedNoDataMessage(
                                                  titleText:
                                                      "No active shops available at this location!",
                                                  subtitleText:
                                                      "Change your location and continue shopping 🚀",
                                                ),
                                              )
                                              : ListView.builder(
                                                shrinkWrap: true,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                itemCount:
                                                    displayedStores.length,
                                                itemBuilder: (context, index) {
                                                  final shop =
                                                      displayedStores[index];
                                                  return InkWell(
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder:
                                                              (
                                                                context,
                                                              ) => ShopProductsScreen(
                                                                shop: ShopModel(
                                                                  id:
                                                                      shop.id ??
                                                                      '',
                                                                  shopName:
                                                                      shop.shopName ??
                                                                      '',
                                                                  headerImage:
                                                                      shop.headerImage,
                                                                  mobileNumber:
                                                                      shop.mobileNumber ??
                                                                      '',
                                                                  place:
                                                                      shop.place ??
                                                                      '',
                                                                ),
                                                              ),
                                                        ),
                                                      );
                                                    },
                                                    child: buildStoreListItem(
                                                      shop.shopName ?? '',
                                                      shop.headerImage,
                                                      (shop.category ?? [])
                                                          .join(", "),

                                                      shop.locality
                                                          .toString(), // Ensure your model includes distance
                                                    ),
                                                  );
                                                },
                                              ),
                                    ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
          ),
        ),
      ),
    );
  }

  /// ✅ Location widget display
  Widget _buildLocationWidget() {
    if (_currentAddress == null) {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.deepOrange,
            ),
          ),
          SizedBox(width: 8),
          Text(
            "Fetching location...",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.deepOrange,
            ),
          ),
        ],
      );
    }

    return Text(
      _currentAddress!,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.deepOrange,
      ),
    );
  }

  Widget buildSectionTitle(
    String title,
    String actionText,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (actionText.isNotEmpty)
            InkWell(
              onTap: onTap,
              child: Text(
                actionText,
                style: TextStyle(color: Colors.blue.shade700),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildStoreListItem(
    String name,
    String? imageUrl,
    String category,
    String locality,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ⬇️ Slightly wider image (height same)
              Container(
                width: 72, // ⬅️ Increased width
                height: 65, // same height
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade50, Colors.orange.shade100],
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child:
                      imageUrl != null && imageUrl.isNotEmpty
                          ? Image.network(
                            imageUrl,
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

              const SizedBox(width: 20), // Slightly reduced to give more space
              // ⬆️ Larger content area
              Expanded(
                flex: 3, // ⬅️ Increased to give more width
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 1,
                        vertical: 3,
                      ),
                      // decoration: BoxDecoration(
                      //   color: Colors.orange.withOpacity(0.1),
                      //   borderRadius: BorderRadius.circular(6),
                      // ),
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: 11,
                          // color: Colors.orange.shade700,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 13,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            locality.isNotEmpty
                                ? locality
                                : 'Location not available',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 6), // reduced spacing
              // Distance + Arrow
              Column(
                children: [
                  Text(
                    "1.2 km",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildElegantPlaceholder() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
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
            size: 24,
            color: Colors.orange.shade600,
          ),
          const SizedBox(height: 4),
          Text(
            'Shop',
            style: TextStyle(
              fontSize: 10,
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
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
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
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrange),
          ),
        ),
      ),
    );
  }
}





// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:poketstore/controllers/fcm_controller/fcm_controller.dart';
// import 'package:poketstore/controllers/home_product_controller/home_product_controller.dart';
// import 'package:poketstore/controllers/location_controller/location_controller.dart';
// import 'package:poketstore/controllers/shop_nearby_controller/shop_nearby_controller.dart';
// import 'package:poketstore/model/add_shope_model/add_shop_model.dart';
// import 'package:poketstore/model/shop_nearby_model/shop_nearby_model.dart';
// import 'package:poketstore/utilities/custom_app_bar.dart';
// import 'package:poketstore/utilities/search_bar.dart';
// import 'package:poketstore/view/home/view/home_screen/shop_product_screen/shop_product_screen.dart';
// import 'package:poketstore/view/home/widgets/advertisment_slider.dart';
// import 'package:poketstore/utilities/no_data_warning.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// // Import your product model
// import 'package:poketstore/model/product_search_model/product_search_model.dart'
//     as productSearch;

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   bool _isLoadingInitialData = true;
//   String? _initialErrorMessage;
//   String? _userId;
//   bool _showAllStores = false;
//   bool _isDataLoaded = false;
//   String? _currentAddress;
//   Position? _currentPosition;

//   late LocationMapController _locationMapController;
//   late HomeProductController _homeProductController;

//   // 🔥 NEW SEARCH VARIABLES
//   bool _isSearching = false;
//   List<dynamic> _searchResults = [];
//   String? _currentProductQuery;
//   String? _currentState;
//   String? _currentDistrict;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Provider.of<FCMProvider>(
//         context,
//         listen: false,
//       ).registerFcmToken(context);
//     });
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     if (!_isDataLoaded) {
//       _locationMapController = Provider.of<LocationMapController>(
//         context,
//         listen: false,
//       );
//       _homeProductController = Provider.of<HomeProductController>(
//         context,
//         listen: false,
//       );
//       _loadInitialData();
//       _isDataLoaded = true;
//     }
//   }

//   Future<void> _loadInitialData() async {
//     setState(() {
//       _isLoadingInitialData = true;
//       _initialErrorMessage = null;
//     });
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       _userId = prefs.getString('userId');

//       if (_userId == null) {
//         throw Exception("User ID not found in SharedPreferences");
//       }

//       await _getCurrentLocation();

//       await Future.wait([
//         _locationMapController.loadUserLocation(_userId!),
//         Provider.of<ShopNearbyController>(
//           context,
//           listen: false,
//         ).loadNearbyShops(_userId!),
//       ]);

//       setState(() {});
//     } catch (error) {
//       setState(() {
//         _initialErrorMessage = "Failed to load initial data: $error";
//       });
//     } finally {
//       setState(() {
//         _isLoadingInitialData = false;
//       });
//     }
//   }

//   /// Get GPS location
//   Future<void> _getCurrentLocation() async {
//     bool serviceEnabled;
//     LocationPermission permission;

//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       setState(() {
//         _currentAddress = "Location services are disabled.";
//       });
//       return;
//     }

//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         setState(() {
//           _currentAddress = "Location permission denied.";
//         });
//         return;
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       setState(() {
//         _currentAddress =
//             "Location permissions are permanently denied. Enable in settings.";
//       });
//       return;
//     }

//     final position = await Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.high,
//     );

//     setState(() {
//       _currentPosition = position;
//     });

//     await _getAddressFromLatLng(position);
//   }

//   /// Convert lat-long → address
//   Future<void> _getAddressFromLatLng(Position position) async {
//     try {
//       List<Placemark> placemarks = await placemarkFromCoordinates(
//         position.latitude,
//         position.longitude,
//       );

//       Placemark place = placemarks[0];
//       setState(() {
//         _currentAddress =
//             "${place.locality}, ${place.administrativeArea} - ${place.postalCode}";
//       });
//     } catch (e) {
//       setState(() {
//         _currentAddress = "Unable to get address";
//       });
//     }
//   }

//   // Callback from SearchWidget
//   void _onSearchResultsReceived(
//     List<dynamic> results, {
//     String? productQuery,
//     String? state,
//     String? district,
//   }) {
//     setState(() {
//       _searchResults = results;
//       _isSearching = results.isNotEmpty;
//       _currentProductQuery = productQuery;
//       _currentState = state;
//       _currentDistrict = district;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final shopNearbyController = Provider.of<ShopNearbyController>(context);

//     List<ShopNearbyModel> allActiveShops =
//         shopNearbyController.shops
//             .where((shop) => shop.subscription?.isActive == true)
//             .toList();

//     final displayedStores =
//         _showAllStores ? allActiveShops : allActiveShops.take(6).toList();

//     return Container(
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [Color(0xFF696FDD), Color(0xFF8F75FF)],
//         ),
//       ),
//       child: Scaffold(
//         backgroundColor: Colors.transparent,
//         appBar: const CustomAppBar(),
//         body: SafeArea(
//           child:
//               _isLoadingInitialData
//                   ? const Center(child: CircularProgressIndicator())
//                   : _initialErrorMessage != null
//                   ? Center(child: Text(_initialErrorMessage!))
//                   : CustomScrollView(
//                     slivers: [
//                       SliverToBoxAdapter(
//                         child: Column(
//                           children: [
//                             const SizedBox(height: 20),
//                             SearchWidget(
//                               onHomeSearchResults: (
//                                 results, {
//                                 String? productQuery,
//                                 String? state,
//                                 String? district,
//                               }) {
//                                 _onSearchResultsReceived(
//                                   results,
//                                   productQuery: productQuery,
//                                   state: state,
//                                   district: district,
//                                 );
//                               },
//                             ),
//                             const SizedBox(height: 20),
//                             const AdvertisementCarousel(),
//                             const SizedBox(height: 10),
//                           ],
//                         ),
//                       ),

//                       _isSearching
//                           ? SliverList(
//                             delegate: SliverChildBuilderDelegate((
//                               context,
//                               index,
//                             ) {
//                               final result = _searchResults[index];

//                               if (result is productSearch.ProductSearchModel) {
//                                 return _buildProductCard(result);
//                               }
//                               if (result is ShopNearbyModel) {
//                                 return _buildShopCard(result);
//                               }
//                               return const SizedBox();
//                             }, childCount: _searchResults.length),
//                           )
//                           : SliverToBoxAdapter(
//                             child: _buildNormalContent(
//                               shopNearbyController,
//                               displayedStores,
//                               allActiveShops,
//                             ),
//                           ),
//                     ],
//                   ),
//         ),
//       ),
//     );
//   }

//   // ⭐ SEARCH RESULTS LIST (Now properly scrollable)
//   Widget _buildSearchResults() {
//     if (_searchResults.isEmpty) {
//       return Center(
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 Icons.search_off,
//                 size: 60,
//                 color: Colors.white.withOpacity(0.7),
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 "No results found",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 18,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               if (_currentState != null || _currentDistrict != null)
//                 Padding(
//                   padding: const EdgeInsets.only(top: 8),
//                   child: Text(
//                     "State: ${_currentState ?? 'Not selected'} | District: ${_currentDistrict ?? 'Not selected'}",
//                     style: TextStyle(
//                       color: Colors.white.withOpacity(0.8),
//                       fontSize: 14,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       );
//     }

//     return ListView.builder(
//       padding: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
//       itemCount: _searchResults.length,
//       itemBuilder: (context, index) {
//         final result = _searchResults[index];

//         if (result is productSearch.ProductSearchModel) {
//           return _buildProductCard(result);
//         }

//         if (result is ShopNearbyModel) {
//           return _buildShopCard(result);
//         }

//         return const SizedBox();
//       },
//     );
//   }

//   // Normal content (stores list) when not searching
//   Widget _buildNormalContent(
//     ShopNearbyController shopNearbyController,
//     List<ShopNearbyModel> displayedStores,
//     List<ShopNearbyModel> allActiveShops,
//   ) {
//     return SingleChildScrollView(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           buildSectionTitle(
//             "Stores",
//             _showAllStores || allActiveShops.length <= 6 ? "" : "See all",
//             () => setState(() => _showAllStores = !_showAllStores),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16.0),
//             child:
//                 shopNearbyController.isLoading
//                     ? const Center(child: CircularProgressIndicator())
//                     : allActiveShops.isEmpty
//                     ? const Center(
//                       child: AnimatedNoDataMessage(
//                         titleText:
//                             "No active shops available at this location!",
//                         subtitleText:
//                             "Change your location and continue shopping 🚀",
//                       ),
//                     )
//                     : ListView.builder(
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       itemCount: displayedStores.length,
//                       itemBuilder: (context, index) {
//                         final shop = displayedStores[index];
//                         return InkWell(
//                           onTap: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder:
//                                     (context) => ShopProductsScreen(
//                                       shop: ShopModel(
//                                         id: shop.id ?? '',
//                                         shopName: shop.shopName ?? '',
//                                         headerImage: shop.headerImage,
//                                         mobileNumber: shop.mobileNumber ?? '',
//                                         place: shop.place ?? '',
//                                       ),
//                                     ),
//                               ),
//                             );
//                           },
//                           child: _buildShopCard(shop),
//                         );
//                       },
//                     ),
//           ),
//           const SizedBox(height: 20),
//         ],
//       ),
//     );
//   }

//   // Build Shop Card
//   Widget _buildShopCard(ShopNearbyModel shop) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: InkWell(
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder:
//                   (context) => ShopProductsScreen(
//                     shop: ShopModel(
//                       id: shop.id ?? '',
//                       shopName: shop.shopName ?? '',
//                       headerImage: shop.headerImage,
//                       mobileNumber: shop.mobileNumber ?? '',
//                       place: shop.place ?? '',
//                     ),
//                   ),
//             ),
//           );
//         },
//         child: Card(
//           margin: const EdgeInsets.symmetric(vertical: 6),
//           elevation: 0,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(14),
//             side: BorderSide(color: Colors.grey.shade200, width: 1),
//           ),
//           child: Container(
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(14),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(12),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Container(
//                     width: 72,
//                     height: 65,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(10),
//                       gradient: LinearGradient(
//                         colors: [Colors.orange.shade50, Colors.orange.shade100],
//                       ),
//                     ),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(10),
//                       child:
//                           (shop.headerImage != null &&
//                                   shop.headerImage!.isNotEmpty)
//                               ? Image.network(
//                                 shop.headerImage!,
//                                 fit: BoxFit.cover,
//                                 loadingBuilder: (
//                                   context,
//                                   child,
//                                   loadingProgress,
//                                 ) {
//                                   if (loadingProgress == null) return child;
//                                   return _buildImageLoadingShimmer();
//                                 },
//                                 errorBuilder:
//                                     (context, error, stackTrace) =>
//                                         _buildShopPlaceholder(),
//                               )
//                               : _buildShopPlaceholder(),
//                     ),
//                   ),
//                   const SizedBox(width: 20),
//                   Expanded(
//                     flex: 3,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           shop.shopName ?? 'Unknown Shop',
//                           style: const TextStyle(
//                             fontWeight: FontWeight.w700,
//                             fontSize: 15,
//                             color: Colors.black87,
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           (shop.category ?? []).join(", "),
//                           style: const TextStyle(
//                             fontSize: 11,
//                             color: Colors.black,
//                             fontWeight: FontWeight.w600,
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         const SizedBox(height: 4),
//                         Row(
//                           children: [
//                             Icon(
//                               Icons.location_on_rounded,
//                               size: 13,
//                               color: Colors.grey.shade600,
//                             ),
//                             const SizedBox(width: 4),
//                             Expanded(
//                               child: Text(
//                                 shop.locality?.toString().isNotEmpty == true
//                                     ? shop.locality.toString()
//                                     : (shop.place?.isNotEmpty == true
//                                         ? shop.place!
//                                         : 'Location not available'),
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   color: Colors.grey.shade600,
//                                 ),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(width: 6),
//                   Column(
//                     children: [
//                       const SizedBox(height: 6),
//                       Container(
//                         width: 28,
//                         height: 28,
//                         decoration: BoxDecoration(
//                           color: Colors.orange.shade50,
//                           shape: BoxShape.circle,
//                         ),
//                         child: Icon(
//                           Icons.arrow_forward_ios_rounded,
//                           size: 12,
//                           color: Colors.orange.shade700,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // Build Product Card
//   Widget _buildProductCard(productSearch.ProductSearchModel product) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Card(
//         margin: const EdgeInsets.symmetric(vertical: 6),
//         elevation: 0,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(14),
//           side: BorderSide(color: Colors.grey.shade200, width: 1),
//         ),
//         child: InkWell(
//           onTap: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder:
//                     (context) => ShopProductsScreen(
//                       shop: ShopModel(
//                         id: product.shop.id,
//                         shopName: product.shop.shopName,
//                         headerImage: product.shop.headerImage,
//                         mobileNumber: product.shop.mobileNumber,
//                         place: product.shop.place,
//                       ),
//                     ),
//               ),
//             );
//           },
//           child: Container(
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(14),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(12),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   // Product Image
//                   Container(
//                     width: 72,
//                     height: 65,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(10),
//                       color: Colors.grey.shade100,
//                     ),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(10),
//                       child:
//                           product.productImage.isNotEmpty
//                               ? Image.network(
//                                 product.productImage,
//                                 fit: BoxFit.cover,
//                                 loadingBuilder: (
//                                   context,
//                                   child,
//                                   loadingProgress,
//                                 ) {
//                                   if (loadingProgress == null) return child;
//                                   return _buildImageLoadingShimmer();
//                                 },
//                                 errorBuilder:
//                                     (context, error, stackTrace) =>
//                                         _buildProductPlaceholder(),
//                               )
//                               : _buildProductPlaceholder(),
//                     ),
//                   ),
//                   const SizedBox(width: 20),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           product.name,
//                           style: const TextStyle(
//                             fontWeight: FontWeight.w700,
//                             fontSize: 15,
//                             color: Colors.black87,
//                           ),
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           "by ${product.shop.shopName}",
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.grey.shade600,
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         const SizedBox(height: 4),
//                         Row(
//                           children: [
//                             Icon(
//                               Icons.location_on_outlined,
//                               size: 13,
//                               color: Colors.grey.shade600,
//                             ),
//                             const SizedBox(width: 4),
//                             Expanded(
//                               child: Text(
//                                 product.shop.locality.isNotEmpty
//                                     ? product.shop.locality
//                                     : 'Location not available',
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   color: Colors.grey.shade600,
//                                 ),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 4),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               '₹${product.price}',
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 16,
//                                 color: Colors.green,
//                               ),
//                             ),
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 8,
//                                 vertical: 4,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: Colors.blue.shade50,
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               child: Text(
//                                 'Product',
//                                 style: TextStyle(
//                                   fontSize: 10,
//                                   color: Colors.blue.shade700,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildProductPlaceholder() {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(10),
//         gradient: LinearGradient(
//           colors: [Colors.blue.shade100, Colors.blue.shade200],
//         ),
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.shopping_bag_outlined,
//             size: 24,
//             color: Colors.blue.shade600,
//           ),
//           const SizedBox(height: 4),
//           Text(
//             'Product',
//             style: TextStyle(
//               fontSize: 10,
//               color: Colors.blue.shade700,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildShopPlaceholder() {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(10),
//         gradient: LinearGradient(
//           colors: [Colors.orange.shade100, Colors.orange.shade200],
//         ),
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.store_mall_directory_rounded,
//             size: 24,
//             color: Colors.orange.shade600,
//           ),
//           const SizedBox(height: 4),
//           Text(
//             'Shop',
//             style: TextStyle(
//               fontSize: 10,
//               color: Colors.orange.shade700,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildImageLoadingShimmer() {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(10),
//         gradient: LinearGradient(
//           colors: [
//             Colors.grey.shade200,
//             Colors.grey.shade300,
//             Colors.grey.shade200,
//           ],
//         ),
//       ),
//       child: const Center(
//         child: SizedBox(
//           width: 20,
//           height: 20,
//           child: CircularProgressIndicator(
//             strokeWidth: 2,
//             valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrange),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget buildSectionTitle(
//     String title,
//     String actionText,
//     VoidCallback onTap,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             title,
//             style: const TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//           if (actionText.isNotEmpty)
//             InkWell(
//               onTap: onTap,
//               child: Text(
//                 actionText,
//                 style: TextStyle(color: Colors.blue.shade700),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }






