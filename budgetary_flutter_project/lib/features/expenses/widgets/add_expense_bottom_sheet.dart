import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../models/expense.dart';

class AddExpenseBottomSheet extends StatefulWidget {
  final Expense? expense;
  final Function(Expense) onAddExpense;

  const AddExpenseBottomSheet({
    super.key,
    this.expense,
    required this.onAddExpense,
  });

  @override
  State<AddExpenseBottomSheet> createState() => _AddExpenseBottomSheetState();
}

class _AddExpenseBottomSheetState extends State<AddExpenseBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  final _amountController = TextEditingController();
  final _categoryController = TextEditingController();
  final _paymentMethodController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      _titleController.text = widget.expense!.title;
      _noteController.text = widget.expense!.note;
      _amountController.text = widget.expense!.amount.toString();
      _categoryController.text = widget.expense!.category;
      _paymentMethodController.text = widget.expense!.paymentMethod;
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final expense = Expense(
      id: widget.expense?.id ?? const Uuid().v4(),
      category: _categoryController.text.trim(),
      title: _titleController.text.trim(),
      note: _noteController.text.trim(),
      paymentMethod: _paymentMethodController.text.trim(),
      amount: double.parse(_amountController.text.trim()),
      date: DateTime.now(),
    );

    widget.onAddExpense(expense);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.expense == null ? 'Add Expense' : 'Edit Expense',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (v) => v!.isEmpty ? 'Enter title' : null,
            ),
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: 'Category'),
              validator: (v) => v!.isEmpty ? 'Enter category' : null,
            ),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v!.isEmpty) return 'Enter amount';
                if (double.tryParse(v) == null) return 'Enter valid number';
                return null;
              },
            ),
            TextFormField(
              controller: _paymentMethodController,
              decoration: const InputDecoration(labelText: 'Payment Method'),
            ),
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(labelText: 'Note'),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
