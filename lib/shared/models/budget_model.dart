import 'package:cloud_firestore/cloud_firestore.dart';

class BudgetModel {
  final String id;
  final String userId;
  final String category;
  final double allocatedAmount;
  final double spentAmount;
  final String period;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final bool isLoan; // New flag for loan budgets
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isLoanCategory;

  BudgetModel({
    required this.id,
    required this.userId,
    required this.category,
    required this.allocatedAmount,
    required this.spentAmount,
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    this.isLoan = false,
    required this.createdAt,
    required this.updatedAt,
    this.isLoanCategory = false, // Default to false
  });

  factory BudgetModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BudgetModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      category: data['category'] ?? '',
      allocatedAmount: (data['allocatedAmount'] ?? 0).toDouble(),
      spentAmount: (data['spentAmount'] ?? 0).toDouble(),
      period: data['period'] ?? '',
      startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (data['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] ?? true,
      isLoan: data['isLoan'] ?? false, // New
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isLoanCategory: data['isLoanCategory'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'category': category,
      'allocatedAmount': allocatedAmount,
      'spentAmount': spentAmount,
      'period': period,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'isActive': isActive,
      'isLoan': isLoan, // New
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isLoanCategory': isLoanCategory,
    };
  }

  BudgetModel copyWith({
    String? id,
    String? userId,
    String? category,
    double? allocatedAmount,
    double? spentAmount,
    String? period,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    bool? isLoan,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      allocatedAmount: allocatedAmount ?? this.allocatedAmount,
      spentAmount: spentAmount ?? this.spentAmount,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      isLoan: isLoan ?? this.isLoan,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isOverBudget => spentAmount > allocatedAmount;
  bool get isNearLimit => spentAmount >= allocatedAmount * 0.8;
}
