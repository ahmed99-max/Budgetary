import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum DeviceType { mobile, tablet, desktop }

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, DeviceType deviceType) builder;
  final Widget? mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
    this.mobile,
    this.tablet,
    this.desktop,
  });

  const ResponsiveBuilder.widgets({
    super.key,
    this.mobile,
    this.tablet,
    this.desktop,
  }) : builder = _defaultBuilder;

  static Widget _defaultBuilder(BuildContext context, DeviceType deviceType) {
    return const SizedBox();
  }

  static DeviceType getDeviceType(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 600) {
      return DeviceType.mobile;
    } else if (screenWidth < 1200) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  static bool isMobile(BuildContext context) => 
    getDeviceType(context) == DeviceType.mobile;

  static bool isTablet(BuildContext context) => 
    getDeviceType(context) == DeviceType.tablet;

  static bool isDesktop(BuildContext context) => 
    getDeviceType(context) == DeviceType.desktop;

  @override
  Widget build(BuildContext context) {
    final deviceType = getDeviceType(context);

    if (mobile != null || tablet != null || desktop != null) {
      switch (deviceType) {
        case DeviceType.mobile:
          return mobile ?? tablet ?? desktop ?? const SizedBox();
        case DeviceType.tablet:
          return tablet ?? mobile ?? desktop ?? const SizedBox();
        case DeviceType.desktop:
          return desktop ?? tablet ?? mobile ?? const SizedBox();
      }
    }

    return builder(context, deviceType);
  }
}

class ResponsiveValue<T> {
  final T mobile;
  final T? tablet;
  final T? desktop;

  const ResponsiveValue({
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  T getValue(BuildContext context) {
    final deviceType = ResponsiveBuilder.getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }
}

// Screen size constants
class ScreenSizes {
  static const double mobileMaxWidth = 599;
  static const double tabletMaxWidth = 1199;
  static const double desktopMinWidth = 1200;

  // Breakpoints
  static const double xs = 0;      // Extra small devices
  static const double sm = 576;    // Small devices
  static const double md = 768;    // Medium devices
  static const double lg = 992;    // Large devices
  static const double xl = 1200;   // Extra large devices
  static const double xxl = 1400;  // Extra extra large devices
}

// Responsive spacing and sizing utilities
class ResponsiveUtils {
  static double getScreenWidth(BuildContext context) => 
    MediaQuery.of(context).size.width;

  static double getScreenHeight(BuildContext context) => 
    MediaQuery.of(context).size.height;

  static bool isLandscape(BuildContext context) => 
    MediaQuery.of(context).orientation == Orientation.landscape;

  static double getResponsiveFontSize(BuildContext context, double baseFontSize) {
    final screenWidth = getScreenWidth(context);

    if (screenWidth <= ScreenSizes.sm) {
      return baseFontSize * 0.9;
    } else if (screenWidth <= ScreenSizes.md) {
      return baseFontSize;
    } else if (screenWidth <= ScreenSizes.lg) {
      return baseFontSize * 1.1;
    } else {
      return baseFontSize * 1.2;
    }
  }

  static EdgeInsets getResponsivePadding(BuildContext context, {
    double mobile = 16,
    double? tablet,
    double? desktop,
  }) {
    final deviceType = ResponsiveBuilder.getDeviceType(context);

    double padding;
    switch (deviceType) {
      case DeviceType.mobile:
        padding = mobile;
        break;
      case DeviceType.tablet:
        padding = tablet ?? mobile * 1.5;
        break;
      case DeviceType.desktop:
        padding = desktop ?? tablet ?? mobile * 2;
        break;
    }

    return EdgeInsets.all(padding);
  }

  static EdgeInsets getResponsiveMargin(BuildContext context, {
    double mobile = 8,
    double? tablet,
    double? desktop,
  }) {
    final deviceType = ResponsiveBuilder.getDeviceType(context);

    double margin;
    switch (deviceType) {
      case DeviceType.mobile:
        margin = mobile;
        break;
      case DeviceType.tablet:
        margin = tablet ?? mobile * 1.5;
        break;
      case DeviceType.desktop:
        margin = desktop ?? tablet ?? mobile * 2;
        break;
    }

    return EdgeInsets.all(margin);
  }

  static int getResponsiveGridCount(BuildContext context, {
    int mobile = 1,
    int? tablet,
    int? desktop,
  }) {
    final deviceType = ResponsiveBuilder.getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile * 2;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile * 3;
    }
  }

  static double getResponsiveCardWidth(BuildContext context) {
    final screenWidth = getScreenWidth(context);

    if (screenWidth <= ScreenSizes.sm) {
      return screenWidth - 32; // Full width minus padding
    } else if (screenWidth <= ScreenSizes.md) {
      return (screenWidth - 48) / 2; // Two cards per row
    } else if (screenWidth <= ScreenSizes.lg) {
      return (screenWidth - 64) / 3; // Three cards per row
    } else {
      return (screenWidth - 80) / 4; // Four cards per row
    }
  }

  static double getMaxContentWidth(BuildContext context) {
    final screenWidth = getScreenWidth(context);

    if (screenWidth <= ScreenSizes.lg) {
      return screenWidth;
    } else {
      return ScreenSizes.lg; // Max content width for desktop
    }
  }
}

// ScreenUtil extensions for easier responsive design
extension ResponsiveScreenUtil on num {
  double get rw => ScreenUtil().setWidth(this);
  double get rh => ScreenUtil().setHeight(this);
  double get rf => ScreenUtil().setSp(this);
  double get rr => ScreenUtil().radius(this);

  EdgeInsets get rPadding => EdgeInsets.all(ScreenUtil().setWidth(this));
  EdgeInsets get rMargin => EdgeInsets.all(ScreenUtil().setWidth(this));

  EdgeInsets rPaddingOnly({
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    return EdgeInsets.only(
      left: left?.rw ?? 0,
      top: top?.rh ?? 0,
      right: right?.rw ?? 0,
      bottom: bottom?.rh ?? 0,
    );
  }

  EdgeInsets rPaddingSymmetric({
    double? horizontal,
    double? vertical,
  }) {
    return EdgeInsets.symmetric(
      horizontal: horizontal?.rw ?? 0,
      vertical: vertical?.rh ?? 0,
    );
  }
}

// Responsive text styles
class ResponsiveTextStyles {
  static TextStyle getHeadline1(BuildContext context) {
    return TextStyle(
      fontSize: ResponsiveUtils.getResponsiveFontSize(context, 32),
      fontWeight: FontWeight.w700,
    );
  }

  static TextStyle getHeadline2(BuildContext context) {
    return TextStyle(
      fontSize: ResponsiveUtils.getResponsiveFontSize(context, 28),
      fontWeight: FontWeight.w600,
    );
  }

  static TextStyle getHeadline3(BuildContext context) {
    return TextStyle(
      fontSize: ResponsiveUtils.getResponsiveFontSize(context, 24),
      fontWeight: FontWeight.w600,
    );
  }

  static TextStyle getSubtitle1(BuildContext context) {
    return TextStyle(
      fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
      fontWeight: FontWeight.w500,
    );
  }

  static TextStyle getSubtitle2(BuildContext context) {
    return TextStyle(
      fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
      fontWeight: FontWeight.w500,
    );
  }

  static TextStyle getBody1(BuildContext context) {
    return TextStyle(
      fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
      fontWeight: FontWeight.w400,
    );
  }

  static TextStyle getBody2(BuildContext context) {
    return TextStyle(
      fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
      fontWeight: FontWeight.w400,
    );
  }

  static TextStyle getCaption(BuildContext context) {
    return TextStyle(
      fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
      fontWeight: FontWeight.w400,
    );
  }
}
