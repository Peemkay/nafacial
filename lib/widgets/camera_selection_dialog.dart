import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../config/design_system.dart';

class CameraSelectionDialog extends StatelessWidget {
  final List<CameraDescription> cameras;
  final Function(CameraDescription) onCameraSelected;

  const CameraSelectionDialog({
    Key? key,
    required this.cameras,
    required this.onCameraSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Camera'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: cameras.length,
          itemBuilder: (context, index) {
            final camera = cameras[index];
            final isFrontFacing = camera.lensDirection == CameraLensDirection.front;
            final isBackFacing = camera.lensDirection == CameraLensDirection.back;
            final isExternal = camera.lensDirection == CameraLensDirection.external;
            
            String cameraName = 'Camera ${index + 1}';
            IconData cameraIcon = Icons.camera_alt;
            
            if (isFrontFacing) {
              cameraName = 'Front Camera';
              cameraIcon = Icons.camera_front;
            } else if (isBackFacing) {
              cameraName = 'Back Camera';
              cameraIcon = Icons.camera_rear;
            } else if (isExternal) {
              cameraName = 'External Camera';
              cameraIcon = Icons.videocam;
            }
            
            return ListTile(
              leading: Icon(
                cameraIcon,
                color: DesignSystem.primaryColor,
              ),
              title: Text(cameraName),
              subtitle: Text(camera.name),
              onTap: () {
                Navigator.of(context).pop();
                onCameraSelected(camera);
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

/// Shows a dialog to select a camera
Future<void> showCameraSelectionDialog({
  required BuildContext context,
  required List<CameraDescription> cameras,
  required Function(CameraDescription) onCameraSelected,
}) async {
  if (cameras.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No cameras available'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }
  
  if (cameras.length == 1) {
    // If there's only one camera, select it automatically
    onCameraSelected(cameras.first);
    return;
  }
  
  await showDialog(
    context: context,
    builder: (context) => CameraSelectionDialog(
      cameras: cameras,
      onCameraSelected: onCameraSelected,
    ),
  );
}
