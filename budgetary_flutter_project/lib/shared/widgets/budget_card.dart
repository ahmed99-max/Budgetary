import 'package:flutter/material.dart';
import '../../../models/budget.dart';

class BudgetCard extends StatelessWidget {
  final Budget budget;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onAddExpense;

  const BudgetCard({
    super.key,
    required this.budget,
    required this.onEdit,
    required this.onDelete,
    required this.onAddExpense,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(budget.category),
        subtitle: Text('Amount: ${budget.amount}'),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit')
              onEdit();
            else if (value == 'delete')
              onDelete();
            else if (value == 'add_expense') onAddExpense();
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
            const PopupMenuItem(
                value: 'add_expense', child: Text('Add Expense')),
          ],
        ),
      ),
    );
  }
}
