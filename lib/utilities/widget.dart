// // Add this widget to your UI where you display the error
// import 'package:flutter/material.dart';
// import 'package:poketstore/controllers/my_shope_controller/add_product_controller.dart';
// import 'package:poketstore/view/subscription/subscription.dart';
// // Add this widget to your UI where you display the error

// Widget _buildSubscriptionError(
//   BuildContext context,
//   ProductProvider controller,
// ) {
//   if (controller.errorMessage != null &&
//       controller.shopIdForSubscription != null) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 16.0),
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Expanded(
//                 child: Text(
//                   controller.errorMessage!,
//                   style: TextStyle(color: Colors.red, fontSize: 16),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//               SizedBox(width: 8),
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder:
//                           (context) => SubscriptionScreen(
//                             shopId: controller.shopIdForSubscription!,
//                           ),
//                     ),
//                   );
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue, // Button background color
//                   foregroundColor: Colors.white, // Button text color
//                 ),
//                 child: Text('Subscribe'),
//               ),
//             ],
//           ),
//           SizedBox(height: 8),
//           Text(
//             'You need an active subscription to add products',
//             style: TextStyle(color: Colors.grey[600], fontSize: 14),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   } else if (controller.errorMessage != null) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 16.0),
//       child: Text(
//         controller.errorMessage!,
//         style: TextStyle(color: Colors.red, fontSize: 16),
//         textAlign: TextAlign.center,
//       ),
//     );
//   }
//   return SizedBox.shrink();
// }
