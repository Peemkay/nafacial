import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// A unified design system for consistent styling across platforms
class DesignSystem {
  // Platform detection
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  static bool get isWindows => !kIsWeb && Platform.isWindows;
  static bool get isWeb => kIsWeb;

  // Color palette - consistent across all platforms
  static const Color primaryColor = Color(0xFF001F3F); // Navy Blue
  static const Color secondaryColor = Color(0xFF4A90E2); // Sky Blue
  static const Color accentColor = Color(0xFFFFD700); // Yellow
  static const Color successColor = Color(0xFF00C853); // Green
  static const Color warningColor = Color(0xFFFFB300); // Amber
  static const Color errorColor = Color(0xFFD50000); // Red
  static const Color surfaceColor = Colors.white;
  static const Color backgroundColor = Colors.white;
  static const Color textPrimaryColor = Color(0xFF001F3F);
  static const Color textSecondaryColor = Color(0xFF4A4A4A);

  // Typography - base sizes (will be adjusted per platform)
  static const double fontSizeXSmall = 12.0;
  static const double fontSizeSmall = 14.0;
  static const double fontSizeMedium = 16.0;
  static const double fontSizeLarge = 18.0;
  static const double fontSizeXLarge = 20.0;
  static const double fontSizeXXLarge = 24.0;
  static const double fontSizeDisplay = 30.0;

  // Platform-specific font size adjustments
  static double get _fontSizeAdjustment {
    if (isAndroid) return 0.85; // Smaller on Android
    if (isWindows) return 0.95; // Slightly smaller on Windows
    if (isWeb) return 0.9; // Slightly smaller on web
    return 0.9; // Default
  }

  // Adjusted font sizes for current platform
  static double get adjustedFontSizeXSmall =>
      fontSizeXSmall * _fontSizeAdjustment;
  static double get adjustedFontSizeSmall =>
      fontSizeSmall * _fontSizeAdjustment;
  static double get adjustedFontSizeMedium =>
      fontSizeMedium * _fontSizeAdjustment;
  static double get adjustedFontSizeLarge =>
      fontSizeLarge * _fontSizeAdjustment;
  static double get adjustedFontSizeXLarge =>
      fontSizeXLarge * _fontSizeAdjustment;
  static double get adjustedFontSizeXXLarge =>
      fontSizeXXLarge * _fontSizeAdjustment;
  static double get adjustedFontSizeDisplay =>
      fontSizeDisplay * _fontSizeAdjustment;

  // Spacing - consistent across platforms but with minor adjustments
  static const double spacingXXSmall = 2.0;
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;
  static const double spacingXXLarge = 48.0;

  // Platform-specific spacing adjustments
  static double get _spacingAdjustment {
    if (isAndroid) return 0.8; // Tighter on Android
    if (isWindows) return 0.95; // Slightly tighter on Windows
    if (isWeb) return 0.9; // Slightly tighter on web
    return 0.9; // Default
  }

  // Adjusted spacing for current platform
  static double get adjustedSpacingXXSmall =>
      spacingXXSmall * _spacingAdjustment;
  static double get adjustedSpacingXSmall => spacingXSmall * _spacingAdjustment;
  static double get adjustedSpacingSmall => spacingSmall * _spacingAdjustment;
  static double get adjustedSpacingMedium => spacingMedium * _spacingAdjustment;
  static double get adjustedSpacingLarge => spacingLarge * _spacingAdjustment;
  static double get adjustedSpacingXLarge => spacingXLarge * _spacingAdjustment;
  static double get adjustedSpacingXXLarge =>
      spacingXXLarge * _spacingAdjustment;

  // Border radius - consistent across platforms
  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusMedium = 8.0;
  static const double borderRadiusLarge = 12.0;
  static const double borderRadiusXLarge = 16.0;
  static const double borderRadiusCircular = 999.0;

  // Elevation - consistent across platforms
  static const double elevationNone = 0.0;
  static const double elevationXSmall = 1.0;
  static const double elevationSmall = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationLarge = 8.0;
  static const double elevationXLarge = 16.0;

  // Icon sizes - consistent across platforms
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeXLarge = 48.0;

  // Animation durations - consistent across platforms
  static const Duration durationShort = Duration(milliseconds: 150);
  static const Duration durationMedium = Duration(milliseconds: 300);
  static const Duration durationLong = Duration(milliseconds: 500);

  // Platform-specific UI adjustments
  static EdgeInsets get defaultScreenPadding {
    if (isAndroid) {
      return const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0);
    } else if (isWindows) {
      return const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0);
    } else if (isWeb) {
      return const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0);
    }
    return const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0);
  }

  // Button sizes - consistent across platforms
  static Size get defaultButtonSize {
    if (isAndroid) {
      return const Size(100.0, 36.0);
    } else if (isWindows) {
      return const Size(120.0, 40.0);
    } else if (isWeb) {
      return const Size(110.0, 38.0);
    }
    return const Size(100.0, 36.0);
  }

  // Input field heights - consistent across platforms
  static double get inputFieldHeight {
    if (isAndroid) {
      return 48.0;
    } else if (isWindows) {
      return 52.0;
    } else if (isWeb) {
      return 50.0;
    }
    return 48.0;
  }

  // Card styles - consistent across platforms
  static BorderRadius get cardBorderRadius {
    if (isAndroid) {
      return BorderRadius.circular(borderRadiusMedium);
    } else if (isWindows) {
      return BorderRadius.circular(borderRadiusLarge);
    } else if (isWeb) {
      return BorderRadius.circular(borderRadiusMedium);
    }
    return BorderRadius.circular(borderRadiusMedium);
  }

  static double get cardElevation {
    if (isAndroid) {
      return elevationSmall;
    } else if (isWindows) {
      return elevationMedium;
    } else if (isWeb) {
      return elevationSmall;
    }
    return elevationSmall;
  }

  // Screen breakpoints - consistent across platforms
  static const double breakpointMobile = 600.0;
  static const double breakpointTablet = 900.0;
  static const double breakpointDesktop = 1200.0;

  // Max content width constraints - consistent across platforms
  static const double maxWidthMobile = 600.0;
  static const double maxWidthTablet = 900.0;
  static const double maxWidthDesktop = 1200.0;

  // Container sizes - consistent across platforms
  static const double containerSizeSmall = 80.0;
  static const double containerSizeMedium = 120.0;
  static const double containerSizeLarge = 160.0;
  static const double containerSizeExtraLarge = 220.0;

  // Font weights - consistent across platforms
  static const FontWeight fontWeightLight = FontWeight.w300;
  static const FontWeight fontWeightRegular = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemiBold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;

  // Letter spacing - consistent across platforms
  static const double letterSpacingTight = -0.5;
  static const double letterSpacingNormal = 0.0;
  static const double letterSpacingWide = 0.5;
  static const double letterSpacingExtraWide = 1.0;
}
