import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:poketstore/model/favorite_model/favorite_model.dart';
import 'package:poketstore/model/favorite_model/get_favourite_model.dart';

class FavoriteService {
  final Dio _dio = Dio();
  final String _baseUrl = 'https://api.poketstor.com/api';

  Future<bool> addFavorite(String userId, String productId) async {
    final url = '$_baseUrl/favorite/$userId/$productId';
    final data = FavoriteModel(favorites: [productId]).toJson();

    try {
      final response = await _dio.post(url, data: data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        log("Favorite added: ${response.data}");
        return true;
      }
      log("Failed to add favorite: ${response.statusCode}");
    } catch (e) {
      log("Error adding favorite: $e");
    }
    return false;
  }

  Future<List<GetFavoriteModel>> getFavorites(String userId) async {
    try {
      final response = await _dio.get(
        'https://api.poketstor.com/api/favorite/$userId',
      );

      final List favorites = response.data['favorites'];
      return favorites.map((json) => GetFavoriteModel.fromJson(json)).toList();
    } catch (e) {
      log('Error fetching favorites: $e');
      return [];
    }
  }

  Future<bool> deleteFavorite(String userId, String productId) async {
    final url = '$_baseUrl/favorite/$userId/$productId';

    try {
      final response = await _dio.delete(url);
      if (response.statusCode == 200 || response.statusCode == 204) {
        log("Favorite deleted: ${response.data}");
        return true;
      }
      log("Failed to delete favorite: ${response.statusCode}");
    } catch (e) {
      log("Error deleting favorite: $e");
    }
    return false;
  }
}
