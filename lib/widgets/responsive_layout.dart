import 'package:flutter/material.dart';
import '../utils/responsive_utils.dart';

/// A widget that displays different layouts based on screen size and platform
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;
  final Widget? android;
  final Widget? web;

  const ResponsiveLayout({
    Key? key,
    required this.mobile,
    this.tablet,
    required this.desktop,
    this.android,
    this.web,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Platform-specific layouts take precedence
    if (android != null && ResponsiveUtils.isAndroidPlatform()) {
      return android!;
    }

    if (web != null && ResponsiveUtils.isWebPlatform()) {
      return web!;
    }

    // Standard responsive layouts
    if (ResponsiveUtils.isDesktop(context)) {
      return desktop;
    } else if (ResponsiveUtils.isTablet(context)) {
      return tablet ?? desktop;
    } else {
      return mobile;
    }
  }
}

/// A widget that applies responsive padding based on screen size and platform
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final EdgeInsets mobilePadding;
  final EdgeInsets? tabletPadding;
  final EdgeInsets desktopPadding;
  final EdgeInsets? androidPadding;
  final EdgeInsets? webPadding;

  const ResponsivePadding({
    Key? key,
    required this.child,
    required this.mobilePadding,
    this.tabletPadding,
    required this.desktopPadding,
    this.androidPadding,
    this.webPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: ResponsiveUtils.getResponsivePadding(
        context,
        mobile: mobilePadding,
        tablet: tabletPadding,
        desktop: desktopPadding,
        androidSpecific: androidPadding,
        webSpecific: webPadding,
      ),
      child: child,
    );
  }
}

/// A widget that applies responsive constraints based on screen size and platform
class ResponsiveConstrainedBox extends StatelessWidget {
  final Widget child;
  final BoxConstraints mobileConstraints;
  final BoxConstraints? tabletConstraints;
  final BoxConstraints desktopConstraints;
  final BoxConstraints? androidConstraints;
  final BoxConstraints? webConstraints;

  const ResponsiveConstrainedBox({
    Key? key,
    required this.child,
    required this.mobileConstraints,
    this.tabletConstraints,
    required this.desktopConstraints,
    this.androidConstraints,
    this.webConstraints,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    BoxConstraints constraints;

    // Platform-specific constraints
    if (androidConstraints != null && ResponsiveUtils.isAndroidPlatform()) {
      constraints = androidConstraints!;
    } else if (webConstraints != null && ResponsiveUtils.isWebPlatform()) {
      constraints = webConstraints!;
    }
    // Standard responsive constraints
    else if (ResponsiveUtils.isDesktop(context)) {
      constraints = desktopConstraints;
    } else if (ResponsiveUtils.isTablet(context)) {
      constraints = tabletConstraints ?? desktopConstraints;
    } else {
      constraints = mobileConstraints;
    }

    return ConstrainedBox(
      constraints: constraints,
      child: child,
    );
  }
}

/// A widget that applies platform-specific styling
class PlatformAwareContainer extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final Color? androidBackgroundColor;
  final Color? webBackgroundColor;
  final EdgeInsets? padding;
  final EdgeInsets? androidPadding;
  final EdgeInsets? webPadding;
  final BoxDecoration? decoration;
  final BoxDecoration? androidDecoration;
  final BoxDecoration? webDecoration;

  const PlatformAwareContainer({
    Key? key,
    required this.child,
    this.backgroundColor,
    this.androidBackgroundColor,
    this.webBackgroundColor,
    this.padding,
    this.androidPadding,
    this.webPadding,
    this.decoration,
    this.androidDecoration,
    this.webDecoration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine the appropriate decoration
    BoxDecoration? finalDecoration;
    if (androidDecoration != null && ResponsiveUtils.isAndroidPlatform()) {
      finalDecoration = androidDecoration;
    } else if (webDecoration != null && ResponsiveUtils.isWebPlatform()) {
      finalDecoration = webDecoration;
    } else {
      finalDecoration = decoration;
    }

    // If no decoration but background color is specified
    if (finalDecoration == null) {
      Color? bgColor;
      if (androidBackgroundColor != null &&
          ResponsiveUtils.isAndroidPlatform()) {
        bgColor = androidBackgroundColor;
      } else if (webBackgroundColor != null &&
          ResponsiveUtils.isWebPlatform()) {
        bgColor = webBackgroundColor;
      } else {
        bgColor = backgroundColor;
      }

      if (bgColor != null) {
        finalDecoration = BoxDecoration(color: bgColor);
      }
    }

    // Determine the appropriate padding
    EdgeInsets? finalPadding;
    if (androidPadding != null && ResponsiveUtils.isAndroidPlatform()) {
      finalPadding = androidPadding;
    } else if (webPadding != null && ResponsiveUtils.isWebPlatform()) {
      finalPadding = webPadding;
    } else {
      finalPadding = padding;
    }

    return Container(
      decoration: finalDecoration,
      padding: finalPadding,
      child: child,
    );
  }
}

/// A widget that applies different text styles based on platform
class PlatformAwareText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextStyle? androidStyle;
  final TextStyle? webStyle;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;

  const PlatformAwareText(
    this.text, {
    Key? key,
    this.style,
    this.androidStyle,
    this.webStyle,
    this.textAlign,
    this.overflow,
    this.maxLines,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextStyle? finalStyle;

    if (androidStyle != null && ResponsiveUtils.isAndroidPlatform()) {
      finalStyle = androidStyle;
    } else if (webStyle != null && ResponsiveUtils.isWebPlatform()) {
      finalStyle = webStyle;
    } else {
      finalStyle = style;
    }

    return Text(
      text,
      style: finalStyle,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
    );
  }
}
