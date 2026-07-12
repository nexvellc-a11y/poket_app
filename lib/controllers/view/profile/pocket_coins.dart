import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:poketstore/controllers/user_profile_controller/user_profile_controller.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class PocketCoinsScreen extends StatelessWidget {
  const PocketCoinsScreen({super.key});

  final List<Map<String, dynamic>> _pocketCoinsImages = const [
    {
      'image': 'assets/computerphone.png',
      'title': 'Mobile/Laptop',
      'coins': '100 points',
      'bgColor': '#E8EAF6', // Light indigo
    },
    {
      'image': 'assets/trip.png',
      'title': 'Trip',
      'coins': '200 points',
      'bgColor': '#FFF9C4', // Light yellow
    },
    {
      'image': 'assets/home appliances.png',
      'title': 'Home Appliance',
      'coins': '300 points',
      'bgColor': '#FFF3E0', // Light orange
    },
    {
      'image': 'assets/bike-removebg-preview.png',
      'title': 'Bike',
      'coins': '500 points',
      'bgColor': '#FCE4EC', // Light pink
    },
    {
      'image': 'assets/car.png',
      'title': 'Car',
      'coins': '1000 points',
      'bgColor': '#E3F2FD', // Light blue
    },
    {
      'image': 'assets/home.png',
      'title': 'House ',
      'coins': '2000 points',
      'bgColor': '#E8F5E9', // Light green
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0703C9),
      body: Consumer<UserProfileController>(
        builder: (context, controller, _) {
          // 🔄 Loading state
          if (controller.isLoading) {
            return _buildLoading();
          }

          // ❌ Error / empty state
          if (controller.userProfile == null) {
            return _buildError();
          }

          // ✅ Data ready
          final double totalEarned =
              controller.userProfile!.rewards.totalEarned.toDouble();

          return _buildContent(totalEarned);
        },
      ),
    );
  }

  /// ================= UI =================

  Widget _buildContent(double totalEarned) {
    return CustomScrollView(
      slivers: [
        _buildAppBar(),
        SliverToBoxAdapter(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                _buildTotalEarnedCard(totalEarned),
                _buildHowPocketCoins(),
                const SizedBox(height: 16),
                _buildRewardsList(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      backgroundColor: const Color(0xFF0703C9),
      expandedHeight: 200,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0703C9), Color(0xFF2925E8)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.monetization_on,
                  size: 60,
                  color: Colors.amber,
                ),
              ),
              const SizedBox(height: 16),
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 28),
                  children: [
                    TextSpan(
                      text: 'Pocket ',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(
                      text: 'Rewards',
                      style: GoogleFonts.poppins(
                        color: Color(0xFFFFEA00),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTotalEarnedCard(double totalEarned) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20), // Reduced from 24 to 20
        width: 350,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.amber.shade600, Colors.orange.shade700],
          ),
          borderRadius: BorderRadius.circular(16), // Reduced from 20 to 16
        ),
        child: Column(
          children: [
            const Text(
              'Your Total Earned',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ), // Reduced from 18 to 16
            ),
            const SizedBox(height: 6), // Reduced from 8 to 6
            Text(
              '${totalEarned.toStringAsFixed(1)} Points',
              style: const TextStyle(
                fontSize: 24, // Reduced from 28 to 24
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHowPocketCoins() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16), // Reduced from 20 to 16
      width: 350,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12), // Reduced from 15 to 12
        border: Border.all(color: Colors.green, width: 1), // Added width
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star, color: Colors.green, size: 20), // Added size
              SizedBox(width: 6), // Reduced from 8 to 6
              Text(
                'How PocketPoints',
                style: TextStyle(
                  fontSize: 16, // Reduced from 18 to 16
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: 6), // Reduced from 8 to 6
          Text(
            'Every sale and purchase at PoketStor earns PoketPoints—every point brings you closer to your dream lifestyle.',
            style: TextStyle(fontSize: 14), // Reduced from 16 to 14
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsList() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pocket Rewards',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ), // Reduced from 22 to 20
          ),
          const SizedBox(height: 8), // Reduced from 10 to 8
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _pocketCoinsImages.length,
            itemBuilder: (context, index) {
              final item = _pocketCoinsImages[index];
              return Container(
                margin: const EdgeInsets.only(
                  bottom: 12,
                ), // Reduced from 16 to 12
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    12,
                  ), // Reduced from 15 to 12
                  color: _getColorFromHex(item['bgColor']),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Text
                    Padding(
                      padding: const EdgeInsets.all(
                        12,
                      ), // Reduced from 16 to 12
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['title'],
                                  style: const TextStyle(
                                    fontSize: 16, // Reduced from 18 to 16
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(
                                  height: 2,
                                ), // Reduced from 4 to 2
                                Text(
                                  'Earn ${item['coins']} on purchase',
                                  style: TextStyle(
                                    fontSize: 12, // Reduced from 14 to 12
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10, // Reduced from 12 to 10
                              vertical: 4, // Reduced from 6 to 4
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade600,
                              borderRadius: BorderRadius.circular(
                                16,
                              ), // Reduced from 20 to 16
                            ),
                            child: Text(
                              item['coins'],
                              style: const TextStyle(
                                fontSize: 11, // Reduced from 12 to 11
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Image
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(
                          12,
                        ), // Reduced from 15 to 12
                        bottomRight: Radius.circular(
                          12,
                        ), // Reduced from 15 to 12
                      ),
                      child: Image.asset(
                        item['image'],
                        height: 160, // Reduced from 200 to 160
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Helper function to convert hex color string to Color
  Color _getColorFromHex(String? hexColor) {
    if (hexColor == null) return Colors.grey.shade100;
    String color = hexColor.replaceAll('#', '');
    if (color.length == 6) {
      return Color(int.parse('FF$color', radix: 16));
    } else if (color.length == 8) {
      return Color(int.parse(color, radix: 16));
    }
    return Colors.grey.shade100;
  }

  /// ================= STATES =================

  Widget _buildLoading() {
    return Center(
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          width: 300,
          height: 150,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return const Center(
      child: Text(
        'Failed to load Pocket Coins',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
