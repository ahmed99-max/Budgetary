import 'package:flutter/material.dart';
import '../../../models/budget.dart';

class SavingsGoalCard extends StatelessWidget {
  final SavingsGoal goal;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onAddSavings;

  const SavingsGoalCard({
    super.key,
    required this.goal,
    required this.onEdit,
    required this.onDelete,
    required this.onAddSavings,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(goal.name),
        subtitle: Text(
            'Target: ${goal.targetAmount}, Current: ${goal.currentAmount}'),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit')
              onEdit();
            else if (value == 'delete')
              onDelete();
            else if (value == 'add_savings') onAddSavings();
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
            const PopupMenuItem(
                value: 'add_savings', child: Text('Add Savings')),
          ],
        ),
      ),
    );
  }
}
