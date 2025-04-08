import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'design_system.dart';

class AppThemes {
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
      background: DesignSystem.lightBackgroundColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: DesignSystem.lightTextPrimaryColor,
      onBackground: DesignSystem.lightTextPrimaryColor,
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
      thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return DesignSystem.lightPrimaryColor;
        }
        return Colors.grey;
      }),
      trackColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return DesignSystem.lightPrimaryColor.withAlpha(150);
        }
        return Colors.grey.withAlpha(150);
      }),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return DesignSystem.lightPrimaryColor;
        }
        return Colors.transparent;
      }),
      checkColor: MaterialStateProperty.all(Colors.white),
    ),
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
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
      iconTheme: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return const IconThemeData(color: DesignSystem.lightPrimaryColor);
        }
        return const IconThemeData(color: DesignSystem.lightTextSecondaryColor);
      }),
      labelTextStyle: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
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
      primary: DesignSystem.darkCyan,
      secondary: DesignSystem.darkTeal,
      tertiary: DesignSystem.darkAccentColor,
      error: DesignSystem.darkErrorColor,
      surface: DesignSystem.darkSurfaceColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: DesignSystem.darkTextPrimaryColor,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: DesignSystem.darkBackgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: DesignSystem.darkAppBarColor,
      foregroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: DesignSystem.darkIconColor),
      actionsIconTheme: IconThemeData(color: DesignSystem.darkIconColor),
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
        foregroundColor: DesignSystem.darkCyan,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: DesignSystem.darkCyan,
        side: const BorderSide(color: DesignSystem.darkCyan),
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
      selectedItemColor: DesignSystem.darkCyan,
      unselectedItemColor: DesignSystem.darkTextSecondaryColor,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
    ),
    iconTheme: const IconThemeData(
      color: DesignSystem.darkIconColor,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.all(DesignSystem.darkCyan),
      trackColor: MaterialStateProperty.all(DesignSystem.darkGrey5),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.all(DesignSystem.darkCyan),
      checkColor: MaterialStateProperty.all(Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignSystem.borderRadiusSmall / 2),
      ),
    ),
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.all(DesignSystem.darkCyan),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: DesignSystem.darkSurfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignSystem.borderRadiusMedium),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: DesignSystem.darkCyan,
      foregroundColor: Colors.white,
      elevation: 4,
      highlightElevation: 8,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: DesignSystem.darkSurfaceColor,
      contentTextStyle:
          const TextStyle(color: DesignSystem.darkTextPrimaryColor),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignSystem.borderRadiusSmall),
      ),
      behavior: SnackBarBehavior.floating,
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: DesignSystem.darkNavBarColor,
      indicatorColor: DesignSystem.darkCyan,
      surfaceTintColor: Colors.transparent,
      elevation: 4,
    ),
    // Additional theme properties
    splashColor: DesignSystem.darkSplashColor,
    highlightColor: DesignSystem.darkHighlightColor,
    focusColor: DesignSystem.darkFocusColor,
    hoverColor: DesignSystem.darkCyan,
    disabledColor: DesignSystem.darkDisabledColor,
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: DesignSystem.darkCyan,
      circularTrackColor: DesignSystem.darkGrey5,
      linearTrackColor: DesignSystem.darkGrey5,
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: DesignSystem.darkGrey6,
        borderRadius: BorderRadius.circular(DesignSystem.borderRadiusSmall),
      ),
      textStyle: const TextStyle(color: DesignSystem.darkTextPrimaryColor),
    ),
  );
}
