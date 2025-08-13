import 'package:flutter/material.dart';
import '../../../shared/widgets/neumorphic_app_bar.dart';

class AddExpenseScreen extends StatelessWidget {
  const AddExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: NeumorphicAppBar(title: 'Add Expense'),
      body: Center(child: Text('Add Expense Screen - Coming Soon!')),
    );
  }
}