import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? profileImageUrl;
  final String country;
  final String city;
  final String currency;
  final double monthlyIncome;
  final Map<String, double> budgetCategories;
  final List<dynamic> emiLoans;
  final List<dynamic> investments;
  final bool hasCompletedSetup;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.profileImageUrl,
    required this.country,
    required this.city,
    required this.currency,
    required this.monthlyIncome,
    required this.budgetCategories,
    required this.emiLoans,
    required this.investments,
    required this.hasCompletedSetup,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'],
      profileImageUrl: data['profileImageUrl'],
      country: data['country'] ?? '',
      city: data['city'] ?? '',
      currency: data['currency'] ?? 'USD',
      monthlyIncome: (data['monthlyIncome'] ?? 0).toDouble(),
      budgetCategories:
          Map<String, double>.from(data['budgetCategories'] ?? {}),
      emiLoans: List.from(data['emiLoans'] ?? []),
      investments: List.from(data['investments'] ?? []),
      hasCompletedSetup: data['hasCompletedSetup'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'country': country,
      'city': city,
      'currency': currency,
      'monthlyIncome': monthlyIncome,
      'budgetCategories': budgetCategories,
      'emiLoans': emiLoans,
      'investments': investments,
      'hasCompletedSetup': hasCompletedSetup,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? phoneNumber,
    String? profileImageUrl,
    String? country,
    String? city,
    String? currency,
    double? monthlyIncome,
    Map<String, double>? budgetCategories,
    List<dynamic>? emiLoans,
    List<dynamic>? investments,
    bool? hasCompletedSetup,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      country: country ?? this.country,
      city: city ?? this.city,
      currency: currency ?? this.currency,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      budgetCategories: budgetCategories ?? this.budgetCategories,
      emiLoans: emiLoans ?? this.emiLoans,
      investments: investments ?? this.investments,
      hasCompletedSetup: hasCompletedSetup ?? this.hasCompletedSetup,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
