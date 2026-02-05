import 'package:flutter/material.dart';
import 'package:poketstore/controllers/product_search_controller/product_search_controller.dart';
import 'package:provider/provider.dart';
import 'package:poketstore/model/product_search_model/product_search_model.dart';

class ProductSearchScreen extends StatefulWidget {
  const ProductSearchScreen({super.key});

  @override
  State<ProductSearchScreen> createState() => _ProductSearchScreenState();
}

class _ProductSearchScreenState extends State<ProductSearchScreen> {
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _localityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Clear old search results whenever this screen is created/refreshed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductSearchProvider>(
        context,
        listen: false,
      ).clearSearchResults();
    });
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _localityController.dispose();
    super.dispose();
  }

  // Function to trigger the product search.
  void _performSearch() {
    final String productName = _productNameController.text.trim();
    final String locality = _localityController.text.trim();

    // Call the fetchSearchResults method from the provider.
    // It will handle passing 'null' to the API if fields are empty.
    Provider.of<ProductSearchProvider>(
      context,
      listen: false,
    ).fetchSearchResults(productName, locality);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Search'),
        backgroundColor: const Color(0XFF094497),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Product Name Search Field
            TextField(
              controller: _productNameController,
              decoration: InputDecoration(
                labelText: 'Product Name',
                hintText: 'e.g., "Apple", "Rice"',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.shopping_bag_outlined),
              ),
              onSubmitted: (_) => _performSearch(), // Search on keyboard submit
            ),
            const SizedBox(height: 16),
            // Locality Search Field
            TextField(
              controller: _localityController,
              decoration: InputDecoration(
                labelText: 'Locality/Place',
                hintText: 'e.g., "Edappal", "Bangalore"',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.location_on_outlined),
              ),
              onSubmitted: (_) => _performSearch(), // Search on keyboard submit
            ),
            const SizedBox(height: 24),
            // Search Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _performSearch,
                icon: const Icon(Icons.search),
                label: const Text('Search Products'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0XFF094497),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Consumer to rebuild UI based on ProductSearchProvider state
            Expanded(
              child: Consumer<ProductSearchProvider>(
                builder: (context, productSearchProvider, child) {
                  if (productSearchProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (productSearchProvider.errorMessage.isNotEmpty) {
                    return Center(
                      child: Text(
                        // 'Error: ${productSearchProvider.errorMessage}',
                        'No Product/Shop found',
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    );
                  } else if (productSearchProvider.searchResults.isEmpty) {
                    return const Center(
                      child: Text(
                        'No products found. Try a different search.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    );
                  } else {
                    // Display search results in a ListView
                    return ListView.builder(
                      itemCount: productSearchProvider.searchResults.length,
                      itemBuilder: (context, index) {
                        final ProductSearchModel product =
                            productSearchProvider.searchResults[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                // Product Image
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: NetworkImage(product.productImage),
                                      fit: BoxFit.cover,
                                      onError:
                                          (exception, stackTrace) =>
                                              const AssetImage(
                                                'assets/image.png',
                                              ), // Fallback
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Product Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Category: ${product.category}',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        'Price: ₹${product.price.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.green,
                                        ),
                                      ),
                                      // Text(
                                      //   'Sold by: ${product.}', // Assuming shop name is available or can be fetched
                                      //   style: const TextStyle(fontSize: 13),
                                      // ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
