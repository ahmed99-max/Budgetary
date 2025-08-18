import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../models/user_model.dart';
import '../../core/services/firebase_service.dart';
import '../../core/services/hive_service.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasUser => _user != null;

  // User data getters
  String get userName => _user?.name ?? '';
  String get userEmail => _user?.email ?? '';
  String get currency => _user?.currency ?? 'USD';
  double get monthlyIncome => _user?.monthlyIncome ?? 0.0;
  String get country => _user?.country ?? '';
  String get city => _user?.city ?? '';
  String? get profileImageUrl => _user?.profileImageUrl;
  Map<String, double> get budgetCategories => _user?.budgetCategories ?? {};

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  Future<void> loadUserData(String uid) async {
    try {
      _setLoading(true);
      _setError(null);

      final doc = await FirebaseService.getUserDocument(uid).get();
      if (doc.exists) {
        _user = UserModel.fromFirestore(doc);
        // Cache user data locally
        await HiveService.saveUserData('current_user', doc.data()!);
      }
    } catch (e) {
      _setError('Failed to load user data');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? phoneNumber,
    String? country,
    String? city,
    String? currency,
    double? monthlyIncome,
    Map<String, double>? budgetCategories,
    List<String>? emiLoans,
    List<String>? investments,
  }) async {
    if (_user == null) return false;

    try {
      _setLoading(true);
      _setError(null);

      final updatedUser = _user!.copyWith(
        name: name,
        phoneNumber: phoneNumber,
        country: country,
        city: city,
        currency: currency,
        monthlyIncome: monthlyIncome,
        budgetCategories: budgetCategories,
        emiLoans: emiLoans,
        investments: investments,
        updatedAt: DateTime.now(),
      );

      await FirebaseService.setUserDocument(
        _user!.uid,
        updatedUser.toFirestore(),
      );

      _user = updatedUser;

      // Update local cache
      await HiveService.saveUserData('current_user', updatedUser.toFirestore());

      return true;
    } catch (e, st) {
      print('ERROR in updateProfile: $e');
      print('Stack trace: $st');
      _setError('Failed to update profile');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> completeProfileSetup({
    required String phoneNumber,
    required String country,
    required String city,
    required String currency,
    required double monthlyIncome,
    required Map<String, double> budgetCategories,
    required List<String> emiLoans,
    required List<String> investments,
  }) async {
    if (_user == null) return false;

    try {
      _setLoading(true);
      _setError(null);

      final updatedUser = _user!.copyWith(
        phoneNumber: phoneNumber,
        country: country,
        city: city,
        currency: currency,
        monthlyIncome: monthlyIncome,
        budgetCategories: budgetCategories,
        emiLoans: emiLoans,
        investments: investments,
        hasCompletedSetup: true,
        updatedAt: DateTime.now(),
      );

      print('DEBUG: Updating user doc with data:');
      print(updatedUser.toFirestore());

      await FirebaseService.setUserDocument(
        _user!.uid,
        updatedUser.toFirestore(),
      );

      _user = updatedUser;

      return true;
    } catch (e, st) {
      print('ERROR in completeProfileSetup: $e');
      print('Stack trace: $st');
      _setError('Failed to complete profile setup');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> uploadProfileImage(XFile imageFile) async {
    if (_user == null) return false;

    try {
      _setLoading(true);
      _setError(null);

      final file = File(imageFile.path);
      final ref = FirebaseService.getUserStorageRef(_user!.uid)
          .child('profile_image.jpg');

      await ref.putFile(file);
      final downloadUrl = await ref.getDownloadURL();

      final updatedUser = _user!.copyWith(
        profileImageUrl: downloadUrl,
        updatedAt: DateTime.now(),
      );

      await FirebaseService.setUserDocument(
        _user!.uid,
        updatedUser.toFirestore(),
      );

      _user = updatedUser;

      return true;
    } catch (e, st) {
      print('ERROR in uploadProfileImage: $e');
      print('Stack trace: $st');
      _setError('Failed to upload profile image');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
