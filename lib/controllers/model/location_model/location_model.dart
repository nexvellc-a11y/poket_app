class LocationMapModel {
  final String? latitude;
  final String? longitude;
  final String? locality;
  final String? state;
  final String? pincode;
  final String? place;

  LocationMapModel({
    this.latitude,
    this.longitude,
    this.locality,
    this.state,
    this.pincode,
    this.place,
  });

  factory LocationMapModel.fromJson(Map<String, dynamic> json) {
    return LocationMapModel(
      state: json['state'],
      place: json['place'],
      locality: json['locality'],
      pincode: json['pincode'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'locality': locality,
    'state': state,
    'pincode': pincode,
    'place': place,
  };
}
