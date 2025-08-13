import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Reports & Analytics')),
      body: const Center(child: Text('Comprehensive Reports with Charts - Coming Soon!')),
    );
  }
}
