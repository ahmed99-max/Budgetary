import 'package:cloud_firestore/cloud_firestore.dart';

class LoanModel {
  final String id;
  final String userId;
  final String name;
  final double totalAmount;
  final double emiAmount;
  final DateTime startDate;
  final int tenureMonths; // total months
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

  /// Months elapsed from startDate to now (floor, >= 0)
  int get monthsElapsed {
    final now = DateTime.now();
    int diff = (now.year - startDate.year) * 12 + (now.month - startDate.month);
    if (now.day < startDate.day) diff -= 1; // approximate month boundary
    return diff < 0 ? 0 : diff;
  }

  int get remainingMonths {
    final rem = tenureMonths - monthsElapsed;
    return rem < 0 ? 0 : rem;
  }

  double get remainingAmount {
    final rem = remainingMonths * emiAmount;
    // don’t exceed total; clamp to [0, totalAmount]
    if (rem < 0) return 0;
    if (rem > totalAmount) return totalAmount;
    return rem;
  }

  double get progress {
    if (totalAmount <= 0) return 0;
    final paid = totalAmount - remainingAmount;
    return (paid / totalAmount).clamp(0.0, 1.0);
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
  } // Getter aliases for existing fields (based on your model structure)
  double get monthlyInstallment => emiAmount; // Assumes emiAmount exists
  double get amount => totalAmount; // Assumes totalAmount exists
  String get title => name; // Assumes name exists
  
}
