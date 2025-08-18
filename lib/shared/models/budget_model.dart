import 'package:cloud_firestore/cloud_firestore.dart';

class BudgetModel {
  final String id;
  final String userId;
  final String category;
  final double allocatedAmount;
  final double spentAmount;
  final String period; // 'monthly', 'weekly', 'yearly'
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

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
    required this.createdAt,
    required this.updatedAt,
  });

  factory BudgetModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BudgetModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      category: data['category'] ?? '',
      allocatedAmount: (data['allocatedAmount'] ?? 0).toDouble(),
      spentAmount: (data['spentAmount'] ?? 0).toDouble(),
      period: data['period'] ?? 'monthly',
      startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (data['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
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
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  BudgetModel copyWith({
    String? category,
    double? allocatedAmount,
    double? spentAmount,
    String? period,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    DateTime? updatedAt,
  }) {
    return BudgetModel(
      id: id,
      userId: userId,
      category: category ?? this.category,
      allocatedAmount: allocatedAmount ?? this.allocatedAmount,
      spentAmount: spentAmount ?? this.spentAmount,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // Helper getters
  double get remainingAmount => allocatedAmount - spentAmount;
  double get spentPercentage =>
      allocatedAmount > 0 ? (spentAmount / allocatedAmount) * 100 : 0;
  bool get isOverBudget => spentAmount > allocatedAmount;
  bool get isNearLimit => spentPercentage >= 80;

  String getFormattedAllocated(String currency) {
    return '$currency ${allocatedAmount.toStringAsFixed(2)}';
  }

  String getFormattedSpent(String currency) {
    return '$currency ${spentAmount.toStringAsFixed(2)}';
  }

  String getFormattedRemaining(String currency) {
    return '$currency ${remainingAmount.toStringAsFixed(2)}';
  }
}
