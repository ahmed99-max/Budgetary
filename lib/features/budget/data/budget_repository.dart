import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/firebase_service.dart';
import '../../../shared/models/budget_model.dart';

class BudgetRepository {
  final CollectionReference _col = FirebaseService.budgetsCollection;

  /// Stream budgets for current user only
  Stream<List<BudgetModel>> watchBudgets() {
    return _col
        .where('userId', isEqualTo: FirebaseService.userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => BudgetModel.fromFirestore(doc)).toList());
  }

  /// Add a new budget for the logged-in user
  Future<void> addBudget(BudgetModel budget) {
    final data = budget.toFirestore();
    data['userId'] = FirebaseService.userId;
    data['createdAt'] = FieldValue.serverTimestamp();
    data['updatedAt'] = FieldValue.serverTimestamp();
    return _col.add(data);
  }

  /// Update existing budget
  Future<void> updateBudget(BudgetModel budget) {
    final data = budget.toFirestore();
    data['updatedAt'] = FieldValue.serverTimestamp();
    return _col.doc(budget.id).update(data);
  }

  /// Delete budget by id
  Future<void> deleteBudget(String id) {
    return _col.doc(id).delete();
  }
}
