import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Utility class for responsive design
class ResponsiveUtils {
  /// Screen size breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  /// Android-specific breakpoints
  static const double androidSmallBreakpoint = 360;
  static const double androidMediumBreakpoint = 400;
  static const double androidLargeBreakpoint = 480;

  /// Web-specific breakpoints
  static const double webSmallBreakpoint = 640;
  static const double webMediumBreakpoint = 768;
  static const double webLargeBreakpoint = 1024;
  static const double webXLargeBreakpoint = 1280;

  /// Check if the current platform is web
  static bool isWebPlatform() {
    return kIsWeb;
  }

  /// Check if the current platform is Android
  static bool isAndroidPlatform() {
    return !kIsWeb && Platform.isAndroid;
  }

  /// Check if the current screen size is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  /// Check if the current screen size is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < desktopBreakpoint;
  }

  /// Check if the current screen size is desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }

  /// Check if the device is in landscape orientation
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Check if the device is in portrait orientation
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  /// Get Android-specific screen size category
  static String getAndroidScreenCategory(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < androidSmallBreakpoint) return 'android-xsmall';
    if (width < androidMediumBreakpoint) return 'android-small';
    if (width < androidLargeBreakpoint) return 'android-medium';
    if (width < mobileBreakpoint) return 'android-large';
    return 'android-xlarge';
  }

  /// Get web-specific screen size category
  static String getWebScreenCategory(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < webSmallBreakpoint) return 'web-xsmall';
    if (width < webMediumBreakpoint) return 'web-small';
    if (width < webLargeBreakpoint) return 'web-medium';
    if (width < webXLargeBreakpoint) return 'web-large';
    return 'web-xlarge';
  }

  /// Get a responsive value based on screen size
  static T getResponsiveValue<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    required T desktop,
    T? androidSpecific,
    T? webSpecific,
  }) {
    // Platform-specific overrides
    if (androidSpecific != null && isAndroidPlatform()) {
      return androidSpecific;
    }

    if (webSpecific != null && isWebPlatform()) {
      return webSpecific;
    }

    // Standard responsive logic
    if (isDesktop(context)) {
      return desktop;
    } else if (isTablet(context)) {
      return tablet ?? desktop;
    } else {
      return mobile;
    }
  }

  /// Get a responsive font size
  static double getResponsiveFontSize(
    BuildContext context, {
    required double mobile,
    double? tablet,
    required double desktop,
    double? androidSpecific,
    double? webSpecific,
  }) {
    return getResponsiveValue(
      context: context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
      androidSpecific: androidSpecific,
      webSpecific: webSpecific,
    );
  }

  /// Get a responsive padding
  static EdgeInsets getResponsivePadding(
    BuildContext context, {
    required EdgeInsets mobile,
    EdgeInsets? tablet,
    required EdgeInsets desktop,
    EdgeInsets? androidSpecific,
    EdgeInsets? webSpecific,
  }) {
    return getResponsiveValue(
      context: context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
      androidSpecific: androidSpecific,
      webSpecific: webSpecific,
    );
  }

  /// Get a responsive size (width or height)
  static double getResponsiveSize(
    BuildContext context, {
    required double mobile,
    double? tablet,
    required double desktop,
    double? androidSpecific,
    double? webSpecific,
  }) {
    return getResponsiveValue(
      context: context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
      androidSpecific: androidSpecific,
      webSpecific: webSpecific,
    );
  }

  /// Get safe area padding
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Get device pixel ratio
  static double getDevicePixelRatio(BuildContext context) {
    return MediaQuery.of(context).devicePixelRatio;
  }

  /// Calculate text scale factor for accessibility
  static double getAccessibleTextScale(BuildContext context,
      {double baseSize = 1.0}) {
    // Get the platform's text scale factor (user's accessibility settings)
    final platformTextScale = MediaQuery.of(context).textScaler.scale(baseSize);

    // Limit the maximum text scaling to prevent layout issues
    return platformTextScale > 1.5 ? 1.5 : platformTextScale;
  }
}
