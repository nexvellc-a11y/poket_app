import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final IconData icon;
  final String imagePath;
  final String title;
  final String weight;
  final dynamic price;

  const ProductCard({
    super.key,
    required this.icon,
    required this.imagePath,
    required this.title,
    required this.weight,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: Colors.black12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image section
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              imagePath.isNotEmpty
                  ? imagePath
                  : 'https://via.placeholder.com/150',
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          // Content section
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (weight.isNotEmpty)
                  Text(
                    weight,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${price ?? 'N/A'}",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    // Container(
                    //   padding: const EdgeInsets.all(6),
                    //   decoration: BoxDecoration(
                    //     color: Colors.black,
                    //     borderRadius: BorderRadius.circular(8),
                    //   ),
                    //   child: Icon(icon, size: 18, color: Colors.white),
                    // ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
