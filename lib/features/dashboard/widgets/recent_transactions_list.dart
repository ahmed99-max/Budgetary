import 'package:flutter/material.dart';
import '../../../shared/widgets/neumorphic_container.dart';
import '../../../models/expense_model.dart';

class RecentTransactionsList extends StatelessWidget {
  final List<ExpenseModel> transactions;
  final VoidCallback? onViewAll;

  const RecentTransactionsList({
    super.key,
    required this.transactions,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return NeumorphicContainer(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              TextButton(onPressed: onViewAll, child: const Text('View All')),
            ],
          ),
          const SizedBox(height: 16),
          const Text('No transactions yet. Add your first expense!'),
        ],
      ),
    );
  }
}