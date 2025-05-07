import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'design_system.dart';
import 'dynamic_color_theme.dart';

class AppThemes {
  // Get dynamic theme based on user preferences
  static Future<ThemeData> getDynamicLightTheme({
    required bool useDynamicColors,
    required int colorSchemeIndex,
  }) async {
    return DynamicColorTheme.getLightTheme(
      useDynamicColors: useDynamicColors,
      colorSchemeIndex: colorSchemeIndex,
    ).then((dynamicTheme) {
      // Apply our custom theme properties to the dynamic theme
      return dynamicTheme.copyWith(
        appBarTheme: lightTheme.appBarTheme,
        cardTheme: lightTheme.cardTheme,
        elevatedButtonTheme: lightTheme.elevatedButtonTheme,
        textButtonTheme: lightTheme.textButtonTheme,
        outlinedButtonTheme: lightTheme.outlinedButtonTheme,
        switchTheme: lightTheme.switchTheme,
        checkboxTheme: lightTheme.checkboxTheme,
        radioTheme: lightTheme.radioTheme,
        dialogTheme: lightTheme.dialogTheme,
        snackBarTheme: lightTheme.snackBarTheme,
        navigationBarTheme: lightTheme.navigationBarTheme,
      );
    });
  }

  static Future<ThemeData> getDynamicDarkTheme({
    required bool useDynamicColors,
    required int colorSchemeIndex,
  }) async {
    return DynamicColorTheme.getDarkTheme(
      useDynamicColors: useDynamicColors,
      colorSchemeIndex: colorSchemeIndex,
    ).then((dynamicTheme) {
      // Apply our custom theme properties to the dynamic theme
      return dynamicTheme.copyWith(
        appBarTheme: darkTheme.appBarTheme,
        cardTheme: darkTheme.cardTheme,
        elevatedButtonTheme: darkTheme.elevatedButtonTheme,
        textButtonTheme: darkTheme.textButtonTheme,
        outlinedButtonTheme: darkTheme.outlinedButtonTheme,
        switchTheme: darkTheme.switchTheme,
        checkboxTheme: darkTheme.checkboxTheme,
        radioTheme: darkTheme.radioTheme,
        dialogTheme: darkTheme.dialogTheme,
        snackBarTheme: darkTheme.snackBarTheme,
        navigationBarTheme: darkTheme.navigationBarTheme,
        splashColor: darkTheme.splashColor,
        highlightColor: darkTheme.highlightColor,
        focusColor: darkTheme.focusColor,
        hoverColor: darkTheme.hoverColor,
        disabledColor: darkTheme.disabledColor,
      );
    });
  }

  // Light theme definition
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: DesignSystem.lightPrimaryColor,
    colorScheme: const ColorScheme.light(
      primary: DesignSystem.lightPrimaryColor,
      secondary: DesignSystem.lightSecondaryColor,
      tertiary: DesignSystem.lightAccentColor,
      error: DesignSystem.lightErrorColor,
      surface: DesignSystem.lightSurfaceColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: DesignSystem.lightTextPrimaryColor,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: DesignSystem.lightBackgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: DesignSystem.lightAppBarColor,
      foregroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      actionsIconTheme: IconThemeData(color: Colors.white),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: DesignSystem.lightStatusBarColor,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: DesignSystem.lightNavBarColor,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    ),
    cardTheme: CardTheme(
      color: DesignSystem.lightCardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignSystem.borderRadiusMedium),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: DesignSystem.lightPrimaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignSystem.borderRadiusSmall),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: DesignSystem.lightPrimaryColor,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: DesignSystem.lightPrimaryColor,
        side: const BorderSide(color: DesignSystem.lightPrimaryColor),
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: DesignSystem.lightTextPrimaryColor,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: TextStyle(
        color: DesignSystem.lightTextPrimaryColor,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: TextStyle(
        color: DesignSystem.lightTextPrimaryColor,
        fontWeight: FontWeight.bold,
      ),
      headlineLarge: TextStyle(
        color: DesignSystem.lightTextPrimaryColor,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: DesignSystem.lightTextPrimaryColor,
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: TextStyle(
        color: DesignSystem.lightTextPrimaryColor,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        color: DesignSystem.lightTextPrimaryColor,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: DesignSystem.lightTextPrimaryColor,
        fontWeight: FontWeight.bold,
      ),
      titleSmall: TextStyle(
        color: DesignSystem.lightTextPrimaryColor,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(
        color: DesignSystem.lightTextPrimaryColor,
      ),
      bodyMedium: TextStyle(
        color: DesignSystem.lightTextPrimaryColor,
      ),
      bodySmall: TextStyle(
        color: DesignSystem.lightTextSecondaryColor,
      ),
      labelLarge: TextStyle(
        color: DesignSystem.lightTextPrimaryColor,
      ),
      labelMedium: TextStyle(
        color: DesignSystem.lightTextPrimaryColor,
      ),
      labelSmall: TextStyle(
        color: DesignSystem.lightTextSecondaryColor,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: DesignSystem.lightDividerColor,
      thickness: 1,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: DesignSystem.lightNavBarColor,
      selectedItemColor: DesignSystem.lightPrimaryColor,
      unselectedItemColor: DesignSystem.lightTextSecondaryColor,
      elevation: 8,
    ),
    iconTheme: const IconThemeData(
      color: DesignSystem.lightIconColor,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return DesignSystem.lightPrimaryColor;
        }
        return Colors.grey;
      }),
      trackColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return DesignSystem.lightPrimaryColor.withAlpha(150);
        }
        return Colors.grey.withAlpha(150);
      }),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return DesignSystem.lightPrimaryColor;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(Colors.white),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return DesignSystem.lightPrimaryColor;
        }
        return DesignSystem.lightTextSecondaryColor;
      }),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: DesignSystem.lightSurfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignSystem.borderRadiusMedium),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: DesignSystem.lightPrimaryColor,
      foregroundColor: Colors.white,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: DesignSystem.lightSurfaceColor,
      contentTextStyle:
          const TextStyle(color: DesignSystem.lightTextPrimaryColor),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignSystem.borderRadiusSmall),
      ),
      behavior: SnackBarBehavior.floating,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: DesignSystem.lightNavBarColor,
      indicatorColor: DesignSystem.lightPrimaryColor.withAlpha(50),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: DesignSystem.lightPrimaryColor);
        }
        return const IconThemeData(color: DesignSystem.lightTextSecondaryColor);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(color: DesignSystem.lightPrimaryColor);
        }
        return const TextStyle(color: DesignSystem.lightTextSecondaryColor);
      }),
    ),
  );

  // Dark theme definition
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: DesignSystem.darkPrimaryColor,
    colorScheme: const ColorScheme.dark(
      primary: DesignSystem.darkPrimaryColor,
      secondary: DesignSystem.darkSecondaryColor,
      tertiary: DesignSystem.darkAccentColor,
      error: DesignSystem.darkErrorColor,
      surface: DesignSystem.darkSurfaceColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: DesignSystem.darkBackgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: DesignSystem.darkAppBarColor,
      foregroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      actionsIconTheme: IconThemeData(color: Colors.white),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: DesignSystem.darkStatusBarColor,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: DesignSystem.darkNavBarColor,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    ),
    cardTheme: CardTheme(
      color: DesignSystem.darkCardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignSystem.borderRadiusMedium),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: DesignSystem.darkButtonColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignSystem.borderRadiusSmall),
        ),
        elevation: 2,
        shadowColor: DesignSystem.darkButtonColor.withAlpha(100),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white),
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: DesignSystem.darkTextPrimaryColor,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: TextStyle(
        color: DesignSystem.darkTextPrimaryColor,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: TextStyle(
        color: DesignSystem.darkTextPrimaryColor,
        fontWeight: FontWeight.bold,
      ),
      headlineLarge: TextStyle(
        color: DesignSystem.darkTextPrimaryColor,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: DesignSystem.darkTextPrimaryColor,
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: TextStyle(
        color: DesignSystem.darkTextPrimaryColor,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        color: DesignSystem.darkTextPrimaryColor,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: DesignSystem.darkTextPrimaryColor,
        fontWeight: FontWeight.bold,
      ),
      titleSmall: TextStyle(
        color: DesignSystem.darkTextPrimaryColor,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(
        color: DesignSystem.darkTextPrimaryColor,
      ),
      bodyMedium: TextStyle(
        color: DesignSystem.darkTextPrimaryColor,
      ),
      bodySmall: TextStyle(
        color: DesignSystem.darkTextSecondaryColor,
      ),
      labelLarge: TextStyle(
        color: DesignSystem.darkTextPrimaryColor,
      ),
      labelMedium: TextStyle(
        color: DesignSystem.darkTextPrimaryColor,
      ),
      labelSmall: TextStyle(
        color: DesignSystem.darkTextSecondaryColor,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: DesignSystem.darkDividerColor,
      thickness: 1,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: DesignSystem.darkNavBarColor,
      selectedItemColor: Colors.white,
      unselectedItemColor: DesignSystem.darkTextSecondaryColor,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
    ),
    iconTheme: const IconThemeData(
      color:
          Colors.white, // White icons for better visibility on dark backgrounds
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.all(Colors.white),
      trackColor: WidgetStateProperty.all(DesignSystem.darkPrimaryColor),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.all(DesignSystem.darkPrimaryColor),
      checkColor: WidgetStateProperty.all(Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignSystem.borderRadiusSmall / 2),
      ),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.all(DesignSystem.darkPrimaryColor),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: DesignSystem.darkCardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignSystem.borderRadiusMedium),
      ),
      surfaceTintColor: Colors.transparent,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: DesignSystem.darkPrimaryColor,
      foregroundColor: Colors.white,
      elevation: 4,
      highlightElevation: 8,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: DesignSystem.darkCardColor,
      contentTextStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignSystem.borderRadiusSmall),
      ),
      behavior: SnackBarBehavior.floating,
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: DesignSystem.darkNavBarColor,
      indicatorColor: DesignSystem.darkPrimaryColor,
      surfaceTintColor: Colors.transparent,
      elevation: 4,
    ),
    // Additional theme properties
    splashColor: DesignSystem.darkSplashColor,
    highlightColor: DesignSystem.darkHighlightColor,
    focusColor: DesignSystem.darkFocusColor,
    hoverColor: DesignSystem.darkPrimaryColor,
    disabledColor: DesignSystem.darkDisabledColor,
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Colors.white,
      circularTrackColor: DesignSystem.darkPrimaryColor,
      linearTrackColor: DesignSystem.darkPrimaryColor,
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: DesignSystem.darkCardColor,
        borderRadius: BorderRadius.circular(DesignSystem.borderRadiusSmall),
      ),
      textStyle: const TextStyle(color: Colors.white),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: DesignSystem.darkMenuColor,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignSystem.borderRadiusSmall),
      ),
      surfaceTintColor: Colors.transparent,
    ),
  );
}
