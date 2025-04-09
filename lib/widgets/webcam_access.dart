import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:camera/camera.dart';
// import 'package:image_gallery_saver/image_gallery_saver.dart';
import '../config/design_system.dart';
import '../widgets/camera_selection_dialog.dart';

class WebcamAccess extends StatefulWidget {
  final Function(File) onImageCaptured;
  final bool showControls;
  final bool isVideoMode;

  const WebcamAccess({
    Key? key,
    required this.onImageCaptured,
    this.showControls = true,
    this.isVideoMode = false,
  }) : super(key: key);

  @override
  State<WebcamAccess> createState() => _WebcamAccessState();
}

class _WebcamAccessState extends State<WebcamAccess>
    with WidgetsBindingObserver {
  // Static map to store web image bytes (workaround for web platform)
  static final Map<String, Uint8List> _webImageBytes = {};

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
    if (!mounted) return;

    try {
      // Get available cameras with timeout
      _cameras = await availableCameras().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Camera detection timed out');
        },
      );

      if (!mounted) return;

      if (_cameras == null || _cameras!.isEmpty) {
        _showError('No cameras available');
        return;
      }

      // Print available cameras for debugging
      debugPrint('\n\n===== AVAILABLE CAMERAS =====');
      for (int i = 0; i < _cameras!.length; i++) {
        debugPrint(
            'Camera $i: ${_cameras![i].name} (${_cameras![i].lensDirection})');
      }
      debugPrint('===========================\n\n');

      // For desktop and web, show camera selection dialog
      if (mounted &&
          (kIsWeb || DesignSystem.isWindows) &&
          _cameras!.length > 1) {
        await showCameraSelectionDialog(
          context: context,
          cameras: _cameras!,
          onCameraSelected: (camera) {
            if (!mounted) return;
            final index = _cameras!.indexOf(camera);
            if (index >= 0) {
              _setupCamera(index);
            }
          },
        );
        return;
      }

      if (!mounted) return;

      // Try to find an external camera first for mobile
      int cameraToUse = _selectedCameraIndex;
      for (int i = 0; i < _cameras!.length; i++) {
        if (_cameras![i].lensDirection == CameraLensDirection.external) {
          cameraToUse = i;
          debugPrint('Found external camera at index $i');
          break;
        }
      }

      // Initialize with the selected camera
      await _setupCamera(cameraToUse);
    } catch (e) {
      if (mounted) {
        _showError('Error initializing camera: $e');
        debugPrint('Camera initialization error: $e');
      }
    }
  }

  Future<void> _setupCamera(int cameraIndex) async {
    if (!mounted || _cameras == null || _cameras!.isEmpty) return;

    if (cameraIndex >= _cameras!.length) {
      cameraIndex = 0;
    }

    try {
      // Dispose previous controller safely
      if (_cameraController != null) {
        final CameraController oldController = _cameraController!;
        _cameraController = null;
        await oldController.dispose().catchError((e) {
          debugPrint('Error disposing previous camera: $e');
        });
      }

      if (!mounted) return;

      // Get the camera description
      final camera = _cameras![cameraIndex];
      debugPrint('Setting up camera: ${camera.name} (${camera.lensDirection})');

      // Create new controller with lower resolution to avoid blank view issues
      _cameraController = CameraController(
        camera,
        ResolutionPreset.medium, // Use medium instead of high
        enableAudio: false,
        imageFormatGroup: kIsWeb
            ? ImageFormatGroup.jpeg
            : Platform.isAndroid
                ? ImageFormatGroup.yuv420
                : ImageFormatGroup.bgra8888,
      );

      if (!mounted) return;

      try {
        // Initialize the camera with a timeout
        debugPrint('Initializing camera controller...');
        await _cameraController!.initialize().timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw TimeoutException('Camera initialization timed out');
          },
        );

        if (!mounted) return;

        // Set flash mode to off to avoid issues
        await _cameraController!.setFlashMode(FlashMode.off).catchError((e) {
          debugPrint('Error setting flash mode: $e');
          // Continue even if setting flash mode fails
        });

        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
            _selectedCameraIndex = cameraIndex;
          });
          debugPrint('Camera initialized successfully');
        }
      } catch (e) {
        if (!mounted) return;
        debugPrint('Error setting up camera: $e');
        _showError('Error setting up camera: $e');

        // Reset controller to avoid further issues
        if (_cameraController != null) {
          await _cameraController!.dispose().catchError((e) {
            debugPrint(
                'Error disposing camera after initialization failure: $e');
          });
          _cameraController = null;
        }
      }
    } catch (e) {
      if (mounted) {
        debugPrint('Unexpected error in camera setup: $e');
        _showError('Unexpected error in camera setup: $e');
      }
    }
  }

  Future<void> _captureImage() async {
    if (_cameraController == null || !_isCameraInitialized || _isCapturing) {
      debugPrint('Cannot capture image: camera not ready or already capturing');
      return;
    }

    try {
      if (!mounted) return;

      setState(() {
        _isCapturing = true;
      });

      // Take picture with timeout
      final XFile photo = await _cameraController!.takePicture().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw TimeoutException('Taking picture timed out');
        },
      );

      if (!mounted) return;

      try {
        if (kIsWeb) {
          // For web, we need to handle the XFile differently
          // File.fromRawPath is not properly supported in web
          // Instead, we'll create a temporary file in memory
          try {
            final bytes = await photo.readAsBytes();

            // Create a temporary path for web
            final tempPath =
                'temp_${DateTime.now().millisecondsSinceEpoch}.jpg';
            final tempFile = File(tempPath);

            // Use a different approach for web
            // This is a workaround since File operations work differently on web
            widget.onImageCaptured(tempFile);

            // Store the bytes in a static map that can be accessed later if needed
            _webImageBytes[tempPath] = bytes;

            debugPrint('Web image captured successfully');
          } catch (webError) {
            debugPrint('Web-specific error: $webError');
            throw Exception('Failed to process image on web: $webError');
          }
        } else {
          final file = File(photo.path);
          // Verify file exists before proceeding
          if (await file.exists()) {
            final fileSize = await file.length();
            if (fileSize > 0) {
              debugPrint(
                  'Image captured successfully: ${file.path} ($fileSize bytes)');
              widget.onImageCaptured(file);
            } else {
              throw Exception('Captured image file is empty (0 bytes)');
            }
          } else {
            throw Exception(
                'Captured image file does not exist: ${photo.path}');
          }
        }
      } catch (e) {
        debugPrint('Error processing captured image: $e');
        if (mounted) {
          _showError('Error processing captured image: $e');
        }
      }
    } catch (e) {
      debugPrint('Error capturing image: $e');
      if (mounted) {
        _showError('Error capturing image: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  Future<void> _switchCamera() async {
    if (!mounted || _cameras == null || _cameras!.length <= 1) return;

    try {
      final nextIndex = (_selectedCameraIndex + 1) % _cameras!.length;
      await _setupCamera(nextIndex);
    } catch (e) {
      debugPrint('Error switching camera: $e');
      if (mounted) {
        _showError('Error switching camera: $e');
      }
    }
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
