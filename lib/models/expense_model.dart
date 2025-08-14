// lib/core/models/expense_model.dart
// categoryName was already present as a field; made it a getter for explicit access
// Preserved all original fields, methods, and logic (e.g., copyWith, toMap, fromMap)

class ExpenseModel {
  final String id;
  final String title;
  final double amount;
  final String categoryId;
  final String _categoryName; // Made private to enforce getter usage
  final String description;
  final DateTime date;
  final String? receiptPath;
  final DateTime createdAt;
  final DateTime updatedAt;

  ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.categoryId,
    required String categoryName, // Enforce non-null
    required this.description,
    required this.date,
    this.receiptPath,
    required this.createdAt,
    required this.updatedAt,
  }) : _categoryName = categoryName;

  // Added explicit getter for categoryName to resolve undefined getter error
  // This ensures it's accessible as expense.categoryName
  String get categoryName => _categoryName;

  ExpenseModel copyWith({
    String? title,
    double? amount,
    String? categoryId,
    String? categoryName,
    String? description,
    DateTime? date,
    String? receiptPath,
    DateTime? updatedAt,
  }) {
    return ExpenseModel(
      id: id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      description: description ?? this.description,
      date: date ?? this.date,
      receiptPath: receiptPath ?? this.receiptPath,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'description': description,
      'date': date.toIso8601String(),
      'receiptPath': receiptPath,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static ExpenseModel fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      amount: map['amount']?.toDouble() ?? 0.0,
      categoryId: map['categoryId'] ?? '',
      categoryName: map['categoryName'] ?? '',
      description: map['description'] ?? '',
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      receiptPath: map['receiptPath'],
      createdAt:
          DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
