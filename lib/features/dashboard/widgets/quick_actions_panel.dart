import 'package:flutter/material.dart';
import '../../../shared/widgets/neumorphic_container.dart';
import '../../../shared/widgets/neumorphic_button.dart';

class QuickActionsPanel extends StatelessWidget {
  final VoidCallback? onAddExpense;
  final VoidCallback? onViewReports;
  final VoidCallback? onScanReceipt;
  final VoidCallback? onSetBudget;

  const QuickActionsPanel({
    super.key,
    this.onAddExpense,
    this.onViewReports,
    this.onScanReceipt,
    this.onSetBudget,
  });

  @override
  Widget build(BuildContext context) {
    return NeumorphicContainer(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: NeumorphicButton(text: 'Add Expense', onPressed: onAddExpense)),
              const SizedBox(width: 12),
              Expanded(child: NeumorphicButton(text: 'View Reports', onPressed: onViewReports)),
            ],
          ),
        ],
      ),
    );
  }
}