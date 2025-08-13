import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:ui'; // For ImageFilter.blur
import '../../../core/providers/expense_provider.dart'; // Assuming you have this for saving expenses
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/neumorphic_container.dart'; // For beautiful container styling
import '../../../models/expense.dart'; // Assuming you have an Expense model

// New CategoryProvider (handles dynamic categories from Firestore)
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

// Function to show the Add Expense modal (call this from your expenses tab/button)
void showAddExpenseModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Allows full height and keyboard handling
    backgroundColor: Colors.transparent, // Transparent for blur effect
    barrierColor: Colors.transparent, // No default overlay color
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
          top: Radius.circular(20)), // Rounded top corners
    ),
    builder: (BuildContext context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.9, // Starts at 90% height
        minChildSize: 0.5, // Minimum draggable size
        maxChildSize: 0.95, // Maximum draggable size
        builder: (BuildContext context, ScrollController scrollController) {
          return BackdropFilter(
            filter: ImageFilter.blur(
                sigmaX: 10, sigmaY: 10), // Blur effect on background
            child: Container(
              decoration: BoxDecoration(
                color: Colors
                    .white, // Solid white background (opaque, no transparency inside sheet)
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20)), // Rounded top
              ),
              child: AddExpenseContent(
                  scrollController:
                      scrollController), // Extracted content widget
            ),
          );
        },
      );
    },
  );
}

// The content of the modal (extracted for clarity)
class AddExpenseContent extends StatefulWidget {
  final ScrollController scrollController;
  const AddExpenseContent({super.key, required this.scrollController});

  @override
  State<AddExpenseContent> createState() => _AddExpenseContentState();
}

class _AddExpenseContentState extends State<AddExpenseContent>
    with TickerProviderStateMixin {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _noteController = TextEditingController();
  final _categoryController = TextEditingController();
  String? _selectedPaymentMethod;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    Provider.of<CategoryProvider>(context, listen: false).ensureLoaded();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _noteController.dispose();
    _categoryController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  void _saveExpense() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final categoryValue = _categoryController.text.trim();
    if (amount <= 0 ||
        categoryValue.isEmpty ||
        _descriptionController.text.isEmpty ||
        _selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);
    if (!categoryProvider.categories.contains(categoryValue)) {
      categoryProvider.addCategory(categoryValue);
    }

    final expense = Expense(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _descriptionController.text,
      amount: amount,
      category: categoryValue,
      date: _selectedDate,
      note: _noteController.text,
      paymentMethod: _selectedPaymentMethod!,
    );

    Provider.of<ExpenseProvider>(context, listen: false).addExpense(expense);
    setState(() => _isLoading = false);
    context.pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Expense added successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: widget.scrollController,
      padding: const EdgeInsets.all(AppConstants.largeSpacing),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: NeumorphicContainer(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.mediumSpacing),
            child: Consumer<CategoryProvider>(
              builder: (context, categoryProvider, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'New Expense Details',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppConstants.extraLargeSpacing),
                    CustomTextField(
                      controller: _amountController,
                      label: 'Amount',
                      hint: 'Enter amount',
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.currency_rupee,
                    ),
                    const SizedBox(height: AppConstants.mediumSpacing),
                    Autocomplete<String>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text == '') {
                          return categoryProvider.categories;
                        }
                        return categoryProvider.categories.where(
                          (c) => c
                              .toLowerCase()
                              .contains(textEditingValue.text.toLowerCase()),
                        );
                      },
                      fieldViewBuilder:
                          (context, ctrl, focusNode, onFieldSubmitted) {
                        _categoryController.value = ctrl.value;
                        return CustomTextField(
                          controller: ctrl,
                          focusNode: focusNode,
                          label: 'Category',
                          hint: 'Type or select a category',
                          prefixIcon: Icons.category,
                        );
                      },
                      onSelected: (selection) {
                        _categoryController.text = selection;
                      },
                    ),
                    const SizedBox(height: AppConstants.mediumSpacing),
                    DropdownButtonFormField<String>(
                      value: _selectedPaymentMethod,
                      decoration: InputDecoration(
                        labelText: 'Payment Method',
                        prefixIcon: const Icon(Icons.payment),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                AppConstants.mediumRadius)),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                        DropdownMenuItem(
                            value: 'Credit Card', child: Text('Credit Card')),
                        DropdownMenuItem(
                            value: 'Debit Card', child: Text('Debit Card')),
                        DropdownMenuItem(value: 'UPI', child: Text('UPI')),
                      ],
                      onChanged: (value) =>
                          setState(() => _selectedPaymentMethod = value),
                    ),
                    const SizedBox(height: AppConstants.mediumSpacing),
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Date',
                          prefixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  AppConstants.mediumRadius)),
                        ),
                        child: Text(
                          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.mediumSpacing),
                    CustomTextField(
                      controller: _descriptionController,
                      label: 'Description',
                      hint: 'Enter description',
                      prefixIcon: Icons.description,
                    ),
                    const SizedBox(height: AppConstants.mediumSpacing),
                    CustomTextField(
                      controller: _noteController,
                      label: 'Note',
                      hint: 'Optional note',
                      prefixIcon: Icons.note,
                    ),
                    const SizedBox(height: AppConstants.largeSpacing),
                    CustomButton(
                      text: 'Save Expense',
                      onPressed: _saveExpense,
                      isLoading: _isLoading,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
