import 'package:flutter/material.dart';
import 'package:poketstore/controllers/product_by_shop_controller/product_by_shop_controller.dart';
import 'package:poketstore/view/home/view/product_details_screen/product_details_screen.dart';
import 'package:provider/provider.dart';

class ShopProductListScreen extends StatefulWidget {
  final String shopId;
  final String shopName;

  const ShopProductListScreen({
    super.key,
    required this.shopId,
    required this.shopName,
  });

  @override
  State<ShopProductListScreen> createState() => _ShopProductListScreenState();
}

class _ShopProductListScreenState extends State<ShopProductListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<ProductsByShopProvider>(
        context,
        listen: false,
      ).getProductsByShopId(widget.shopId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductsByShopProvider>(context);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text('${widget.shopName} Products')),
        body:
            productProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : productProvider.productList.isEmpty
                ? const Center(child: Text("No products found"))
                : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: productProvider.productList.length,
                  itemBuilder: (context, index) {
                    final product = productProvider.productList[index];

                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) =>
                                    ProductDetailsScreen(productId: product.id),
                          ),
                        );
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    product.productImage,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, _, __) => Image.asset(
                                          'assets/placeholder.png',
                                        ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                product.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "₹${product.price}",
                                style: const TextStyle(color: Colors.green),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
