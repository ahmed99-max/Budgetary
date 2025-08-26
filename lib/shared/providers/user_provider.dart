// lib/shared/providers/user_provider.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
  Map<String, double> get budgetCategories => _user?.budgetCategories ?? {};

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

      print('🔄 LOADING USER DATA FOR UID: $uid');
      final doc = await FirebaseService.getUserDocument(uid).get();

      if (doc.exists) {
        // FIXED: Safely cast Object? to Map<String, dynamic>
        final data = doc.data();
        if (data != null && data is Map<String, dynamic>) {
          // FIXED: Convert Timestamps to DateTime for Hive compatibility
          final fixedData = _convertTimestamps(data);
          _user = UserModel.fromFirestore(doc);
          await HiveService.saveUserData('current_user', fixedData);
          print('✅ USER DATA LOADED: ${_user!.name} (${_user!.email})');
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
            print('✅ USER DATA LOADED ON RETRY: ${_user!.name}');
          } else {
            throw Exception('Invalid retry data format from Firestore');
          }
        } else {
          _setError('User data not found');
          print('❌ USER DATA NOT FOUND FOR UID: $uid');
        }
      }
    } catch (e) {
      print('❌ ERROR LOADING USER DATA: $e');
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

      print('✅ USER PROFILE UPDATED: ${updatedUser.name}');
      return true;
    } catch (e, st) {
      print('❌ ERROR IN updateProfile: $e');
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
        budgetCategories: Map<String, double>.from(budgetCategories),
        emiLoans: emiLoans,
        investments: investments,
        hasCompletedProfileSetup: true,
        updatedAt: DateTime.now(),
      );

      print('DEBUG: Updating user doc with data:');
      print(updatedUser.toFirestore());

      await FirebaseService.setUserDocument(
        _user!.uid,
        updatedUser.toFirestore(),
      );

      _user = updatedUser;

      // 👈 NEW: Create loans in LoanProvider if provided
      if (loanProvider != null && emiLoans.isNotEmpty) {
        print('🏦 CREATING ${emiLoans.length} LOANS FROM PROFILE SETUP');
        for (var loanData in emiLoans) {
          if (loanData is Map<String, dynamic>) {
            final title = loanData['name'] ?? 'Loan';
            final amount = (loanData['amount'] ?? 0.0) as double;
            final monthlyInstallment = (loanData['monthlyPayment'] ?? 0.0)
                as double; // FIXED: Match LoanEMI field (monthlyPayment)
            final remainingMonths = (loanData['remainingMonths'] ?? 0)
                as int; // FIXED: Match LoanEMI field

            if (amount > 0 && monthlyInstallment > 0 && remainingMonths > 0) {
              final success = await loanProvider.addLoan(
                title: title,
                amount: amount,
                monthlyInstallment: monthlyInstallment,
                remainingMonths: remainingMonths,
              );
              print(success
                  ? '✅ CREATED LOAN: $title'
                  : '❌ FAILED TO CREATE LOAN: $title');
            }
          }
        }
      }

      print('✅ PROFILE SETUP COMPLETED FOR: ${updatedUser.name}');
      return true;
    } catch (e, st) {
      print('❌ ERROR IN completeProfileSetup: $e');
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
      print('✅ PROFILE IMAGE UPLOADED');
      return true;
    } catch (e, st) {
      print('❌ ERROR IN uploadProfileImage: $e');
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
