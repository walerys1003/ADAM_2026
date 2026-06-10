/// SilverTech Agent Adam — Accessibility Mixin
/// Provides accessibility helpers for senior-friendly interfaces
/// June 2026 — WCAG AA + senior UX guidelines

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Mixin providing accessibility utilities for senior-friendly UI
mixin AccessibilityMixin<T extends StatefulWidget> on State<T> {
  /// Minimum touch target size (Material: 48px, Senior: 56px)
  static const double minTouchTarget = 56.0;

  /// Large font scale for senior mode
  static const double seniorFontScale = 1.35;

  /// Standard large font sizes for senior readability
  static const double bodyLarge = 20.0;
  static const double bodyMedium = 18.0;
  static const double titleLarge = 28.0;
  static const double headlineLarge = 36.0;
  static const double buttonText = 20.0;

  /// Wrap a widget with proper semantics for screen readers
  Widget withSemantics({
    required Widget child,
    required String label,
    String? hint,
    bool isButton = false,
    bool isHeader = false,
    VoidCallback? onTap,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      button: isButton,
      header: isHeader,
      onTap: onTap,
      enabled: onTap != null,
      child: child,
    );
  }

  /// Ensure minimum touch target size for interactive elements
  Widget withTouchTarget(Widget child, {double minSize = minTouchTarget}) {
    return SizedBox(
      width: minSize,
      height: minSize,
      child: Center(child: child),
    );
  }

  /// High contrast text style optimized for seniors
  TextStyle get seniorBodyStyle => const TextStyle(
        fontSize: bodyMedium,
        fontWeight: FontWeight.w500,
        height: 1.5,
        letterSpacing: 0.3,
      );

  TextStyle get seniorTitleStyle => const TextStyle(
        fontSize: titleLarge,
        fontWeight: FontWeight.w700,
        height: 1.3,
      );

  TextStyle get seniorButtonStyle => const TextStyle(
        fontSize: buttonText,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      );

  /// High contrast color pairs (WCAG AA+)
  static const Color seniorTextPrimary = Color(0xFF1A1A2E);
  static const Color seniorTextSecondary = Color(0xFF4A4A5A);
  static const Color seniorBackground = Color(0xFFFAFAFA);
  static const Color seniorSurface = Colors.white;

  /// Check if senior mode is active
  bool get isSeniorMode => true; // Override based on user preference

  /// Large icon size for senior visibility
  static const double seniorIconSize = 32.0;

  /// Spacing constants for senior-friendly layouts
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;
  static const double spacingXXLarge = 48.0;

  /// Card decoration for senior-friendly cards
  BoxDecoration get seniorCardDecoration => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      );

  /// Announce a message to screen readers
  void announce(String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }

  /// Focus management helper
  void requestFocusOn(FocusNode node) {
    node.requestFocus();
  }

  /// Calculate optimal button padding for senior touch targets
  EdgeInsets get seniorButtonPadding =>
      const EdgeInsets.symmetric(horizontal: 24, vertical: 18);

  /// Large checkbox/radio target area
  static const Size largeCheckboxSize = Size(56, 56);

  /// Exclude semantics for decorative elements
  Widget decorative(Widget child) {
    return ExcludeSemantics(child: child);
  }

  /// Scale font size for senior readability
  double getScaledFontSize(double baseSize) => baseSize * (isSeniorMode ? seniorFontScale : 1.0);

  /// Get minimum touch target size
  double getScaledTouchTarget(double baseSize) => baseSize < minTouchTarget ? minTouchTarget : baseSize;

  /// Group related elements semantically
  Widget semanticGroup({
    required String label,
    required List<Widget> children,
  }) {
    return Semantics(
      label: label,
      container: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

/// Extension methods for building accessible widgets
extension AccessibilityExtensions on Widget {
  /// Wrap with large touch target
  Widget largeTouchTarget({double size = 56.0}) {
    return SizedBox(width: size, height: size, child: Center(child: this));
  }

  /// Add semantic label
  Widget semantic(String label, {String? hint, bool isButton = false}) {
    return Semantics(
      label: label,
      hint: hint,
      button: isButton,
      child: this,
    );
  }

  /// Add padding for senior-friendly spacing
  Widget seniorPadding() {
    return Padding(padding: const EdgeInsets.all(16.0), child: this);
  }
}
