import 'package:flutter/material.dart';
import '../config/design_system.dart';
import '../utils/device_info_utils.dart';
import 'platform_aware_widgets.dart';

class VersionInfo extends StatefulWidget {
  final Color? textColor;
  final bool useBackground;
  final bool showIcon;
  final double fontSize;
  final EdgeInsets padding;

  const VersionInfo({
    Key? key,
    this.textColor,
    this.useBackground = false,
    this.showIcon = false,
    this.fontSize = 12.0,
    this.padding = const EdgeInsets.symmetric(vertical: 16.0),
  }) : super(key: key);

  @override
  State<VersionInfo> createState() => _VersionInfoState();
}

class _VersionInfoState extends State<VersionInfo> {
  String _versionInfo = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVersionInfo();
  }

  Future<void> _loadVersionInfo() async {
    final versionInfo = await DeviceInfoUtils.getFullVersionInfo();
    if (mounted) {
      setState(() {
        _versionInfo = versionInfo;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = widget.textColor ??
        (isDarkMode
            ? DesignSystem.darkTextSecondaryColor
            : DesignSystem.lightTextSecondaryColor);

    if (_isLoading) {
      return Padding(
        padding: widget.padding,
        child: const SizedBox(
          height: 16,
          width: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      );
    }

    final versionText = widget.showIcon
        ? Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline,
                size: widget.fontSize + 2,
                color: textColor,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  _versionInfo,
                  style: TextStyle(
                    color: textColor,
                    fontSize: widget.fontSize,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          )
        : Text(
            _versionInfo,
            style: TextStyle(
              color: textColor,
              fontSize: widget.fontSize,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          );

    if (widget.useBackground) {
      return Padding(
        padding: widget.padding,
        child: PlatformContainer(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          backgroundColor: isDarkMode
              ? DesignSystem.darkSurfaceColor.withAlpha(179) // 0.7 opacity
              : DesignSystem.lightSurfaceColor.withAlpha(179), // 0.7 opacity
          borderRadius: BorderRadius.circular(DesignSystem.borderRadiusSmall),
          child: versionText,
        ),
      );
    }

    return Padding(
      padding: widget.padding,
      child: versionText,
    );
  }
}
