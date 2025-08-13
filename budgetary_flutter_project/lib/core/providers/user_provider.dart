import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfile {
  final String? firstName;
  final String? lastName;
  final String? username;
  final String? email;
  final double? totalIncome;
  final double? monthlyBudget;
  final String? country;
  final String? countryCode;
  final String? phoneCode;
  final String? phone;
  final String? currency;
  final String? preferredCurrency;
  final String? state;
  final String? city;
  final String? profileImageUrl;
  final DateTime? createdAt;

  UserProfile({
    this.firstName,
    this.lastName,
    this.username,
    this.email,
    this.totalIncome,
    this.monthlyBudget,
    this.country,
    this.countryCode,
    this.phoneCode,
    this.phone,
    this.currency,
    this.preferredCurrency,
    this.state,
    this.city,
    this.profileImageUrl,
    this.createdAt,
  });

  factory UserProfile.fromFirestore(Map<String, dynamic> data) {
    return UserProfile(
      firstName: data['firstName'],
      lastName: data['lastName'],
      username: data['username'],
      email: data['email'],
      totalIncome: data['totalIncome']?.toDouble(),
      monthlyBudget: data['monthlyBudget']?.toDouble(),
      country: data['country'],
      countryCode: data['countryCode'],
      phoneCode: data['phoneCode'],
      phone: data['phone'],
      currency: data['currency'],
      preferredCurrency: data['preferredCurrency'],
      state: data['state'],
      city: data['city'],
      profileImageUrl: data['profileImageUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'username': username,
      'email': email,
      'totalIncome': totalIncome,
      'monthlyBudget': monthlyBudget,
      'country': country,
      'countryCode': countryCode,
      'phoneCode': phoneCode,
      'phone': phone,
      'currency': currency,
      'preferredCurrency': preferredCurrency,
      'state': state,
      'city': city,
      'profileImageUrl': profileImageUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  UserProfile copyWith({
    String? firstName,
    String? lastName,
    String? username,
    String? email,
    double? totalIncome,
    double? monthlyBudget,
    String? country,
    String? countryCode,
    String? phoneCode,
    String? phone,
    String? currency,
    String? preferredCurrency,
    String? state,
    String? city,
    String? profileImageUrl,
  }) {
    return UserProfile(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      username: username ?? this.username,
      email: email ?? this.email,
      totalIncome: totalIncome ?? this.totalIncome,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      country: country ?? this.country,
      countryCode: countryCode ?? this.countryCode,
      phoneCode: phoneCode ?? this.phoneCode,
      phone: phone ?? this.phone,
      currency: currency ?? this.currency,
      preferredCurrency: preferredCurrency ?? this.preferredCurrency,
      state: state ?? this.state,
      city: city ?? this.city,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt,
    );
  }
}

class UserProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserProfile? _userProfile;
  bool _isLoading = false;
  String? errorMessage;

  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;

  /// Added getter for userId
  String? get userId => FirebaseAuth.instance.currentUser?.uid;

  /// Re-added getter for monthlyIncome (maps to totalIncome)
  double get monthlyIncome => _userProfile?.totalIncome ?? 0.0;

  /// Optional: monthly budget getter
  double get monthlyBudget => _userProfile?.monthlyBudget ?? 0.0;

  /// Load user profile from Firestore
  Future<void> loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        _userProfile = UserProfile.fromFirestore(doc.data()!);
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update user profile
  Future<bool> updateUserProfile({
    String? firstName,
    String? lastName,
    String? username,
    String? email,
    String? country,
    String? countryCode,
    String? phoneCode,
    String? phone,
    double? totalIncome,
    double? monthlyBudget,
    String? currency,
    String? preferredCurrency,
    String? state,
    String? city,
    String? profileImageUrl,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final updatedProfile = (_userProfile ?? UserProfile()).copyWith(
        firstName: firstName,
        lastName: lastName,
        username: username,
        email: email,
        country: country,
        countryCode: countryCode,
        phoneCode: phoneCode,
        phone: phone,
        totalIncome: totalIncome,
        monthlyBudget: monthlyBudget,
        currency: currency,
        preferredCurrency: preferredCurrency,
        state: state,
        city: city,
        profileImageUrl: profileImageUrl,
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .update(updatedProfile.toFirestore());

      _userProfile = updatedProfile;
      errorMessage = null;
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
