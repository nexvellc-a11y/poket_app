import 'package:dio/dio.dart';
import 'package:poketstore/model/product_search_model/district_search_model.dart';

class DistrictService {
  final Dio _dio = Dio();

  Future<DistrictModel> fetchDistricts(String state) async {
    try {
      final response = await _dio.get(
        "https://api.poketstor.com/api/location/states/$state",
      );

      return DistrictModel.fromJson(response.data);
    } catch (e) {
      throw Exception("Failed to load districts: $e");
    }
  }
}
