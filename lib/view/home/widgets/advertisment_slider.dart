import 'package:flutter/material.dart';
import 'package:poketstore/controllers/advertisment_controller/advertisment_controller.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class AdvertisementCarousel extends StatefulWidget {
  const AdvertisementCarousel({super.key});

  @override
  State<AdvertisementCarousel> createState() => _AdvertisementCarouselState();
}

class _AdvertisementCarouselState extends State<AdvertisementCarousel> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Fetch advertisements when widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdvertisementController>(
        context,
        listen: false,
      ).getAdvertisements();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdvertisementController>(
      builder: (context, adController, child) {
        if (adController.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (adController.ads.isEmpty) {
          return const Center(child: Text("No advertisements found"));
        }

        return Column(
          children: [
            CarouselSlider(
              options: CarouselOptions(
                height: 150,
                autoPlay: true,
                enlargeCenterPage: true,
                autoPlayInterval: const Duration(seconds: 3),
                onPageChanged: (index, reason) {
                  setState(() => _currentIndex = index);
                },
              ),
              items:
                  adController.ads.map((ad) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        ad.image, // ✅ use API image
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) =>
                                const Icon(Icons.broken_image, size: 50),
                      ),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 20),
            // Center(
            //   child: AnimatedSmoothIndicator(
            //     activeIndex: _currentIndex,
            //     count: adController.ads.length,
            //     effect: const JumpingDotEffect(
            //       activeDotColor: Colors.blue,
            //       dotHeight: 8.0,
            //       dotWidth: 8.0,
            //       verticalOffset: 8.0, // how high the active dot jumps
            //       jumpScale: .7, // optional: scale of the jump animation
            //       // optional: rotation during jump
            //     ),
            //   ),
            // ),
          ],
        );
      },
    );
  }
}
