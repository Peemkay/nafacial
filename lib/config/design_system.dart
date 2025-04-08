import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// A unified design system for consistent styling across platforms
class DesignSystem {
  // Platform detection
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  static bool get isWindows => !kIsWeb && Platform.isWindows;
  static bool get isWeb => kIsWeb;

  // Base color palette - consistent across all platforms
  static const Color navyBlue = Color(0xFF001F3F);
  static const Color skyBlue = Color(0xFF4A90E2);
  static const Color yellow = Color(0xFFFFD700);
  static const Color green = Color(0xFF00C853);
  static const Color amber = Color(0xFFFFB300);
  static const Color red = Color(0xFFD50000);
  static const Color militaryGreen = Color(0xFF1E5631);

  // Enhanced dark mode palette
  static const Color darkBlue = Color(0xFF0A1929);
  static const Color darkNavyBlue = Color(0xFF172B4D);
  static const Color darkSteelBlue = Color(0xFF2C3E50);
  static const Color darkSlateBlue = Color(0xFF1A365D);
  static const Color darkCyan = Color(0xFF0E7490);
  static const Color darkTeal = Color(0xFF0F766E);
  static const Color darkForestGreen = Color(0xFF166534);
  static const Color darkOliveGreen = Color(0xFF3F6212);
  static const Color darkGold = Color(0xFFB45309);
  static const Color darkAmber = Color(0xFFD97706);

  // Enhanced grey palette for dark mode
  static const Color darkGrey1 = Color(0xFF121212); // Darkest
  static const Color darkGrey2 = Color(0xFF1E1E1E);
  static const Color darkGrey3 = Color(0xFF222222);
  static const Color darkGrey4 = Color(0xFF272727);
  static const Color darkGrey5 = Color(0xFF2C2C2C);
  static const Color darkGrey6 = Color(0xFF323232);
  static const Color darkGrey7 = Color(0xFF383838);
  static const Color darkGrey8 = Color(0xFF424242);
  static const Color darkGrey9 = Color(0xFF616161); // Lightest

  // Light theme colors
  static const Color lightPrimaryColor = navyBlue;
  static const Color lightSecondaryColor = skyBlue;
  static const Color lightAccentColor = yellow;
  static const Color lightBackgroundColor = Colors.white;
  static const Color lightSurfaceColor = Colors.white;
  static const Color lightCardColor = Colors.white;
  static const Color lightIconColor = navyBlue;
  static const Color lightTextPrimaryColor = navyBlue;
  static const Color lightTextSecondaryColor = Color(0xFF4A4A4A);
  static const Color lightDividerColor = Color(0xFFE0E0E0);
  static const Color lightAppBarColor = navyBlue;
  static const Color lightStatusBarColor = navyBlue;
  static const Color lightNavBarColor = Colors.white;

  // Dark theme colors
  static const Color darkPrimaryColor = darkSlateBlue;
  static const Color darkSecondaryColor = darkCyan;
  static const Color darkAccentColor = Color(0xFFFFD54F); // Softer yellow
  static const Color darkBackgroundColor =
      Color(0xFF0A0A0A); // Darker background
  static const Color darkSurfaceColor = Color(0xFF121212); // Darker surface
  static const Color darkCardColor = Color(0xFF1A1A1A); // Darker card
  static const Color darkIconColor = Color(0xFF9E9E9E); // Grey icons
  static const Color darkTextPrimaryColor = Colors.white; // Pure white text
  static const Color darkTextSecondaryColor =
      Color(0xFFBDBDBD); // Light grey text
  static const Color darkDividerColor = Color(0xFF2C2C2C); // Darker divider
  static const Color darkAppBarColor = Color(0xFF1A1A1A); // Darker app bar
  static const Color darkStatusBarColor =
      Color(0xFF0A0A0A); // Darker status bar
  static const Color darkNavBarColor = Color(0xFF1A1A1A); // Darker nav bar

  // Additional dark theme colors for UI elements
  static const Color darkButtonColor = darkCyan;
  static const Color darkButtonHoverColor = Color(0xFF0891B2); // Lighter cyan
  static const Color darkSelectionColor = darkTeal;
  static const Color darkHighlightColor = darkGold;
  static const Color darkFocusColor = darkAmber;
  static const Color darkSplashColor = Color(0xFF155E75); // Darker cyan

  // Semantic colors - consistent across themes but with appropriate contrast
  static const Color lightSuccessColor = green;
  static const Color lightWarningColor = amber;
  static const Color lightErrorColor = red;
  static const Color darkSuccessColor =
      Color(0xFF4CAF50); // Professional green for dark mode
  static const Color darkWarningColor =
      Color(0xFFFFC107); // Professional amber for dark mode
  static const Color darkErrorColor =
      Color(0xFFF44336); // Professional red for dark mode

  // Additional semantic colors for dark mode
  static const Color darkInfoColor = Color(0xFF2196F3); // Blue for information
  static const Color darkDisabledColor = darkGrey8; // For disabled elements

  // Aliases for backward compatibility
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
