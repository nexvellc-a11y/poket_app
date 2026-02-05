import 'dart:developer';
import 'package:dio/dio.dart';
// Ensure this import points to your updated address_model.dart file
import 'package:poketstore/model/address_model/address_model.dart';

/// Service class for interacting with the delivery address API.
class DeliveryAddressService {
  final Dio _dio = Dio();

  /// Creates a new delivery address for a given user.
  /// Returns an [AddressListResponse] if successful, otherwise null.
  Future<AddressListResponse?> createAddress(
    String userId,
    Address address,
  ) async {
    final url = 'https://api.poketstor.com/api/delivery/create/$userId';

    try {
      // Send the address data nested under an "address" key, as indicated by your backend.
      final response = await _dio.post(
        url,
        data: {"address": address.toJson()},
      );

      log("Create address response data: ${response.data}");
      // Parse the response using the new AddressListResponse model
      return AddressListResponse.fromJson(response.data);
    } on DioException catch (e) {
      // Handle Dio-specific errors (e.g., network issues, bad response)
      log("Create address Dio error: ${e.message}");
      if (e.response != null) {
        log("Create address Dio error response data: ${e.response?.data}");
      }
      return null;
    } catch (e) {
      // Handle any other unexpected errors
      log("Create address generic error: $e");
      return null;
    }
  }

  /// Fetches all delivery addresses for a given user.
  /// Returns an [AddressListResponse] if successful, otherwise null.
  Future<AddressListResponse?> getAddresses(String userId) async {
    final url = 'https://api.poketstor.com/api/delivery/get/$userId';

    try {
      final response = await _dio.get(url);
      log("Get address response data: ${response.data}");
      // Parse the response using the new AddressListResponse model
      return AddressListResponse.fromJson(response.data);
    } on DioException catch (e) {
      // Handle Dio-specific errors
      log("Get address Dio error: ${e.message}");
      if (e.response != null) {
        log("Get address Dio error response data: ${e.response?.data}");
      }
      return null;
    } catch (e) {
      // Handle any other unexpected errors
      log("Get address generic error: $e");
      return null;
    }
  }

  Future<AddressListResponse?> updateAddress(
    String userId,
    String addressId,
    Address address,
  ) async {
    final url =
        'https://api.poketstor.com/api/delivery/update/$userId/$addressId';

    try {
      // Send the updated address data nested under an "address" key.
      final response = await _dio.put(url, data: {"address": address.toJson()});

      log("Update address response data: ${response.data}");
      // Parse the response using the AddressListResponse model
      return AddressListResponse.fromJson(response.data);
    } on DioException catch (e) {
      log("Update address Dio error: ${e.message}");
      if (e.response != null) {
        log("Update address Dio error response data: ${e.response?.data}");
      }
      return null;
    } catch (e) {
      log("Update address generic error: $e");
      return null;
    }
  }

  Future<AddressListResponse?> deleteAddress(
    String userId,
    String addressId,
  ) async {
    final url =
        'https://api.poketstor.com/api/delivery/delete/$userId/$addressId';

    try {
      final response = await _dio.delete(url);

      log("Delete address response data: ${response.data}");
      // Parse the response using the AddressListResponse model
      return AddressListResponse.fromJson(response.data);
    } on DioException catch (e) {
      log("Delete address Dio error: ${e.message}");
      if (e.response != null) {
        log("Delete address Dio error response data: ${e.response?.data}");
      }
      return null;
    } catch (e) {
      log("Delete address generic error: $e");
      return null;
    }
  }
}
