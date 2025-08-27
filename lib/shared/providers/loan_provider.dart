// lib/shared/providers/loan_provider.dart
// COMPLETE FIXED VERSION

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../features/loan/models/loan_model.dart';

class LoanProvider extends ChangeNotifier {
  List<LoanModel> _loans = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<LoanModel> get loans => _loans;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get totalLoanAmount =>
      _loans.fold(0, (sum, loan) => sum + loan.totalAmount);

  double get totalRemaining =>
      _loans.fold(0, (sum, loan) => sum + loan.remainingAmount);

  double get totalMonthlyInstallments =>
      _loans.fold(0, (sum, loan) => sum + loan.emiAmount);

  List<LoanModel> get activeLoans =>
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

      print("🎯 LOAN PROVIDER: Loading loans for user: $uid");

      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        print("❌ LOAN PROVIDER: User document not found");
        _setError('User document not found');
        return;
      }

      final userData = userDoc.data() as Map<String, dynamic>?;
      final emiLoansArray = userData?['emiLoans'] as List<dynamic>? ?? [];

      print(
          "📊 LOAN PROVIDER: Found ${emiLoansArray.length} loans in database");

      _loans = emiLoansArray.asMap().entries.map((entry) {
        final index = entry.key;
        final data = entry.value as Map<String, dynamic>;

        print(
            "🔄 LOAN PROVIDER: Processing loan ${index + 1}: ${data['name']}");

        return LoanModel(
          id: data['id']?.toString() ?? 'loan_$index',
          userId: uid,
          name: data['name']?.toString() ?? 'Unnamed Loan',
          totalAmount: _parseDouble(data['totalAmount']),
          emiAmount: _parseDouble(data['monthlyPayment']),
          startDate: _parseDate(data['startDate']),
          tenureMonths: _parseInt(data['totalMonths']),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }).toList();

      print("✅ LOAN PROVIDER: Successfully loaded ${_loans.length} loans");

      notifyListeners();
    } catch (e, stackTrace) {
      print("❌ LOAN PROVIDER ERROR: $e");
      print("📍 STACK TRACE: $stackTrace");
      _setError('Failed to load loans: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addLoan({
    required String title,
    required double amount,
    required double monthlyInstallment,
    required int totalMonths,
    DateTime? startDate,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      _setError('No authenticated user');
      return false;
    }

    try {
      _setLoading(true);
      _setError(null);

      final loanId = DateTime.now().millisecondsSinceEpoch.toString();
      final loanStartDate = startDate ?? DateTime.now();

      final loanData = {
        'id': loanId,
        'name': title,
        'totalAmount': amount,
        'monthlyPayment': monthlyInstallment,
        'totalMonths': totalMonths,
        'startDate': loanStartDate.toIso8601String(),
      };

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'emiLoans': FieldValue.arrayUnion([loanData]),
      });

      await loadLoans();
      return true;
    } catch (e) {
      _setError('Failed to add loan: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateLoan(LoanModel updatedLoan) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      _setError('Unauthorized to update this loan');
      return false;
    }

    try {
      _setLoading(true);
      _setError(null);

      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final userData = userDoc.data() as Map<String, dynamic>?;
      final emiLoansArray = List<Map<String, dynamic>>.from(
          userData?['emiLoans'] as List<dynamic>? ?? []);

      final index = emiLoansArray
          .indexWhere((loanMap) => loanMap['id'] == updatedLoan.id);
      if (index == -1) {
        _setError('Loan not found');
        return false;
      }

      emiLoansArray[index] = {
        'id': updatedLoan.id,
        'name': updatedLoan.name,
        'totalAmount': updatedLoan.totalAmount,
        'monthlyPayment': updatedLoan.emiAmount,
        'totalMonths': updatedLoan.tenureMonths,
        'startDate': updatedLoan.startDate.toIso8601String(),
      };

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'emiLoans': emiLoansArray,
      });

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

      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final userData = userDoc.data() as Map<String, dynamic>?;
      final emiLoansArray = List<Map<String, dynamic>>.from(
          userData?['emiLoans'] as List<dynamic>? ?? []);

      emiLoansArray.removeWhere((loanMap) => loanMap['id'] == loanId);

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'emiLoans': emiLoansArray,
      });

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

      final monthsToReduce = (paymentAmount / loan.emiAmount).floor();
      final newTenureMonths =
          (loan.tenureMonths - monthsToReduce).clamp(0, loan.tenureMonths);

      final updatedLoan = loan.copyWith(
        tenureMonths: newTenureMonths,
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

  // Helper methods for safe parsing
  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    if (value is Timestamp) {
      return value.toDate();
    }
    return DateTime.now();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
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
