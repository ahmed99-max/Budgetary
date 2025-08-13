import 'package:flutter/material.dart';
import '../../../shared/widgets/neumorphic_app_bar.dart';

class ExpenseDetailsScreen extends StatelessWidget {
  final String expenseId;
  const ExpenseDetailsScreen({super.key, required this.expenseId});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: NeumorphicAppBar(title: 'Expense Details'),
      body: Center(child: Text('Expense Details Screen - Coming Soon!')),
    );
  }
}