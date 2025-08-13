import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseModel {
  final String? id;
  final double amount;
  final String category;
  final String description;
  final String paymentMethod;
  final DateTime date;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ExpenseModel({
    this.id,
    required this.amount,
    required this.category,
    required this.description,
    required this.paymentMethod,
    required this.date,
    required this.createdAt,
    this.updatedAt,
  });

  factory ExpenseModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ExpenseModel(
      id: doc.id,
      amount: data['amount'].toDouble(),
      category: data['category'],
      description: data['description'],
      paymentMethod: data['paymentMethod'],
      date: DateTime.parse(data['date']),
      createdAt: DateTime.parse(data['createdAt']),
      updatedAt: data['updatedAt'] != null 
          ? DateTime.parse(data['updatedAt']) 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'category': category,
      'description': description,
      'paymentMethod': paymentMethod,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  ExpenseModel copyWith({
    String? id,
    double? amount,
    String? category,
    String? description,
    String? paymentMethod,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      description: description ?? this.description,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
