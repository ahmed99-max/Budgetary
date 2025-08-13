import 'package:flutter/material.dart';
import '../../../shared/widgets/neumorphic_app_bar.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: NeumorphicAppBar(title: 'Budget'),
      body: Center(child: Text('Budget Screen - Coming Soon!')),
    );
  }
}