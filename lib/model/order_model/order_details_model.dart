class Address {
  final String countryName;
  final String phoneNumber;
  final String houseNo;
  final String area;
  final String landmark;
  final String pincode;
  final String town;
  final String state;

  Address({
    required this.countryName,
    required this.phoneNumber,
    required this.houseNo,
    required this.area,
    required this.landmark,
    required this.pincode,
    required this.town,
    required this.state,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      countryName: json['countryName'],
      phoneNumber: json['phoneNumber'],
      houseNo: json['houseNo'],
      area: json['area'],
      landmark: json['landmark'],
      pincode: json['pincode'],
      town: json['town'],
      state: json['state'],
    );
  }
}

class OrderProduct {
  final String productName;
  final String productImage;
  final int productPrice;
  final int quantityBought;
  final dynamic totalPrice; // Changed to dynamic to handle "N/A"
  final String shopName;
  final String shopEmail;
  final String? shopMobile; // Made nullable as it's not in the example JSON

  OrderProduct({
    required this.productName,
    required this.productImage,
    required this.productPrice,
    required this.quantityBought,
    required this.totalPrice,
    required this.shopName,
    required this.shopEmail,
    this.shopMobile, // Now optional
  });

  factory OrderProduct.fromJson(Map<String, dynamic> json) {
    return OrderProduct(
      productName: json['productName'],
      productImage: json['productImage'],
      productPrice: json['productPrice'],
      quantityBought: json['quantityBought'],
      totalPrice: json['totalPrice'], // Handles "N/A" or number
      shopName: json['shopName'],
      shopEmail: json['shopEmail'],
      shopMobile: json['shopMobile'],
    );
  }
}

class OrderDetail {
  final String orderId;
  final String userId;
  final int totalCartAmount;
  final String createdAt;
  final Address address;
  final List<OrderProduct> products;

  OrderDetail({
    required this.orderId,
    required this.userId,
    required this.totalCartAmount,
    required this.createdAt,
    required this.address,
    required this.products,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      orderId: json['orderId'],
      userId: json['userId'],
      totalCartAmount: json['totalCartAmount'],
      createdAt: json['createdAt'],
      address: Address.fromJson(json['address']),
      products: List<OrderProduct>.from(
        json['products'].map((p) => OrderProduct.fromJson(p)),
      ),
    );
  }
}
