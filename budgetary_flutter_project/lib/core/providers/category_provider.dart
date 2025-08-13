import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CategoryProvider extends ChangeNotifier {
  final List<String> _categories = [];
  List<String> get categories => _categories;

  final _db = FirebaseFirestore.instance;
  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  bool _isLoaded = false;

  Future<void> loadCategories() async {
    if (_userId == null) return;
    final snap = await _db
        .collection('users')
        .doc(_userId)
        .collection('categories')
        .get();
    _categories
      ..clear()
      ..addAll(snap.docs.map((doc) => doc.data()['name'] as String));
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> addCategory(String name) async {
    if (name.isEmpty || _userId == null) return;
    if (_categories.contains(name)) return;
    await _db
        .collection('users')
        .doc(_userId)
        .collection('categories')
        .add({'name': name});
    _categories.add(name);
    notifyListeners();
  }

  Future ensureLoaded() async {
    if (!_isLoaded) await loadCategories();
  }
}
