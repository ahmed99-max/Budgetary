import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final double amount;
  final String category;
  final String? subcategory;
  final DateTime date;
  final String? receiptUrl;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  ExpenseModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.amount,
    required this.category,
    this.subcategory,
    required this.date,
    this.receiptUrl,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExpenseModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ExpenseModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      category: data['category'] ?? '',
      subcategory: data['subcategory'],
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      receiptUrl: data['receiptUrl'],
      metadata: data['metadata'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'amount': amount,
      'category': category,
      'subcategory': subcategory,
      'date': Timestamp.fromDate(date),
      'receiptUrl': receiptUrl,
      'metadata': metadata,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  ExpenseModel copyWith({
    String? title,
    String? description,
    double? amount,
    String? category,
    String? subcategory,
    DateTime? date,
    String? receiptUrl,
    Map<String, dynamic>? metadata,
    DateTime? updatedAt,
    required String id,
  }) {
    return ExpenseModel(
      id: id,
      userId: userId,
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      date: date ?? this.date,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // Helper getters
  String get categoryName => category;
  bool get hasReceipt => receiptUrl != null && receiptUrl!.isNotEmpty;

  // Formatted amount for display
  String getFormattedAmount(String currency) {
    return '$currency ${amount.toStringAsFixed(2)}';
  }
}
