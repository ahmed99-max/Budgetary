import 'package:flutter/material.dart';
import '../../../models/budget.dart';

class BudgetOverviewChart extends StatelessWidget {
  final List<Budget> budgets;

  const BudgetOverviewChart({super.key, required this.budgets});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with FL Chart or other library
    return Container(
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: const Text('Budget Overview Chart Placeholder'),
    );
  }
}
