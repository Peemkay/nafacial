import 'package:flutter/material.dart';
import 'design_system.dart';

/// A theme extension that provides platform-specific styling
class PlatformThemeExtension extends ThemeExtension<PlatformThemeExtension> {
  final Color platformAccentColor;
  final double platformBorderRadius;
  final EdgeInsets platformContentPadding;
  final double platformElevation;
  final Duration platformAnimationDuration;
  final Curve platformAnimationCurve;
  final double platformIconSize;
  final double platformButtonHeight;
  final double platformCardElevation;

  const PlatformThemeExtension({
    required this.platformAccentColor,
    required this.platformBorderRadius,
    required this.platformContentPadding,
    required this.platformElevation,
    required this.platformAnimationDuration,
    required this.platformAnimationCurve,
    required this.platformIconSize,
    required this.platformButtonHeight,
    required this.platformCardElevation,
  });

  /// Factory method to create Android-specific theme extension
  factory PlatformThemeExtension.android() {
    return PlatformThemeExtension(
      platformAccentColor: DesignSystem.secondaryColor,
      platformBorderRadius: DesignSystem.borderRadiusMedium,
      platformContentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 12.0,
      ),
      platformElevation: DesignSystem.elevationSmall,
      platformAnimationDuration: DesignSystem.durationMedium,
      platformAnimationCurve: Curves.easeInOut,
      platformIconSize: DesignSystem.iconSizeMedium,
      platformButtonHeight: 48.0,
      platformCardElevation: 2.0,
    );
  }

  /// Factory method to create Windows-specific theme extension
  factory PlatformThemeExtension.windows() {
    return PlatformThemeExtension(
      platformAccentColor: DesignSystem.primaryColor,
      platformBorderRadius: DesignSystem.borderRadiusLarge,
      platformContentPadding: const EdgeInsets.symmetric(
        horizontal: 24.0,
        vertical: 16.0,
      ),
      platformElevation: DesignSystem.elevationMedium,
      platformAnimationDuration: DesignSystem.durationShort,
      platformAnimationCurve: Curves.fastOutSlowIn,
      platformIconSize: DesignSystem.iconSizeLarge,
      platformButtonHeight: 44.0,
      platformCardElevation: 4.0,
    );
  }

  /// Factory method to create web-specific theme extension
  factory PlatformThemeExtension.web() {
    return PlatformThemeExtension(
      platformAccentColor: DesignSystem.accentColor,
      platformBorderRadius: DesignSystem.borderRadiusMedium,
      platformContentPadding: const EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 14.0,
      ),
      platformElevation: DesignSystem.elevationSmall,
      platformAnimationDuration: DesignSystem.durationMedium,
      platformAnimationCurve: Curves.easeOut,
      platformIconSize: DesignSystem.iconSizeMedium,
      platformButtonHeight: 42.0,
      platformCardElevation: 3.0,
    );
  }

  /// Get the appropriate platform theme extension based on the current platform
  static PlatformThemeExtension forCurrentPlatform() {
    if (DesignSystem.isAndroid) {
      return PlatformThemeExtension.android();
    } else if (DesignSystem.isWindows) {
      return PlatformThemeExtension.windows();
    } else if (DesignSystem.isWeb) {
      return PlatformThemeExtension.web();
    } else {
      // Default to Android if platform is unknown
      return PlatformThemeExtension.android();
    }
  }

  @override
  ThemeExtension<PlatformThemeExtension> copyWith({
    Color? platformAccentColor,
    double? platformBorderRadius,
    EdgeInsets? platformContentPadding,
    double? platformElevation,
    Duration? platformAnimationDuration,
    Curve? platformAnimationCurve,
    double? platformIconSize,
    double? platformButtonHeight,
    double? platformCardElevation,
  }) {
    return PlatformThemeExtension(
      platformAccentColor: platformAccentColor ?? this.platformAccentColor,
      platformBorderRadius: platformBorderRadius ?? this.platformBorderRadius,
      platformContentPadding: platformContentPadding ?? this.platformContentPadding,
      platformElevation: platformElevation ?? this.platformElevation,
      platformAnimationDuration: platformAnimationDuration ?? this.platformAnimationDuration,
      platformAnimationCurve: platformAnimationCurve ?? this.platformAnimationCurve,
      platformIconSize: platformIconSize ?? this.platformIconSize,
      platformButtonHeight: platformButtonHeight ?? this.platformButtonHeight,
      platformCardElevation: platformCardElevation ?? this.platformCardElevation,
    );
  }

  @override
  ThemeExtension<PlatformThemeExtension> lerp(
    covariant ThemeExtension<PlatformThemeExtension>? other,
    double t,
  ) {
    if (other is! PlatformThemeExtension) {
      return this;
    }

    return PlatformThemeExtension(
      platformAccentColor: Color.lerp(platformAccentColor, other.platformAccentColor, t)!,
      platformBorderRadius: lerpDouble(platformBorderRadius, other.platformBorderRadius, t),
      platformContentPadding: EdgeInsets.lerp(platformContentPadding, other.platformContentPadding, t)!,
      platformElevation: lerpDouble(platformElevation, other.platformElevation, t),
      platformAnimationDuration: lerpDuration(platformAnimationDuration, other.platformAnimationDuration, t),
      platformAnimationCurve: t < 0.5 ? platformAnimationCurve : other.platformAnimationCurve,
      platformIconSize: lerpDouble(platformIconSize, other.platformIconSize, t),
      platformButtonHeight: lerpDouble(platformButtonHeight, other.platformButtonHeight, t),
      platformCardElevation: lerpDouble(platformCardElevation, other.platformCardElevation, t),
    );
  }

  // Helper method to lerp double values
  double lerpDouble(double a, double b, double t) {
    return a + (b - a) * t;
  }

  // Helper method to lerp durations
  Duration lerpDuration(Duration a, Duration b, double t) {
    return Duration(
      milliseconds: lerpDouble(a.inMilliseconds.toDouble(), b.inMilliseconds.toDouble(), t).round(),
    );
  }
}
