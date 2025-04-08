import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../config/design_system.dart';

class WebcamAccess extends StatefulWidget {
  final Function(File) onImageCaptured;
  final bool showControls;

  const WebcamAccess({
    Key? key,
    required this.onImageCaptured,
    this.showControls = true,
  }) : super(key: key);

  @override
  State<WebcamAccess> createState() => _WebcamAccessState();
}

class _WebcamAccessState extends State<WebcamAccess>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isCapturing = false;
  int _selectedCameraIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (_cameraController != null) {
        _initializeCamera();
      }
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();

      if (_cameras == null || _cameras!.isEmpty) {
        _showError('No cameras available');
        return;
      }

      // Print available cameras for debugging
      print('\n\n===== AVAILABLE CAMERAS =====');
      for (int i = 0; i < _cameras!.length; i++) {
        print(
            'Camera $i: ${_cameras![i].name} (${_cameras![i].lensDirection})');
      }
      print('===========================\n\n');

      // Try to find an external camera first
      int cameraToUse = _selectedCameraIndex;
      for (int i = 0; i < _cameras!.length; i++) {
        if (_cameras![i].lensDirection == CameraLensDirection.external) {
          cameraToUse = i;
          print('Found external camera at index $i');
          break;
        }
      }

      // Initialize with the selected camera
      await _setupCamera(cameraToUse);
    } catch (e) {
      _showError('Error initializing camera: $e');
    }
  }

  Future<void> _setupCamera(int cameraIndex) async {
    if (_cameras == null || _cameras!.isEmpty) return;

    if (cameraIndex >= _cameras!.length) {
      cameraIndex = 0;
    }

    // Dispose previous controller
    await _cameraController?.dispose();

    // Get the camera description
    final camera = _cameras![cameraIndex];
    print('Setting up camera: ${camera.name} (${camera.lensDirection})');

    // Create new controller with lower resolution to avoid blank view issues
    _cameraController = CameraController(
      camera,
      ResolutionPreset.medium, // Use medium instead of high
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.yuv420
          : ImageFormatGroup.bgra8888,
    );

    try {
      // Initialize the camera with a timeout
      print('Initializing camera controller...');
      await _cameraController!.initialize().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Camera initialization timed out');
        },
      );

      // Set flash mode to off to avoid issues
      await _cameraController!.setFlashMode(FlashMode.off);

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
          _selectedCameraIndex = cameraIndex;
        });
        print('Camera initialized successfully');
      }
    } catch (e) {
      print('Error setting up camera: $e');
      _showError('Error setting up camera: $e');
    }
  }

  Future<void> _captureImage() async {
    if (_cameraController == null || !_isCameraInitialized || _isCapturing) {
      return;
    }

    try {
      setState(() {
        _isCapturing = true;
      });

      final XFile photo = await _cameraController!.takePicture();

      if (mounted) {
        widget.onImageCaptured(File(photo.path));
      }
    } catch (e) {
      _showError('Error capturing image: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  void _switchCamera() async {
    if (_cameras == null || _cameras!.length <= 1) return;

    final nextIndex = (_selectedCameraIndex + 1) % _cameras!.length;
    await _setupCamera(nextIndex);
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized || _cameraController == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              _cameras == null || _cameras!.isEmpty
                  ? 'No cameras available'
                  : 'Initializing camera...',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(DesignSystem.borderRadiusMedium),
            child: CameraPreview(_cameraController!),
          ),
        ),
        if (widget.showControls)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Switch camera button
                if (_cameras != null && _cameras!.length > 1)
                  IconButton(
                    icon: const Icon(Icons.flip_camera_ios),
                    onPressed: _switchCamera,
                    tooltip: 'Switch Camera',
                    color: DesignSystem.primaryColor,
                    iconSize: 32,
                  ),

                // Capture button
                GestureDetector(
                  onTap: _captureImage,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: DesignSystem.primaryColor,
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                    ),
                    child: _isCapturing
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 36,
                          ),
                  ),
                ),

                // Placeholder to balance the layout
                if (_cameras != null && _cameras!.length > 1)
                  const SizedBox(width: 48)
                else
                  const SizedBox(width: 0),
              ],
            ),
          ),
      ],
    );
  }
}
