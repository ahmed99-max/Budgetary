import 'package:flutter/material.dart';
import '../../../shared/widgets/neumorphic_app_bar.dart';

class ExpenseListScreen extends StatelessWidget {
  const ExpenseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: NeumorphicAppBar(title: 'Expenses'),
      body: Center(child: Text('Expense List Screen - Coming Soon!')),
    );
  }
}