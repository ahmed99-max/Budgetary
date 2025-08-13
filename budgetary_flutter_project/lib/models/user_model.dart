import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? city;
  final String? phone;
  final String? photoURL;
  final double? monthlyBudget;
  final bool profileCompleted;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.city,
    this.phone,
    this.photoURL,
    this.monthlyBudget,
    this.profileCompleted = false,
    required this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      city: data['city'],
      phone: data['phone'],
      photoURL: data['photoURL'],
      monthlyBudget: data['monthlyBudget']?.toDouble(),
      profileCompleted: data['profileCompleted'] ?? false,
      createdAt: DateTime.parse(data['createdAt']),
      updatedAt: data['updatedAt'] != null 
          ? DateTime.parse(data['updatedAt']) 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'city': city,
      'phone': phone,
      'photoURL': photoURL,
      'monthlyBudget': monthlyBudget,
      'profileCompleted': profileCompleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? city,
    String? phone,
    String? photoURL,
    double? monthlyBudget,
    bool? profileCompleted,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      city: city ?? this.city,
      phone: phone ?? this.phone,
      photoURL: photoURL ?? this.photoURL,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      profileCompleted: profileCompleted ?? this.profileCompleted,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
