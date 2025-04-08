import 'package:flutter/material.dart';
import '../config/design_system.dart';

/// A custom painter that draws a grid pattern for security-themed backgrounds
class SecurityPatternPainter extends CustomPainter {
  final Color? gridColor;
  final double gridSpacing;
  final double strokeWidth;

  SecurityPatternPainter({
    this.gridColor,
    this.gridSpacing = 20.0,
    this.strokeWidth = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor ?? DesignSystem.secondaryColor.withAlpha(13)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    // Draw vertical lines
    for (double x = 0; x < size.width; x += gridSpacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += gridSpacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(SecurityPatternPainter oldDelegate) =>
      oldDelegate.gridColor != gridColor ||
      oldDelegate.gridSpacing != gridSpacing ||
      oldDelegate.strokeWidth != strokeWidth;
}
