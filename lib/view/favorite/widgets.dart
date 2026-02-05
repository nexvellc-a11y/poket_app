// import 'package:flutter/material.dart';
// import 'package:poketstore/model/cart_model/fetch_cart_model.dart';

// class CartItemWidget extends StatelessWidget {
//   final FetchCartItem item;

//   const CartItemWidget({super.key, required this.item});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.shade200,
//             blurRadius: 8,
//             spreadRadius: 2,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           // Product image
//           ClipRRect(
//             borderRadius: BorderRadius.circular(12),
//             child: Image.network(
//               item.product.productImage ?? '',
//               width: 90,
//               height: 90,
//               fit: BoxFit.cover,
//               errorBuilder:
//                   (context, error, stackTrace) => Container(
//                     width: 90,
//                     height: 90,
//                     color: Colors.grey.shade200,
//                     child: const Icon(
//                       Icons.image_not_supported,
//                       size: 40,
//                       color: Colors.grey,
//                     ),
//                   ),
//             ),
//           ),
//           const SizedBox(width: 16),
//           // Product info
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   item.product.name ?? 'Unnamed Product',
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//                 Text(
//                   "₹ ${item.totalAmount?.toStringAsFixed(2) ?? '0.00'}",
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF2E7D32), // greenish price tag
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 10,
//                     vertical: 4,
//                   ),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFE3F2FD),
//                     borderRadius: BorderRadius.circular(6),
//                   ),
//                   child: Text(
//                     'Qty: ${item.quantity ?? 0}',
//                     style: const TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w500,
//                       color: Color(0xFF1976D2),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
