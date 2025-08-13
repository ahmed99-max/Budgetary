import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:provider/provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/theme/neumorphic_theme.dart';
import 'responsive_builder.dart';
import 'neumorphic_button.dart';

class NeumorphicAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final bool centerTitle;
  final double? elevation;
  final Color? backgroundColor;
  final PreferredSizeWidget? bottom;
  final VoidCallback? onBackPressed;

  const NeumorphicAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.centerTitle = true,
    this.elevation,
    this.backgroundColor,
    this.bottom,
    this.onBackPressed,
  });

  @override
  Size get preferredSize => Size.fromHeight(
    kToolbarHeight + (bottom?.preferredSize.height ?? 0),
  );

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

    Color getTextColor() {
      return isDarkMode ? const Color(0xFFECF0F1) : const Color(0xFF2C3E50);
    }

    Widget? buildLeading() {
      if (leading != null) return leading;

      if (automaticallyImplyLeading) {
        final canPop = Navigator.of(context).canPop();
        if (canPop) {
          return Padding(
            padding: EdgeInsets.all(8.rr),
            child: NeumorphicButton(
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
              padding: EdgeInsets.all(8.rr),
              child: Icon(
                Icons.arrow_back_ios,
                size: 18.rr,
                color: getTextColor(),
              ),
            ),
          );
        }
      }

      return null;
    }

    Widget buildTitle() {
      if (titleWidget != null) return titleWidget!;

      if (title != null) {
        return Text(
          title!,
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 20),
            fontWeight: FontWeight.w700,
            color: getTextColor(),
          ),
        );
      }

      return const SizedBox();
    }

    List<Widget> buildActions() {
      if (actions == null) return [];

      return actions!.map((action) {
        if (action is IconButton) {
          return Padding(
            padding: EdgeInsets.all(4.rr),
            child: NeumorphicButton(
              onPressed: (action as IconButton).onPressed,
              padding: EdgeInsets.all(8.rr),
              child: Icon(
                (action as IconButton).icon is Icon 
                  ? ((action as IconButton).icon as Icon).icon 
                  : Icons.more_vert,
                size: 20.rr,
                color: getTextColor(),
              ),
            ),
          );
        }
        return action;
      }).toList();
    }

    return Container(
      decoration: BoxDecoration(
        color: getBackgroundColor(),
        boxShadow: [
          BoxShadow(
            color: isDarkMode 
              ? NeumorphicThemeConfig.darkShadowColor.withOpacity(0.3)
              : NeumorphicThemeConfig.lightShadowColor.withOpacity(0.2),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              height: kToolbarHeight,
              padding: EdgeInsets.symmetric(horizontal: 16.rw),
              child: Row(
                children: [
                  if (buildLeading() != null) ...[
                    buildLeading()!,
                    SizedBox(width: 8.rw),
                  ],
                  if (centerTitle) ...[
                    Expanded(child: Center(child: buildTitle())),
                  ] else ...[
                    Expanded(child: buildTitle()),
                  ],
                  ...buildActions().map((action) => Padding(
                    padding: EdgeInsets.only(left: 8.rw),
                    child: action,
                  )),
                ],
              ),
            ),
            if (bottom != null) bottom!,
          ],
        ),
      ),
    );
  }
}

class NeumorphicSliverAppBar extends StatelessWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final Widget? flexibleSpace;
  final double expandedHeight;
  final bool pinned;
  final bool floating;
  final bool snap;
  final Color? backgroundColor;

  const NeumorphicSliverAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.flexibleSpace,
    this.expandedHeight = 200,
    this.pinned = true,
    this.floating = false,
    this.snap = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return SliverAppBar(
      title: titleWidget ?? (title != null 
        ? Text(
            title!,
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 20),
              fontWeight: FontWeight.w700,
              color: isDarkMode ? const Color(0xFFECF0F1) : const Color(0xFF2C3E50),
            ),
          )
        : null),
      leading: leading,
      actions: actions,
      backgroundColor: backgroundColor ?? 
        (isDarkMode 
          ? NeumorphicThemeConfig.darkBaseColor 
          : NeumorphicThemeConfig.lightBaseColor),
      expandedHeight: expandedHeight.rh,
      pinned: pinned,
      floating: floating,
      snap: snap,
      elevation: 0,
      flexibleSpace: flexibleSpace != null 
        ? FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: isDarkMode 
                  ? NeumorphicThemeConfig.darkGradient 
                  : NeumorphicThemeConfig.lightGradient,
              ),
              child: flexibleSpace,
            ),
          )
        : null,
    );
  }
}
