import 'package:flutter/material.dart';
import '../config/design_system.dart';
import 'security_pattern_painter.dart';
import 'gradient_background_wrapper.dart';

/// A reusable widget that provides a grid background for screens
class GridBackground extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final Color? gridColor;
  final Gradient? gradient;
  final bool useGradient;
  final bool isSpecialScreen;

  const GridBackground({
    Key? key,
    required this.child,
    this.backgroundColor,
    this.gridColor,
    this.gradient,
    this.useGradient = true,
    this.isSpecialScreen = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // If this is a special screen (splash, login, registration), use the gradient background wrapper
    if (isSpecialScreen) {
      return GradientBackgroundWrapper(child: child);
    }

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Default gradient for dark mode only, light mode uses white background
    final defaultGradient = isDarkMode
        ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              DesignSystem.darkBackgroundColor,
              DesignSystem.darkBackgroundColor.withAlpha(230),
              DesignSystem.darkSurfaceColor,
            ],
          )
        : null; // No gradient for light mode

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode
            ? (useGradient
                ? null
                : (backgroundColor ?? DesignSystem.darkBackgroundColor))
            : Colors.white, // Always white in light mode
        gradient:
            isDarkMode && useGradient ? (gradient ?? defaultGradient) : null,
      ),
      child: CustomPaint(
        painter: SecurityPatternPainter(
          gridColor: gridColor ??
              (isDarkMode
                  ? Colors.white.withAlpha(20)
                  : Colors.grey
                      .withAlpha(10)), // Very subtle grey grid in light mode
          gridSpacing: 20.0,
        ),
        foregroundPainter: null,
        child: child,
      ),
    );
  }
}
