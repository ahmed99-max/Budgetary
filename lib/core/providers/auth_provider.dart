// lib/core/providers/auth_provider.dart
// Updated to include uid, displayName, and email getters (pulling from Firebase current user)
// Preserved all original fields, methods, and logic (e.g., _initialize, signInWithEmail, signUpWithEmail, signInWithGoogle, signOut, error mapping)
// No other changes—everything from your provided code is intact

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:developer' as developer;

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  // Added for fixes: Getters pulling from Firebase current user
  // These resolve the undefined getter errors in user_setup_screen.dart
  String get uid => _auth.currentUser?.uid ?? '';
  String? get displayName => _auth.currentUser?.displayName;
  String? get email => _auth.currentUser?.email;

  AuthProvider() {
    _initialize();
  }

  void _initialize() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
    _initGoogleSignIn();
  }

  Future<void> _initGoogleSignIn() async {
    try {
      await GoogleSignIn.instance.initialize(
          // Provide your OAuth web client ID if necessary:
          // clientId: 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com',
          // Optionally:
          // serverClientId: 'YOUR_SERVER_CLIENT_ID.apps.googleusercontent.com',
          );
    } catch (e) {
      developer.log('GoogleSignIn init error: $e');
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<bool> signInWithEmail(String email, String password) async {
    _setLoading(true);
    _setError(null);
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      developer.log('Email sign-in error: ${e.code}');
      _setError(_mapFirebaseAuthError(e.code));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signUpWithEmail(
      String email, String password, String displayName) async {
    _setLoading(true);
    _setError(null);
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await cred.user?.updateDisplayName(displayName);
      await cred.user?.reload();
      return true;
    } on FirebaseAuthException catch (e) {
      developer.log('Email sign-up error: ${e.code}');
      _setError(_mapFirebaseAuthError(e.code));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _setError(null);
    try {
      if (!GoogleSignIn.instance.supportsAuthenticate()) {
        _setError('Google Sign-In not supported on this platform.');
        return false;
      }

      // Initiate interactive sign-in
      final account = await GoogleSignIn.instance.authenticate(
        scopeHint: ['email'],
      );
      if (account == null) {
        _setError('Google sign-in cancelled.');
        return false;
      }

      final googleAuth = await account.authentication;

      if (googleAuth.idToken == null) {
        _setError('Missing ID token from Google.');
        return false;
      }

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        // Drop accessToken since it's no longer reliably available
      );

      await _auth.signInWithCredential(credential);
      return true;
    } on FirebaseAuthException catch (e) {
      developer.log('Google sign-in error: ${e.code}');
      _setError(_mapFirebaseAuthError(e.code));
      return false;
    } catch (e) {
      developer.log('Google sign-in unknown error: $e');
      _setError('Google sign-in failed.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    _setError(null);
    try {
      await Future.wait([
        _auth.signOut(),
        GoogleSignIn.instance.signOut(),
      ]);
    } catch (e) {
      developer.log('Sign out error: $e');
    } finally {
      _user = null;
      _setLoading(false);
      notifyListeners();
    }
  }

  String _mapFirebaseAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This user has been disabled.';
      case 'operation-not-allowed':
        return 'Operation not allowed.';
      default:
        return 'Authentication error. Please try again.';
    }
  }
}
