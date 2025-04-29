import 'package:flutter/material.dart';
import '../config/design_system.dart';

/// Button types for platform buttons
enum PlatformButtonType {
  primary,
  secondary,
  danger,
  success,
  warning,
}

/// A button that adapts to the current platform
class PlatformButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isPrimary;
  final bool isFullWidth;
  final bool isSmall;
  final PlatformButtonType? buttonType;

  const PlatformButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isPrimary = true,
    this.isFullWidth = false,
    this.isSmall = false,
    this.buttonType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine button style based on button type or primary flag
    ButtonStyle buttonStyle;

    if (buttonType != null) {
      switch (buttonType!) {
        case PlatformButtonType.primary:
          buttonStyle = ElevatedButton.styleFrom(
            backgroundColor: DesignSystem.primaryColor,
            foregroundColor: Colors.white,
          );
          break;
        case PlatformButtonType.secondary:
          buttonStyle = ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: DesignSystem.primaryColor,
            side: const BorderSide(color: DesignSystem.primaryColor),
          );
          break;
        case PlatformButtonType.danger:
          buttonStyle = ElevatedButton.styleFrom(
            backgroundColor: DesignSystem.errorColor,
            foregroundColor: Colors.white,
          );
          break;
        case PlatformButtonType.success:
          buttonStyle = ElevatedButton.styleFrom(
            backgroundColor: DesignSystem.successColor,
            foregroundColor: Colors.white,
          );
          break;
        case PlatformButtonType.warning:
          buttonStyle = ElevatedButton.styleFrom(
            backgroundColor: DesignSystem.warningColor,
            foregroundColor: Colors.white,
          );
          break;
      }
    } else {
      // Use the legacy isPrimary flag for backward compatibility
      buttonStyle = isPrimary
          ? ElevatedButton.styleFrom(
              backgroundColor: DesignSystem.primaryColor,
              foregroundColor: Colors.white,
            )
          : ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: DesignSystem.primaryColor,
              side: const BorderSide(color: DesignSystem.primaryColor),
            );
    }

    // Determine button size
    final buttonSize = isSmall
        ? Size(DesignSystem.defaultButtonSize.width * 0.8,
            DesignSystem.defaultButtonSize.height * 0.8)
        : DesignSystem.defaultButtonSize;

    // Create button with or without icon
    Widget button;
    if (icon != null) {
      button = ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: DesignSystem.iconSizeSmall),
        label: Text(text),
        style: buttonStyle.copyWith(
          minimumSize: WidgetStateProperty.all(buttonSize),
        ),
      );
    } else {
      button = ElevatedButton(
        onPressed: onPressed,
        style: buttonStyle.copyWith(
          minimumSize: WidgetStateProperty.all(buttonSize),
        ),
        child: Text(text),
      );
    }

    // Apply full width if needed
    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }
}

/// A card that adapts to the current platform
class PlatformCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? elevation;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const PlatformCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.elevation,
    this.borderRadius,
    this.backgroundColor,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Platform-specific adjustments
    final effectiveElevation = elevation ?? DesignSystem.cardElevation;
    final effectiveBorderRadius = borderRadius ?? DesignSystem.cardBorderRadius;
    final effectiveBackgroundColor =
        backgroundColor ?? DesignSystem.surfaceColor;
    final effectivePadding =
        padding ?? EdgeInsets.all(DesignSystem.adjustedSpacingMedium);
    final effectiveMargin =
        margin ?? EdgeInsets.all(DesignSystem.adjustedSpacingSmall);

    // Create the card
    final card = Card(
      elevation: effectiveElevation,
      shape: RoundedRectangleBorder(
        borderRadius: effectiveBorderRadius,
      ),
      color: effectiveBackgroundColor,
      margin: effectiveMargin,
      child: Padding(
        padding: effectivePadding,
        child: child,
      ),
    );

    // Make it tappable if needed
    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: effectiveBorderRadius,
        child: card,
      );
    }

    return card;
  }
}

/// A text field that adapts to the current platform
class PlatformTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final int? maxLines;
  final int? minLines;
  final bool enabled;

  const PlatformTextField({
    Key? key,
    this.label,
    this.hint,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
    this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.maxLines = 1,
    this.minLines,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Platform-specific adjustments
    final borderRadius = BorderRadius.circular(DesignSystem.borderRadiusMedium);

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      onChanged: onChanged,
      maxLines: maxLines,
      minLines: minLines,
      enabled: enabled,
      style: TextStyle(
        fontSize: DesignSystem.adjustedFontSizeMedium,
        color: DesignSystem.textPrimaryColor,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: suffixIcon != null
            ? IconButton(
                icon: Icon(suffixIcon),
                onPressed: onSuffixIconPressed,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: borderRadius,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(
            color: DesignSystem.primaryColor.withValues(alpha: 128),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: const BorderSide(
            color: DesignSystem.primaryColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: const BorderSide(
            color: DesignSystem.errorColor,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: DesignSystem.adjustedSpacingMedium,
          vertical: DesignSystem.adjustedSpacingSmall,
        ),
      ),
    );
  }
}

/// A container that adapts to the current platform
class PlatformContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final double? width;
  final double? height;
  final Alignment? alignment;

  const PlatformContainer({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.border,
    this.boxShadow,
    this.width,
    this.height,
    this.alignment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Platform-specific adjustments
    final effectivePadding =
        padding ?? EdgeInsets.all(DesignSystem.adjustedSpacingMedium);
    final effectiveMargin = margin ?? EdgeInsets.zero;
    final effectiveBorderRadius =
        borderRadius ?? BorderRadius.circular(DesignSystem.borderRadiusMedium);

    return Container(
      width: width,
      height: height,
      padding: effectivePadding,
      margin: effectiveMargin,
      alignment: alignment,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: effectiveBorderRadius,
        border: border,
        boxShadow: boxShadow,
      ),
      child: child,
    );
  }
}

/// A text widget that adapts to the current platform
class PlatformText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final bool isTitle;
  final bool isHeadline;
  final bool isCaption;

  const PlatformText(
    this.text, {
    Key? key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.isTitle = false,
    this.isHeadline = false,
    this.isCaption = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine text style based on properties
    TextStyle effectiveStyle;

    if (isHeadline) {
      effectiveStyle = Theme.of(context).textTheme.headlineMedium!;
    } else if (isTitle) {
      effectiveStyle = Theme.of(context).textTheme.titleLarge!;
    } else if (isCaption) {
      effectiveStyle = Theme.of(context).textTheme.bodySmall!;
    } else {
      effectiveStyle = Theme.of(context).textTheme.bodyMedium!;
    }

    // Apply custom properties
    if (fontSize != null || fontWeight != null || color != null) {
      effectiveStyle = effectiveStyle.copyWith(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      );
    }

    // Apply custom style if provided
    if (style != null) {
      effectiveStyle = effectiveStyle.merge(style);
    }

    return Text(
      text,
      style: effectiveStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// A scaffold that adapts to the current platform
class PlatformScaffold extends StatelessWidget {
  final String? title;
  final Widget? body;
  final Widget? floatingActionButton;
  final List<Widget>? actions;
  final Widget? drawer;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;
  final bool resizeToAvoidBottomInset;
  final PreferredSizeWidget? appBar;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const PlatformScaffold({
    Key? key,
    this.title,
    this.body,
    this.floatingActionButton,
    this.actions,
    this.drawer,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
    this.appBar,
    this.scaffoldKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Create platform-specific app bar if title is provided
    final effectiveAppBar = appBar ??
        (title != null
            ? AppBar(
                title: Text(title!),
                actions: actions,
                backgroundColor: DesignSystem.primaryColor,
                elevation: DesignSystem.elevationSmall,
              )
            : null);

    // Create scaffold with platform-specific adjustments
    return Scaffold(
      key: scaffoldKey,
      appBar: effectiveAppBar,
      body: body,
      floatingActionButton: floatingActionButton,
      drawer: drawer,
      bottomNavigationBar: bottomNavigationBar,
      backgroundColor: backgroundColor ?? DesignSystem.backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    );
  }
}
