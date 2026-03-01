import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:poketstore/controllers/user_profile_controller/user_profile_controller.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class PocketCoinsScreen extends StatelessWidget {
  const PocketCoinsScreen({super.key});

  final List<Map<String, dynamic>> _pocketCoinsImages = const [
    {
      'image': 'assets/appliance.jpeg',
      'title': 'Appliance Purchase',
      'coins': '500 Coins',
    },
    {
      'image': 'assets/house.jpeg',
      'title': 'House Purchase',
      'coins': '100,000 Coins',
    },
    {
      'image': 'assets/car.jpeg',
      'title': 'Car Purchase',
      'coins': '25,000 Coins',
    },
    {
      'image': 'assets/bike.jpeg',
      'title': 'Bike Purchase',
      'coins': '5,000 Coins',
    },
    {
      'image': 'assets/mobile.jpeg',
      'title': 'Mobile Purchase',
      'coins': '2,000 Coins',
    },
    {
      'image': 'assets/trip.jpeg',
      'title': 'Trip Booking',
      'coins': '10,000 Coins',
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
        padding: const EdgeInsets.all(24),
        width: 350,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.amber.shade600, Colors.orange.shade700],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            const Text(
              'Your Total Earned',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              '${totalEarned.toStringAsFixed(1)} Coins',
              style: const TextStyle(
                fontSize: 28,
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
      padding: const EdgeInsets.all(20),
      width: 350,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.green),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star, color: Colors.green),
              SizedBox(width: 8),
              Text(
                'How PocketCoins',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Every purchase at PoketStor earns PoketCoins—every coin brings you closer to your dream lifestyle.',
            style: TextStyle(fontSize: 16),
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
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _pocketCoinsImages.length,
            itemBuilder: (context, index) {
              final item = _pocketCoinsImages[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(
                    item['image'],
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
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
