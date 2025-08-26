import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/firebase_service.dart';
import '../../core/services/hive_service.dart';
import '../../core/services/navigation_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasCompletedProfileSetup = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;
  bool get hasCompletedProfileSetup => _hasCompletedProfileSetup;

  AuthProvider() {
    _initialize();
  }

  void _initialize() {
    FirebaseService.auth.authStateChanges().listen((User? user) async {
      try {
        _user = user;
        if (user != null) {
          await _checkProfileSetupStatus();
        } else {
          _hasCompletedProfileSetup = false;
        }
        notifyListeners();
      } catch (e) {
        debugPrint('Error in authStateChanges listener: $e');
        _setError('Authentication state error');
      }
    });
  }

  Future<void> _checkProfileSetupStatus() async {
    if (_user != null) {
      final userDocRef = FirebaseService.getUserDocument(_user!.uid);
      try {
        final userDocSnapshot = await userDocRef.get();
        if (userDocSnapshot.exists) {
          final data = userDocSnapshot.data() as Map<String, dynamic>;
          _hasCompletedProfileSetup = data['hasCompletedProfileSetup'] ?? false;
        } else {
          _hasCompletedProfileSetup = false;
        }
      } catch (e) {
        await Future.delayed(const Duration(seconds: 1));
        final userDocSnapshot = await userDocRef.get();
        if (userDocSnapshot.exists) {
          final data = userDocSnapshot.data() as Map<String, dynamic>;
          _hasCompletedProfileSetup = data['hasCompletedProfileSetup'] ?? false;
        } else {
          _hasCompletedProfileSetup = false;
        }
      }
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  Future<bool> signInWithEmail(String email, String password) async {
    try {
      _setLoading(true);
      _setError(null);
      await FirebaseService.auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await _checkProfileSetupStatus();
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_getAuthErrorMessage(e.code));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signUpWithEmail(
      String email, String password, String name) async {
    try {
      _setLoading(true);
      _setError(null);
      final credential =
          await FirebaseService.auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      if (credential.user != null) {
        await credential.user!.updateDisplayName(name);
        _user = credential.user;
        await FirebaseService.createUserDocument(credential.user!.uid, {
          'name': name,
          'email': email.trim(),
          'hasCompletedProfileSetup': false,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'country': '',
          'city': '',
          'currency': 'USD',
          'monthlyIncome': 0.0,
          'budgetCategories': {},
          'emiLoans': [],
          'investments': [],
        });
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _setError(_getAuthErrorMessage(e.code));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    // REMOVED context parameter
    try {
      _setLoading(true);
      await FirebaseService.auth.signOut();
      await HiveService.clearAllData();
      _hasCompletedProfileSetup = false;
      NavigationService.goToLanding(); // Direct navigation
    } finally {
      _setLoading(false);
    }
  }

  Future<void> completeProfileSetup() async {
    if (_user != null) {
      await FirebaseService.updateUserDocument(_user!.uid, {
        'hasCompletedProfileSetup': true,
      });
      _hasCompletedProfileSetup = true;
      notifyListeners();
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _setError(null);
      await FirebaseService.auth.sendPasswordResetEmail(email: email.trim());
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_getAuthErrorMessage(e.code));
      return false;
    } catch (e) {
      _setError('An unexpected error occurred');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
