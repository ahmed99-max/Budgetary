import 'package:flutter/material.dart';
import '../../../shared/widgets/neumorphic_app_bar.dart';

class ProfileSetupScreen extends StatelessWidget {
  const ProfileSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: NeumorphicAppBar(title: 'Setup Profile'),
      body: Center(child: Text('Profile Setup Screen - Coming Soon!')),
    );
  }
}