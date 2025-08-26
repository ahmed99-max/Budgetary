// lib/features/loan/models/loan_model.dart
// BATCH 2: UPDATE THIS EXISTING FILE

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LoanModel {
  final String id;
  final String userId;
  final String name;
  final double totalAmount;
  final double emiAmount;
  final DateTime startDate; // This should be the actual loan start date
  final int tenureMonths; // Total loan tenure in months
  final DateTime createdAt;
  final DateTime updatedAt;

  LoanModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.totalAmount,
    required this.emiAmount,
    required this.startDate,
    required this.tenureMonths,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Calculate months elapsed from the actual loan start date to current date
  int get monthsElapsed {
    final now = DateTime.now();

    // Calculate the difference in months more accurately
    int yearDiff = now.year - startDate.year;
    int monthDiff = now.month - startDate.month;
    int dayDiff = now.day - startDate.day;

    int totalMonthsElapsed = yearDiff * 12 + monthDiff;

    // If the current day is before the start day, subtract one month
    if (dayDiff < 0) {
      totalMonthsElapsed -= 1;
    }

    return totalMonthsElapsed < 0 ? 0 : totalMonthsElapsed;
  }

  int get remainingMonths {
    final rem = tenureMonths - monthsElapsed;
    return rem < 0 ? 0 : rem;
  }

  double get remainingAmount {
    return remainingMonths * emiAmount;
  }

  double get paidAmount {
    return monthsElapsed * emiAmount;
  }

  double get progress {
    if (tenureMonths <= 0) return 0;
    return (monthsElapsed / tenureMonths).clamp(0.0, 1.0);
  }

  double get progressPercentage {
    return progress * 100;
  }

  bool get isCompleted => remainingMonths <= 0;

  // Status based on completion percentage
  String get status {
    if (isCompleted) return 'Completed';
    if (progressPercentage >= 80) return 'Near Completion';
    if (progressPercentage >= 50) return 'Mid Term';
    if (progressPercentage >= 25) return 'Early Stage';
    return 'Just Started';
  }

  Color get statusColor {
    if (isCompleted) return Colors.green;
    if (progressPercentage >= 80) return Colors.orange;
    if (progressPercentage >= 50) return Colors.blue;
    return Colors.purple;
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'name': name,
        'totalAmount': totalAmount,
        'emiAmount': emiAmount,
        'startDate': Timestamp.fromDate(startDate),
        'tenureMonths': tenureMonths,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  factory LoanModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return LoanModel(
      id: doc.id,
      userId: d['userId'] as String,
      name: d['name'] as String,
      totalAmount: (d['totalAmount'] as num).toDouble(),
      emiAmount: (d['emiAmount'] as num).toDouble(),
      startDate: (d['startDate'] as Timestamp).toDate(),
      tenureMonths: d['tenureMonths'] as int,
      createdAt: (d['createdAt'] as Timestamp).toDate(),
      updatedAt: (d['updatedAt'] as Timestamp).toDate(),
    );
  }

  // Getter aliases for existing fields (backward compatibility)
  double get monthlyInstallment => emiAmount;
  double get amount => totalAmount;
  String get title => name;
  int get totalMonths => tenureMonths;
  double get totalPaid => paidAmount;
  double get totalRemaining => remainingAmount;
  double get completionPercentage => progressPercentage;

  // copyWith method for updates
  LoanModel copyWith({
    String? id,
    String? userId,
    String? name,
    double? totalAmount,
    double? emiAmount,
    DateTime? startDate,
    int? tenureMonths,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LoanModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      totalAmount: totalAmount ?? this.totalAmount,
      emiAmount: emiAmount ?? this.emiAmount,
      startDate: startDate ?? this.startDate,
      tenureMonths: tenureMonths ?? this.tenureMonths,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // For better debugging
  @override
  String toString() {
    return 'LoanModel(id: $id, name: $name, totalAmount: $totalAmount, emiAmount: $emiAmount, startDate: $startDate, tenureMonths: $tenureMonths, monthsElapsed: $monthsElapsed, remainingMonths: $remainingMonths, progressPercentage: ${progressPercentage.toStringAsFixed(1)}%)';
  }
}
