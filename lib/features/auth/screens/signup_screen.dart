import 'package:flutter/material.dart';
import '../../../shared/widgets/neumorphic_app_bar.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: NeumorphicAppBar(title: 'Sign Up'),
      body: Center(child: Text('Sign Up Screen - Coming Soon!')),
    );
  }
}