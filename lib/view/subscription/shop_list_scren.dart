import 'package:flutter/material.dart';
import 'package:poketstore/model/subscription_model/user_shop_list_model.dart';

class ShopListScreen extends StatelessWidget {
  final List<UserShopListModel> shops;
  final Function(String shopId) onShopSelected;

  const ShopListScreen({
    super.key,
    required this.shops,
    required this.onShopSelected,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      // appBar: AppBar(
      //   backgroundColor: Colors.white,
      //   elevation: 0,
      //   leading: Container(
      //     margin: const EdgeInsets.all(8),
      //     decoration: BoxDecoration(
      //       color: Colors.grey[100],
      //       borderRadius: BorderRadius.circular(12),
      //     ),
      //     child: IconButton(
      //       icon: const Icon(
      //         Icons.arrow_back_ios_rounded,
      //         color: Colors.black54,
      //         size: 20,
      //       ),
      //       onPressed: () => Navigator.pop(context),
      //     ),
      //   ),
      //   title: const Text(
      //     "Your Shops",
      //     style: TextStyle(
      //       color: Colors.black87,
      //       fontWeight: FontWeight.w600,
      //       fontSize: 20,
      //     ),
      //   ),
      //   centerTitle: true,
      //   bottom: PreferredSize(
      //     preferredSize: const Size.fromHeight(1),
      //     child: Container(height: 1, color: Colors.grey[200]),
      //   ),
      // ),
      body:
          shops.isEmpty
              ? _buildEmptyState()
              : isTablet
              ? _buildGridView(shops)
              : _buildListView(shops),
    );
  }

  Widget _buildListView(List<UserShopListModel> shops) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: shops.length,
      itemBuilder: (context, index) {
        final shop = shops[index];
        return _buildShopCard(shop, index);
      },
    );
  }

  Widget _buildGridView(List<UserShopListModel> shops) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: shops.length,
      itemBuilder: (context, index) {
        final shop = shops[index];
        return _buildShopGridCard(shop, index);
      },
    );
  }

  Widget _buildShopCard(UserShopListModel shop, int index) {
    // Generate consistent color based on shop name
    final Color cardColor = _getColorFromString(shop.shopName, index);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onShopSelected(shop.id),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Row(
              children: [
                // Shop Icon with colored background
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: cardColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.store_rounded, color: cardColor, size: 28),
                ),
                const SizedBox(width: 16),

                // Shop Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shop.shopName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              shop.place?.isNotEmpty == true
                                  ? shop.place!
                                  : 'Location not specified',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Arrow Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: cardColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShopGridCard(UserShopListModel shop, int index) {
    // Generate consistent color based on shop name
    final Color cardColor = _getColorFromString(shop.shopName, index);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onShopSelected(shop.id),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Shop Icon with colored background
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: cardColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(Icons.store_rounded, color: cardColor, size: 32),
              ),
              const SizedBox(height: 12),

              // Shop Name
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  shop.shopName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),

              // Location
              if (shop.place?.isNotEmpty == true)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 12,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          shop.place!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.blue[50],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.store_rounded, size: 60, color: Colors.blue[300]),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Shops Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You don\'t have any shops yet.\nCreate your first shop to get started.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Navigate to create shop screen
              // You can add this navigation logic
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Create Shop',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorFromString(String input, int index) {
    // List of beautiful colors for shop cards
    const List<Color> colors = [
      Color(0xFF4A6FA5), // Soft Blue
      Color(0xFF4ECDC4), // Mint
      Color(0xFFFF6B6B), // Coral
      Color(0xFFFFB347), // Orange
      Color(0xFF9B59B6), // Purple
      Color(0xFF2ECC71), // Green
      Color(0xFFE67E22), // Carrot
      Color(0xFF3498DB), // Light Blue
      Color(0xFFE74C3C), // Red
      Color(0xFF1ABC9C), // Turquoise
    ];

    // Use index to pick color (with wrap around)
    return colors[index % colors.length];
  }
}
