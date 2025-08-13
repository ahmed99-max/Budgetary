import 'package:flutter/material.dart';
import '../../../shared/widgets/neumorphic_container.dart';
import '../../../models/expense_model.dart';

class SpendingChart extends StatelessWidget {
  final List<ExpenseModel> expenses;
  final String period;

  const SpendingChart({
    super.key,
    required this.expenses,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    return NeumorphicContainer(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Spending Chart - $period', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          Container(
            height: 200,
            child: const Center(child: Text('Chart placeholder - Add FL Chart implementation')),
          ),
        ],
      ),
    );
  }
}