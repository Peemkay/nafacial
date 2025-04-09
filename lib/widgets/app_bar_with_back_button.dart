import 'package:flutter/material.dart';
import '../config/design_system.dart';

/// A custom app bar with a back button
class AppBarWithBackButton extends StatelessWidget implements PreferredSizeWidget {
  /// The title of the app bar
  final String title;
  
  /// Callback when the back button is pressed
  final VoidCallback? onBackPressed;
  
  /// Additional actions to display in the app bar
  final List<Widget>? actions;
  
  /// Whether to center the title
  final bool centerTitle;
  
  /// The background color of the app bar
  final Color? backgroundColor;
  
  /// The color of the title and back button
  final Color? foregroundColor;
  
  /// The elevation of the app bar
  final double elevation;
  
  const AppBarWithBackButton({
    Key? key,
    required this.title,
    this.onBackPressed,
    this.actions,
    this.centerTitle = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: foregroundColor ?? (isDarkMode ? Colors.white : DesignSystem.lightTextPrimaryColor),
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? (isDarkMode ? DesignSystem.darkCardColor : Colors.white),
      elevation: elevation,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: foregroundColor ?? (isDarkMode ? Colors.white : DesignSystem.lightTextPrimaryColor),
        ),
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
      ),
      actions: actions,
    );
  }
  
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
