import 'package:flutter/material.dart';
import 'package:poketstore/controllers/shop_of_user_controller/shop_of_user_controller.dart';
import 'package:poketstore/model/add_shope_model/add_shop_model.dart';
import 'package:poketstore/utilities/custom_app_bar.dart';
import 'package:poketstore/view/add_shop/add_shop.dart';
import 'package:poketstore/view/add_shop/shop_under_product_screen.dart';
import 'package:poketstore/utilities/no_data_warning.dart';
import 'package:provider/provider.dart';

class ShopListScreen extends StatefulWidget {
  const ShopListScreen({super.key});

  @override
  State<ShopListScreen> createState() => _ShopListScreenState();
}

class _ShopListScreenState extends State<ShopListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ShopOfUserProvider>(context, listen: false).fetchUserShops();
    });
  }

  @override
  Widget build(BuildContext context) {
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
        appBar: CustomAppBar(title: "My Shops", showBackButton: false),
        body: Container(
          // decoration: const BoxDecoration(
          //   gradient: LinearGradient(
          //     begin: Alignment.topCenter,
          //     end: Alignment.bottomCenter,
          //     colors: [Color(0xFF0703C9), Colors.white],
          //   ),
          // ),
          child: Column(
            children: [
              // Search bar
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              //   child: TextField(
              //     decoration: InputDecoration(
              //       hintText: "Search products or shop names...",
              //       prefixIcon: Icon(Icons.search),
              //       border: OutlineInputBorder(
              //         borderRadius: BorderRadius.circular(12),
              //       ),
              //       contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              //     ),
              //   ),
              // ),

              // Grid content
              Expanded(
                child: Consumer<ShopOfUserProvider>(
                  builder: (context, shopProvider, _) {
                    if (shopProvider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (shopProvider.shopList.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: () => shopProvider.fetchUserShops(),
                        child: Center(
                          child: SingleChildScrollView(
                            physics: AlwaysScrollableScrollPhysics(),
                            child: AnimatedNoDataMessage(
                              titleText: "No shops available yet!",
                              subtitleText: "Add Your Shop !!!.",
                            ),
                            // Container(
                            //   decoration: BoxDecoration(
                            //     color:
                            //         Colors
                            //             .blue
                            //             .shade50, // A very light blue background
                            //     border: Border.all(
                            //       color:
                            //           Colors
                            //               .blue
                            //               .shade300, // A nice, soft blue border
                            //       width: 2,
                            //     ),
                            //     borderRadius: BorderRadius.circular(
                            //       10,
                            //     ), // Rounded corners
                            //   ),
                            //   padding: const EdgeInsets.all(20),
                            //   child: Column(
                            //     mainAxisSize:
                            //         MainAxisSize
                            //             .min, // Make the column size to its content
                            //     children: [
                            //       Icon(
                            //         Icons
                            //             .store_mall_directory_outlined, // A shop icon
                            //         color: Colors.blue.shade700,
                            //         size: 50,
                            //       ),
                            //       const SizedBox(height: 10), // Spacing
                            //       const Text(
                            //         "No shops available.",
                            //         style: TextStyle(
                            //           fontSize: 18,
                            //           fontWeight: FontWeight.bold,
                            //           color: Colors.black87,
                            //         ),
                            //         textAlign: TextAlign.center,
                            //       ),
                            //       const SizedBox(height: 5), // Spacing
                            //       const Text(
                            //         "Tap '+' to add your first shop!",
                            //         style: TextStyle(
                            //           fontSize: 16,
                            //           color: Colors.black54,
                            //         ),
                            //         textAlign: TextAlign.center,
                            //       ),
                            //     ],
                            //   ),
                            // ),
                            // Text(
                            //   "No shops available. Tap '+' to add your first shop!",
                            //   style: TextStyle(fontSize: 16, color: Colors.black),
                            //   textAlign: TextAlign.center,
                            // ),
                          ),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () => shopProvider.fetchUserShops(),
                      child: GridView.builder(
                        padding: const EdgeInsets.all(10),
                        itemCount: shopProvider.shopList.length,
                        // Adjust crossAxisCount and childAspectRatio for a wider, list-like appearance
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              // Using 1 for a list-like appearance in a GridView
                              crossAxisCount: 1,
                              // Adjust aspect ratio to make the card flat (wide and short)
                              childAspectRatio: 3.5,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                        itemBuilder: (context, index) {
                          final shop = shopProvider.shopList[index];
                          return InkWell(
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => ShopDetailsWithProductsScreen(
                                        shop: ShopModel(
                                          id: shop.id,
                                          shopName: shop.shopName,
                                          headerImage: shop.headerImage,
                                          place: shop.place,
                                        ),
                                      ),
                                ),
                              );
                              if (result == true) {
                                shopProvider.fetchUserShops();
                              }
                            },
                            child: Card(
                              // Use Card for the elevated, rounded effect
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              color:
                                  Colors.white, // Light purple background color
                              elevation: 2, // Add some shadow
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 12.0,
                                ),
                                child: Row(
                                  children: [
                                    // Shop Icon (Left side)
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child:
                                          shop.headerImage != null &&
                                                  shop.headerImage!.isNotEmpty
                                              ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Image.network(
                                                  shop.headerImage!,
                                                  width: 24,
                                                  height: 24,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) {
                                                    // Fallback icon if image fails to load
                                                    return const Icon(
                                                      Icons.storefront_outlined,
                                                      color: Color(0xFF6750A4),
                                                      size: 24,
                                                    );
                                                  },
                                                  loadingBuilder: (
                                                    context,
                                                    child,
                                                    loadingProgress,
                                                  ) {
                                                    if (loadingProgress == null)
                                                      return child;
                                                    return const SizedBox(
                                                      width: 24,
                                                      height: 24,
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        valueColor:
                                                            AlwaysStoppedAnimation(
                                                              Color(0xFF6750A4),
                                                            ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              )
                                              : const Icon(
                                                Icons.storefront_outlined,
                                                color: Color(0xFF6750A4),
                                                size: 24,
                                              ),
                                    ),
                                    const SizedBox(width: 16),
                                    // Text Content (Right side)
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            shop.shopName, // Abcd
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color:
                                                  Colors
                                                      .black, // Dark text color
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const Text(
                                            "Shop", // "Shop" label
                                            style: TextStyle(
                                              fontSize: 14,
                                              color:
                                                  Colors
                                                      .black54, // Lighter gray for secondary text
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          // Row(
                                          //   children: [
                                          //     const Icon(
                                          //       Icons.location_on_outlined,
                                          //       color: Color(
                                          //         0xFF6750A4,
                                          //       ), // Purple location icon
                                          //       size: 16,
                                          //     ),
                                          //     const SizedBox(width: 4),
                                          // Text(
                                          //   // Ternary operator to display "Unknown location" if shop.place is null/empty
                                          //   shop.place.isNotEmpty
                                          //       ? shop.place
                                          //       : "Unknown location",
                                          //   style: const TextStyle(
                                          //     fontSize: 12,
                                          //     color: Color.fromARGB(
                                          //       255,
                                          //       7,
                                          //       3,
                                          //       201,
                                          //     ), // Purple text color for location
                                          //     fontWeight: FontWeight.bold,
                                          //   ),
                                          //   maxLines: 1,
                                          //   overflow: TextOverflow.ellipsis,
                                          // ),
                                          //   ],
                                          // ),
                                        ],
                                      ),
                                    ),
                                    // Arrow (Far right)
                                    const Icon(
                                      Icons.chevron_right,
                                      color: Colors.black54,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(15),
                child: GestureDetector(
                  onTap: () async {
                    final bool? didAddShop = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddShop()),
                    );
                    if (didAddShop == true) {
                      Provider.of<ShopOfUserProvider>(
                        // ignore: use_build_context_synchronously
                        context,
                        listen: false,
                      ).fetchUserShops();
                    }
                  },
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 84, 82, 204),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Add Shop',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(Icons.add, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // // Two buttons at the bottom
        // floatingActionButton: Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: [
        //       Expanded(
        //         child: SizedBox(
        //           height: 40,
        //           child: ElevatedButton.icon(
        //             onPressed: () async {
        //               final bool? didAddShop = await Navigator.push(
        //                 context,
        //                 MaterialPageRoute(builder: (_) => const AddShop()),
        //               );
        //               if (didAddShop == true) {
        //                 Provider.of<ShopOfUserProvider>(
        //                   context,
        //                   listen: false,
        //                 ).fetchUserShops();
        //               }
        //             },
        //             icon: const Icon(Icons.store, color: Colors.white),
        //             label: const Text(
        //               "Add New Shop",
        //               style: TextStyle(color: Colors.white, fontSize: 13),
        //             ),
        //             style: ElevatedButton.styleFrom(
        //               backgroundColor: const Color.fromARGB(255, 7, 3, 201),
        //               shape: RoundedRectangleBorder(
        //                 borderRadius: BorderRadius.circular(30),
        //               ),
        //               elevation: 0,
        //             ),
        //           ),
        //         ),
        //       ),
        //       const SizedBox(width: 16),
        //       Expanded(
        //         child: SizedBox(
        //           height: 40,
        //           child: ElevatedButton.icon(
        //             onPressed: () {
        //               Navigator.push(
        //                 context,
        //                 MaterialPageRoute(builder: (_) => const MyShopScreen()),
        //               );
        //             },
        //             icon: const Icon(
        //               Icons.add_shopping_cart,
        //               color: Colors.white,
        //             ),
        //             label: const Text(
        //               "Add Product",
        //               style: TextStyle(color: Colors.white, fontSize: 13),
        //             ),
        //             style: ElevatedButton.styleFrom(
        //               backgroundColor: Colors.green,
        //               shape: RoundedRectangleBorder(
        //                 borderRadius: BorderRadius.circular(30),
        //               ),
        //               elevation: 0,
        //             ),
        //           ),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
        // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
