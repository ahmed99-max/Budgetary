import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<QuerySnapshot> getUserExpenses(String userId) async {
    return await _firestore
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .orderBy('date', descending: true)
        .get();
  }

  Future<DocumentReference> addExpense(String userId, Map<String, dynamic> expenseData) async {
    expenseData['createdAt'] = DateTime.now().toIso8601String();
    return await _firestore
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .add(expenseData);
  }

  Future<void> updateExpense(String userId, String expenseId, Map<String, dynamic> data) async {
    data['updatedAt'] = DateTime.now().toIso8601String();
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .doc(expenseId)
        .update(data);
  }

  Future<void> deleteExpense(String userId, String expenseId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .doc(expenseId)
        .delete();
  }

  Future<DocumentSnapshot> getExpense(String userId, String expenseId) async {
    return await _firestore
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .doc(expenseId)
        .get();
  }

  Stream<QuerySnapshot> getUserExpensesStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .orderBy('date', descending: true)
        .snapshots();
  }

  Future<QuerySnapshot> getExpensesByCategory(String userId, String category) async {
    return await _firestore
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .where('category', isEqualTo: category)
        .orderBy('date', descending: true)
        .get();
  }

  Future<QuerySnapshot> getExpensesByDateRange(
      String userId, DateTime start, DateTime end) async {
    return await _firestore
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .where('date', isGreaterThanOrEqualTo: start.toIso8601String())
        .where('date', isLessThanOrEqualTo: end.toIso8601String())
        .orderBy('date', descending: true)
        .get();
  }
}
