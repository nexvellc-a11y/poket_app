import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:poketstore/model/user_profile_model/user_profile_model.dart';
import 'package:shimmer/shimmer.dart';

class PocketCoinsScreen extends StatefulWidget {
  final UserProfile userProfile;

  const PocketCoinsScreen({super.key, required this.userProfile});

  @override
  State<PocketCoinsScreen> createState() => _PocketCoinsScreenState();
}

class _PocketCoinsScreenState extends State<PocketCoinsScreen> {
  final List<Map<String, dynamic>> _pocketCoinsImages = [
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

  bool _isLoading = true;
  int _totalEarned = 0;

  @override
  void initState() {
    super.initState();
    // Simulate loading delay for the total earned coins
    _loadTotalEarned();
  }

  Future<void> _loadTotalEarned() async {
    // Simulate API call or data fetching delay
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _totalEarned = widget.userProfile.rewards.totalEarned;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0703C9),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
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
                            text: 'Pocket',
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
          ),

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
                  /// CURRENT BALANCE CARD
                  Center(
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      padding: const EdgeInsets.all(24),
                      width: 350,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.amber.shade600,
                            Colors.orange.shade700,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Your Total Earned',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),

                          /// 🔥 LOADING OR DISPLAY TOTAL EARNED
                          _isLoading
                              ? Shimmer.fromColors(
                                baseColor: Colors.amber.shade700,
                                highlightColor: Colors.orange.shade300,
                                child: Container(
                                  width: 120,
                                  height: 35,
                                  decoration: BoxDecoration(
                                    color: Colors.amber,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              )
                              : Text(
                                '$_totalEarned Coins',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                              ),
                        ],
                      ),
                    ),
                  ),

                  /// HOW POCKET COINS
                  Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(20),
                      width: 350,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.green.shade200,
                          width: 1.5,
                        ),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.green, size: 20),
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
                            style: TextStyle(fontSize: 16, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// REWARDS LIST
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pocket Rewards',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        _buildImagesList(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagesList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _pocketCoinsImages.length,
      itemBuilder: (context, index) {
        final item = _pocketCoinsImages[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
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
    );
  }
}
