// import 'package:flutter/material.dart';
// import 'package:poketstore/utilities/custom_app_bar.dart';
// import 'package:provider/provider.dart';
// import 'package:poketstore/controllers/favorite_controller/favorite_controller.dart';

// class FavoriteScreen extends StatefulWidget {
//   const FavoriteScreen({super.key});

//   @override
//   State<FavoriteScreen> createState() => _FavoriteScreenState();
// }

// class _FavoriteScreenState extends State<FavoriteScreen>
//     with WidgetsBindingObserver {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     _fetchFavorites();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     super.didChangeAppLifecycleState(state);
//     if (state == AppLifecycleState.resumed) {
//       _fetchFavorites();
//     }
//   }

//   void _fetchFavorites() {
//     Provider.of<FavoriteProvider>(context, listen: false).fetchFavorites();
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar(title: "My Favorites"),
//       // PreferredSize(
//       //   preferredSize: const Size.fromHeight(60),
//       //   child: AppBar(
//       //     backgroundColor: const Color.fromARGB(255, 7, 3, 201),
//       //     shape: const RoundedRectangleBorder(
//       //       borderRadius: BorderRadius.vertical(
//       //         bottom: Radius.circular(20),
//       //       ),
//       //     ),
//       //     title: const Text(
//       //       'My Favorites',
//       //       style: TextStyle(color: Colors.white),
//       //     ),
//       //     iconTheme: const IconThemeData(color: Colors.white),
//       //   ),
//       // ),
//       body: Consumer<FavoriteProvider>(
//         builder: (context, controller, child) {
//           if (controller.isLoading) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (controller.errorMessage.isNotEmpty) {
//             return Center(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Text(
//                   'Error loading favorites: ${controller.errorMessage}',
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(color: Colors.red),
//                 ),
//               ),
//             );
//           }

//           if (controller.favorites.isEmpty) {
//             return const Center(child: Text("No favorites added yet."));
//           }

//           return ListView.builder(
//             itemCount: controller.favorites.length,
//             itemBuilder: (context, index) {
//               final item = controller.favorites[index];
//               return Card(
//                 margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 child: ListTile(
//                   leading: Image.network(
//                     item.productImage,
//                     width: 50,
//                     height: 50,
//                     fit: BoxFit.cover,
//                     errorBuilder:
//                         (context, error, stackTrace) =>
//                             const Icon(Icons.broken_image, size: 50),
//                   ),
//                   title: Text(item.name),
//                   subtitle: Text(item.description),
//                   trailing: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Text('₹${item.price}'),
//                       const SizedBox(width: 8),
//                       IconButton(
//                         icon: const Icon(Icons.delete, color: Colors.redAccent),
//                         onPressed: () async {
//                           await controller.removeFromFavorite(item.id);
//                           if (controller.errorMessage.isEmpty) {
//                             // ignore: use_build_context_synchronously
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                 content: Text('Removed from favorites'),
//                               ),
//                             );
//                           } else {
//                             // ignore: use_build_context_synchronously
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(
//                                 content: Text(
//                                   'Failed to remove favorite: ${controller.errorMessage}',
//                                 ),
//                               ),
//                             );
//                           }
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
