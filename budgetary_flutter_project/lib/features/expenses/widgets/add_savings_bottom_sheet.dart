import 'package:flutter/material.dart';
import '../../../models/budget.dart';

class AddSavingsBottomSheet extends StatelessWidget {
  final SavingsGoal? goal;

  const AddSavingsBottomSheet({super.key, this.goal});

  @override
  Widget build(BuildContext context) {
    TextEditingController nameCtrl =
        TextEditingController(text: goal?.name ?? '');
    TextEditingController targetCtrl =
        TextEditingController(text: goal?.targetAmount.toString() ?? '');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(goal == null ? 'Add Savings Goal' : 'Edit Savings Goal',
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(labelText: 'Goal Name'),
          ),
          TextField(
            controller: targetCtrl,
            decoration: const InputDecoration(labelText: 'Target Amount'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // TODO: Save goal
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
