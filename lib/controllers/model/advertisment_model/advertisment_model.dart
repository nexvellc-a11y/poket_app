class AdvertisementModel {
  final String id;
  final String title;
  final String image;

  AdvertisementModel({
    required this.id,
    required this.title,
    required this.image,
  });

  factory AdvertisementModel.fromJson(Map<String, dynamic> json) {
    return AdvertisementModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      image: json['image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {"_id": id, "title": title, "image": image};
  }
}
