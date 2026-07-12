import 'package:flutter/material.dart';
import 'package:poketstore/utilities/search_bar.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Back Button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FF),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF696FDD).withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Color(0xFF696FDD),
                        size: 20,
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Title Section
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Search",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Find products, shops & more",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Filter Button
                  // GestureDetector(
                  //   onTap: () {
                  //     // TODO: Implement filter functionality
                  //   },
                  //   child: Container(
                  //     width: 48,
                  //     height: 48,
                  //     decoration: BoxDecoration(
                  //       color: const Color(0xFF696FDD),
                  //       borderRadius: BorderRadius.circular(16),
                  //     ),
                  //     child: const Icon(
                  //       Icons.tune_rounded,
                  //       color: Colors.white,
                  //       size: 22,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),

            // Search Section - Use the SearchWidget in full page mode
            Expanded(
              child: SearchWidget(
                isFullPageMode: true,
                onClosePressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
