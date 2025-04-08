import 'package:flutter/material.dart';
import 'design_system.dart';

class AppThemes {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: DesignSystem.primaryColor,
    colorScheme: ColorScheme.light(
      primary: DesignSystem.primaryColor,
      secondary: DesignSystem.secondaryColor,
      error: DesignSystem.errorColor,
      background: Colors.white,
      surface: Colors.white,
    ),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: DesignSystem.primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignSystem.borderRadiusMedium),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: DesignSystem.primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignSystem.borderRadiusSmall),
        ),
      ),
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        color: DesignSystem.textPrimaryColor,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: DesignSystem.textPrimaryColor,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(
        color: DesignSystem.textPrimaryColor,
      ),
      bodyMedium: TextStyle(
        color: DesignSystem.textPrimaryColor,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: DesignSystem.dividerColor,
      thickness: 1,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: DesignSystem.primaryColor,
      unselectedItemColor: DesignSystem.textSecondaryColor,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: DesignSystem.primaryColor,
    colorScheme: ColorScheme.dark(
      primary: DesignSystem.primaryColor,
      secondary: DesignSystem.secondaryColor,
      error: DesignSystem.errorColor,
      background: const Color(0xFF121212),
      surface: const Color(0xFF1E1E1E),
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      color: const Color(0xFF1E1E1E),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignSystem.borderRadiusMedium),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: DesignSystem.primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignSystem.borderRadiusSmall),
        ),
      ),
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(
        color: Colors.white,
      ),
      bodyMedium: TextStyle(
        color: Colors.white,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF3E3E3E),
      thickness: 1,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1E1E1E),
      selectedItemColor: DesignSystem.primaryColor,
      unselectedItemColor: Colors.grey,
    ),
  );
}
