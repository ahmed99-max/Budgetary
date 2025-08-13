import 'package:flutter/material.dart';
import '../../../shared/widgets/neumorphic_app_bar.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: NeumorphicAppBar(title: 'Reset Password'),
      body: Center(child: Text('Reset Password Screen - Coming Soon!')),
    );
  }
}