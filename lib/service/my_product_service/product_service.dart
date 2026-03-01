import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:poketstore/model/my_shope_model/product_model.dart'; // Ensure this path is correct

/// A service class for interacting with product-related APIs.
/// It handles creation, fetching, updating, and deleting of products.
class ProductService {
  final Dio _dio = Dio();
  final String _baseUrl = "https://api.poketstor.com/api/products";

  /// Creates a new product on the backend.
  ///
  /// This method sends a POST request to the API with product details,
  /// including an optional product image.
  ///
  /// Returns the created [Product] object if successful, otherwise returns `null`.
  Future<Product?> createProduct({
    required String userId,
    required String shopId,
    File? productImage,
    String? name,
    String? description,
    int? price,
    int? quantity,
    String? category,
    String? estimatedTime,
    String? unitType,
    String? itemType,
    String? deliveryOption,
  }) async {
    try {
      final formData = FormData.fromMap({
        "userId": userId,
        if (name != null) "name": name,
        if (description != null) "description": description,
        if (price != null) "price": price,
        if (quantity != null) "quantity": quantity,
        if (estimatedTime != null) "estimatedTime": estimatedTime,
        if (unitType != null) "unitType": unitType,
        if (itemType != null) "itemType": itemType,
        if (deliveryOption != null) "deliveryOption": deliveryOption,
        if (productImage != null)
          "productImage": await MultipartFile.fromFile(
            productImage.path,
            filename: productImage.path.split('/').last,
          ),
      });

      final response = await _dio.post(
        '$_baseUrl/$shopId',
        data: formData,
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      log("Create product response: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Product.fromJson(response.data['product']);
      }

      if (response.statusCode == 403) {
        log("Subscription inactive or forbidden");
        return null;
      }

      return null;
    } catch (e, stackTrace) {
      log("Error creating product", error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Fetches a list of all products from the backend.
  ///
  /// This method sends a GET request to retrieve all products available.
  ///
  /// Returns a [List] of [Product] objects. Throws an [Exception] if the fetch fails.
  Future<List<Product>> fetchProducts() async {
    try {
      final response = await _dio.get(_baseUrl);

      log("Fetch Products Status Code: ${response.statusCode}");
      log("Fetch Products Response Data: ${response.data}");

      if (response.statusCode == 200 && response.data != null) {
        if (response.data.containsKey("products") &&
            response.data["products"] is List) {
          List<dynamic> productsJson = response.data["products"];

          if (productsJson.isEmpty) {
            log("No products found.");
            return [];
          }

          List<Product> productList =
              productsJson.map((json) {
                log("Processing Product: ${json['name']}");

                // Handle incorrect category format, ensuring it's always a List<String>
                List<String> categories;
                if (json["category"] is List) {
                  categories = List<String>.from(json["category"]);
                } else if (json["category"] is String) {
                  // If category is a single string, wrap it in a list
                  categories = [json["category"]];
                } else {
                  categories = [];
                }

                return Product(
                  id: json["_id"],
                  name: json["name"],
                  favorite: json["favorite"] ?? false,
                  description: json["description"] ?? "",
                  price: (json["price"] as num?)?.toDouble() ?? 0.0,
                  quantity: (json["quantity"] as num?)?.toDouble() ?? 0.0,
                  sold: (json["sold"] as num?)?.toDouble() ?? 0.0,
                  category: categories.join(", "),
                  productImage: json["productImage"] ?? "",

                  estimatedTime: json["estimatedTime"] ?? "",
                  unitType: json["unitType"] ?? "",
                  deliveryOption: json["deliveryOption"] ?? "",
                  userId: json["userId"] ?? "",
                  createdAt:
                      DateTime.tryParse(json["createdAt"] ?? "") ??
                      DateTime.now(),
                  updatedAt:
                      DateTime.tryParse(json["updatedAt"] ?? "") ??
                      DateTime.now(),
                );
              }).toList();

          log("Total Products Fetched: ${productList.length}");
          return productList;
        } else {
          throw const FormatException(
            "Invalid API response format: Missing 'products' key or not a list.",
          );
        }
      } else {
        throw Exception(
          "Failed to fetch products: Status Code ${response.statusCode}",
        );
      }
    } on DioException catch (e) {
      log(
        "Dio error fetching products: ${e.message}",
        error: e,
        stackTrace: e.stackTrace,
      );
      throw Exception("Network error: Failed to fetch products.");
    } catch (e, stackTrace) {
      log("Error fetching products: $e", error: e, stackTrace: stackTrace);
      throw Exception("An unexpected error occurred while fetching products.");
    }
  }

  /// Fetches a single product by its ID.
  ///
  /// This method sends a GET request to retrieve specific product details.
  ///
  /// Returns the [Product] object if found. Throws an [Exception] if the product
  /// is not found or an error occurs.
  Future<Product> fetchProduct(String productId) async {
    try {
      final response = await _dio.get("$_baseUrl/getone/$productId");

      log("fetchProduct response for ID $productId: ${response.data}");

      if (response.statusCode == 200) {
        if (response.data != null && response.data['product'] != null) {
          return Product.fromJson(response.data["product"]);
        } else {
          throw Exception("Product data is missing from the response.");
        }
      } else {
        log(
          "fetchProduct failed with status code: ${response.statusCode}, Data: ${response.data}",
        );
        throw Exception("Failed to fetch product with ID $productId.");
      }
    } on DioException catch (e) {
      log(
        "Dio error fetching product with ID $productId: ${e.message}",
        error: e,
        stackTrace: e.stackTrace,
      );
      throw Exception("Network error: Failed to fetch product.");
    } catch (e, stackTrace) {
      log(
        "Error fetching product with ID $productId: $e",
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception(
        "An unexpected error occurred while fetching the product.",
      );
    }
  }

  /// Fetches products associated with a specific user ID.
  ///
  /// This method sends a GET request to retrieve products belonging to a user.
  ///
  /// Returns a [List] of [Product] objects. Throws an [Exception] if the fetch fails.
  Future<List<Product>> fetchProductsForUser(String userId) async {
    try {
      final response = await _dio.get(
        "https://api.poketstor.com/api/products/user/$userId",
      );
      log("Fetch Products for User Status Code: ${response.statusCode}");
      log("Fetch Products for User Response Data: ${response.data}");

      if (response.statusCode == 200) {
        if (response.data.containsKey("products") &&
            response.data["products"] is List) {
          List<dynamic> productsJson = response.data["products"];
          return productsJson.map((json) => Product.fromJson(json)).toList();
        } else {
          throw const FormatException(
            "Invalid API response format for user products: Missing 'products' key or not a list.",
          );
        }
      } else {
        throw Exception(
          "Failed to fetch products for user $userId. Status Code: ${response.statusCode}",
        );
      }
    } on DioException catch (e) {
      log(
        "Dio error fetching products for user $userId: ${e.message}",
        error: e,
        stackTrace: e.stackTrace,
      );
      throw Exception("Network error: Failed to fetch user's products.");
    } catch (e, stackTrace) {
      log(
        "Error fetching products for user $userId: $e",
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception(
        "An unexpected error occurred while fetching user's products.",
      );
    }
  }

  /// Updates an existing product on the backend.
  ///
  /// This method sends a PUT request with updated product details,
  /// including an optional new product image.
  ///
  /// Returns `true` if the product was updated successfully, `false` otherwise.
  Future<bool> updateProduct(
    String productId, {
    File? productImage,
    String? name,
    String? description,
    int? price,
    int? quantity,
    List<String>? category,
    String? estimatedTime,
    String? unitType,
    String? deliveryOption,
  }) async {
    try {
      final FormData formData = FormData.fromMap({
        if (name != null) "name": name,
        if (description != null) "description": description,
        if (price != null) "price": price.toString(),
        if (quantity != null) "quantity": quantity.toString(),
        if (category != null)
          "category":
              category, // Dio handles List<String> correctly for form data
        if (estimatedTime != null) "estimatedTime": estimatedTime,
        if (unitType != null) "unitType": unitType,
        if (deliveryOption != null) "deliveryOption": deliveryOption,
        if (productImage != null)
          "productImage": await MultipartFile.fromFile(
            productImage.path,
            filename: productImage.path.split('/').last,
          ),
      });

      final Response response = await _dio.put(
        "$_baseUrl/update/$productId",
        data: formData,
      );

      if (response.statusCode == 200) {
        log("Product updated successfully: ${response.data}");
        return true;
      } else {
        log(
          "Failed to update product $productId. Status code: ${response.statusCode}, Data: ${response.data}",
        );
        return false;
      }
    } on DioException catch (e) {
      log(
        "Dio error updating product $productId: ${e.message}",
        error: e,
        stackTrace: e.stackTrace,
      );
      return false;
    } catch (e, stackTrace) {
      log(
        "Error updating product $productId: $e",
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    } finally {
      fetchProduct(productId);
    }
  }

  /// Deletes a product by its ID.
  ///
  /// This method sends a DELETE request to remove a product from the backend.
  ///
  /// Returns `true` if the product was deleted successfully, `false` otherwise.
  Future<bool> deleteProduct(String productId) async {
    try {
      final response = await _dio.delete("$_baseUrl/$productId");
      if (response.statusCode == 200) {
        log("Product $productId deleted successfully");
        return true;
      } else {
        log(
          "Failed to delete product $productId. Status code: ${response.statusCode}, Data: ${response.data}",
        );
        return false;
      }
    } on DioException catch (e) {
      log(
        "Dio error deleting product $productId: ${e.message}",
        error: e,
        stackTrace: e.stackTrace,
      );
      return false;
    } catch (e, stackTrace) {
      log(
        "Error deleting product $productId: $e",
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }
}
