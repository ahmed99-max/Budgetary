import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:provider/provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/theme/neumorphic_theme.dart';
import 'responsive_builder.dart';

enum NeumorphicButtonType { flat, convex, primary, secondary }

class NeumorphicButton extends StatefulWidget {
  final Widget? child;
  final String? text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final NeumorphicButtonType type;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool isLoading;
  final bool isDisabled;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? textSize;
  final FontWeight? fontWeight;

  const NeumorphicButton({
    super.key,
    this.child,
    this.text,
    this.icon,
    this.onPressed,
    this.type = NeumorphicButtonType.flat,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.isLoading = false,
    this.isDisabled = false,
    this.backgroundColor,
    this.foregroundColor,
    this.textSize,
    this.fontWeight,
  });

  const NeumorphicButton.primary({
    super.key,
    this.child,
    this.text,
    this.icon,
    this.onPressed,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.isLoading = false,
    this.isDisabled = false,
    this.textSize,
    this.fontWeight,
  }) : type = NeumorphicButtonType.primary,
       backgroundColor = const Color(0xFF6C7CE7),
       foregroundColor = Colors.white;

  const NeumorphicButton.secondary({
    super.key,
    this.child,
    this.text,
    this.icon,
    this.onPressed,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.isLoading = false,
    this.isDisabled = false,
    this.backgroundColor,
    this.foregroundColor,
    this.textSize,
    this.fontWeight,
  }) : type = NeumorphicButtonType.secondary;

  @override
  State<NeumorphicButton> createState() => _NeumorphicButtonState();
}

class _NeumorphicButtonState extends State<NeumorphicButton>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(_) {
    if (!widget.isDisabled && !widget.isLoading) {
      setState(() => _isPressed = true);
      _animationController.forward();
    }
  }

  void _onTapUp(_) {
    if (!widget.isDisabled && !widget.isLoading) {
      setState(() => _isPressed = false);
      _animationController.reverse();
      widget.onPressed?.call();
    }
  }

  void _onTapCancel() {
    if (!widget.isDisabled && !widget.isLoading) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    Color getBackgroundColor() {
      if (widget.isDisabled) {
        return isDarkMode ? const Color(0xFF566573) : const Color(0xFFBDC3C7);
      }

      switch (widget.type) {
        case NeumorphicButtonType.primary:
          return widget.backgroundColor ?? const Color(0xFF6C7CE7);
        case NeumorphicButtonType.secondary:
          return widget.backgroundColor ?? 
            (isDarkMode ? const Color(0xFF34495E) : const Color(0xFFECF0F1));
        case NeumorphicButtonType.flat:
        case NeumorphicButtonType.convex:
        default:
          return widget.backgroundColor ?? 
            (isDarkMode ? NeumorphicThemeConfig.darkBaseColor : NeumorphicThemeConfig.lightBaseColor);
      }
    }

    Color getForegroundColor() {
      if (widget.isDisabled) {
        return isDarkMode ? const Color(0xFF7F8C8D) : const Color(0xFF95A5A6);
      }

      switch (widget.type) {
        case NeumorphicButtonType.primary:
          return widget.foregroundColor ?? Colors.white;
        case NeumorphicButtonType.secondary:
          return widget.foregroundColor ?? 
            (isDarkMode ? const Color(0xFFECF0F1) : const Color(0xFF2C3E50));
        case NeumorphicButtonType.flat:
        case NeumorphicButtonType.convex:
        default:
          return widget.foregroundColor ?? 
            (isDarkMode ? const Color(0xFFECF0F1) : const Color(0xFF2C3E50));
      }
    }

    NeumorphicStyle getButtonStyle() {
      final baseStyle = context.buttonStyle;

      return baseStyle.copyWith(
        color: getBackgroundColor(),
        depth: _isPressed ? -baseStyle.depth! : baseStyle.depth,
        shape: widget.type == NeumorphicButtonType.convex 
          ? NeumorphicShape.convex 
          : NeumorphicShape.flat,
        intensity: widget.isDisabled ? 0.3 : baseStyle.intensity,
      );
    }

    Widget buildButtonContent() {
      final foregroundColor = getForegroundColor();

      if (widget.isLoading) {
        return SizedBox(
          width: 20.rw,
          height: 20.rh,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
          ),
        );
      }

      if (widget.child != null) {
        return DefaultTextStyle(
          style: TextStyle(color: foregroundColor),
          child: IconTheme(
            data: IconThemeData(color: foregroundColor),
            child: widget.child!,
          ),
        );
      }

      List<Widget> children = [];

      if (widget.icon != null) {
        children.add(
          Icon(
            widget.icon,
            size: (widget.textSize ?? 16) + 2,
            color: foregroundColor,
          ),
        );
        if (widget.text != null) {
          children.add(SizedBox(width: 8.rw));
        }
      }

      if (widget.text != null) {
        children.add(
          Text(
            widget.text!,
            style: TextStyle(
              fontSize: widget.textSize ?? ResponsiveUtils.getResponsiveFontSize(context, 16),
              fontWeight: widget.fontWeight ?? FontWeight.w600,
              color: foregroundColor,
            ),
          ),
        );
      }

      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: children,
      );
    }

    return Container(
      margin: widget.margin,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          child: Neumorphic(
            style: getButtonStyle(),
            child: Container(
              width: widget.width,
              height: widget.height ?? 48.rh,
              padding: widget.padding ?? EdgeInsets.symmetric(
                horizontal: 24.rw,
                vertical: 12.rh,
              ),
              child: Center(child: buildButtonContent()),
            ),
          ),
        ),
      ),
    );
  }
}
