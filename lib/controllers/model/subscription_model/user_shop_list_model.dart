class UserShopListModel {
  final String id;
  final String shopName;
  final List<String> category;
  final String sellerType;
  final String state;
  final String place;
  final String locality;
  final String pinCode;
  final String headerImage;
  final String agentCode;
  final String? registeredBySalesman;

  UserShopListModel({
    required this.id,
    required this.shopName,
    required this.category,
    required this.sellerType,
    required this.state,
    required this.place,
    required this.locality,
    required this.pinCode,
    required this.headerImage,
    required this.agentCode,
    this.registeredBySalesman,
  });

  factory UserShopListModel.fromJson(Map<String, dynamic> json) {
    return UserShopListModel(
      id: json['_id'] ?? '',
      shopName: json['shopName'] ?? '',
      category: List<String>.from(json['category'] ?? []),
      sellerType: json['sellerType'] ?? '',
      state: json['state'] ?? '',
      place: json['place'] ?? '',
      locality: json['locality'] ?? '',
      pinCode: json['pinCode'] ?? '',
      headerImage: json['headerImage'] ?? '',
      agentCode: json['agentCode'] ?? '',
      registeredBySalesman: json['registeredBySalesman'],
    );
  }
}
