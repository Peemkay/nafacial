import 'package:flutter/material.dart';
import '../config/design_system.dart';
import 'platform_aware_widgets.dart';

enum CameraMode {
  photo,
  video,
}

class CameraOptionsDialog extends StatelessWidget {
  final Function(CameraMode) onModeSelected;

  const CameraOptionsDialog({
    Key? key,
    required this.onModeSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignSystem.borderRadiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const PlatformText(
              'Select Capture Mode',
              isTitle: true,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildOptionButton(
                  context,
                  icon: Icons.photo_camera,
                  label: 'Photo',
                  onTap: () => onModeSelected(CameraMode.photo),
                  color: DesignSystem.primaryColor,
                ),
                _buildOptionButton(
                  context,
                  icon: Icons.videocam,
                  label: 'Video',
                  onTap: () => onModeSelected(CameraMode.video),
                  color: DesignSystem.accentColor,
                ),
              ],
            ),
            const SizedBox(height: 16),
            PlatformButton(
              text: 'Cancel',
              onPressed: () => Navigator.of(context).pop(),
              buttonType: PlatformButtonType.secondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DesignSystem.borderRadiusMedium),
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(DesignSystem.borderRadiusMedium),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 40,
            ),
            const SizedBox(height: 8),
            PlatformText(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
