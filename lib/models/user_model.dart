import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String? email;

  @HiveField(2)
  String? firstName;

  @HiveField(3)
  String? lastName;

  @HiveField(4)
  String? phoneNumber;

  @HiveField(5)
  String? profilePicture;

  @HiveField(6)
  DateTime? dateOfBirth;

  @HiveField(7)
  String? currency;

  @HiveField(8)
  String? country;

  @HiveField(9)
  double? totalIncome;

  @HiveField(10)
  double? totalExpenses;

  @HiveField(11)
  double? totalSavings;

  @HiveField(12)
  DateTime? createdAt;

  @HiveField(13)
  DateTime? updatedAt;

  @HiveField(14)
  bool? isProfileComplete;

  @HiveField(15)
  Map<String, dynamic>? preferences;

  @HiveField(16)
  List<String>? categories;

  @HiveField(17)
  String? occupation;

  @HiveField(18)
  String? financialGoals;

  UserModel({
    this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.profilePicture,
    this.dateOfBirth,
    this.currency = 'USD',
    this.country,
    this.totalIncome = 0.0,
    this.totalExpenses = 0.0,
    this.totalSavings = 0.0,
    this.createdAt,
    this.updatedAt,
    this.isProfileComplete = false,
    this.preferences,
    this.categories,
    this.occupation,
    this.financialGoals,
  });

  String get fullName => '\${firstName ?? ''} \${lastName ?? ''}'.trim();

  String get initials {
    final first = firstName?.isNotEmpty == true ? firstName![0] : '';
    final last = lastName?.isNotEmpty == true ? lastName![0] : '';
    return (first + last).toUpperCase();
  }

  double get netWorth => (totalIncome ?? 0) - (totalExpenses ?? 0);

  double get savingsRate {
    final income = totalIncome ?? 0;
    if (income == 0) return 0;
    return ((totalSavings ?? 0) / income) * 100;
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'],
      firstName: data['firstName'],
      lastName: data['lastName'],
      phoneNumber: data['phoneNumber'],
      profilePicture: data['profilePicture'],
      dateOfBirth: data['dateOfBirth']?.toDate(),
      currency: data['currency'] ?? 'USD',
      country: data['country'],
      totalIncome: (data['totalIncome'] ?? 0).toDouble(),
      totalExpenses: (data['totalExpenses'] ?? 0).toDouble(),
      totalSavings: (data['totalSavings'] ?? 0).toDouble(),
      createdAt: data['createdAt']?.toDate(),
      updatedAt: data['updatedAt']?.toDate(),
      isProfileComplete: data['isProfileComplete'] ?? false,
      preferences: data['preferences'] != null 
        ? Map<String, dynamic>.from(data['preferences']) 
        : null,
      categories: data['categories'] != null 
        ? List<String>.from(data['categories']) 
        : null,
      occupation: data['occupation'],
      financialGoals: data['financialGoals'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'profilePicture': profilePicture,
      'dateOfBirth': dateOfBirth != null ? Timestamp.fromDate(dateOfBirth!) : null,
      'currency': currency,
      'country': country,
      'totalIncome': totalIncome,
      'totalExpenses': totalExpenses,
      'totalSavings': totalSavings,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'isProfileComplete': isProfileComplete,
      'preferences': preferences,
      'categories': categories,
      'occupation': occupation,
      'financialGoals': financialGoals,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? profilePicture,
    DateTime? dateOfBirth,
    String? currency,
    String? country,
    double? totalIncome,
    double? totalExpenses,
    double? totalSavings,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isProfileComplete,
    Map<String, dynamic>? preferences,
    List<String>? categories,
    String? occupation,
    String? financialGoals,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePicture: profilePicture ?? this.profilePicture,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      currency: currency ?? this.currency,
      country: country ?? this.country,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpenses: totalExpenses ?? this.totalExpenses,
      totalSavings: totalSavings ?? this.totalSavings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      preferences: preferences ?? this.preferences,
      categories: categories ?? this.categories,
      occupation: occupation ?? this.occupation,
      financialGoals: financialGoals ?? this.financialGoals,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, fullName: $fullName)';
  }
}
