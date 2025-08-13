import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../shared/widgets/responsive_builder.dart';
import '../../../shared/widgets/neumorphic_button.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode
          ? const Color(0xFF2C3E50)
          : const Color(0xFFE0E5EC),
      body: SafeArea(
        child: Padding(
          padding: context.responsivePadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo and Title
              Icon(
                Icons.account_balance_wallet,
                size: 80.rr,
                color: const Color(0xFF6C7CE7),
              ).animate().scale(duration: 600.ms).fadeIn(),

              SizedBox(height: 24.rh),

              Text(
                'Budgetary',
                style: TextStyle(
                  fontSize: context.getResponsiveSize(32),
                  fontWeight: FontWeight.w700,
                  color: themeProvider.isDarkMode
                      ? const Color(0xFFECF0F1)
                      : const Color(0xFF2C3E50),
                ),
              ).animate(delay: 200.ms).fadeIn().slideY(),

              SizedBox(height: 12.rh),

              Text(
                'Smart Finance Tracking',
                style: TextStyle(
                  fontSize: context.getResponsiveSize(16),
                  color: themeProvider.isDarkMode
                      ? const Color(0xFFBDC3C7)
                      : const Color(0xFF7F8C8D),
                ),
                textAlign: TextAlign.center,
              ).animate(delay: 400.ms).fadeIn().slideY(),

              SizedBox(height: 60.rh),

              // Action Buttons
              NeumorphicButton.primary(
                text: 'Get Started',
                width: double.infinity,
                onPressed: () => Navigator.of(context).pushNamed('/signup'),
              ).animate(delay: 600.ms).fadeIn().slideY(),

              SizedBox(height: 16.rh),

              NeumorphicButton(
                text: 'Sign In',
                width: double.infinity,
                onPressed: () => Navigator.of(context).pushNamed('/login'),
              ).animate(delay: 800.ms).fadeIn().slideY(),
            ],
          ),
        ),
      ),
    );
  }
}
