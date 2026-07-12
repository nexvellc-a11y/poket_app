import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:poketstore/model/add_shope_model/add_shop_model.dart';
import 'package:poketstore/view/home/view/grocery_sub_header/grocery_sub_header.dart';
import 'package:poketstore/view/home/view/product_details_screen/product_details_screen.dart';
import 'package:poketstore/view/home/view/store_horizontal_scroll/product_by_shop.dart';
import 'package:poketstore/view/home/widgets/product_card.dart';

Widget buildSectionTitle(String title, String action) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        if (action.isNotEmpty)
          Text(
            action,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
          ),
      ],
    ),
  );
}

Widget buildStoreSectionTitle(String title, String action) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        if (action.isNotEmpty)
          Text(
            action,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
          ),
      ],
    ),
  );
}

Widget groceriesHorizontalList(
  Map<String, List<String>> items,
  BuildContext context,
) {
  return SizedBox(
    height: 50,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: items.length,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            //
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => SubGroceryCategoryScreen(
                      header: items.entries.elementAt(index).key,
                      subCategories: items.entries.elementAt(index).value,
                    ),
              ),
            );
          },
          child: buildGroceryItem(
            items.entries.elementAt(index).key,
            Colors.lightBlueAccent.shade100,
          ),
        );
      },
    ),
  );
}

Widget buildGroceryItem(String name, Color color) {
  return Container(
    margin: const EdgeInsets.only(right: 10),
    height: 100,
    // width: 100,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(15),
    ),
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          // Container(
          //   height: 10,
          //   width: 10,
          //   decoration: BoxDecoration(
          //     image: const DecorationImage(
          //       image: AssetImage('assets/groceries.png'),
          //     ),
          //     borderRadius: BorderRadius.circular(5),
          //   ),
          // ),
          const SizedBox(width: 10),
          Text(
            name,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget storeHorizontalList(List<ShopModel> shops) {
  return SizedBox(
    height: 50,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: shops.length,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => ShopProductListScreen(
                      shopId:
                          shops[index].id ??
                          "", // Ensure `id` is present in ShopData
                      shopName: shops[index].shopName ?? "Unnamed Shop",
                    ),
              ),
            );
          },
          child: buildStoreItem(
            shops[index].shopName ?? "Unnamed Shop",
            Colors.blue.shade100,
          ),
        );
      },
    ),
  );
}

Widget buildStoreItem(String name, Color color) {
  return Container(
    margin: const EdgeInsets.only(right: 10),
    height: 100,
    width: 150,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(15),
    ),
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          // Container(
          //   height: 70,
          //   width: 70,
          //   decoration: BoxDecoration(
          //     image: const DecorationImage(
          //       image: AssetImage('assets/groceries.png'),
          //     ),
          //     borderRadius: BorderRadius.circular(5),
          //   ),
          // ),
          const SizedBox(width: 10),
          Text(
            name,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
  );
}

Widget productGridView(List<Map<String, dynamic>> products) {
  return GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 0.75,
    ),
    itemCount: products.length,
    padding: const EdgeInsets.all(10),
    itemBuilder: (context, index) {
      final product = products[index];
      return GestureDetector(
        onTap: () {
          String productId = product["_id"].toString();
          log("Tapped Product ID: $productId");
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailsScreen(productId: productId),
            ),
          );
        },
        child: ProductCard(
          icon: Icons.shopping_cart_outlined,
          imagePath:
              product["image"] ?? "", // Provide default image path if null
          title: product["name"] ?? "Product", // Provide default title if null
          weight: product["weight"]?.toString() ?? "", // Handle null weight
          price: product["price"] ?? 0, // Provide default price if null
        ),
      );
    },
  );
}

Future<bool> showLocationDisclosure(BuildContext context) async {
  return await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => AlertDialog(
              title: const Text("Location Permission Required"),
              content: const Text(
                "PoketStor uses your location to:\n"
                "• Show nearby shops\n"
                "• Register shop location accurately\n\n"
                "Location data is used only for these features "
                "and is never shared.",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text("Allow & Continue"),
                ),
              ],
            ),
      ) ??
      false;
}
