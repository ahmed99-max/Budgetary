// lib/shared/providers/loan_provider.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Loan {
  final String id;
  final String userId;
  final String title;
  final double amount;
  final double monthlyInstallment;
  final int remainingMonths;
  final int totalMonths; // Track original loan term
  final DateTime createdAt;
  final DateTime? updatedAt; // Track updates

  Loan({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.monthlyInstallment,
    required this.remainingMonths,
    required this.totalMonths,
    required this.createdAt,
    this.updatedAt,
  });

  // Calculated properties
  double get totalRemaining => monthlyInstallment * remainingMonths;
  double get totalPaid => amount - totalRemaining;
  double get completionPercentage => totalMonths > 0
      ? ((totalMonths - remainingMonths) / totalMonths) * 100
      : 0;
  bool get isCompleted => remainingMonths <= 0;

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'title': title,
        'amount': amount,
        'monthlyInstallment': monthlyInstallment,
        'remainingMonths': remainingMonths,
        'totalMonths': totalMonths,
        'createdAt': createdAt,
        'updatedAt': updatedAt ?? DateTime.now(),
      };

  factory Loan.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Loan(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      monthlyInstallment:
          (data['monthlyInstallment'] as num?)?.toDouble() ?? 0.0,
      remainingMonths: (data['remainingMonths'] as num?)?.toInt() ?? 0,
      totalMonths: (data['totalMonths'] as num?)?.toInt() ??
          (data['remainingMonths'] as num?)?.toInt() ??
          0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Loan copyWith({
    String? title,
    double? amount,
    double? monthlyInstallment,
    int? remainingMonths,
    int? totalMonths,
    DateTime? updatedAt,
  }) {
    return Loan(
      id: id,
      userId: userId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      monthlyInstallment: monthlyInstallment ?? this.monthlyInstallment,
      remainingMonths: remainingMonths ?? this.remainingMonths,
      totalMonths: totalMonths ?? this.totalMonths,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

class LoanProvider extends ChangeNotifier {
  List<Loan> _loans = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Loan> get loans => _loans;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get totalLoanAmount =>
      _loans.fold(0, (sum, loan) => sum + loan.amount);

  double get totalRemaining => _loans.fold(
      0, (sum, loan) => sum + (loan.monthlyInstallment * loan.remainingMonths));

  double get totalMonthlyInstallments =>
      _loans.fold(0, (sum, loan) => sum + loan.monthlyInstallment);

  List<Loan> get activeLoans =>
      _loans.where((loan) => !loan.isCompleted).toList();

  // lib/shared/providers/loan_provider.dart

  Future<void> loadLoans() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      _setError('No authenticated user');
      return;
    }

    try {
      _setLoading(true);
      _setError(null);

      print('🔄 LOADING LOANS FOR CURRENT UID: $uid');

      // FIXED: Query the subcollection under the user document
      final snapshot = await FirebaseFirestore.instance
          .collection('users') // ← Go to users collection
          .doc(uid) // ← Get the current user's document
          .collection('emiLoans') // ← Access the emiLoans subcollection
          .orderBy('createdAt',
              descending: true) // ← No index needed for subcollection
          .get();

      _loans = snapshot.docs.map((doc) => Loan.fromFirestore(doc)).toList();
      print('✅ LOADED ${_loans.length} LOANS FOR USER: $uid');
      notifyListeners();
    } catch (e) {
      print('❌ ERROR LOADING LOANS: $e');
      _setError('Failed to load loans: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addLoan({
    required String title,
    required double amount,
    required double monthlyInstallment,
    required int remainingMonths,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      _setError('No authenticated user');
      return false;
    }

    try {
      _setLoading(true);
      _setError(null);
      final now = DateTime.now();

      final loanData = {
        'title': title,
        'amount': amount,
        'monthlyInstallment': monthlyInstallment,
        'remainingMonths': remainingMonths,
        'totalMonths': remainingMonths,
        'createdAt': now,
        'updatedAt': now,
      };

      // FIXED: Add to subcollection
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('emiLoans')
          .add(loanData);

      final newLoan = Loan(
        id: doc.id,
        userId: uid,
        title: title,
        amount: amount,
        monthlyInstallment: monthlyInstallment,
        remainingMonths: remainingMonths,
        totalMonths: remainingMonths,
        createdAt: now,
        updatedAt: now,
      );

      _loans.insert(0, newLoan);
      print('✅ ADDED LOAN FOR USER: $uid - $title');
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ ERROR ADDING LOAN: $e');
      _setError('Failed to add loan: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateLoan(Loan updatedLoan) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      _setError('Unauthorized to update this loan');
      return false;
    }

    try {
      _setLoading(true);
      _setError(null);

      // FIXED: Update in subcollection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('emiLoans')
          .doc(updatedLoan.id)
          .update(updatedLoan.toFirestore());

      final index = _loans.indexWhere((loan) => loan.id == updatedLoan.id);
      if (index != -1) {
        _loans[index] = updatedLoan;
        notifyListeners();
      }

      print('✅ UPDATED LOAN: ${updatedLoan.title}');
      return true;
    } catch (e) {
      print('❌ ERROR UPDATING LOAN: $e');
      _setError('Failed to update loan: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteLoan(String loanId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      _setError('No authenticated user');
      return false;
    }

    try {
      _setLoading(true);
      _setError(null);

      // FIXED: Delete from subcollection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('emiLoans')
          .doc(loanId)
          .delete();

      _loans.removeWhere((loan) => loan.id == loanId);
      print('✅ DELETED LOAN: $loanId');
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ ERROR DELETING LOAN: $e');
      _setError('Failed to delete loan: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> makePayment(String loanId, double paymentAmount) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      _setError('No authenticated user');
      return false;
    }

    try {
      _setLoading(true);
      _setError(null);

      final loanIndex = _loans.indexWhere((loan) => loan.id == loanId);
      if (loanIndex == -1) {
        _setError('Loan not found');
        return false;
      }

      final loan = _loans[loanIndex];
      if (loan.userId != uid) {
        _setError('Unauthorized to update this loan');
        return false;
      }

      // Calculate new remaining
      final currentRemaining = loan.totalRemaining;
      final newRemaining =
          (currentRemaining - paymentAmount).clamp(0.0, double.infinity);
      final newRemainingMonths = loan.monthlyInstallment > 0
          ? (newRemaining / loan.monthlyInstallment).ceil()
          : 0;

      final updatedLoan = loan.copyWith(
        remainingMonths: newRemainingMonths,
        updatedAt: DateTime.now(),
      );

      final success = await updateLoan(updatedLoan);
      if (success) {
        print('✅ PAYMENT MADE: $paymentAmount on ${loan.title}');
      }
      return success;
    } catch (e) {
      print('❌ ERROR MAKING PAYMENT: $e');
      _setError('Failed to make payment: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    if (!loading) notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearLoans() {
    _loans.clear();
    notifyListeners();
  }
}
