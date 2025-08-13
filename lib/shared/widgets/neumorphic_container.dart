import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:provider/provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/theme/neumorphic_theme.dart';
import 'responsive_builder.dart';

class NeumorphicContainer extends StatelessWidget {
  final Widget? child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final NeumorphicStyle? style;
  final bool isClickable;
  final VoidCallback? onTap;
  final Duration? animationDuration;

  const NeumorphicContainer({
    super.key,
    this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.style,
    this.isClickable = false,
    this.onTap,
    this.animationDuration,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isPressed = false; // State management for pressed animation

    return AnimatedContainer(
      duration: animationDuration ?? NeumorphicThemeConfig.shortAnimation,
      margin: margin ?? ResponsiveUtils.getResponsiveMargin(context),
      child: Neumorphic(
        style: style ?? context.cardStyle.copyWith(
          color: themeProvider.isDarkMode 
            ? NeumorphicThemeConfig.darkBaseColor 
            : NeumorphicThemeConfig.lightBaseColor,
        ),
        child: GestureDetector(
          onTap: isClickable ? onTap : null,
          onTapDown: isClickable ? (_) {
            // Add pressed state animation logic here if needed
          } : null,
          onTapUp: isClickable ? (_) {
            // Add release state animation logic here if needed
          } : null,
          child: Container(
            width: width,
            height: height,
            padding: padding ?? ResponsiveUtils.getResponsivePadding(context),
            child: child,
          ),
        ),
      ),
    );
  }
}

class NeumorphicCard extends StatelessWidget {
  final Widget child;
  final String? title;
  final Widget? leading;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double? elevation;

  const NeumorphicCard({
    super.key,
    required this.child,
    this.title,
    this.leading,
    this.trailing,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    return NeumorphicContainer(
      margin: margin ?? 16.rMargin,
      padding: padding ?? 20.rPadding,
      isClickable: onTap != null,
      onTap: onTap,
      style: context.cardStyle.copyWith(
        color: backgroundColor,
        depth: elevation ?? NeumorphicThemeConfig.cardDepth,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null || leading != null || trailing != null)
            Row(
              children: [
                if (leading != null) ...[
                  leading!,
                  SizedBox(width: 12.rw),
                ],
                if (title != null)
                  Expanded(
                    child: Text(
                      title!,
                      style: ResponsiveTextStyles.getHeadline3(context),
                    ),
                  ),
                if (trailing != null) trailing!,
              ],
            ),
          if (title != null || leading != null || trailing != null)
            SizedBox(height: 16.rh),
          child,
        ],
      ),
    );
  }
}
