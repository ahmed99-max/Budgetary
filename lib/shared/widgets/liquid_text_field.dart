import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_theme.dart';

class LiquidTextField extends StatefulWidget {
  final String? labelText;
  final String? hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool enabled;
  final int maxLines;

  const LiquidTextField({
    super.key,
    this.labelText,
    this.hintText,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.maxLines = 1,
  });

  @override
  State<LiquidTextField> createState() => _LiquidTextFieldState();
}

class _LiquidTextFieldState extends State<LiquidTextField>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  late AnimationController _animationController;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });

      if (_isFocused) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null) ...[
          Text(
            widget.labelText!,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: _isFocused ? AppTheme.primaryPurple : Colors.grey.shade600,
            ),
          )
              .animate(target: _isFocused ? 1 : 0)
              .tint(color: AppTheme.primaryPurple),
          SizedBox(height: 8.h),
        ],
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            gradient: _isFocused
                ? LinearGradient(
                    colors: [
                      AppTheme.primaryPurple.withOpacity(0.1),
                      AppTheme.primaryBlue.withOpacity(0.1),
                    ],
                  )
                : AppTheme.cardGradient,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: _isFocused ? AppTheme.primaryPurple : Colors.transparent,
              width: _isFocused ? 2 : 0,
            ),
            boxShadow: [
              BoxShadow(
                color: _isFocused
                    ? AppTheme.primaryPurple.withOpacity(0.2)
                    : Colors.black.withOpacity(0.05),
                blurRadius: _isFocused ? 15 : 10,
                offset: Offset(0, _isFocused ? 5 : 3),
              ),
            ],
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            validator: widget.validator,
            onChanged: widget.onChanged,
            enabled: widget.enabled,
            maxLines: widget.maxLines,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: Colors.grey.shade400,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      color: _isFocused
                          ? AppTheme.primaryPurple
                          : Colors.grey.shade400,
                      size: 20.sp,
                    )
                  : null,
              suffixIcon: widget.suffixIcon != null
                  ? GestureDetector(
                      onTap: widget.onSuffixTap,
                      child: Icon(
                        widget.suffixIcon,
                        color: _isFocused
                            ? AppTheme.primaryPurple
                            : Colors.grey.shade400,
                        size: 20.sp,
                      ),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: widget.prefixIcon != null ? 12.w : 20.w,
                vertical: 16.h,
              ),
            ),
          ),
        )
            .animate(target: _isFocused ? 1 : 0)
            .scale(begin: const Offset(1, 1), end: const Offset(1.02, 1.02))
            .then()
            .shimmer(
                duration: 1500.ms,
                color: AppTheme.primaryPurple.withOpacity(0.1)),
      ],
    );
  }
}
