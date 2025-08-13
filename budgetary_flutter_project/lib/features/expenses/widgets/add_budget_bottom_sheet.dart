import 'package:flutter/material.dart';
import '../../../models/budget.dart';

class AddBudgetBottomSheet extends StatelessWidget {
  final Budget? budget;

  const AddBudgetBottomSheet({super.key, this.budget});

  @override
  Widget build(BuildContext context) {
    TextEditingController categoryCtrl =
        TextEditingController(text: budget?.category ?? '');
    TextEditingController amountCtrl =
        TextEditingController(text: budget?.amount.toString() ?? '');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(budget == null ? 'Add Budget' : 'Edit Budget',
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: categoryCtrl,
            decoration: const InputDecoration(labelText: 'Category'),
          ),
          TextField(
            controller: amountCtrl,
            decoration: const InputDecoration(labelText: 'Amount'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // TODO: Save budget
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
