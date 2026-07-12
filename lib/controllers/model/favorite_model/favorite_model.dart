class FavoriteModel {
  final List<String> favorites;

  FavoriteModel({required this.favorites});

  Map<String, dynamic> toJson() {
    return {
      'favorites': favorites,
    };
  }
}
