import 'package:flutter/material.dart';

/// Responsive breakpoints for the Senior Companion app.
///
/// Designed with mobile-first approach optimized for:
/// - Senior users (larger touch targets, bigger fonts on small screens)
/// - Family dashboard (tablet-optimized layouts)
/// - Admin panel (desktop-friendly)
class ResponsiveHelper {
  /// Mobile breakpoint: < 600dp (phones)
  static const double mobileBreakpoint = 600;

  /// Tablet breakpoint: 600-1024dp (tablets, foldables)
  static const double tabletBreakpoint = 1024;

  /// Desktop breakpoint: >= 1024dp (admin panel, family dashboard)
  static const double desktopBreakpoint = 1024;

  final BuildContext context;

  ResponsiveHelper(this.context);

  /// Current screen width
  double get screenWidth => MediaQuery.of(context).size.width;

  /// Current screen height
  double get screenHeight => MediaQuery.of(context).size.height;

  /// Is this a phone-sized screen?
  bool get isMobile => screenWidth < mobileBreakpoint;

  /// Is this a tablet-sized screen?
  bool get isTablet =>
      screenWidth >= mobileBreakpoint && screenWidth < tabletBreakpoint;

  /// Is this a desktop-sized screen?
  bool get isDesktop => screenWidth >= desktopBreakpoint;

  /// Is this a landscape orientation?
  bool get isLandscape =>
      MediaQuery.of(context).orientation == Orientation.landscape;

  /// Get adaptive font scale for seniors.
  /// Seniors get up to 1.5x base font size on mobile.
  double seniorFontScale({bool isSenior = true}) {
    if (!isSenior) return 1.0;
    if (isMobile) return 1.4;
    if (isTablet) return 1.2;
    return 1.0;
  }

  /// Get adaptive touch target size.
  /// Minimum 48dp per Material guidelines, 56dp for seniors.
  double seniorTouchTarget({bool isSenior = true}) {
    if (!isSenior) return 48.0;
    return isMobile ? 56.0 : 52.0;
  }

  /// Get horizontal padding based on screen size
  double get horizontalPadding {
    if (isMobile) return 16.0;
    if (isTablet) return 24.0;
    return 32.0;
  }

  /// Get vertical padding based on screen size
  double get verticalPadding {
    if (isMobile) return 12.0;
    if (isTablet) return 16.0;
    return 24.0;
  }

  /// Column count for grid layouts
  int get gridColumns {
    if (isMobile) return 2;
    if (isTablet) return 3;
    return 4;
  }

  /// Max content width (for centered layouts on large screens)
  double get maxContentWidth {
    if (isMobile) return screenWidth;
    if (isTablet) return 720;
    return 960;
  }

  /// Card width based on screen
  double get cardWidth {
    if (isMobile) return screenWidth - 32;
    if (isTablet) return (screenWidth - 48) / 2;
    return (screenWidth - 64) / 3;
  }

  /// Bottom nav bar height (taller for seniors)
  double bottomNavHeight({bool isSenior = true}) {
    if (!isSenior) return 56.0;
    return isMobile ? 72.0 : 64.0;
  }
}

/// Static convenience methods for use without BuildContext
class ResponsiveHelperStatic {
  /// Get responsive value based on screen width
  static T responsive<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1024 && desktop != null) return desktop;
    if (width >= 600 && tablet != null) return tablet;
    return mobile;
  }

  /// Get senior-optimized font size
  static double seniorFontSize(BuildContext context, double baseSize,
      {bool isSenior = true}) {
    final width = MediaQuery.of(context).size.width;
    double scale = 1.0;
    if (isSenior) {
      if (width < 600) scale = 1.4;
      else if (width < 1024) scale = 1.2;
    }
    return baseSize * scale;
  }

  /// Safe area top padding including status bar
  static double safeTopPadding(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }

  /// Safe area bottom padding including home indicator
  static double safeBottomPadding(BuildContext context) {
    return MediaQuery.of(context).padding.bottom;
  }
}
