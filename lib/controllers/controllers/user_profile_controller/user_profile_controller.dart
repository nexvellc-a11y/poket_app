import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poketstore/model/user_profile_model/user_profile_model.dart';
import 'package:poketstore/service/user_profile_service/user_profile_service.dart';
import 'dart:developer';

class UserProfileController extends ChangeNotifier {
  final UserProfileService _service = UserProfileService();

  UserProfile? _userProfile;
  bool _isLoading = false;
  String? _error;

  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load user profile using userId from SharedPreferences
  Future<void> loadUserProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null || userId.isEmpty) {
        _error = 'User not logged in. Please login again.';
        log('User ID not found in SharedPreferences');
        return;
      }

      final profile = await _service.fetchUserProfile(userId);

      if (profile != null) {
        _userProfile = profile;
        log('User profile loaded successfully');
      } else {
        _error = 'Failed to load profile.';
        log('Profile fetch returned null');
      }
    } catch (e) {
      _error = 'Something went wrong: $e';
      log('Error in loadUserProfile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Set profile manually (eg: after login)
  void setUserProfile(UserProfile profile) {
    _userProfile = profile;
    _error = null;
    notifyListeners();
  }

  /// Clear profile on logout
  void clearUserProfile() {
    _userProfile = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Update user profile using userId from SharedPreferences
  Future<bool> updateUserProfile({String? newName, String? newEmail}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null || userId.isEmpty) {
        _error = 'User not logged in.';
        return false;
      }

      final Map<String, dynamic> updateData = {};

      if (newName != null && newName.isNotEmpty) {
        updateData['name'] = newName;
      }
      if (newEmail != null && newEmail.isNotEmpty) {
        updateData['email'] = newEmail;
      }

      if (updateData.isEmpty) {
        _error = 'No data to update.';
        return false;
      }

      final updatedProfile = await _service.updateUserProfile(
        userId,
        updateData,
      );

      if (updatedProfile != null) {
        _userProfile = updatedProfile;
        log('Profile updated successfully');
        return true;
      } else {
        _error = 'Profile update failed.';
        return false;
      }
    } catch (e) {
      _error = 'Update failed: $e';
      log('Error in updateUserProfile: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
