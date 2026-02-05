// Import for jsonDecode if you plan to use it to parse raw strings

/// Represents a single address with its details.
class Address {
  final String? countryName;
  final String? phoneNumber;
  final String? houseNo; // This field may be missing in some responses
  final String? area;
  final String? landmark;
  final String? pincode;
  final String? town;
  final String? state;
  final String?
  id; // Renamed from _id to id for Dart conventions, but mapped from _id in JSON

  Address({
    this.countryName,
    this.phoneNumber,
    this.houseNo,
    this.area,
    this.landmark,
    this.pincode,
    this.town,
    this.state,
    this.id,
  });

  /// Factory constructor to create an [Address] object from a JSON map.
  /// Uses null-aware operators (`?.`) to safely access fields that might be missing.
  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      countryName: json['countryName']?.toString(),
      phoneNumber: json['phoneNumber']?.toString(),
      houseNo: json['houseNo']?.toString(), // Safely handles missing 'houseNo'
      area: json['area']?.toString(),
      landmark: json['landmark']?.toString(),
      pincode: json['pincode']?.toString(),
      town: json['town']?.toString(),
      state: json['state']?.toString(),
      id: json['_id']?.toString(), // Maps '_id' from JSON to 'id' property
    );
  }

  /// Converts the [Address] object to a JSON map.
  /// Note: '_id' is typically not sent when creating a new address,
  /// but included here if needed for update operations.
  Map<String, dynamic> toJson() {
    return {
      'countryName': countryName,
      'phoneNumber': phoneNumber,
      'houseNo': houseNo,
      'area': area,
      'landmark': landmark,
      'pincode': pincode,
      'town': town,
      'state': state,
      // '_id': id, // Uncomment if you need to send the ID back to the server for updates
    };
  }
}

/// Represents the top-level response structure for a list of addresses.
/// This class directly maps to your provided JSON, which only contains an "addresses" array.
class AddressListResponse {
  final List<Address> addresses;

  AddressListResponse({required this.addresses});

  /// Factory constructor to create an [AddressListResponse] object from a JSON map.
  /// It parses the 'addresses' list by mapping each item to an [Address] object.
  factory AddressListResponse.fromJson(Map<String, dynamic> json) {
    return AddressListResponse(
      addresses: List<Address>.from(
        json['addresses'].map((x) => Address.fromJson(x)),
      ),
    );
  }

  /// Converts the [AddressListResponse] object to a JSON map.
  Map<String, dynamic> toJson() {
    return {'addresses': addresses.map((x) => x.toJson()).toList()};
  }
}
