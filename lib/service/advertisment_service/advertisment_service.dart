import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:poketstore/model/advertisment_model/advertisment_model.dart';

class AdvertisementService {
  final Dio _dio = Dio();
  final String _baseUrl = "https://api.poketstor.com";

  Future<List<AdvertisementModel>> fetchAdvertisements() async {
    try {
      final response = await _dio.get("$_baseUrl/adminDashboard/advertisement");

      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((json) => AdvertisementModel.fromJson(json)).toList();
      } else {
        log("Failed to fetch advertisements: ${response.statusCode}");
        return [];
      }
    } catch (e, stacktrace) {
      log("Error fetching advertisements: $e", stackTrace: stacktrace);
      return [];
    }
  }
}
