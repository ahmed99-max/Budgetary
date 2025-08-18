import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_theme.dart';

class LiquidCard extends StatefulWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Gradient? gradient;
  final Color? color;
  final VoidCallback? onTap;
  final bool elevated;
  final double borderRadius;

  const LiquidCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.gradient,
    this.color,
    this.onTap,
    this.elevated = true,
    this.borderRadius = 20,
  });

  @override
  State<LiquidCard> createState() => _LiquidCardState();
}

class _LiquidCardState extends State<LiquidCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null
          ? (_) => setState(() => _isPressed = true)
          : null,
      onTapUp: widget.onTap != null
          ? (_) {
              setState(() => _isPressed = false);
              widget.onTap!();
            }
          : null,
      onTapCancel: widget.onTap != null
          ? () => setState(() => _isPressed = false)
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: widget.width,
        height: widget.height,
        margin: widget.margin ??
            EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
        transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
        decoration: BoxDecoration(
          gradient: widget.gradient ??
              (widget.color == null ? AppTheme.cardGradient : null),
          color: widget.color,
          borderRadius: BorderRadius.circular(widget.borderRadius.r),
          boxShadow: widget.elevated
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(_isPressed ? 0.05 : 0.1),
                    blurRadius: _isPressed ? 10 : 20,
                    offset: Offset(0, _isPressed ? 2 : 8),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: AppTheme.primaryPurple
                        .withOpacity(_isPressed ? 0.05 : 0.1),
                    blurRadius: _isPressed ? 15 : 30,
                    offset: Offset(0, _isPressed ? 3 : 10),
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius.r),
          child: Container(
            padding: widget.padding ?? EdgeInsets.all(20.w),
            child: widget.child,
          ),
        ),
      )
          .animate()
          .fadeIn(duration: 600.ms)
          .slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic)
          .then(delay: 200.ms)
          .shimmer(duration: 2000.ms, color: Colors.white.withOpacity(0.1)),
    );
  }
}
