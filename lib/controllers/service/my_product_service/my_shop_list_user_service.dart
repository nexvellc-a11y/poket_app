import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:poketstore/model/my_shope_model/my_shop_list_user_model.dart';

class MyShopListUserService {
  final String baseUrl = 'https://api.poketstor.com/api';

  Future<MyShopListUserResponse> fetchUserShopList(String userId) async {
    final Uri uri = Uri.parse('$baseUrl/products/user/$userId');

    try {
      final response = await http.get(uri);

      log('Response Status Code: ${response.statusCode}');
      log('Response Body: ${response.body}'); // 👈 LOG the raw response

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return MyShopListUserResponse.fromJson(data);
      } else {
        throw Exception(
          'Failed to fetch user shop list: ${response.statusCode}, Response: ${response.body}',
        );
      }
    } catch (error) {
      log('Exception caught: $error'); // 👈 LOG the error
      throw Exception('Failed to connect to the server: $error');
    }
  }
}
