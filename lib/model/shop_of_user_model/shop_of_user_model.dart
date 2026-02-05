class ShopOfUser {
  final String id;
  final String shopName;
  final List<String> category;
  final String sellerType;
  final String state;
  final String place;
  final String pinCode;
  final String locality;
  final String district;
  final String headerImage;

  ShopOfUser({
    required this.id,
    required this.shopName,
    required this.category,
    required this.sellerType,
    required this.state,
    required this.place,
    required this.pinCode,
    required this.locality,
    required this.district,
    required this.headerImage,
  });

  factory ShopOfUser.fromJson(Map<String, dynamic> json) {
    return ShopOfUser(
      id: json['_id'] ?? '',
      shopName: json['shopName'] ?? '',
      category: List<String>.from(json['category'] ?? []),
      sellerType: json['sellerType'] ?? '',
      state: json['state'] ?? '',
      place: json['place'] ?? '',
      pinCode: json['pinCode'] ?? '',
      headerImage: json['headerImage'] ?? '',
      district: json['district'] ?? '',
      locality: json['locality'] ?? '',
    );
  }
}
