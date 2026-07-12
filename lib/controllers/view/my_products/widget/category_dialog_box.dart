// import 'package:flutter/material.dart';
// import 'package:poketstore/model/category_model/category_model.dart';

// class CategorySelectionDialog extends StatefulWidget {
//   final List<Category> categories;
//   final List<String> selectedCategories;

//   const CategorySelectionDialog({
//     required this.categories,
//     required this.selectedCategories,
//     super.key,
//   });

//   @override
//   _CategorySelectionDialogState createState() =>
//       _CategorySelectionDialogState();
// }

// class _CategorySelectionDialogState extends State<CategorySelectionDialog> {
//   late Set<String> tempSelected;

//   @override
//   void initState() {
//     super.initState();
//     tempSelected = Set.from(widget.selectedCategories);
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Optional: Sort categories alphabetically
//     final sortedCategories = [...widget.categories]
//       ..sort((a, b) => a.name.compareTo(b.name));

//     return AlertDialog(
//       title: const Text("Select Categories"),
//       content: SizedBox(
//         width: double.maxFinite,
//         child: ListView(
//           shrinkWrap: true,
//           children:
//               sortedCategories.map((category) {
//                 return CheckboxListTile(
//                   title: Text(category.name),
//                   value: tempSelected.contains(category.name),
//                   onChanged: (bool? selected) {
//                     setState(() {
//                       if (selected == true) {
//                         tempSelected.add(category.name);
//                       } else {
//                         tempSelected.remove(category.name);
//                       }
//                     });
//                   },
//                 );
//               }).toList(),
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: const Text("Cancel"),
//         ),
//         ElevatedButton(
//           onPressed: () => Navigator.pop(context, tempSelected.toList()),
//           child: const Text("OK"),
//         ),
//       ],
//     );
//   }
// }
