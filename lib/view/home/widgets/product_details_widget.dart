import 'package:flutter/material.dart';

/// Custom Method to Build Quantity Buttons
Widget buildQuantityButton(IconData icon) {
  return Container(
    height: 30,
    width: 30,
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.shade300, width: 1),
      borderRadius: BorderRadius.circular(5),
    ),
    child: Center(child: Icon(icon, size: 18, color: Colors.black)),
  );
}

/// Custom Method for Expandable Sections  IconData icon
Widget buildExpandableSection(String title) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        // Icon(icon, color: Colors.black),
      ],
    ),
  );
}

/// Custom Method for Rows with an Arrow
Widget buildRowWithArrow(String title, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            Text(value, style: TextStyle(color: Colors.grey)),
            SizedBox(width: 5),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
          ],
        ),
      ],
    ),
  );
}

/// Custom Method for Rows with Stars
Widget buildRowWithStars(String title, int starCount) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Row(
          children: List.generate(
            starCount,
            (index) => Icon(Icons.star, color: Colors.orange, size: 18),
          ),
        ),
      ],
    ),
  );
}
