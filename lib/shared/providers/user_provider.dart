// lib/shared/providers/user_provider.dart
// FIXED VERSION

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart'; // FIXED: Added for debugPrint

import '../models/user_model.dart';
import '../../core/services/firebase_service.dart';
import '../../core/services/hive_service.dart';
import 'loan_provider.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasUser => _user != null;
  String get userName => _user?.name ?? '';
  String get userEmail => _user?.email ?? '';
  String get currency => _user?.currency ?? 'USD';
  double get monthlyIncome => _user?.monthlyIncome ?? 0.0;
  String get country => _user?.country ?? '';
  String get city => _user?.city ?? '';
  String? get profileImageUrl => _user?.profileImageUrl;
  Map<String, dynamic> get budgetCategories => _user?.budgetCategories ?? {};

  void _setLoading(bool loading) {
    _isLoading = loading;
    if (!loading) notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  Future<void> loadUserData(String uid) async {
    try {
      _setLoading(true);
      _setError(null);
      debugPrint(
          '🔄 LOADING USER DATA FOR UID: $uid'); // FIXED: avoid_print -> debugPrint

      final doc = await FirebaseService.getUserDocument(uid).get();
      if (doc.exists) {
        // FIXED: Safely cast Object? to Map
        final data = doc.data();
        if (data != null && data is Map<String, dynamic>) {
          // FIXED: Convert Timestamps to DateTime for Hive compatibility
          final fixedData = _convertTimestamps(data);
          _user = UserModel.fromFirestore(doc);
          await HiveService.saveUserData('current_user', fixedData);
          debugPrint(
              '✅ USER DATA LOADED: ${_user!.name} (${_user!.email})'); // FIXED: avoid_print -> debugPrint
        } else {
          throw Exception(
              'Invalid data format from Firestore: expected Map<String, dynamic>');
        }
      } else {
        // Retry once
        await Future.delayed(const Duration(seconds: 1));
        final retryDoc = await FirebaseService.getUserDocument(uid).get();
        if (retryDoc.exists) {
          final retryData = retryDoc.data();
          if (retryData != null && retryData is Map<String, dynamic>) {
            final fixedRetryData = _convertTimestamps(retryData);
            _user = UserModel.fromFirestore(retryDoc);
            await HiveService.saveUserData('current_user', fixedRetryData);
            debugPrint(
                '✅ USER DATA LOADED ON RETRY: ${_user!.name}'); // FIXED: avoid_print -> debugPrint
          } else {
            throw Exception('Invalid retry data format from Firestore');
          }
        } else {
          _setError('User data not found');
          debugPrint(
              '❌ USER DATA NOT FOUND FOR UID: $uid'); // FIXED: avoid_print -> debugPrint
        }
      }
    } catch (e) {
      debugPrint(
          '❌ ERROR LOADING USER DATA: $e'); // FIXED: avoid_print -> debugPrint
      _setError('Failed to load user data: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ADDED: Helper to convert Timestamps for Hive (prevents unknown type error)
  Map<String, dynamic> _convertTimestamps(Map<String, dynamic> data) {
    final fixed = Map<String, dynamic>.from(data);
    fixed.forEach((key, value) {
      if (value is Timestamp) {
        fixed[key] = value.toDate();
      }
    });
    return fixed;
  }

  Future<bool> updateProfile({
    String? name,
    String? phoneNumber,
    String? country,
    String? city,
    String? currency,
    double? monthlyIncome,
    Map<String, double>? budgetCategories,
    List<dynamic>? emiLoans,
    List<dynamic>? investments,
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
      await HiveService.saveUserData('current_user', updatedUser.toFirestore());
      debugPrint(
          '✅ USER PROFILE UPDATED: ${updatedUser.name}'); // FIXED: avoid_print -> debugPrint
      return true;
    } catch (e, st) {
      debugPrint(
          '❌ ERROR IN updateProfile: $e'); // FIXED: avoid_print -> debugPrint
      debugPrint('Stack trace: $st'); // FIXED: avoid_print -> debugPrint
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
    required Map<String, dynamic> budgetCategories,
    required List<dynamic> emiLoans,
    required List<dynamic> investments,
    LoanProvider? loanProvider, // 👈 NEW: Accept loan provider
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
        budgetCategories: Map.from(budgetCategories),
        emiLoans: emiLoans,
        investments: investments,
        hasCompletedProfileSetup: true,
        updatedAt: DateTime.now(),
      );
      debugPrint(
          'DEBUG: Updating user doc with data:'); // FIXED: avoid_print -> debugPrint
      debugPrint(updatedUser
          .toFirestore()
          .toString()); // FIXED: avoid_print -> debugPrint
      await FirebaseService.setUserDocument(
        _user!.uid,
        updatedUser.toFirestore(),
      );
      _user = updatedUser;
      // 👈 NEW: Create loans in LoanProvider if provided
      if (loanProvider != null && emiLoans.isNotEmpty) {
        debugPrint(
            '🏦 CREATING ${emiLoans.length} LOANS FROM PROFILE SETUP'); // FIXED: avoid_print -> debugPrint
        for (var loanData in emiLoans) {
          if (loanData is Map<String, dynamic>) {
            final title = loanData['name'] ?? 'Loan';
            final amount = (loanData['amount'] ?? 0.0) as double;
            final monthlyInstallment = (loanData['monthlyPayment'] ?? 0.0)
                as double; // FIXED: Match LoanEMI field (monthlyPayment)
            final totalMonths = (loanData['totalMonths'] ?? 0)
                as int; // FIXED: Use totalMonths instead of remainingMonths
            if (amount > 0 && monthlyInstallment > 0 && totalMonths > 0) {
              final success = await loanProvider.addLoan(
                title: title,
                amount: amount,
                monthlyInstallment: monthlyInstallment,
                totalMonths: totalMonths, // FIXED: Use totalMonths
                startDate: DateTime.now(),
              );
              debugPrint(success
                  ? '✅ CREATED LOAN: $title'
                  : '❌ FAILED TO CREATE LOAN: $title'); // FIXED: avoid_print -> debugPrint
            }
          }
        }
      }
      debugPrint(
          '✅ PROFILE SETUP COMPLETED FOR: ${updatedUser.name}'); // FIXED: avoid_print -> debugPrint
      return true;
    } catch (e, st) {
      debugPrint(
          '❌ ERROR IN completeProfileSetup: $e'); // FIXED: avoid_print -> debugPrint
      debugPrint('Stack trace: $st'); // FIXED: avoid_print -> debugPrint
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
      debugPrint(
          '✅ PROFILE IMAGE UPLOADED'); // FIXED: avoid_print -> debugPrint
      return true;
    } catch (e, st) {
      debugPrint(
          '❌ ERROR IN uploadProfileImage: $e'); // FIXED: avoid_print -> debugPrint
      debugPrint('Stack trace: $st'); // FIXED: avoid_print -> debugPrint
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
