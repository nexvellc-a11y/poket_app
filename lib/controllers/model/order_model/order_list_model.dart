class ProductNameOnly {
  final String name;

  ProductNameOnly({required this.name});

  factory ProductNameOnly.fromJson(Map<String, dynamic> json) {
    return ProductNameOnly(name: json['name']);
  }
}

class OrderSummary {
  final String orderId;
  final String userId;
  final String createdAt;
  final List<ProductNameOnly> products;
  final int totalCartAmount;

  OrderSummary({
    required this.orderId,
    required this.userId,
    required this.createdAt,
    required this.products,
    required this.totalCartAmount,
  });

  factory OrderSummary.fromJson(Map<String, dynamic> json) {
    return OrderSummary(
      orderId: json['orderId'],
      userId: json['userId'],
      createdAt: json['createdAt'],
      products: List<ProductNameOnly>.from(
        json['products'].map((p) => ProductNameOnly.fromJson(p)),
      ),
      totalCartAmount: (json['totalCartAmount'] as num).toInt(),
    );
  }
}
