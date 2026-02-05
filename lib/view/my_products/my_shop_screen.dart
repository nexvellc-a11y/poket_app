// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:poketstore/model/my_shope_model/my_shop_list_user_model.dart';
// import 'package:poketstore/utilities/custom_app_bar.dart';
// import 'package:poketstore/utilities/no_data_warning.dart';
// import 'package:poketstore/view/my_products/product_details_screen.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:poketstore/controllers/my_shope_controller/my_shop_list_user_controller.dart';
// import 'package:poketstore/view/add_shop/add_shop.dart';
// import 'package:poketstore/view/my_products/add_product_screen.dart';
// import 'package:poketstore/view/my_products/widget/widget.dart'; // Correct import for MyShopProductDetails

// class MyShopScreen extends StatefulWidget {
//   const MyShopScreen({super.key});

//   @override
//   State<MyShopScreen> createState() => _MyShopScreenState();
// }

// class _MyShopScreenState extends State<MyShopScreen> {
//   String? _userId;
//   // ignore: unused_field
//   bool _isLoading = true;
//   final TextEditingController _searchController = TextEditingController();
//   List<Map<String, dynamic>> _filteredProducts = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadUserIdAndShops();
//     _searchController.addListener(_filterProducts);
//   }

//   @override
//   void dispose() {
//     _searchController.removeListener(_filterProducts);
//     _searchController.dispose();
//     super.dispose();
//   }

//   void _showAddDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return Dialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Icon(Icons.info, size: 50, color: Colors.blueAccent),
//                 const SizedBox(height: 15),
//                 const Text(
//                   "Notice",
//                   style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 10),
//                 const Text(
//                   "If you have a store, continue adding a product.\nOtherwise, create one by clicking 'Create'.",
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 20),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: TextButton(
//                         style: TextButton.styleFrom(
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                           backgroundColor: Colors.grey[300],
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                         ),
//                         onPressed: () => Navigator.pop(context),
//                         child: const Text(
//                           "Cancel",
//                           style: TextStyle(color: Colors.black),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     Expanded(
//                       child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                           backgroundColor: Colors.blueAccent,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                         ),
//                         onPressed: () {
//                           Navigator.pop(context);
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => const AddProductScreen(),
//                             ),
//                           ).then((value) {
//                             if (value == true) _loadUserShops();
//                           });
//                         },
//                         child: const Text("Continue"),
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     Expanded(
//                       child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                           backgroundColor: Colors.green,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                         ),
//                         onPressed: () {
//                           Navigator.pop(context);
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(builder: (_) => const AddShop()),
//                           );
//                         },
//                         child: const Text("Create"),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Future<void> _loadUserIdAndShops() async {
//     final prefs = await SharedPreferences.getInstance();
//     _userId = prefs.getString('userId');
//     if (_userId != null) {
//       await _loadUserShops();
//     } else {
//       setState(() => _isLoading = false);
//     }
//   }

//   Future<void> _loadUserShops() async {
//     if (_userId != null) {
//       final provider = Provider.of<MyShopListUserProvider>(
//         context,
//         listen: false,
//       );
//       await provider.fetchUserShopList(_userId!);
//       if (provider.shopList.isNotEmpty) {
//         _processShopData(provider.shopList);
//       } else {
//         // If shopList is empty, clear products as well
//         provider.allProductsWithShopName.clear();
//         _filteredProducts.clear();
//       }
//     }
//     setState(() => _isLoading = false);
//   }

//   void _processShopData(List<ShopData> shopList) {
//     final provider = Provider.of<MyShopListUserProvider>(
//       context,
//       listen: false,
//     );
//     provider.allProductsWithShopName.clear();
//     for (var shop in shopList) {
//       for (var product in shop.products) {
//         provider.allProductsWithShopName.add({
//           "_id": product.id,
//           "image":
//               (product.productImage?.isNotEmpty ?? false)
//                   ? product.productImage
//                   : "https://via.placeholder.com/150",
//           "name": product.name,
//           "weight": product.productType ?? "N/A",
//           "price":
//               "₹${(product.price != null && product.price! > 0) ? product.price : 'N/A'}",
//           "shopName": shop.shopName,
//         });
//       }
//     }
//     _filteredProducts = List.from(provider.allProductsWithShopName);
//   }

//   void _filterProducts() {
//     String query = _searchController.text.toLowerCase();
//     setState(() {
//       final provider = Provider.of<MyShopListUserProvider>(
//         context,
//         listen: false,
//       );
//       _filteredProducts =
//           provider.allProductsWithShopName.where((product) {
//             return (product["name"] as String).toLowerCase().contains(query) ||
//                 (product["shopName"] as String).toLowerCase().contains(query);
//           }).toList();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<MyShopListUserProvider>(
//       context,
//       listen: false,
//     );
//     return SafeArea(
//       child: Scaffold(
//         appBar: CustomAppBar(title: "My Products"),
//         body:
//             provider.isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : Column(
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.all(8.0), // Added padding here
//                       child: TextField(
//                         controller: _searchController,
//                         decoration: InputDecoration(
//                           hintText: 'Search products or shop names...',
//                           prefixIcon: const Icon(Icons.search),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10.0),
//                           ),
//                           filled: true,
//                           fillColor: Colors.white,
//                         ),
//                       ),
//                     ),
//                     Expanded(
//                       child: Consumer<MyShopListUserProvider>(
//                         builder: (context, provider, child) {
//                           if (_userId == null) {
//                             return const Center(
//                               child: Text(
//                                 "Please log in to view your shops and products.",
//                               ),
//                             );
//                           }

//                           if (provider.isLoading &&
//                               provider.allProductsWithShopName.isEmpty) {
//                             return const Center(
//                               child: CircularProgressIndicator(),
//                             );
//                           } else if (provider.error != null) {
//                             log(
//                               "Error loading product data: ${provider.error!}",
//                             );
//                             return const Center(
//                               child: Text(
//                                 "No Products Available , Add Your Products.",
//                               ),
//                             );
//                           } else if (_filteredProducts.isEmpty &&
//                               _searchController.text.isNotEmpty) {
//                             return const Center(
//                               child: Text(
//                                 "No products or shops found matching your search.",
//                               ),
//                             );
//                           } else if (provider.allProductsWithShopName.isEmpty) {
//                             return const Center(
//                               child: AnimatedNoDataMessage(
//                                 titleText: "No Products available yet!",
//                                 subtitleText: "Add Your product !!!.",
//                               ),
//                             );
//                           }

//                           return productMyShopeGridView(
//                             _filteredProducts,
//                             onProductTap: (productId) async {
//                               final bool? result = await Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder:
//                                       (context) => MyShopProductDetails(
//                                         productId: productId,
//                                       ),
//                                 ),
//                               );
//                               if (result == true) {
//                                 _loadUserShops();
//                               }
//                             },
//                           );
//                         },
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(15),
//                       child: GestureDetector(
//                         onTap: () => _showAddDialog(context),
//                         child: Container(
//                           height: 50,
//                           width: double.infinity,
//                           decoration: BoxDecoration(
//                             color: const Color.fromARGB(255, 7, 3, 201),
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: const Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Text(
//                                 'Add Product',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               Icon(Icons.add, color: Colors.white),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//       ),
//     );
//   }

//   // void _showAddDialog(BuildContext context) {
//   //   showDialog(
//   //     context: context,
//   //     builder: (context) {
//   //       return Dialog(
//   //         shape: RoundedRectangleBorder(
//   //           borderRadius: BorderRadius.circular(16),
//   //         ),
//   //         child: Padding(
//   //           padding: const EdgeInsets.all(20),
//   //           child: Column(
//   //             mainAxisSize: MainAxisSize.min,
//   //             children: [
//   //               const Icon(Icons.info, size: 50, color: Colors.blueAccent),
//   //               const SizedBox(height: 15),
//   //               const Text(
//   //                 "Notice",
//   //                 style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//   //               ),
//   //               const SizedBox(height: 10),
//   //               const Text(
//   //                 "If you have a store, continue adding a product.\nOtherwise, create one by clicking 'Create'.",
//   //                 textAlign: TextAlign.center,
//   //               ),
//   //               const SizedBox(height: 20),
//   //               Row(
//   //                 children: [
//   //                   Expanded(
//   //                     child: TextButton(
//   //                       style: TextButton.styleFrom(
//   //                         padding: const EdgeInsets.symmetric(vertical: 12),
//   //                         backgroundColor: Colors.grey[300],
//   //                         shape: RoundedRectangleBorder(
//   //                           borderRadius: BorderRadius.circular(10),
//   //                         ),
//   //                       ),
//   //                       onPressed: () => Navigator.pop(context),
//   //                       child: const Text(
//   //                         "Cancel",
//   //                         style: TextStyle(color: Colors.black),
//   //                       ),
//   //                     ),
//   //                   ),
//   //                   const SizedBox(width: 10),
//   //                   Expanded(
//   //                     child: ElevatedButton(
//   //                       style: ElevatedButton.styleFrom(
//   //                         padding: const EdgeInsets.symmetric(vertical: 12),
//   //                         backgroundColor: Colors.blueAccent,
//   //                         shape: RoundedRectangleBorder(
//   //                           borderRadius: BorderRadius.circular(10),
//   //                         ),
//   //                       ),
//   //                       onPressed: () {
//   //                         Navigator.pop(context);
//   //                         Navigator.push(
//   //                           context,
//   //                           MaterialPageRoute(
//   //                             builder: (_) => const AddProductScreen(shopId:,),
//   //                           ),
//   //                         ).then((value) {
//   //                           if (value == true) _loadUserShops();
//   //                         });
//   //                       },
//   //                       child: const Text("Continue"),
//   //                     ),
//   //                   ),
//   //                   const SizedBox(width: 10),
//   //                   Expanded(
//   //                     child: ElevatedButton(
//   //                       style: ElevatedButton.styleFrom(
//   //                         padding: const EdgeInsets.symmetric(vertical: 12),
//   //                         backgroundColor: Colors.green,
//   //                         shape: RoundedRectangleBorder(
//   //                           borderRadius: BorderRadius.circular(10),
//   //                         ),
//   //                       ),
//   //                       onPressed: () {
//   //                         Navigator.pop(context);
//   //                         Navigator.push(
//   //                           context,
//   //                           MaterialPageRoute(builder: (_) => const AddShop()),
//   //                         );
//   //                       },
//   //                       child: const Text("Create"),
//   //                     ),
//   //                   ),
//   //                 ],
//   //               ),
//   //             ],
//   //           ),
//   //         ),
//   //       );
//   //     },
//   //   );
//   // }
// }
