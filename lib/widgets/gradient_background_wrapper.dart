import 'package:flutter/material.dart';
import '../config/design_system.dart';
import '../config/theme.dart';
import 'security_pattern_painter.dart';

/// A widget that provides a consistent dark blue and green gradient background
/// for splash, login, and registration screens regardless of theme mode
class GradientBackgroundWrapper extends StatelessWidget {
  final Widget child;

  const GradientBackgroundWrapper({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Define the consistent gradient for these special screens
    final specialGradient = LinearGradient(
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
        gradient: specialGradient,
      ),
      child: CustomPaint(
        painter: SecurityPatternPainter(
          gridColor: Colors.white.withAlpha(20),
          gridSpacing: 20.0,
        ),
        foregroundPainter: null,
        child: child,
      ),
    );
  }
}
