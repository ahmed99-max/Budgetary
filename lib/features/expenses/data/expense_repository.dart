import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/firebase_service.dart';
import '../../../shared/models/expense_model.dart';

class ExpenseRepository {
  final CollectionReference _col = FirebaseService.expensesCollection;

  /// Stream expenses for current user only
  Stream<List<ExpenseModel>> watchExpenses() {
    return _col
        .where('userId', isEqualTo: FirebaseService.userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => ExpenseModel.fromFirestore(doc)).toList());
  }

  /// Add a new expense for the logged-in user
  Future<void> addExpense(ExpenseModel expense) {
    final data = expense.toFirestore();
    data['userId'] = FirebaseService.userId;
    data['createdAt'] = FieldValue.serverTimestamp();
    data['updatedAt'] = FieldValue.serverTimestamp();
    return _col.add(data);
  }

  /// Update existing expense
  Future<void> updateExpense(ExpenseModel expense) {
    final data = expense.toFirestore();
    data['updatedAt'] = FieldValue.serverTimestamp();
    return _col.doc(expense.id).update(data);
  }

  /// Delete expense by id
  Future<void> deleteExpense(String id) {
    return _col.doc(id).delete();
  }
}
