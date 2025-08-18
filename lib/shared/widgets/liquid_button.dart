import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_theme.dart';

class LiquidButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double? height;
  final Color? color;
  final Gradient? gradient;
  final IconData? icon;
  final bool isOutlined;

  const LiquidButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.height,
    this.color,
    this.gradient,
    this.icon,
    this.isOutlined = false,
  });

  @override
  State<LiquidButton> createState() => _LiquidButtonState();
}

class _LiquidButtonState extends State<LiquidButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        if (widget.onPressed != null && !widget.isLoading) {
          widget.onPressed!();
        }
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: widget.width ?? double.infinity,
        height: widget.height ?? 56.h,
        decoration: BoxDecoration(
          gradient: widget.isOutlined
              ? null
              : (widget.gradient ?? AppTheme.liquidBackground),
          color: widget.isOutlined ? Colors.transparent : widget.color,
          border: widget.isOutlined
              ? Border.all(color: AppTheme.primaryPurple, width: 2)
              : null,
          borderRadius: BorderRadius.circular(28.r),
          boxShadow: widget.isOutlined
              ? null
              : [
                  BoxShadow(
                    color: (widget.color ?? AppTheme.primaryPurple)
                        .withOpacity(_isPressed ? 0.2 : 0.3),
                    blurRadius: _isPressed ? 10 : 20,
                    offset: Offset(0, _isPressed ? 2 : 8),
                  ),
                ],
        ),
        transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28.r),
          child: Material(
            color: Colors.transparent,
            child: Container(
              child: widget.isLoading
                  ? Center(
                      child: SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            widget.isOutlined
                                ? AppTheme.primaryPurple
                                : Colors.white,
                          ),
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(
                            widget.icon,
                            color: widget.isOutlined
                                ? AppTheme.primaryPurple
                                : Colors.white,
                            size: 20.sp,
                          ),
                          SizedBox(width: 8.w),
                        ],
                        Text(
                          widget.text,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: widget.isOutlined
                                ? AppTheme.primaryPurple
                                : Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      )
          .animate(target: _isPressed ? 1 : 0)
          .shimmer(duration: 1500.ms, color: Colors.white.withOpacity(0.3))
          .then()
          .shake(hz: 1, curve: Curves.easeInOutCubic),
    );
  }
}
