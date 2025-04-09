import 'package:flutter/material.dart';
import '../config/design_system.dart';
import '../services/biometric_service.dart';

/// A button widget that triggers biometric authentication
class BiometricAuthButton extends StatefulWidget {
  /// The text to display on the button
  final String text;
  
  /// The icon to display on the button
  final IconData icon;
  
  /// The reason for authentication to display to the user
  final String reason;
  
  /// Callback when authentication is successful
  final VoidCallback? onSuccess;
  
  /// Callback when authentication fails
  final Function(String)? onError;
  
  /// Callback when authentication is canceled
  final VoidCallback? onCancel;
  
  /// Whether to show a loading indicator during authentication
  final bool showLoading;
  
  /// The color of the button
  final Color? color;
  
  /// The size of the button
  final double size;
  
  const BiometricAuthButton({
    Key? key,
    this.text = 'Authenticate',
    this.icon = Icons.fingerprint,
    this.reason = 'Please authenticate to continue',
    this.onSuccess,
    this.onError,
    this.onCancel,
    this.showLoading = true,
    this.color,
    this.size = 48.0,
  }) : super(key: key);

  @override
  State<BiometricAuthButton> createState() => _BiometricAuthButtonState();
}

class _BiometricAuthButtonState extends State<BiometricAuthButton> {
  final BiometricService _biometricService = BiometricService();
  bool _isAuthenticating = false;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final buttonColor = widget.color ?? 
        (isDarkMode ? DesignSystem.accentColor : DesignSystem.primaryColor);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: _isAuthenticating ? null : _authenticate,
          borderRadius: BorderRadius.circular(widget.size / 2),
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: buttonColor.withOpacity(0.1),
              border: Border.all(
                color: buttonColor,
                width: 2,
              ),
            ),
            child: _isAuthenticating && widget.showLoading
                ? Padding(
                    padding: EdgeInsets.all(widget.size / 6),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(buttonColor),
                    ),
                  )
                : Icon(
                    widget.icon,
                    color: buttonColor,
                    size: widget.size / 2,
                  ),
          ),
        ),
        if (widget.text.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            widget.text,
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;
    
    setState(() {
      _isAuthenticating = true;
    });
    
    try {
      final result = await _biometricService.authenticate(
        reason: widget.reason,
      );
      
      if (result) {
        widget.onSuccess?.call();
      } else {
        widget.onCancel?.call();
      }
    } catch (e) {
      widget.onError?.call(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
        });
      }
    }
  }
}
