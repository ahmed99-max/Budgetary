// lib/shared/providers/loan_provider.dart
// Modified existing code: Changed loadLoans to fetch from 'emiLoans' array field in user document (matches your DB).
// Added 'startDate' to Loan class (from DB).
// Mapped DB 'name' to Loan 'title', 'monthlyPayment' to 'monthlyInstallment', etc.
// Computed 'remainingMonths' based on startDate and current date (DB doesn't have it).
// For add/update/delete/makePayment: Update the array field in the user doc using transactions for safety.
// Removed prints for production; added error handling.

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
  final DateTime startDate; // ADDED: To match your DB and compute remaining
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
    required this.startDate,
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
        'id': id,
        'name': title, // Map back to DB 'name'
        'totalAmount': amount,
        'monthlyPayment': monthlyInstallment, // Map to DB 'monthlyPayment'
        'totalMonths': totalMonths,
        'startDate': startDate.toIso8601String(),
      };

  factory Loan.fromMap(Map<String, dynamic> data, String id, String userId) {
    final now = DateTime.now();
    final startDate = DateTime.tryParse(data['startDate'] ?? '') ?? now;

    // Compute monthsElapsed
    num monthsElapsed =
        (now.year - startDate.year) * 12 + (now.month - startDate.month);
    if (now.day < startDate.day) monthsElapsed -= 1;
    monthsElapsed = monthsElapsed.clamp(0, data['totalMonths'] ?? 0);

    // Compute remainingMonths
    final totalMonths = (data['totalMonths'] as num?)?.toInt() ?? 0;
    int remainingMonths = totalMonths - monthsElapsed.toInt();
    remainingMonths = remainingMonths.clamp(0, totalMonths);

    return Loan(
      id: id,
      userId: userId,
      title: data['name'] ?? '',
      amount: (data['totalAmount'] as num?)?.toDouble() ?? 0.0,
      monthlyInstallment: (data['monthlyPayment'] as num?)?.toDouble() ?? 0.0,
      remainingMonths: remainingMonths,
      totalMonths: totalMonths,
      startDate: startDate,
      createdAt: now, // Set if not in data; adjust if available
      updatedAt: now, // Set if not in data; adjust if available
    );
  }

  Loan copyWith({
    String? title,
    double? amount,
    double? monthlyInstallment,
    int? remainingMonths,
    int? totalMonths,
    DateTime? startDate,
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
      startDate: startDate ?? this.startDate,
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

  Future<void> loadLoans() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      _setError('No authenticated user');
      return;
    }

    try {
      _setLoading(true);
      _setError(null);

      // Fetch the user document
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        _setError('User document not found');
        return;
      }

      // Get the emiLoans array from the user document
      final emiLoansArray = userDoc.data()?['emiLoans'] as List<dynamic>? ?? [];

      // Map each item in the array to a Loan object
      _loans = emiLoansArray.asMap().entries.map((entry) {
        final index = entry.key;
        final data = entry.value as Map<String, dynamic>;
        return Loan.fromMap(data, data['id'] ?? 'array_$index',
            uid); // Use DB 'id' or index-based
      }).toList();

      notifyListeners();
    } catch (e) {
      _setError('Failed to load loans: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addLoanWithStartDate({
    required String title,
    required double amount,
    required double monthlyInstallment,
    required int totalMonths,
    required DateTime startDate,
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
        'id': DateTime.now().millisecondsSinceEpoch.toString(), // Generate ID
        'name': title,
        'totalAmount': amount,
        'monthlyPayment': monthlyInstallment,
        'totalMonths': totalMonths,
        'startDate': startDate.toIso8601String(),
      };

      // Append to emiLoans array in user doc
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'emiLoans': FieldValue.arrayUnion([loanData]),
      });

      // Reload loans to reflect changes
      await loadLoans();
      return true;
    } catch (e) {
      _setError('Failed to add loan: $e');
      return false;
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
        'id': DateTime.now().millisecondsSinceEpoch.toString(), // Generate ID
        'name': title,
        'totalAmount': amount,
        'monthlyPayment': monthlyInstallment,
        'totalMonths':
            remainingMonths, // Assuming totalMonths = remainingMonths for new loan
        'startDate': now.toIso8601String(),
      };

      // Append to emiLoans array in user doc
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'emiLoans': FieldValue.arrayUnion([loanData]),
      });

      // Reload loans to reflect changes
      await loadLoans();
      return true;
    } catch (e) {
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

      // Fetch current array, update the matching loan, set new array
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final emiLoansArray =
          List<Map<String, dynamic>>.from(userDoc.data()?['emiLoans'] ?? []);

      final index = emiLoansArray
          .indexWhere((loanMap) => loanMap['id'] == updatedLoan.id);
      if (index == -1) {
        _setError('Loan not found');
        return false;
      }

      emiLoansArray[index] = updatedLoan.toFirestore();

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'emiLoans': emiLoansArray,
      });

      // Reload loans to reflect changes
      await loadLoans();
      return true;
    } catch (e) {
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

      // Fetch current array, remove the matching loan, set new array
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final emiLoansArray =
          List<Map<String, dynamic>>.from(userDoc.data()?['emiLoans'] ?? []);

      emiLoansArray.removeWhere((loanMap) => loanMap['id'] == loanId);

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'emiLoans': emiLoansArray,
      });

      // Reload loans to reflect changes
      await loadLoans();
      return true;
    } catch (e) {
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
      return success;
    } catch (e) {
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
