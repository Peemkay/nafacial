import 'package:flutter/material.dart';
import '../config/design_system.dart';
import '../utils/device_info_utils.dart';

class VersionInfo extends StatefulWidget {
  final Color? textColor;
  
  const VersionInfo({
    Key? key,
    this.textColor,
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
        (isDarkMode ? DesignSystem.darkTextSecondaryColor : DesignSystem.lightTextSecondaryColor);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: _isLoading
          ? const SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
          : Text(
              _versionInfo,
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
    );
  }
}
