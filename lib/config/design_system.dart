import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';

/// A unified design system for consistent styling across platforms
class DesignSystem {
  // Platform detection
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  static bool get isWindows => !kIsWeb && Platform.isWindows;
  static bool get isWeb => kIsWeb;

  // ======== CORE COLOR PALETTE ========
  // These are the base colors used throughout the app
  static const Color navy = Color(0xFF001F3F);
  static const Color blue = Color(0xFF0A3D62);
  static const Color lightBlue = Color(0xFF3498DB);
  static const Color yellow = Color(0xFFF1C40F);
  static const Color green = Color(0xFF27AE60);
  static const Color red = Color(0xFFE74C3C);
  static const Color orange = Color(0xFFE67E22);
  static const Color white = Colors.white;
  static const Color black = Colors.black;

  // Grays
  static const Color gray100 = Color(0xFFF8F9FA); // Lightest
  static const Color gray200 = Color(0xFFE5E8E8);
  static const Color gray300 = Color(0xFFD1D5D8);
  static const Color gray400 = Color(0xFFAEB6BF);
  static const Color gray500 = Color(0xFF7F8C8D);
  static const Color gray600 = Color(0xFF5D6D7E);
  static const Color gray700 = Color(0xFF2C3E50);
  static const Color gray800 = Color(0xFF1E2A38);
  static const Color gray900 = Color(0xFF0F1A2A); // Darkest

  // ======== LIGHT THEME COLORS ========
  // Primary colors
  static const Color lightPrimaryColor = blue;
  static const Color lightSecondaryColor = lightBlue;
  static const Color lightAccentColor = yellow;

  // Background and surface colors
  static const Color lightBackgroundColor = gray100;
  static const Color lightSurfaceColor = white;
  static const Color lightCardColor = white;

  // Text colors
  static const Color lightTextPrimaryColor = gray700;
  static const Color lightTextSecondaryColor = gray600;

  // UI element colors
  static const Color lightIconColor = blue;
  static const Color lightDividerColor = gray200;
  static const Color lightAppBarColor = blue;
  static const Color lightStatusBarColor = blue;
  static const Color lightNavBarColor = white;

  // Semantic colors
  static const Color lightSuccessColor = green;
  static const Color lightWarningColor = orange;
  static const Color lightErrorColor = red;

  // ======== DARK THEME COLORS ========
  // Primary colors
  static const Color darkPrimaryColor = Color(0xFF001F3F); // Deep navy blue
  static const Color darkSecondaryColor = Color(0xFF0A3D62); // Dark blue
  static const Color darkAccentColor = yellow;

  // Background and surface colors
  static const Color darkBackgroundColor =
      Color(0xFF001428); // Very dark blue background
  static const Color darkSurfaceColor = Color(0xFF0A1929); // Dark blue surface
  static const Color darkCardColor = Color(0xFF0F2A45); // Dark blue card color
  static const Color darkMenuColor =
      Color(0xFF0F2A45); // Dark blue menu background
  static const Color darkSectionColor =
      Color(0xFF0A1929); // Dark blue section background

  // Text colors
  static const Color darkTextPrimaryColor = white;
  static const Color darkTextSecondaryColor = gray300;

  // UI element colors
  static const Color darkIconColor = white;
  static const Color darkDividerColor =
      Color(0xFF1E3A5F); // Blue-tinted divider
  static const Color darkAppBarColor =
      Color(0xFF001F3F); // Deep navy blue app bar
  static const Color darkStatusBarColor = black;
  static const Color darkNavBarColor =
      Color(0xFF001F3F); // Deep navy blue nav bar

  // Interactive element colors
  static const Color darkButtonColor = blue;
  static const Color darkButtonHoverColor = lightBlue;
  static const Color darkSelectionColor = lightBlue;
  static const Color darkHighlightColor = yellow;
  static const Color darkFocusColor = lightBlue;
  static const Color darkSplashColor = lightBlue;
  static const Color darkDisabledColor = gray500;

  // Semantic colors
  static const Color darkSuccessColor = green;
  static const Color darkWarningColor = orange;
  static const Color darkErrorColor = red;
  static const Color darkInfoColor = lightBlue;

  // ======== BACKWARD COMPATIBILITY ALIASES ========
  // These aliases maintain compatibility with existing code
  static const Color primaryColor = lightPrimaryColor;
  static const Color secondaryColor = lightSecondaryColor;
  static const Color accentColor = lightAccentColor;
  static const Color successColor = lightSuccessColor;
  static const Color warningColor = lightWarningColor;
  static const Color errorColor = lightErrorColor;
  static const Color surfaceColor = lightSurfaceColor;
  static const Color backgroundColor = lightBackgroundColor;
  static const Color textPrimaryColor = lightTextPrimaryColor;
  static const Color textSecondaryColor = lightTextSecondaryColor;
  static const Color dividerColor = lightDividerColor;

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
