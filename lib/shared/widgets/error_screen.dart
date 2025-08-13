import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:provider/provider.dart';
import '../../core/providers/theme_provider.dart';
import 'neumorphic_container.dart';
import 'neumorphic_button.dart';
import 'responsive_builder.dart';

class ErrorScreen extends StatelessWidget {
  final String error;
  final String? details;
  final VoidCallback? onRetry;

  const ErrorScreen({
    super.key, 
    required this.error,
    this.details,
    this.onRetry,
  });

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
              NeumorphicContainer(
                style: context.convexStyle.copyWith(
                  boxShape: const NeumorphicBoxShape.circle(),
                ),
                child: Container(
                  width: 100.rr,
                  height: 100.rr,
                  child: const Icon(
                    Icons.error_outline,
                    size: 50,
                    color: Color(0xFFE74C3C),
                  ),
                ),
              ),
              SizedBox(height: 30.rh),
              NeumorphicContainer(
                padding: EdgeInsets.all(20.rr),
                child: Column(
                  children: [
                    Text(
                      'Oops! Something went wrong',
                      style: TextStyle(
                        fontSize: context.getResponsiveSize(20),
                        fontWeight: FontWeight.w600,
                        color: themeProvider.isDarkMode
                            ? const Color(0xFFECF0F1)
                            : const Color(0xFF2C3E50),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12.rh),
                    Text(
                      error,
                      style: TextStyle(
                        fontSize: context.getResponsiveSize(14),
                        color: themeProvider.isDarkMode
                            ? const Color(0xFFBDC3C7)
                            : const Color(0xFF7F8C8D),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30.rh),
              if (onRetry != null)
                NeumorphicButton.primary(
                  text: 'Try Again',
                  icon: Icons.refresh,
                  onPressed: onRetry,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
