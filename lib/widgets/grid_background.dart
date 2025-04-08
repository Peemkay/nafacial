import 'package:flutter/material.dart';
import '../config/design_system.dart';
import '../config/theme.dart';
import 'security_pattern_painter.dart';

/// A reusable widget that provides a grid background for screens
class GridBackground extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final Color? gridColor;
  final Gradient? gradient;
  final bool useGradient;

  const GridBackground({
    Key? key,
    required this.child,
    this.backgroundColor,
    this.gridColor,
    this.gradient,
    this.useGradient = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Default gradient for dark and light modes
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
        : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              DesignSystem.primaryColor,
              DesignSystem.primaryColor.withAlpha(230),
              AppTheme.green.withAlpha(204),
            ],
          );

    return Container(
      decoration: BoxDecoration(
        color: useGradient
            ? null
            : (backgroundColor ??
                (isDarkMode
                    ? DesignSystem.darkBackgroundColor
                    : DesignSystem.backgroundColor)),
        gradient: useGradient ? (gradient ?? defaultGradient) : null,
      ),
      child: CustomPaint(
        painter: SecurityPatternPainter(
          gridColor: gridColor ??
              (isDarkMode
                  ? Colors.white.withAlpha(20)
                  : Colors.white.withAlpha(13)),
          gridSpacing: 20.0,
        ),
        foregroundPainter: null,
        child: child,
      ),
    );
  }
}
