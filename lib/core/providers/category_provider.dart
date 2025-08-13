import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  final String icon;
  final Color color;

  CategoryModel({required this.id, required this.name, required this.icon, required this.color});
}

class CategoryProvider with ChangeNotifier {
  final List<CategoryModel> _categories = [
    CategoryModel(id: '1', name: 'Food & Dining', icon: '🍽️', color: Color(0xFFE74C3C)),
    CategoryModel(id: '2', name: 'Transportation', icon: '🚗', color: Color(0xFF3498DB)),
    CategoryModel(id: '3', name: 'Shopping', icon: '🛍️', color: Color(0xFF9B59B6)),
    CategoryModel(id: '4', name: 'Entertainment', icon: '🎬', color: Color(0xFFE67E22)),
    CategoryModel(id: '5', name: 'Bills', icon: '📄', color: Color(0xFF95A5A6)),
    CategoryModel(id: '6', name: 'Health', icon: '⚕️', color: Color(0xFF27AE60)),
    CategoryModel(id: '7', name: 'Education', icon: '📚', color: Color(0xFFE67E22)),
    CategoryModel(id: '8', name: 'Travel', icon: '✈️', color: Color(0xFF3498DB)),
  ];

  List<CategoryModel> get categories => _categories;

  void addCategory(CategoryModel category) {
    _categories.add(category);
    notifyListeners();
  }

  void removeCategory(String id) {
    _categories.removeWhere((cat) => cat.id == id);
    notifyListeners();
  }

  CategoryModel? getCategoryById(String id) {
    try {
      return _categories.firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }
}