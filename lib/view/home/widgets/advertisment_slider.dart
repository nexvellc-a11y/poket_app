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
  // Remove CarouselController and use CarouselSliderController instead
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  // Enhanced responsive breakpoints
  static const double _mobileBreakpoint = 480; // Smaller phones
  static const double _mobileLargeBreakpoint = 600; // Standard mobile
  static const double _tabletBreakpoint = 900;
  static const double _desktopBreakpoint = 1200;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdvertisementController>(
        context,
        listen: false,
      ).getAdvertisements();
    });
  }

  // Enhanced responsive checks
  bool get _isSmallMobile =>
      MediaQuery.of(context).size.width < _mobileBreakpoint;
  bool get _isMobile =>
      MediaQuery.of(context).size.width < _mobileLargeBreakpoint;
  bool get _isTablet =>
      MediaQuery.of(context).size.width >= _mobileLargeBreakpoint &&
      MediaQuery.of(context).size.width < _tabletBreakpoint;
  bool get _isLargeTablet =>
      MediaQuery.of(context).size.width >= _tabletBreakpoint &&
      MediaQuery.of(context).size.width < _desktopBreakpoint;
  bool get _isDesktop =>
      MediaQuery.of(context).size.width >= _desktopBreakpoint;

  // Get device orientation
  bool get _isPortrait =>
      MediaQuery.of(context).orientation == Orientation.portrait;
  double get _screenWidth => MediaQuery.of(context).size.width;
  double get _screenHeight => MediaQuery.of(context).size.height;

  // Responsive carousel height with orientation support
  double get _carouselHeight {
    if (_isSmallMobile) {
      return _isPortrait ? 140.0 : 120.0;
    }
    if (_isMobile) {
      return _isPortrait ? 180.0 : 140.0;
    }
    if (_isTablet) {
      return _isPortrait ? 260.0 : 200.0;
    }
    if (_isLargeTablet) {
      return _isPortrait ? 300.0 : 240.0;
    }
    return 320.0;
  }

  // Responsive carousel viewport fraction
  double get _viewportFraction {
    if (_isSmallMobile) return 0.8;
    if (_isMobile) return _isPortrait ? 0.75 : 0.7;
    if (_isTablet) return _isPortrait ? 0.65 : 0.6;
    return _isPortrait ? 0.6 : 0.55;
  }

  // Responsive carousel padding
  EdgeInsets get _carouselPadding {
    if (_isSmallMobile) return const EdgeInsets.symmetric(horizontal: 4.0);
    if (_isMobile) return const EdgeInsets.symmetric(horizontal: 8.0);
    if (_isTablet) return const EdgeInsets.symmetric(horizontal: 16.0);
    return const EdgeInsets.symmetric(horizontal: 24.0);
  }

  // Responsive border radius
  double get _borderRadius {
    if (_isSmallMobile) return 8.0;
    if (_isMobile) return 12.0;
    if (_isTablet) return 16.0;
    return 20.0;
  }

  // Responsive indicator size
  double get _indicatorSize {
    if (_isSmallMobile) return 6.0;
    if (_isMobile) return 8.0;
    if (_isTablet) return 10.0;
    return 12.0;
  }

  // Responsive indicator spacing
  double get _indicatorSpacing {
    if (_isSmallMobile) return 8.0;
    if (_isMobile) return 12.0;
    if (_isTablet) return 15.0;
    return 20.0;
  }

  // Responsive auto-play interval
  Duration get _autoPlayInterval {
    if (_isSmallMobile) return const Duration(seconds: 5);
    return const Duration(seconds: 3);
  }

  // Responsive margin between items
  EdgeInsets get _itemMargin {
    if (_isSmallMobile) return const EdgeInsets.all(2.0);
    if (_isMobile) return const EdgeInsets.all(4.0);
    if (_isTablet) return const EdgeInsets.all(6.0);
    return const EdgeInsets.all(8.0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Consumer<AdvertisementController>(
          builder: (context, adController, child) {
            if (adController.isLoading) {
              return _buildLoadingShimmer(theme);
            }

            if (adController.ads.isEmpty) {
              return _buildEmptyState(theme);
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Carousel Container
                Container(
                  padding: _carouselPadding,
                  child: CarouselSlider.builder(
                    carouselController: _carouselController,
                    options: CarouselOptions(
                      height: _carouselHeight,
                      viewportFraction: _viewportFraction,
                      autoPlay: adController.ads.length > 1,
                      enlargeCenterPage: true,
                      autoPlayInterval: _autoPlayInterval,
                      autoPlayAnimationDuration: const Duration(
                        milliseconds: 800,
                      ),
                      enableInfiniteScroll: adController.ads.length > 1,
                      onPageChanged: (index, reason) {
                        setState(() => _currentIndex = index);
                      },
                      aspectRatio: _isPortrait ? 16 / 9 : 21 / 9,
                    ),
                    itemCount: adController.ads.length,
                    itemBuilder: (context, index, realIndex) {
                      final ad = adController.ads[index];
                      return _buildCarouselItem(ad.image);
                    },
                  ),
                ),

                // Indicator with responsive spacing
                SizedBox(height: _indicatorSpacing),

                // Page Indicator (only show if more than 1 item)
                // if (adController.ads.length > 1)
                //   _buildPageIndicator(adController.ads.length, theme),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildCarouselItem(String imageUrl) {
    return Container(
      margin: _itemMargin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_isMobile ? 0.08 : 0.1),
            blurRadius: _isMobile ? 4 : 6,
            spreadRadius: _isMobile ? 1 : 2,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_borderRadius),
        child: Image.network(
          imageUrl,
          width: double.infinity,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildImageLoadingShimmer();
          },
          errorBuilder:
              (context, error, stackTrace) => _buildErrorPlaceholder(),
        ),
      ),
    );
  }

  // Widget _buildPageIndicator(int count, ThemeData theme) {
  //   return GestureDetector(
  //     onTap: () {
  //       // Optional: Tap indicator to navigate
  //       // Note: You might need to remove this if CarouselSliderController doesn't have animateToPage
  //       // You can use _carouselController.jumpToPage(_currentIndex) instead
  //     },
  //     child: AnimatedSmoothIndicator(
  //       activeIndex: _currentIndex,
  //       count: count,
  //       effect: ExpandingDotsEffect(
  //         activeDotColor: theme.primaryColor,
  //         dotColor: theme.colorScheme.surfaceVariant,
  //         dotHeight: _indicatorSize,
  //         dotWidth: _indicatorSize,
  //         spacing: _indicatorSize * 1.5,
  //         expansionFactor: _isMobile ? 1.2 : 1.5,
  //       ),
  //     ),
  //   );
  // }

  Widget _buildLoadingShimmer(ThemeData theme) {
    return Container(
      height: _carouselHeight,
      margin: _carouselPadding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_borderRadius),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            theme.colorScheme.surfaceVariant,
            theme.colorScheme.surface,
            theme.colorScheme.surfaceVariant,
          ],
        ),
      ),
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: _isMobile ? 1.5 : 2,
          valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Container(
      height: _carouselHeight * 0.6,
      margin: _carouselPadding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_borderRadius),
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_search,
              size: _getIconSize(),
              color: theme.colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: _indicatorSpacing * 0.5),
            Text(
              "No advertisements available",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: _getFontSize(scale: 0.9),
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageLoadingShimmer() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.grey.shade200,
            Colors.grey.shade300,
            Colors.grey.shade200,
          ],
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image,
              size: _getIconSize() * 0.8,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            SizedBox(height: _indicatorSpacing * 0.3),
            Text(
              "Image not available",
              style: TextStyle(
                fontSize: _getFontSize(scale: 0.8),
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _getFontSize({double scale = 1.0}) {
    double baseSize;
    if (_isSmallMobile) {
      baseSize = 12.0;
    } else if (_isMobile) {
      baseSize = 14.0;
    } else if (_isTablet) {
      baseSize = 16.0;
    } else {
      baseSize = 18.0;
    }
    return baseSize * scale;
  }

  double _getIconSize() {
    if (_isSmallMobile) return 32.0;
    if (_isMobile) return 40.0;
    if (_isTablet) return 50.0;
    return 60.0;
  }
}
