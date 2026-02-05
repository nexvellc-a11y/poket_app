import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:poketstore/model/address_model/address_model.dart';
import 'package:poketstore/service/address_service/address_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeliveryAddressController extends ChangeNotifier {
  final DeliveryAddressService _service = DeliveryAddressService();

  List<Address> addresses = [];
  bool loading = false;
  String? errorMessage;

  String? _userId; // 🔹 Cache userId

  // ---------- Helpers ----------

  Future<String?> _getUserId() async {
    if (_userId != null) return _userId;

    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('userId');
    return _userId;
  }

  void _setLoading(bool value) {
    if (loading == value) return;
    loading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    errorMessage = message;
    notifyListeners();
  }

  bool _validateUser(String? userId, String action) {
    if (userId == null) {
      _setError("User ID not found. Please log in again.");
      log('DeliveryAddressController: User ID null during $action');
      return false;
    }
    return true;
  }

  // ---------- API Actions ----------

  Future<void> submitAddress(Address address) async {
    _setLoading(true);
    errorMessage = null;

    final userId = await _getUserId();
    if (!_validateUser(userId, "submitAddress")) {
      _setLoading(false);
      return;
    }

    try {
      final result = await _service.createAddress(userId!, address);

      if (result != null) {
        addresses = result.addresses;
        log('✅ Address added. Total: ${addresses.length}');
      } else {
        _setError("Failed to create address.");
      }
    } catch (e, st) {
      log('❌ submitAddress error', error: e, stackTrace: st);
      _setError("Error creating address");
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchAddresses({bool showLoader = true}) async {
    if (showLoader) _setLoading(true);
    errorMessage = null;

    final userId = await _getUserId();
    if (!_validateUser(userId, "fetchAddresses")) {
      if (showLoader) _setLoading(false);
      return;
    }

    try {
      final result = await _service.getAddresses(userId!);

      if (result != null) {
        addresses = result.addresses;
        log('✅ Addresses fetched: ${addresses.length}');
      } else {
        _setError("Failed to fetch addresses.");
      }
    } catch (e, st) {
      log('❌ fetchAddresses error', error: e, stackTrace: st);
      _setError("Error fetching addresses");
    } finally {
      if (showLoader) _setLoading(false);
    }
  }

  Future<void> updateAddress(String addressId, Address updatedAddress) async {
    _setLoading(true);
    errorMessage = null;

    final userId = await _getUserId();
    if (!_validateUser(userId, "updateAddress")) {
      _setLoading(false);
      return;
    }

    try {
      final result = await _service.updateAddress(
        userId!,
        addressId,
        updatedAddress,
      );

      if (result != null) {
        addresses = result.addresses;
        log('✅ Address updated');
      } else {
        _setError("Failed to update address.");
      }
    } catch (e, st) {
      log('❌ updateAddress error', error: e, stackTrace: st);
      _setError("Error updating address");
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteAddress(String addressId) async {
    _setLoading(true);
    errorMessage = null;

    final userId = await _getUserId();
    if (!_validateUser(userId, "deleteAddress")) {
      _setLoading(false);
      return;
    }

    try {
      final result = await _service.deleteAddress(userId!, addressId);

      if (result != null) {
        addresses = result.addresses;
        log('✅ Address deleted. Remaining: ${addresses.length}');
      } else {
        _setError("Failed to delete address.");
      }
    } catch (e, st) {
      log('❌ deleteAddress error', error: e, stackTrace: st);
      _setError("Error deleting address");
    } finally {
      _setLoading(false);
    }
  }
}
