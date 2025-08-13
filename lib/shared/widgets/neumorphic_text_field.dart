import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:provider/provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/theme/neumorphic_theme.dart';
import 'responsive_builder.dart';

class NeumorphicTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? height;
  final bool enabled;
  final FocusNode? focusNode;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;

  const NeumorphicTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.padding,
    this.margin,
    this.height,
    this.enabled = true,
    this.focusNode,
    this.textStyle,
    this.hintStyle,
  });

  @override
  State<NeumorphicTextField> createState() => _NeumorphicTextFieldState();
}

class _NeumorphicTextFieldState extends State<NeumorphicTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    Color getBackgroundColor() {
      if (!widget.enabled) {
        return isDarkMode ? const Color(0xFF34495E) : const Color(0xFFECF0F1);
      }
      return isDarkMode 
        ? NeumorphicThemeConfig.darkBaseColor 
        : NeumorphicThemeConfig.lightBaseColor;
    }

    Color getTextColor() {
      if (!widget.enabled) {
        return isDarkMode ? const Color(0xFF7F8C8D) : const Color(0xFF95A5A6);
      }
      return isDarkMode ? const Color(0xFFECF0F1) : const Color(0xFF2C3E50);
    }

    Color getHintColor() {
      return isDarkMode ? const Color(0xFFBDC3C7) : const Color(0xFF7F8C8D);
    }

    NeumorphicStyle getTextFieldStyle() {
      return context.textFieldStyle.copyWith(
        color: getBackgroundColor(),
        depth: _isFocused ? -6 : -4,
        intensity: widget.enabled ? 0.8 : 0.3,
      );
    }

    return Container(
      margin: widget.margin ?? EdgeInsets.symmetric(vertical: 8.rh),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.labelText != null) ...[
            Padding(
              padding: EdgeInsets.only(bottom: 8.rh, left: 4.rw),
              child: Text(
                widget.labelText!,
                style: widget.textStyle ?? TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                  fontWeight: FontWeight.w600,
                  color: getTextColor(),
                ),
              ),
            ),
          ],
          Neumorphic(
            style: getTextFieldStyle(),
            child: Container(
              height: widget.height ?? (widget.maxLines == 1 ? 50.rh : null),
              padding: widget.padding ?? EdgeInsets.symmetric(
                horizontal: 16.rw,
                vertical: widget.maxLines == 1 ? 0 : 12.rh,
              ),
              child: Row(
                children: [
                  if (widget.prefixIcon != null) ...[
                    Icon(
                      widget.prefixIcon,
                      size: 20.rr,
                      color: _isFocused 
                        ? const Color(0xFF6C7CE7) 
                        : getHintColor(),
                    ),
                    SizedBox(width: 12.rw),
                  ],
                  Expanded(
                    child: TextFormField(
                      controller: widget.controller,
                      focusNode: _focusNode,
                      obscureText: widget.obscureText,
                      keyboardType: widget.keyboardType,
                      inputFormatters: widget.inputFormatters,
                      validator: widget.validator,
                      onChanged: widget.onChanged,
                      onTap: widget.onTap,
                      readOnly: widget.readOnly,
                      enabled: widget.enabled,
                      maxLines: widget.maxLines,
                      minLines: widget.minLines,
                      style: widget.textStyle ?? TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                        fontWeight: FontWeight.w400,
                        color: getTextColor(),
                      ),
                      decoration: InputDecoration(
                        hintText: widget.hintText,
                        hintStyle: widget.hintStyle ?? TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                          fontWeight: FontWeight.w400,
                          color: getHintColor(),
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  if (widget.suffixIcon != null) ...[
                    SizedBox(width: 12.rw),
                    widget.suffixIcon!,
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
