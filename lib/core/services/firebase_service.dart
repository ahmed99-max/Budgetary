import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  static FirebaseAuth get auth => FirebaseAuth.instance;
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;
  static FirebaseStorage get storage => FirebaseStorage.instance;

  static Future<void> init() async {
    // Configure Firestore settings
    await firestore.enableNetwork();
    // Set up auth state persistence
    await auth.setPersistence(Persistence.LOCAL);
  }

  // Auth Methods
  static User? get currentUser => auth.currentUser;
  static bool get isLoggedIn => auth.currentUser != null;
  static String get userId => auth.currentUser?.uid ?? '';

  // Firestore Collections
  static CollectionReference get usersCollection =>
      firestore.collection('users');
  static CollectionReference get expensesCollection =>
      firestore.collection('expenses');
  static CollectionReference get budgetsCollection =>
      firestore.collection('budgets');
  static CollectionReference get categoriesCollection =>
      firestore.collection('categories');

  // User Document
  static DocumentReference getUserDocument(String uid) =>
      usersCollection.doc(uid);

  // Storage References
  static Reference get storageRef => storage.ref();
  static Reference getUserStorageRef(String uid) =>
      storageRef.child('users').child(uid);

  // NEW: user-scoped subcollections
  static CollectionReference<Map<String, dynamic>> userLoansCollection(
          String uid) =>
      firestore.collection('users').doc(uid).collection('loans');

  static CollectionReference<Map<String, dynamic>> userExpensesCollection(
          String uid) =>
      firestore.collection('users').doc(uid).collection('expenses');

  // (optional) convenience for current user (throws if null)
  static String get currentUid => auth.currentUser!.uid;

  // Helper Methods
  static Future<bool> checkUserExists(String uid) async {
    try {
      final doc = await getUserDocument(uid).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final doc = await getUserDocument(uid).get();
      return doc.exists ? doc.data() as Map<String, dynamic>? : null;
    } catch (e) {
      return null;
    }
  }

  static Future<void> createUserDocument(
      String uid, Map<String, dynamic> data) async {
    await getUserDocument(uid).set({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> updateUserDocument(
      String uid, Map<String, dynamic> data) async {
    await getUserDocument(uid).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // NEW: Create or update with merge
  static Future<void> setUserDocument(
      String uid, Map<String, dynamic> data) async {
    try {
      await getUserDocument(uid).set(data, SetOptions(merge: true));
    } catch (e, st) {
      print('ERROR FirebaseService.setUserDocument: $e');
      print('STACK FirebaseService.setUserDocument: $st');
      rethrow;
    }
  }
}
