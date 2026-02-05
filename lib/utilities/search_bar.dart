import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:poketstore/controllers/product_search_controller/district_search_controller.dart';
import 'package:poketstore/controllers/product_search_controller/product_search_controller.dart';
import 'package:poketstore/controllers/product_search_controller/shop_search_controller.dart';
import 'package:poketstore/controllers/product_search_controller/state_search_controller.dart';
import 'package:poketstore/model/add_shope_model/add_shop_model.dart'
    as addShop;
import 'package:poketstore/model/product_search_model/product_search_model.dart'
    as productSearch;
import 'package:poketstore/model/shop_nearby_model/shop_nearby_model.dart';
import 'package:poketstore/view/home/view/home_screen/shop_product_screen/shop_product_screen.dart';
import 'package:provider/provider.dart';

class SearchWidget extends StatefulWidget {
  final Function(List<dynamic>)? onHomeSearchResults;
  final bool isFullPageMode;
  final VoidCallback? onClosePressed;

  const SearchWidget({
    super.key,
    this.onHomeSearchResults,
    this.isFullPageMode = false,
    this.onClosePressed,
  });

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final TextEditingController _productSearchController =
      TextEditingController();
  final TextEditingController _shopSearchController = TextEditingController();
  Timer? _debounce;

  List<productSearch.ProductSearchModel> _productResults = [];
  List<ShopNearbyModel> _shopResults = [];
  String _activeSearchType = '';
  String? _selectedState;
  String? _selectedDistrict;
  bool _isLocalLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StateController>(context, listen: false).fetchStates();
    });

    _productSearchController.addListener(() {
      _startSearchDebounce("product");
    });

    _shopSearchController.addListener(() {
      _startSearchDebounce("shop");
    });
  }

  void _startSearchDebounce(String type) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    if (!_isLocalLoading) {
      setState(() {
        _isLocalLoading = true;
      });
    }

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _activeSearchType = type;
      String productQuery = _productSearchController.text.trim();
      String shopQuery = _shopSearchController.text.trim();

      if (productQuery.isEmpty &&
          shopQuery.isEmpty &&
          _selectedDistrict == null) {
        Provider.of<ProductSearchProvider>(
          context,
          listen: false,
        ).clearSearchResults();
        Provider.of<ShopSearchController>(context, listen: false).shops = [];

        setState(() {
          _productResults = [];
          _shopResults = [];
          _activeSearchType = '';
          _isLocalLoading = false;
        });

        if (widget.onHomeSearchResults != null) {
          widget.onHomeSearchResults!([]);
        }
      } else {
        _performSearch(productQuery: productQuery, shopQuery: shopQuery);
      }
    });
  }

  Future<void> _performSearch({String? productQuery, String? shopQuery}) async {
    final productProvider = Provider.of<ProductSearchProvider>(
      context,
      listen: false,
    );
    final shopProvider = Provider.of<ShopSearchController>(
      context,
      listen: false,
    );

    productProvider.errorMessage = '';
    shopProvider.errorMessage = '';
    productProvider.isLoading = true;
    shopProvider.isLoading = true;

    productProvider.notifyListeners();
    shopProvider.notifyListeners();

    try {
      if ((productQuery ?? '').isNotEmpty) {
        log(
          "Performing Product Search with Query: $productQuery and District: $_selectedDistrict",
        );
        await productProvider.fetchSearchResults(
          productQuery!,
          _selectedDistrict ?? "",
        );
        _productResults = productProvider.searchResults;
        _activeSearchType = "product";
        _convertProductResultsToShops();
      } else if ((shopQuery ?? '').isNotEmpty) {
        log("Performing Shop Search with Query: $shopQuery");
        await shopProvider.searchShopsWithPrefs(shopQuery!);
        _activeSearchType = "shop";
        _convertShopResults();
      } else if (_selectedDistrict != null && _selectedDistrict!.isNotEmpty) {
        log("Performing District Filter for Products in: $_selectedDistrict");
        await productProvider.fetchProductsByDistrict(_selectedDistrict!);
        _productResults = productProvider.searchResults;
        _activeSearchType = "product";
        _convertProductResultsToShops();
      } else {
        log("No active search query or selected district.");
        _productResults = [];
        _shopResults = [];
        _activeSearchType = '';
      }

      if (widget.onHomeSearchResults != null) {
        widget.onHomeSearchResults!(_shopResults);
      }
    } catch (e) {
      log("Search Error: $e");
      if (e.toString().contains("400")) {
        productProvider.errorMessage =
            "Please enter a search term or select a location.";
      } else {
        productProvider.errorMessage = 'Failed to load results: $e';
      }
    } finally {
      productProvider.isLoading = false;
      shopProvider.isLoading = false;

      setState(() {
        _isLocalLoading = false;
      });

      productProvider.notifyListeners();
      shopProvider.notifyListeners();
    }
  }

  void _convertProductResultsToShops() {
    final uniqueShops = <String, ShopNearbyModel>{};
    for (var product in _productResults) {
      if (!uniqueShops.containsKey(product.shop.id)) {
        uniqueShops[product.shop.id] = ShopNearbyModel(
          id: product.shop.id,
          shopName: product.shop.shopName,
          headerImage: product.shop.headerImage,
          category: product.shop.category,
          locality: product.shop.locality,
          place: product.shop.place,
          mobileNumber: product.shop.mobileNumber,
          subscription: null,
        );
      }
    }
    _shopResults = uniqueShops.values.toList();
  }

  void _convertShopResults() {
    final shopProvider = Provider.of<ShopSearchController>(
      context,
      listen: false,
    );
    _shopResults =
        shopProvider.shops.map((shop) {
          return ShopNearbyModel(
            id: shop.id ?? '',
            shopName: shop.shopName ?? '',
            headerImage: shop.headerImage,
            category: shop.category ?? [],
            locality: shop.locality ?? '',
            place: shop.place ?? '',
            // mobileNumber: shop.mobileNumber ?? '',
            subscription: null,
          );
        }).toList();
  }

  void _clearAll() {
    _productSearchController.clear();
    _shopSearchController.clear();
    Provider.of<ProductSearchProvider>(
      context,
      listen: false,
    ).clearSearchResults();
    Provider.of<ShopSearchController>(context, listen: false).shops = [];

    setState(() {
      _productResults = [];
      _shopResults = [];
      _activeSearchType = '';
      _isLocalLoading = false;
    });

    if (widget.onHomeSearchResults != null) {
      widget.onHomeSearchResults!([]);
    }

    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _productSearchController.dispose();
    _shopSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductSearchProvider>(context);
    final shopProvider = Provider.of<ShopSearchController>(context);

    List<dynamic> suggestions = [];
    if (_productSearchController.text.trim().isNotEmpty &&
        _activeSearchType == 'product' &&
        _productResults.isNotEmpty) {
      suggestions = [..._productResults];
    } else if (_shopSearchController.text.trim().isNotEmpty &&
        _activeSearchType == 'shop' &&
        _shopResults.isNotEmpty) {
      suggestions = [..._shopResults];
    } else if (_productSearchController.text.trim().isEmpty &&
        _shopSearchController.text.trim().isEmpty &&
        _selectedDistrict != null &&
        _selectedDistrict!.isNotEmpty) {
      suggestions = [..._shopResults];
    }

    final bool isSearching =
        (_productSearchController.text.isNotEmpty ||
            _shopSearchController.text.isNotEmpty ||
            _selectedDistrict != null) &&
        !productProvider.isLoading &&
        !shopProvider.isLoading;
    final bool noResultsFound = isSearching && suggestions.isEmpty;
    final bool showLoading =
        _isLocalLoading || productProvider.isLoading || shopProvider.isLoading;

    final bool showCloseButton =
        widget.isFullPageMode && widget.onClosePressed != null;

    // Remove the main Column's mainAxisSize: MainAxisSize.min
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Show header only if not in full page mode
          if (!widget.isFullPageMode)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Search Products & Shops",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Find what you're looking for",
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

          // Modern State & District Selector
          Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              widget.isFullPageMode ? 20 : 16,
              16,
              12,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFFF8F9FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Color(0xFF696FDD).withOpacity(0.1),
                  width: 1.5,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(1),
                child: Row(
                  children: [
                    // State Selector
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            bottomLeft: Radius.circular(15),
                          ),
                        ),
                        child: Consumer<StateController>(
                          builder: (_, stateCtrl, __) {
                            return DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: _selectedState,
                                hint: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.location_on_outlined,
                                        color: Color(0xFF696FDD),
                                        size: 18,
                                      ),
                                      SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          'State',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                items:
                                    stateCtrl.statesList.map((state) {
                                      return DropdownMenuItem(
                                        value: state,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                          ),
                                          child: Text(
                                            state,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight:
                                                  _selectedState == state
                                                      ? FontWeight.w600
                                                      : FontWeight.w400,
                                              color:
                                                  _selectedState == state
                                                      ? Color(0xFF696FDD)
                                                      : Colors.grey.shade800,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                onChanged: (String? val) {
                                  if (val == null) return;
                                  log("State selected: $val");

                                  setState(() {
                                    _selectedState = val;
                                    _selectedDistrict = null;
                                    _isLocalLoading = true;
                                  });

                                  Provider.of<DistrictController>(
                                    context,
                                    listen: false,
                                  ).fetchDistricts(val);
                                  _productResults = [];
                                  _shopResults = [];

                                  _performSearch(
                                    productQuery: "",
                                    shopQuery: "",
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    // Divider
                    Container(
                      width: 1,
                      height: 40,
                      color: Color(0xFF696FDD).withOpacity(0.1),
                    ),
                    // District Selector
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(15),
                            bottomRight: Radius.circular(15),
                          ),
                        ),
                        child: Consumer<DistrictController>(
                          builder: (_, distCtrl, __) {
                            String? districtValue =
                                distCtrl.districtList.contains(
                                      _selectedDistrict,
                                    )
                                    ? _selectedDistrict
                                    : null;

                            return DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: districtValue,
                                hint: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.map_outlined,
                                        color: Color(0xFF696FDD),
                                        size: 18,
                                      ),
                                      SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          'District',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                items:
                                    distCtrl.districtList.map((dist) {
                                      return DropdownMenuItem(
                                        value: dist,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                          ),
                                          child: Text(
                                            dist,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight:
                                                  _selectedDistrict == dist
                                                      ? FontWeight.w600
                                                      : FontWeight.w400,
                                              color:
                                                  _selectedDistrict == dist
                                                      ? Color(0xFF696FDD)
                                                      : Colors.grey.shade800,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                onChanged: (String? val) {
                                  log("District selected: $val");

                                  setState(() {
                                    _selectedDistrict = val;
                                    _isLocalLoading = true;
                                  });

                                  _productResults = [];
                                  _shopResults = [];

                                  _performSearch(
                                    productQuery:
                                        _productSearchController.text.trim(),
                                    shopQuery:
                                        _shopSearchController.text.trim(),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Product Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFFF8F9FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Color(0xFF696FDD).withOpacity(0.1),
                  width: 1.5,
                ),
              ),
              child: TextField(
                controller: _productSearchController,
                decoration: InputDecoration(
                  hintText: "Search products...",
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 12, right: 8),
                    child: Icon(
                      Icons.search_rounded,
                      color: Color(0xFF696FDD),
                      size: 22,
                    ),
                  ),
                  suffixIcon:
                      _productSearchController.text.isNotEmpty
                          ? Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: Color(0xFF696FDD).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Material(
                                color: Colors.transparent,
                                shape: CircleBorder(),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(14),
                                  onTap: () {
                                    _productSearchController.clear();
                                    if (_shopSearchController.text.isEmpty &&
                                        _selectedDistrict == null) {
                                      setState(() {
                                        _productResults = [];
                                        _shopResults = [];
                                        _activeSearchType = '';
                                        _isLocalLoading = false;
                                      });

                                      if (widget.onHomeSearchResults != null) {
                                        widget.onHomeSearchResults!([]);
                                      }
                                    }
                                  },
                                  child: Icon(
                                    Icons.close_rounded,
                                    size: 16,
                                    color: Color(0xFF696FDD),
                                  ),
                                ),
                              ),
                            ),
                          )
                          : null,
                ),
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                cursorColor: Color(0xFF696FDD),
              ),
            ),
          ),

          // Loading Indicator
          if (showLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: LinearProgressIndicator(
                backgroundColor: Color(0xFFF0F2FF),
                color: Color(0xFF696FDD),
                borderRadius: BorderRadius.circular(4),
                minHeight: 3,
              ),
            ),

          // Results Section - Use SizedBox with fixed height instead of Expanded
          if (suggestions.isNotEmpty)
            Container(
              height: 400, // Fixed height for results container
              margin: EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _activeSearchType == "product"
                              ? "Product Results"
                              : "Shop Results",
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          "${suggestions.length} found",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      padding: EdgeInsets.only(top: 4, bottom: 20),
                      itemCount: suggestions.length,
                      itemBuilder: (_, index) {
                        final item = suggestions[index];
                        if (item is productSearch.ProductSearchModel) {
                          return _buildModernProductCard(item);
                        }
                        if (item is ShopNearbyModel) {
                          return _buildModernShopCard(item);
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ],
              ),
            )
          else if (noResultsFound)
            Container(
              height: 200, // Fixed height for no results state
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off_rounded,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "No results found",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Try different keywords or filters",
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                  ),
                ],
              ),
            )
          else if (widget.isFullPageMode && !showLoading)
            Container(
              height: 200, // Fixed height for start searching state
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_rounded,
                    size: 64,
                    color: Colors.grey.shade300,
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: Text(
                      "Start searching",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Enter product name or shop name",
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                  ),
                ],
              ),
            ),

          // Close button for full page mode
          if (showCloseButton)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Center(
                child: ElevatedButton(
                  onPressed: widget.onClosePressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF696FDD),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                  ),
                  child: const Text(
                    'Close Search',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildModernProductCard(productSearch.ProductSearchModel product) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _clearAll();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => ShopProductsScreen(
                      shop: addShop.ShopModel(
                        id: product.shop.id,
                        shopName: product.shop.shopName,
                        headerImage: product.shop.headerImage,
                        mobileNumber: product.shop.mobileNumber,
                        place: product.shop.place,
                        category: product.shop.category,
                        sellerType: product.shop.sellerType,
                        state: product.shop.state,
                        locality: product.shop.locality,
                        pinCode: product.shop.pinCode,
                        email: product.shop.email,
                        landlineNumber: product.shop.landlineNumber,
                        isBanned: product.shop.isBanned,
                        agentCode: product.shop.agentCode,
                        registeredBySalesman: null,
                        isVerified: product.shop.isVerified,
                      ),
                    ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade100, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(color: Colors.grey.shade100),
                    child: Image.network(
                      product.productImage,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) => Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF696FDD).withOpacity(0.1),
                                  Color(0xFF8F75FF).withOpacity(0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.image_not_supported_rounded,
                              color: Color(0xFF696FDD).withOpacity(0.5),
                              size: 24,
                            ),
                          ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                // Product Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.storefront_rounded,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              product.shop.shopName,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              "${product.shop.locality}",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
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
                // Arrow Icon
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernShopCard(ShopNearbyModel shop) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _clearAll();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => ShopProductsScreen(
                      shop: addShop.ShopModel(
                        id: shop.id ?? '',
                        shopName: shop.shopName ?? '',
                        headerImage: shop.headerImage,
                        mobileNumber: shop.mobileNumber ?? '',
                        place: shop.place ?? '',
                        category: shop.category ?? [],
                        sellerType: '',
                        state: '',
                        locality: shop.locality.toString(),
                        pinCode: '',
                        email: '',
                        landlineNumber: '',
                        isBanned: false,
                        agentCode: '',
                        registeredBySalesman: null,
                        isVerified: false,
                      ),
                    ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade100, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Shop Icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF696FDD), Color(0xFF8F75FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.storefront_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                SizedBox(width: 12),
                // Shop Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shop.shopName ?? '',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFF696FDD).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "SHOP",
                              style: TextStyle(
                                color: Color(0xFF696FDD),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              shop.locality.toString().isNotEmpty
                                  ? shop.locality.toString()
                                  : (shop.place?.isNotEmpty == true
                                      ? shop.place!
                                      : 'Location not specified'),
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
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
                // Arrow Icon
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAnimatedAlert(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(const Duration(seconds: 2), () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        });

        return AlertDialog(
          backgroundColor: Colors.red.shade50,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded, color: Colors.red, size: 32),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: Colors.red.shade800,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// import 'dart:async';
// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:poketstore/controllers/product_search_controller/district_search_controller.dart';
// import 'package:poketstore/controllers/product_search_controller/product_search_controller.dart';
// import 'package:poketstore/controllers/product_search_controller/shop_search_controller.dart';
// import 'package:poketstore/controllers/product_search_controller/state_search_controller.dart';
// import 'package:poketstore/model/add_shope_model/add_shop_model.dart'
//     // ignore: library_prefixes
//     as addShop;
// import 'package:poketstore/model/product_search_model/product_search_model.dart'
//     // ignore: library_prefixes
//     as productSearch;
// import 'package:poketstore/model/shop_nearby_model/shop_nearby_model.dart';
// import 'package:poketstore/view/home/view/home_screen/shop_product_screen/shop_product_screen.dart';
// import 'package:provider/provider.dart';

// class SearchWidget extends StatefulWidget {
//   final Function(List<dynamic>)? onHomeSearchResults; // Add this callback

//   const SearchWidget({super.key, this.onHomeSearchResults});

//   @override
//   State<SearchWidget> createState() => _SearchWidgetState();
// }

// class _SearchWidgetState extends State<SearchWidget> {
//   final TextEditingController _productSearchController =
//       TextEditingController();
//   final TextEditingController _shopSearchController = TextEditingController();
//   Timer? _debounce;

//   List<productSearch.ProductSearchModel> _productResults = [];
//   List<ShopNearbyModel> _shopResults = []; // Use ShopNearbyModel instead

//   String _activeSearchType = '';
//   String? _selectedState;
//   String? _selectedDistrict;
//   bool _isLocalLoading = false;

//   @override
//   void initState() {
//     super.initState();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Provider.of<StateController>(context, listen: false).fetchStates();
//     });

//     _productSearchController.addListener(() {
//       _startSearchDebounce("product");
//     });

//     _shopSearchController.addListener(() {
//       _startSearchDebounce("shop");
//     });
//   }

//   void _startSearchDebounce(String type) {
//     if (_debounce?.isActive ?? false) _debounce!.cancel();

//     if (!_isLocalLoading) {
//       setState(() {
//         _isLocalLoading = true;
//       });
//     }

//     _debounce = Timer(const Duration(milliseconds: 500), () {
//       _activeSearchType = type;

//       String productQuery = _productSearchController.text.trim();
//       String shopQuery = _shopSearchController.text.trim();

//       if (productQuery.isEmpty &&
//           shopQuery.isEmpty &&
//           _selectedDistrict == null) {
//         Provider.of<ProductSearchProvider>(
//           context,
//           listen: false,
//         ).clearSearchResults();
//         Provider.of<ShopSearchController>(context, listen: false).shops = [];

//         setState(() {
//           _productResults = [];
//           _shopResults = [];
//           _activeSearchType = '';
//           _isLocalLoading = false;
//         });

//         // Notify HomeScreen to clear search results
//         if (widget.onHomeSearchResults != null) {
//           widget.onHomeSearchResults!([]);
//         }
//       } else {
//         _performSearch(productQuery: productQuery, shopQuery: shopQuery);
//       }
//     });
//   }

//   Future<void> _performSearch({String? productQuery, String? shopQuery}) async {
//     final productProvider = Provider.of<ProductSearchProvider>(
//       context,
//       listen: false,
//     );
//     final shopProvider = Provider.of<ShopSearchController>(
//       context,
//       listen: false,
//     );

//     productProvider.errorMessage = '';
//     shopProvider.errorMessage = '';
//     productProvider.isLoading = true;
//     shopProvider.isLoading = true;

//     productProvider.notifyListeners();
//     shopProvider.notifyListeners();

//     try {
//       // 1. SEARCHING PRODUCTS
//       if ((productQuery ?? '').isNotEmpty) {
//         log(
//           "Performing Product Search with Query: $productQuery and District: $_selectedDistrict",
//         );

//         await productProvider.fetchSearchResults(
//           productQuery!,
//           _selectedDistrict ?? "",
//         );
//         _productResults = productProvider.searchResults;
//         _activeSearchType = "product";

//         // Convert product search results to shops
//         _convertProductResultsToShops();
//       }
//       // 2. SEARCHING SHOPS
//       else if ((shopQuery ?? '').isNotEmpty) {
//         log("Performing Shop Search with Query: $shopQuery");

//         await shopProvider.searchShopsWithPrefs(shopQuery!);
//         _activeSearchType = "shop";

//         // Convert shop search results to ShopNearbyModel format
//         _convertShopResults();
//       }
//       // 3. FILTERING BY DISTRICT ONLY
//       else if (_selectedDistrict != null && _selectedDistrict!.isNotEmpty) {
//         log("Performing District Filter for Products in: $_selectedDistrict");

//         await productProvider.fetchProductsByDistrict(_selectedDistrict!);
//         _productResults = productProvider.searchResults;
//         _activeSearchType = "product";

//         // Convert product search results to shops
//         _convertProductResultsToShops();
//       }
//       // 4. NO ACTIVE SEARCH
//       else {
//         log("No active search query or selected district.");
//         _productResults = [];
//         _shopResults = [];
//         _activeSearchType = '';
//       }

//       // Send results to HomeScreen
//       if (widget.onHomeSearchResults != null) {
//         widget.onHomeSearchResults!(_shopResults);
//       }
//     } catch (e) {
//       log("Search Error: $e");
//       if (e.toString().contains("400")) {
//         productProvider.errorMessage =
//             "Please enter a search term or select a location.";
//       } else {
//         productProvider.errorMessage = 'Failed to load results: $e';
//       }
//     } finally {
//       productProvider.isLoading = false;
//       shopProvider.isLoading = false;

//       setState(() {
//         _isLocalLoading = false;
//       });

//       productProvider.notifyListeners();
//       shopProvider.notifyListeners();
//     }
//   }

//   void _convertProductResultsToShops() {
//     final uniqueShops = <String, ShopNearbyModel>{};
//     for (var product in _productResults) {
//       if (!uniqueShops.containsKey(product.shop.id)) {
//         uniqueShops[product.shop.id] = ShopNearbyModel(
//           id: product.shop.id,
//           shopName: product.shop.shopName,
//           headerImage: product.shop.headerImage,
//           category: product.shop.category,
//           locality: product.shop.locality,
//           place: product.shop.place,
//           mobileNumber: product.shop.mobileNumber,
//           // Add other required fields as needed
//           subscription: null,
//         );
//       }
//     }
//     _shopResults = uniqueShops.values.toList();
//   }

//   void _convertShopResults() {
//     final shopProvider = Provider.of<ShopSearchController>(
//       context,
//       listen: false,
//     );
//     _shopResults =
//         shopProvider.shops.map((shop) {
//           return ShopNearbyModel(
//             id: shop.id ?? '',
//             shopName: shop.shopName ?? '',
//             headerImage: shop.headerImage,
//             category: shop.category ?? [],
//             locality: shop.locality ?? '',
//             place: shop.place ?? '',
//             // mobileNumber: shop.mobileNumber ?? '',
//             // Add other required fields as needed
//             subscription: null,
//           );
//         }).toList();
//   }

//   void _clearAll() {
//     _productSearchController.clear();
//     _shopSearchController.clear();

//     Provider.of<ProductSearchProvider>(
//       context,
//       listen: false,
//     ).clearSearchResults();
//     Provider.of<ShopSearchController>(context, listen: false).shops = [];

//     setState(() {
//       _productResults = [];
//       _shopResults = [];
//       _activeSearchType = '';
//       _isLocalLoading = false;
//     });

//     // Notify HomeScreen to clear search results
//     if (widget.onHomeSearchResults != null) {
//       widget.onHomeSearchResults!([]);
//     }

//     FocusScope.of(context).unfocus();
//   }

//   @override
//   void dispose() {
//     _debounce?.cancel();
//     _productSearchController.dispose();
//     _shopSearchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final productProvider = Provider.of<ProductSearchProvider>(context);
//     final shopProvider = Provider.of<ShopSearchController>(context);

//     List<dynamic> suggestions = [];

//     if (_productSearchController.text.trim().isNotEmpty &&
//         _activeSearchType == 'product' &&
//         _productResults.isNotEmpty) {
//       suggestions = [..._productResults];
//     } else if (_shopSearchController.text.trim().isNotEmpty &&
//         _activeSearchType == 'shop' &&
//         _shopResults.isNotEmpty) {
//       suggestions = [..._shopResults];
//     } else if (_productSearchController.text.trim().isEmpty &&
//         _shopSearchController.text.trim().isEmpty &&
//         _selectedDistrict != null &&
//         _selectedDistrict!.isNotEmpty) {
//       suggestions = [..._shopResults];
//     }

//     final bool isSearching =
//         (_productSearchController.text.isNotEmpty ||
//             _shopSearchController.text.isNotEmpty ||
//             _selectedDistrict != null) &&
//         !productProvider.isLoading &&
//         !shopProvider.isLoading;
//     final bool noResultsFound = isSearching && suggestions.isEmpty;

//     final bool showLoading =
//         _isLocalLoading || productProvider.isLoading || shopProvider.isLoading;

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           /// 🔹 STATE + DISTRICT
//           Container(
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: Colors.grey.shade300),
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Consumer<StateController>(
//                     builder: (_, stateCtrl, __) {
//                       return DropdownButtonHideUnderline(
//                         child: DropdownButton<String>(
//                           isExpanded: true,
//                           value: _selectedState,
//                           hint: const Padding(
//                             padding: EdgeInsets.symmetric(horizontal: 16),
//                             child: Text(
//                               'SELECT STATE',
//                               style: TextStyle(fontSize: 12),
//                             ),
//                           ),
//                           items:
//                               stateCtrl.statesList.map((state) {
//                                 return DropdownMenuItem(
//                                   value: state,
//                                   child: Padding(
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 16,
//                                     ),
//                                     child: Text(state),
//                                   ),
//                                 );
//                               }).toList(),
//                           onChanged: (String? val) {
//                             if (val == null) return;
//                             log("State selected: $val");

//                             setState(() {
//                               _selectedState = val;
//                               _selectedDistrict = null;
//                               _isLocalLoading = true;
//                             });

//                             Provider.of<DistrictController>(
//                               context,
//                               listen: false,
//                             ).fetchDistricts(val);
//                             _productResults = [];
//                             _shopResults = [];

//                             _performSearch(productQuery: "", shopQuery: "");
//                           },
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//                 Container(width: 1, height: 30, color: Colors.grey.shade300),
//                 Expanded(
//                   child: Consumer<DistrictController>(
//                     builder: (_, distCtrl, __) {
//                       String? districtValue =
//                           distCtrl.districtList.contains(_selectedDistrict)
//                               ? _selectedDistrict
//                               : null;

//                       return DropdownButtonHideUnderline(
//                         child: DropdownButton<String>(
//                           isExpanded: true,
//                           value: districtValue,
//                           hint: const Padding(
//                             padding: EdgeInsets.symmetric(horizontal: 16),
//                             child: Text(
//                               'SELECT DISTRICT',
//                               style: TextStyle(fontSize: 12),
//                             ),
//                           ),
//                           items:
//                               distCtrl.districtList.map((dist) {
//                                 return DropdownMenuItem(
//                                   value: dist,
//                                   child: Padding(
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 16,
//                                     ),
//                                     child: Text(dist),
//                                   ),
//                                 );
//                               }).toList(),
//                           onChanged: (String? val) {
//                             log("District selected: $val");

//                             setState(() {
//                               _selectedDistrict = val;
//                               _isLocalLoading = true;
//                             });

//                             _productResults = [];
//                             _shopResults = [];

//                             _performSearch(
//                               productQuery:
//                                   _productSearchController.text.trim(),
//                               shopQuery: _shopSearchController.text.trim(),
//                             );
//                           },
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 16),

//           /// 🔍 PRODUCT SEARCH
//           Container(
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: Colors.grey.shade300),
//             ),
//             child: TextField(
//               controller: _productSearchController,
//               decoration: InputDecoration(
//                 hintText: "Search products...",
//                 border: InputBorder.none,
//                 contentPadding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 12,
//                 ),
//                 prefixIcon: const Icon(Icons.search, color: Colors.grey),
//                 suffixIcon:
//                     _productSearchController.text.isNotEmpty
//                         ? IconButton(
//                           icon: const Icon(Icons.close, size: 20),
//                           onPressed: () {
//                             _productSearchController.clear();
//                             if (_shopSearchController.text.isEmpty &&
//                                 _selectedDistrict == null) {
//                               setState(() {
//                                 _productResults = [];
//                                 _shopResults = [];
//                                 _activeSearchType = '';
//                                 _isLocalLoading = false;
//                               });

//                               if (widget.onHomeSearchResults != null) {
//                                 widget.onHomeSearchResults!([]);
//                               }
//                             }
//                           },
//                         )
//                         : null,
//               ),
//             ),
//           ),

//           const SizedBox(height: 16),

//           /// 🔍 SHOP SEARCH
//           // Container(
//           //   decoration: BoxDecoration(
//           //     color: Colors.white,
//           //     borderRadius: BorderRadius.circular(8),
//           //     border: Border.all(color: Colors.grey.shade300),
//           //   ),
//           //   child: TextField(
//           //     controller: _shopSearchController,
//           //     decoration: InputDecoration(
//           //       hintText: "Search shops...",
//           //       border: InputBorder.none,
//           //       contentPadding: const EdgeInsets.symmetric(
//           //         horizontal: 16,
//           //         vertical: 12,
//           //       ),
//           //       prefixIcon: const Icon(Icons.store, color: Colors.grey),
//           //       suffixIcon:
//           //           _shopSearchController.text.isNotEmpty
//           //               ? IconButton(
//           //                 icon: const Icon(Icons.close, size: 20),
//           //                 onPressed: () {
//           //                   _shopSearchController.clear();
//           //                   if (_productSearchController.text.isEmpty &&
//           //                       _selectedDistrict == null) {
//           //                     setState(() {
//           //                       _productResults = [];
//           //                       _shopResults = [];
//           //                       _activeSearchType = '';
//           //                       _isLocalLoading = false;
//           //                     });

//           //                     if (widget.onHomeSearchResults != null) {
//           //                       widget.onHomeSearchResults!([]);
//           //                     }
//           //                   }
//           //                 },
//           //               )
//           //               : null,
//           //     ),
//           //   ),
//           // ),
//           if (showLoading) const LinearProgressIndicator(),

//           if (productProvider.errorMessage.isNotEmpty)
//             Builder(
//               builder: (_) {
//                 WidgetsBinding.instance.addPostFrameCallback((_) {
//                   _showAnimatedAlert(context, productProvider.errorMessage);
//                   Provider.of<ProductSearchProvider>(context, listen: false)
//                       .errorMessage = "";
//                 });
//                 return const SizedBox.shrink();
//               },
//             ),

//           if (noResultsFound)
//             const Padding(
//               padding: EdgeInsets.only(top: 8.0),
//               child: Text(
//                 '',
//                 style: TextStyle(
//                   fontStyle: FontStyle.italic,
//                   color: Colors.grey,
//                 ),
//               ),
//             ),

//           /// 🔹 RESULTS (This part remains in SearchWidget for inline results)
//           if (suggestions.isNotEmpty)
//             Padding(
//               padding: const EdgeInsets.only(top: 8.0),
//               child: ConstrainedBox(
//                 constraints: BoxConstraints(
//                   maxHeight: MediaQuery.of(context).size.height * 0.4,
//                 ),
//                 child: ListView.builder(
//                   shrinkWrap: true,
//                   padding: EdgeInsets.zero,
//                   itemCount: suggestions.length,
//                   itemBuilder: (_, index) {
//                     final item = suggestions[index];

//                     if (item is productSearch.ProductSearchModel) {
//                       return _buildProductCard(item);
//                     }

//                     if (item is ShopNearbyModel) {
//                       return _buildShopCard(item);
//                     }

//                     return const SizedBox.shrink();
//                   },
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   void _showAnimatedAlert(BuildContext context, String message) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) {
//         Future.delayed(const Duration(seconds: 2), () {
//           if (Navigator.canPop(context)) {
//             Navigator.pop(context);
//           }
//         });

//         return StatefulBuilder(
//           builder: (context, setState) {
//             AnimationController controller = AnimationController(
//               vsync: Navigator.of(context),
//               duration: const Duration(seconds: 2),
//             )..forward();

//             return ScaleTransition(
//               scale: CurvedAnimation(
//                 parent: controller,
//                 curve: Curves.easeOutBack,
//               ),
//               child: AlertDialog(
//                 backgroundColor: Colors.red.shade50,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 content: Row(
//                   children: [
//                     const Icon(
//                       Icons.error_outline,
//                       color: Colors.red,
//                       size: 32,
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Text(
//                         message,
//                         style: TextStyle(
//                           color: Colors.red.shade800,
//                           fontWeight: FontWeight.w600,
//                           fontSize: 14,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   Widget _buildProductCard(productSearch.ProductSearchModel product) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 8),
//       elevation: 1,
//       child: ListTile(
//         contentPadding: const EdgeInsets.all(12),
//         leading: ClipRRect(
//           borderRadius: BorderRadius.circular(8),
//           child: Image.network(
//             product.productImage,
//             width: 50,
//             height: 50,
//             fit: BoxFit.cover,
//             errorBuilder:
//                 (_, __, ___) => Container(
//                   width: 50,
//                   height: 50,
//                   decoration: BoxDecoration(
//                     color: Colors.orange.shade50,
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: const Icon(
//                     Icons.image_not_supported,
//                     color: Colors.orange,
//                   ),
//                 ),
//           ),
//         ),
//         title: Text(
//           product.name,
//           style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 4),
//             Text(
//               "by ${product.shop.shopName}",
//               style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
//             ),
//             const SizedBox(height: 4),
//             Row(
//               children: [
//                 Icon(
//                   Icons.location_on_outlined,
//                   size: 14,
//                   color: Colors.grey.shade500,
//                 ),
//                 const SizedBox(width: 4),
//                 Text(
//                   "${product.shop.locality}",
//                   style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
//                 ),
//               ],
//             ),
//           ],
//         ),
//         trailing: const Icon(Icons.chevron_right, color: Colors.grey),
//         onTap: () {
//           _clearAll();
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder:
//                   (_) => ShopProductsScreen(
//                     shop: addShop.ShopModel(
//                       id: product.shop.id,
//                       shopName: product.shop.shopName,
//                       headerImage: product.shop.headerImage,
//                       mobileNumber: product.shop.mobileNumber,
//                       place: product.shop.place,
//                       category: product.shop.category,
//                       sellerType: product.shop.sellerType,
//                       state: product.shop.state,
//                       locality: product.shop.locality,
//                       pinCode: product.shop.pinCode,
//                       email: product.shop.email,
//                       landlineNumber: product.shop.landlineNumber,
//                       isBanned: product.shop.isBanned,
//                       agentCode: product.shop.agentCode,
//                       registeredBySalesman: null,
//                       isVerified: product.shop.isVerified,
//                     ),
//                   ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildShopCard(ShopNearbyModel shop) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 8),
//       elevation: 1,
//       child: ListTile(
//         contentPadding: const EdgeInsets.all(12),
//         leading: Container(
//           width: 50,
//           height: 50,
//           decoration: BoxDecoration(
//             color: Colors.blue.shade50,
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: const Icon(Icons.storefront, color: Colors.blue),
//         ),
//         title: Text(
//           shop.shopName ?? '',
//           style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 4),
//             Text(
//               "Shop",
//               style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
//             ),
//             const SizedBox(height: 4),
//             Row(
//               children: [
//                 Icon(
//                   Icons.location_on_outlined,
//                   size: 14,
//                   color: Colors.grey.shade500,
//                 ),
//                 const SizedBox(width: 4),
//                 Text(
//                   shop.locality.toString().isNotEmpty
//                       ? shop.locality.toString()
//                       : (shop.place?.isNotEmpty == true
//                           ? shop.place!
//                           : 'Unknown location'),
//                   style: const TextStyle(
//                     color: Color.fromARGB(255, 7, 3, 201),
//                     fontSize: 12,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//         trailing: const Icon(Icons.chevron_right, color: Colors.grey),
//         onTap: () {
//           _clearAll();
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder:
//                   (_) => ShopProductsScreen(
//                     shop: addShop.ShopModel(
//                       id: shop.id ?? '',
//                       shopName: shop.shopName ?? '',
//                       headerImage: shop.headerImage,
//                       mobileNumber: shop.mobileNumber ?? '',
//                       place: shop.place ?? '',
//                       category: shop.category ?? [],
//                       sellerType: '',
//                       state: '',
//                       locality: shop.locality.toString(),
//                       pinCode: '',
//                       email: '',
//                       landlineNumber: '',
//                       isBanned: false,
//                       agentCode: '',
//                       registeredBySalesman: null,
//                       isVerified: false,
//                     ),
//                   ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
