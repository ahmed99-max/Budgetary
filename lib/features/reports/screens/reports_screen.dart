import 'package:flutter/material.dart';
import '../../../shared/widgets/neumorphic_app_bar.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: NeumorphicAppBar(title: 'Reports'),
      body: Center(child: Text('Reports Screen - Coming Soon!')),
    );
  }
}