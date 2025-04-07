import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'design_system.dart';
import 'platform_theme_extension.dart';

class AppTheme {
  // Color aliases for backward compatibility
  static const darkBlue = DesignSystem.primaryColor;
  static const skyBlue = DesignSystem.secondaryColor;
  static const green = Color(0xFF1E5631); // Military Green
  static const yellow = DesignSystem.accentColor;
  static const white = Colors.white;
  static const black = Colors.black;
  static const grey = DesignSystem.textSecondaryColor;

  // Security level colors
  static const verified = DesignSystem.successColor;
  static const warning = DesignSystem.warningColor;
  static const danger = DesignSystem.errorColor;

  // Spacing aliases for backward compatibility
  static const double defaultSpacing = DesignSystem.spacingMedium;
  static const double smallSpacing = DesignSystem.spacingSmall;
  static const double largeSpacing = DesignSystem.spacingLarge;
  static const double extraLargeSpacing = DesignSystem.spacingXLarge;

  // Border radius aliases for backward compatibility
  static const double defaultBorderRadius = DesignSystem.borderRadiusMedium;
  static const double largeBorderRadius = DesignSystem.borderRadiusLarge;

  // Font size aliases for backward compatibility
  static const double fontSizeSmall = DesignSystem.fontSizeSmall;
  static const double fontSizeNormal = DesignSystem.fontSizeMedium;
  static const double fontSizeMedium = DesignSystem.fontSizeLarge;
  static const double fontSizeLarge = DesignSystem.fontSizeXLarge;
  static const double fontSizeExtraLarge = DesignSystem.fontSizeXXLarge;
  static const double fontSizeHeadline = DesignSystem.fontSizeXXLarge;
  static const double fontSizeDisplay = DesignSystem.fontSizeDisplay;

  // Icon size aliases for backward compatibility
  static const double iconSizeSmall = DesignSystem.iconSizeSmall;
  static const double iconSizeNormal = DesignSystem.iconSizeMedium;
  static const double iconSizeLarge = DesignSystem.iconSizeLarge;
  static const double iconSizeExtraLarge = DesignSystem.iconSizeXLarge;

  // Container size aliases for backward compatibility
  static const double containerSizeSmall = 100.0;
  static const double containerSizeMedium = 150.0;
  static const double containerSizeLarge = 200.0;
  static const double containerSizeExtraLarge = 300.0;

  // Max width constraints aliases for backward compatibility
  static const double maxWidthMobile = DesignSystem.maxWidthMobile;
  static const double maxWidthTablet = DesignSystem.maxWidthTablet;
  static const double maxWidthDesktop = DesignSystem.maxWidthDesktop;

  /// Get the theme data with platform-specific adjustments
  static ThemeData get theme {
    // Get platform-adjusted font sizes
    final adjustedFontSizeSmall = DesignSystem.adjustedFontSizeSmall;
    final adjustedFontSizeMedium = DesignSystem.adjustedFontSizeMedium;
    final adjustedFontSizeLarge = DesignSystem.adjustedFontSizeLarge;
    final adjustedFontSizeXLarge = DesignSystem.adjustedFontSizeXLarge;
    final adjustedFontSizeXXLarge = DesignSystem.adjustedFontSizeXXLarge;
    final adjustedFontSizeDisplay = DesignSystem.adjustedFontSizeDisplay;

    // Get platform-adjusted spacing
    final adjustedSpacingSmall = DesignSystem.adjustedSpacingSmall;
    final adjustedSpacingMedium = DesignSystem.adjustedSpacingMedium;

    // Get platform-specific theme extension
    final platformTheme = PlatformThemeExtension.forCurrentPlatform();

    return ThemeData(
      primaryColor: DesignSystem.primaryColor,
      scaffoldBackgroundColor: DesignSystem.backgroundColor,
      textTheme: GoogleFonts.robotoTextTheme().copyWith(
        displayLarge: TextStyle(
          color: DesignSystem.textPrimaryColor,
          fontSize: adjustedFontSizeDisplay,
          fontWeight: DesignSystem.fontWeightBold,
          letterSpacing: DesignSystem.letterSpacingTight,
        ),
        displayMedium: TextStyle(
          color: DesignSystem.textPrimaryColor,
          fontSize: adjustedFontSizeXXLarge,
          fontWeight: DesignSystem.fontWeightBold,
          letterSpacing: DesignSystem.letterSpacingTight,
        ),
        headlineLarge: TextStyle(
          color: DesignSystem.textPrimaryColor,
          fontSize: adjustedFontSizeXXLarge,
          fontWeight: DesignSystem.fontWeightBold,
        ),
        headlineMedium: TextStyle(
          color: DesignSystem.textPrimaryColor,
          fontSize: adjustedFontSizeXLarge,
          fontWeight: DesignSystem.fontWeightBold,
        ),
        titleLarge: TextStyle(
          color: DesignSystem.textPrimaryColor,
          fontSize: adjustedFontSizeLarge,
          fontWeight: DesignSystem.fontWeightBold,
        ),
        bodyLarge: TextStyle(
          color: DesignSystem.textSecondaryColor,
          fontSize: adjustedFontSizeMedium,
          fontWeight: DesignSystem.fontWeightRegular,
        ),
        bodyMedium: TextStyle(
          color: DesignSystem.textSecondaryColor,
          fontSize: adjustedFontSizeSmall,
          fontWeight: DesignSystem.fontWeightRegular,
        ),
      ),
      colorScheme: ColorScheme.light(
        primary: DesignSystem.primaryColor,
        secondary: platformTheme.platformAccentColor,
        surface: DesignSystem.surfaceColor,
        error: DesignSystem.errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: Colors.black,
        onError: Colors.white,
        brightness: Brightness.light,
      ),
      cardTheme: CardTheme(
        elevation: platformTheme.platformCardElevation,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(platformTheme.platformBorderRadius),
        ),
        margin: EdgeInsets.all(adjustedSpacingSmall),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: platformTheme.platformContentPadding,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(platformTheme.platformBorderRadius),
          ),
          minimumSize: Size(DesignSystem.defaultButtonSize.width,
              platformTheme.platformButtonHeight),
          elevation: platformTheme.platformElevation,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(platformTheme.platformBorderRadius),
        ),
        contentPadding: platformTheme.platformContentPadding,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: DesignSystem.primaryColor,
        foregroundColor: Colors.white,
        elevation: platformTheme.platformElevation,
      ),
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(platformTheme.platformBorderRadius),
        ),
        elevation: platformTheme.platformElevation * 2,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignSystem.borderRadiusSmall),
        ),
      ),
      dividerTheme: DividerThemeData(
        space: adjustedSpacingMedium,
        thickness: 1,
      ),
      // Animation durations
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}
