import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:poketstore/model/product_search_model/state_search.dart';

class StateService {
  final Dio _dio = Dio();

  Future<StateModel?> getStates() async {
    const url = "https://api.poketstor.com/api/location/states";

    try {
      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        return StateModel.fromJson(response.data);
      } else {
        log("Error: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      log("State API Error: $e");
      return null;
    }
  }
}
