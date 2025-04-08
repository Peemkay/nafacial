import 'package:flutter/material.dart';
import '../config/app_themes.dart';

/// A widget that forces light theme for its child widget,
/// regardless of the app's current theme mode.
class LightThemeWrapper extends StatelessWidget {
  final Widget child;

  const LightThemeWrapper({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Create a new context with light theme
    return Theme(
      data: AppThemes.lightTheme,
      child: child,
    );
  }
}
