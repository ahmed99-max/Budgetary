import 'package:flutter/material.dart';
import '../../../shared/widgets/neumorphic_app_bar.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: NeumorphicAppBar(title: 'Login'),
      body: Center(child: Text('Login Screen - Coming Soon!')),
    );
  }
}