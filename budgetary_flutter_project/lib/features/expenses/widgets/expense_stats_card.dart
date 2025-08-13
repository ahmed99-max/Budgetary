import 'package:flutter/material.dart';
import '../../../models/expense.dart';

class ExpenseStatsCard extends StatelessWidget {
  final List<Expense> expenses;
  final double totalExpenses;
  final double monthlyExpenses;
  final double weeklyExpenses;
  final double dailyAverage;

  const ExpenseStatsCard({
    super.key,
    required this.expenses,
    required this.totalExpenses,
    required this.monthlyExpenses,
    required this.weeklyExpenses,
    required this.dailyAverage,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total: \$${totalExpenses.toStringAsFixed(2)}'),
            Text('Monthly: \$${monthlyExpenses.toStringAsFixed(2)}'),
            Text('Weekly: \$${weeklyExpenses.toStringAsFixed(2)}'),
            Text('Daily Avg: \$${dailyAverage.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }
}
