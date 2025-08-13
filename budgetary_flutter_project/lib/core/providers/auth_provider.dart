import 'package:cloud_firestore/cloud_firestore.dart'; // Required for FirebaseFirestore and FieldValue
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'user_provider.dart'; // Import if using UserProvider for loading profiles

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _user = _authService.currentUser;
    _authService.authStateChanges.listen((u) {
      _user = u;
      notifyListeners();
    });
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> signUpWithEmail(String email, String password) async {
    try {
      _setLoading(true);
      final userCredential =
          await _authService.signUpWithEmail(email, password);
      final user = userCredential.user; // Safe access
      if (user != null) {
        await _createInitialProfile(user.uid, user.email ?? '');
        _errorMessage = null;
        return true;
      }
      _errorMessage = 'User creation failed (null user)';
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithEmail(String email, String password) async {
    try {
      _setLoading(true);
      await _authService.signInWithEmail(email, password);
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      _setLoading(true);
      final userCredential = await _authService
          .signInWithGoogle(); // Assuming this returns UserCredential
      final user = userCredential?.user; // Safe access
      if (user != null) {
        await _createInitialProfile(user.uid, user.email ?? '');
        _errorMessage = null;
        return true;
      }
      _errorMessage = 'Google sign-in failed (null user)';
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      await _authService.resetPassword(email);
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    try {
      _setLoading(true);
      await _authService.signOut();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _createInitialProfile(String uid, String email) async {
    debugPrint('Creating initial profile for UID: $uid'); // For debugging
    final docRef = FirebaseFirestore.instance.collection('users').doc(uid);
    final doc = await docRef.get();
    if (!doc.exists) {
      await docRef.set({
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'firstName': '', // Default empty, to be updated in profile setup
        'username': '', // Default empty
        'totalIncome': 0.0,
      });
      debugPrint('Initial profile created successfully');
    } else {
      debugPrint('Profile already exists for UID: $uid');
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
