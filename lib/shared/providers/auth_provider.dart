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

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;
  bool get hasCompletedProfileSetup => _hasCompletedProfileSetup;

  AuthProvider() {
    _initialize();
  }

  void _initialize() {
    // Listen to auth state changes
    FirebaseService.auth.authStateChanges().listen((User? user) async {
      _user = user;
      if (user != null) {
        await _checkProfileSetupStatus();
      } else {
        _hasCompletedProfileSetup = false;
      }
      notifyListeners();
    });
  }

  Future<void> _checkProfileSetupStatus() async {
    if (_user != null) {
      final userData = await FirebaseService.getUserData(_user!.uid);
      _hasCompletedProfileSetup = userData?['hasCompletedSetup'] ?? false;
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

  // Authentication Methods
  Future<bool> signInWithEmail(String email, String password) async {
    try {
      _setLoading(true);
      _setError(null);

      await FirebaseService.auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

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
        await credential.user!.reload();
        _user = FirebaseService.auth.currentUser;

        // Create user document in Firestore
        await FirebaseService.createUserDocument(credential.user!.uid, {
          'name': name,
          'email': email.trim(),
          'hasCompletedSetup': false,
        });
      }

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

  Future<void> signOut() async {
    try {
      _setLoading(true);
      await FirebaseService.auth.signOut();
      await HiveService.clearAllData();
      _hasCompletedProfileSetup = false;
      NavigationService.goToLanding();
    } catch (e) {
      _setError('Failed to sign out');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> completeProfileSetup() async {
    if (_user != null) {
      print('DEBUG: Completing profile setup in AuthProvider');
      await FirebaseService.updateUserDocument(_user!.uid, {
        'hasCompletedSetup': true,
      });
      _hasCompletedProfileSetup = true;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'invalid-email':
        return 'Email address is invalid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
