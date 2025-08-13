import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:provider/provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/theme/neumorphic_theme.dart';
import 'responsive_builder.dart';

class NeumorphicBottomNavigationItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final Color? color;

  const NeumorphicBottomNavigationItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    this.color,
  });
}

class NeumorphicBottomNavigation extends StatelessWidget {
  final List<NeumorphicBottomNavigationItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color? backgroundColor;
  final double? height;
  final bool showLabels;

  const NeumorphicBottomNavigation({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.backgroundColor,
    this.height,
    this.showLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    Color getBackgroundColor() {
      return backgroundColor ?? 
        (isDarkMode 
          ? NeumorphicThemeConfig.darkBaseColor 
          : NeumorphicThemeConfig.lightBaseColor);
    }

    return Container(
      decoration: BoxDecoration(
        color: getBackgroundColor(),
        boxShadow: [
          BoxShadow(
            color: isDarkMode 
              ? NeumorphicThemeConfig.darkShadowColor.withOpacity(0.3)
              : NeumorphicThemeConfig.lightShadowColor.withOpacity(0.2),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: height ?? (showLabels ? 80.rh : 60.rh),
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveUtils.getResponsivePadding(context).horizontal / 2,
            vertical: 8.rh,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = index == currentIndex;

              return Expanded(
                child: _NeumorphicBottomNavItem(
                  item: item,
                  isSelected: isSelected,
                  onTap: () => onTap(index),
                  showLabel: showLabels,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _NeumorphicBottomNavItem extends StatefulWidget {
  final NeumorphicBottomNavigationItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final bool showLabel;

  const _NeumorphicBottomNavItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.showLabel,
  });

  @override
  State<_NeumorphicBottomNavItem> createState() => _NeumorphicBottomNavItemState();
}

class _NeumorphicBottomNavItemState extends State<_NeumorphicBottomNavItem>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _colorAnimation = ColorTween(
      begin: const Color(0xFF7F8C8D),
      end: const Color(0xFF6C7CE7),
    ).animate(_animationController);

    if (widget.isSelected) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(_NeumorphicBottomNavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    Color getInactiveColor() {
      return isDarkMode ? const Color(0xFFBDC3C7) : const Color(0xFF7F8C8D);
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Container(
            padding: EdgeInsets.symmetric(
              horizontal: 8.rw,
              vertical: 4.rh,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Neumorphic(
                  style: NeumorphicStyle(
                    shape: NeumorphicShape.flat,
                    boxShape: const NeumorphicBoxShape.circle(),
                    depth: widget.isSelected ? -2 : 2,
                    intensity: 0.6,
                    color: isDarkMode 
                      ? NeumorphicThemeConfig.darkBaseColor 
                      : NeumorphicThemeConfig.lightBaseColor,
                  ),
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      width: 44.rr,
                      height: 44.rr,
                      child: Icon(
                        widget.isSelected 
                          ? (widget.item.activeIcon ?? widget.item.icon)
                          : widget.item.icon,
                        size: 24.rr,
                        color: widget.item.color ?? _colorAnimation.value ?? getInactiveColor(),
                      ),
                    ),
                  ),
                ),
                if (widget.showLabel) ...[
                  SizedBox(height: 4.rh),
                  Text(
                    widget.item.label,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(context, 11),
                      fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: widget.isSelected 
                        ? (_colorAnimation.value ?? const Color(0xFF6C7CE7))
                        : getInactiveColor(),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
