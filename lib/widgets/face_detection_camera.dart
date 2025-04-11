import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:permission_handler/permission_handler.dart';
import '../config/design_system.dart';
import '../widgets/camera_selection_dialog.dart';

class FaceDetectionCamera extends StatefulWidget {
  final Function(File? image, List<Face>? faces) onFaceDetected;
  final double sensitivity;
  final bool showFaceOverlay;
  final CameraDescription? initialCamera;
  final Function(List<CameraDescription>)? onCamerasAvailable;

  const FaceDetectionCamera({
    Key? key,
    required this.onFaceDetected,
    this.sensitivity = 0.7,
    this.showFaceOverlay = true,
    this.initialCamera,
    this.onCamerasAvailable,
  }) : super(key: key);

  @override
  State<FaceDetectionCamera> createState() => _FaceDetectionCameraState();
}

class _FaceDetectionCameraState extends State<FaceDetectionCamera>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isCameraPermissionGranted = false;
  bool _isProcessingFrame = false;
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableClassification: true,
      enableTracking: true,
      performanceMode: FaceDetectorMode.fast,
      minFaceSize: 0.1, // More lenient minimum face size (0.0 to 1.0)
    ),
  );
  List<Face>? _detectedFaces;
  Size? _imageSize;
  Timer? _detectionTimer;
  int _framesWithFace = 0;
  int _errorCount = 0; // Counter for consecutive errors
  int _requiredFramesWithFace =
      2; // Reduced from 5 to make detection more responsive

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _requestCameraPermission();

    // Adjust required frames based on sensitivity
    _requiredFramesWithFace = (10 * (1 - widget.sensitivity)).round();
    if (_requiredFramesWithFace < 1) _requiredFramesWithFace = 1;
    if (_requiredFramesWithFace > 10) _requiredFramesWithFace = 10;
  }

  @override
  void didUpdateWidget(FaceDetectionCamera oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sensitivity != widget.sensitivity) {
      _requiredFramesWithFace = (10 * (1 - widget.sensitivity)).round();
      if (_requiredFramesWithFace < 1) _requiredFramesWithFace = 1;
      if (_requiredFramesWithFace > 10) _requiredFramesWithFace = 10;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;

    try {
      final CameraController? cameraController = _cameraController;

      // App state changed before we got the chance to initialize the camera
      if (cameraController == null) {
        return;
      }

      if (state == AppLifecycleState.inactive ||
          state == AppLifecycleState.paused) {
        // Stop timer first
        _detectionTimer?.cancel();

        // Then dispose camera safely
        if (_cameraController != null) {
          final CameraController oldController = _cameraController!;
          _cameraController = null;
          _isCameraInitialized = false;
          oldController.dispose().catchError((e) {
            debugPrint('Error disposing camera on lifecycle change: $e');
          });
        }
      } else if (state == AppLifecycleState.resumed) {
        // Reinitialize camera when app is resumed
        if (!_isCameraInitialized) {
          _initializeCamera();
        }
      }
    } catch (e) {
      debugPrint('Error handling app lifecycle state change: $e');
    }
  }

  @override
  void dispose() {
    try {
      // Remove observer first
      WidgetsBinding.instance.removeObserver(this);

      // Cancel timer
      if (_detectionTimer != null) {
        _detectionTimer!.cancel();
        _detectionTimer = null;
      }

      // Dispose camera controller safely
      if (_cameraController != null) {
        final CameraController oldController = _cameraController!;
        _cameraController = null;
        oldController.dispose().catchError((e) {
          debugPrint('Error disposing camera in dispose method: $e');
        });
      }

      // Close face detector
      _faceDetector.close().catchError((e) {
        debugPrint('Error closing face detector: $e');
      });
    } catch (e) {
      debugPrint('Error in dispose method: $e');
    } finally {
      super.dispose();
    }
  }

  /// Switch to a different camera
  Future<void> switchCamera(CameraDescription cameraDescription) async {
    if (!mounted || _cameraController == null) return;

    try {
      // Stop current camera and timer
      _detectionTimer?.cancel();

      // Safely dispose of the previous controller
      final CameraController oldController = _cameraController!;
      _cameraController = null;
      await oldController.dispose().catchError((e) {
        debugPrint('Error disposing previous camera: $e');
      });

      if (!mounted) return;

      // Initialize new camera
      _cameraController = CameraController(
        cameraDescription,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: kIsWeb
            ? ImageFormatGroup.jpeg
            : Platform.isAndroid
                ? ImageFormatGroup.yuv420
                : ImageFormatGroup.bgra8888,
      );

      if (!mounted) return;

      await _cameraController!.initialize().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Camera initialization timed out');
        },
      );

      if (!mounted) return;

      setState(() {
        _isCameraInitialized = true;
      });

      // Restart face detection
      _startFaceDetection();
    } catch (e) {
      debugPrint('Error switching camera: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error switching camera: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    setState(() {
      _isCameraPermissionGranted = status.isGranted;
    });

    if (_isCameraPermissionGranted) {
      _initializeCamera();
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
        debugPrint('No cameras available');
        return;
      }

      // Notify parent about available cameras if callback is provided
      if (widget.onCamerasAvailable != null) {
        widget.onCamerasAvailable!(_cameras!);
      }

      if (!mounted) return;

      // For desktop and web, show camera selection dialog if multiple cameras are available
      if ((kIsWeb || DesignSystem.isWindows) &&
          _cameras!.length > 1 &&
          mounted) {
        CameraDescription? selectedCamera;

        await showCameraSelectionDialog(
          context: context,
          cameras: _cameras!,
          onCameraSelected: (camera) {
            selectedCamera = camera;
          },
        );

        if (!mounted) return;

        if (selectedCamera != null) {
          await _setupCameraController(selectedCamera!);
          return;
        }
      }

      if (!mounted) return;

      // Use the provided camera, front camera, or first available camera
      CameraDescription selectedCamera;
      try {
        selectedCamera = widget.initialCamera ??
            _cameras!.firstWhere(
              (camera) => camera.lensDirection == CameraLensDirection.front,
              orElse: () => _cameras!.first,
            );
      } catch (e) {
        debugPrint('Error selecting camera: $e');
        if (_cameras!.isNotEmpty) {
          selectedCamera = _cameras!.first;
        } else {
          return; // No cameras available
        }
      }

      await _setupCameraController(selectedCamera);
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error initializing camera: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _setupCameraController(CameraDescription camera) async {
    if (!mounted) return;

    try {
      // Dispose previous controller if it exists
      if (_cameraController != null) {
        final CameraController oldController = _cameraController!;
        _cameraController = null;
        await oldController.dispose().catchError((e) {
          debugPrint('Error disposing previous camera: $e');
        });
      }

      if (!mounted) return;

      // Create new controller with higher resolution for better face detection
      _cameraController = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: kIsWeb
            ? ImageFormatGroup.jpeg
            : Platform.isAndroid
                ? ImageFormatGroup.yuv420
                : ImageFormatGroup.bgra8888,
      );

      if (!mounted) return;

      // Initialize with longer timeout
      await _cameraController!.initialize().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException('Camera initialization timed out');
        },
      );

      if (!mounted) return;

      setState(() {
        _isCameraInitialized = true;
      });

      // Start face detection
      _startFaceDetection();
    } catch (e) {
      debugPrint('Error setting up camera controller: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error setting up camera: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _startFaceDetection() {
    _detectionTimer?.cancel();
    _detectionTimer =
        Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (!_isProcessingFrame &&
          _cameraController != null &&
          _cameraController!.value.isInitialized) {
        _processImage();
      }
    });
  }

  // Static map to store web image bytes (workaround for web platform)
  static final Map<String, Uint8List> _webImageBytes = {};

  Future<void> _processImage() async {
    if (_isProcessingFrame ||
        !mounted ||
        _cameraController == null ||
        !_cameraController!.value.isInitialized) {
      return;
    }

    _isProcessingFrame = true;
    File? tempFile;

    try {
      // Take picture with longer timeout
      final XFile imageFile = await _cameraController!.takePicture().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw TimeoutException('Taking picture timed out');
        },
      );

      if (!mounted) return;

      if (kIsWeb) {
        // For web, we need to handle the XFile differently
        try {
          final bytes = await imageFile.readAsBytes();

          // Create a temporary path for web
          final tempPath = 'temp_${DateTime.now().millisecondsSinceEpoch}.jpg';
          tempFile = File(tempPath);

          // Store the bytes in a static map that can be accessed later if needed
          _webImageBytes[tempPath] = bytes;

          // Process image for face detection - for web we need to use InputImage.fromBytes
          // Get image size safely for better face detection
          Size imageSize = const Size(640, 480); // Default size
          Size? previewSize = _cameraController!.value.previewSize;
          if (previewSize != null) {
            imageSize = Size(previewSize.width, previewSize.height);
          }

          final inputImage = InputImage.fromBytes(
            bytes: bytes,
            metadata: InputImageMetadata(
              size: imageSize,
              rotation: InputImageRotation.rotation0deg,
              format: InputImageFormat
                  .bgra8888, // Try BGRA format for better compatibility
              bytesPerRow:
                  imageSize.width.toInt() * 4, // 4 bytes per pixel for RGBA
            ),
          );

          debugPrint('Web image size: ${imageSize.width}x${imageSize.height}');

          debugPrint('Web image captured and processed for face detection');

          // Store the image size for painting face overlay
          _imageSize = imageSize;

          // Process image with longer timeout
          final faces = await _faceDetector.processImage(inputImage).timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              throw TimeoutException('Face detection timed out');
            },
          );

          if (!mounted) return;

          setState(() {
            _detectedFaces = faces;
          });

          if (faces.isNotEmpty) {
            _framesWithFace++;
            if (_framesWithFace >= _requiredFramesWithFace) {
              // We have detected a face consistently for the required number of frames
              widget.onFaceDetected(tempFile, faces);
              _framesWithFace = 0; // Reset counter
            }
          } else {
            _framesWithFace = 0; // Reset counter if no face detected
          }
        } catch (webError) {
          debugPrint('Web-specific error in face detection: $webError');
          // Continue processing to avoid stopping face detection completely
        }
      } else {
        // Native platforms (Android, iOS, Windows, etc.)
        // Create file and verify it exists
        tempFile = File(imageFile.path);
        if (!await tempFile.exists()) {
          throw Exception('Captured image file does not exist');
        }

        final fileSize = await tempFile.length();
        if (fileSize <= 0) {
          throw Exception('Captured image file is empty (0 bytes)');
        }

        // Process image for face detection
        final inputImage = InputImage.fromFilePath(imageFile.path);

        // Log file details for debugging
        debugPrint(
            'Native image captured: ${imageFile.path}, size: ${await tempFile.length()} bytes');

        // Get image size safely
        Size? previewSize = _cameraController!.value.previewSize;
        if (previewSize != null) {
          // Store the correct orientation based on the platform
          if (Platform.isAndroid) {
            // On Android, we may need to swap dimensions based on the device orientation
            final deviceOrientation =
                _cameraController!.value.deviceOrientation;
            if (deviceOrientation == DeviceOrientation.landscapeLeft ||
                deviceOrientation == DeviceOrientation.landscapeRight) {
              _imageSize = Size(previewSize.width, previewSize.height);
            } else {
              _imageSize = Size(previewSize.height, previewSize.width);
            }
          } else {
            // For iOS and other platforms
            _imageSize = Size(previewSize.height, previewSize.width);
          }
          debugPrint(
              'Image size set to: ${_imageSize!.width}x${_imageSize!.height}');
        }

        // Process image with longer timeout
        final faces = await _faceDetector.processImage(inputImage).timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            throw TimeoutException('Face detection timed out');
          },
        );

        if (!mounted) return;

        setState(() {
          _detectedFaces = faces;
        });

        if (faces.isNotEmpty) {
          _framesWithFace++;
          if (_framesWithFace >= _requiredFramesWithFace) {
            // We have detected a face consistently for the required number of frames
            widget.onFaceDetected(tempFile, faces);
            _framesWithFace = 0; // Reset counter
          }
        } else {
          _framesWithFace = 0; // Reset counter if no face detected
        }
      }
    } catch (e) {
      debugPrint('Error processing image: $e');
      // Log more detailed error information
      if (e is TimeoutException) {
        debugPrint(
            'Face detection timed out. This could be due to device performance issues.');
      } else if (e is PlatformException) {
        debugPrint(
            'Platform error during face detection: ${e.code}, ${e.message}');
      }

      // Show error to user if it persists
      _errorCount++;
      if (_errorCount > 5 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Face detection is having trouble. Please ensure good lighting and that your face is clearly visible.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
        _errorCount = 0; // Reset after showing message
      }

      // Don't reset frames with face on error to avoid losing progress
    } finally {
      if (mounted) {
        _isProcessingFrame = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraPermissionGranted) {
      return _buildPermissionDeniedWidget();
    }

    if (!_isCameraInitialized || _cameraController == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Stack(
      children: [
        // Camera preview
        ClipRRect(
          borderRadius: BorderRadius.circular(DesignSystem.borderRadiusMedium),
          child: AspectRatio(
            aspectRatio: 1 / _cameraController!.value.aspectRatio,
            child: CameraPreview(_cameraController!),
          ),
        ),

        // Face overlay
        if (widget.showFaceOverlay &&
            _detectedFaces != null &&
            _imageSize != null)
          CustomPaint(
            painter: FaceOverlayPainter(
              faces: _detectedFaces!,
              imageSize: _imageSize!,
              previewSize: Size(
                MediaQuery.of(context).size.width,
                MediaQuery.of(context).size.width /
                    _cameraController!.value.aspectRatio,
              ),
            ),
          ),

        // Guidance overlay
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _detectedFaces == null || _detectedFaces!.isEmpty
                    ? 'No face detected'
                    : 'Face detected',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionDeniedWidget() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DesignSystem.primaryColor.withAlpha(25),
        borderRadius: BorderRadius.circular(DesignSystem.borderRadiusMedium),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.no_photography,
            size: 60,
            color: DesignSystem.primaryColor,
          ),
          const SizedBox(height: 16),
          const Text(
            'Camera permission is required',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Please grant camera permission to use facial verification',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _requestCameraPermission,
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignSystem.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Grant Permission'),
          ),
        ],
      ),
    );
  }
}

class FaceOverlayPainter extends CustomPainter {
  final List<Face> faces;
  final Size imageSize;
  final Size previewSize;

  FaceOverlayPainter({
    required this.faces,
    required this.imageSize,
    required this.previewSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.green;

    for (final Face face in faces) {
      // Convert face rectangle coordinates to preview coordinates
      final Rect faceRect = _scaleRect(
        rect: face.boundingBox,
        imageSize: imageSize,
        previewSize: previewSize,
      );

      // Draw face rectangle
      canvas.drawRect(faceRect, paint);

      // Draw face contours if available
      if (face.contours.isNotEmpty) {
        for (final MapEntry<FaceContourType, FaceContour?> entry
            in face.contours.entries) {
          final FaceContour? contour = entry.value;
          if (contour == null) continue;

          final List<Offset> scaledPoints = contour.points.map((point) {
            return _scalePoint(
              point: Offset(point.x.toDouble(), point.y.toDouble()),
              imageSize: imageSize,
              previewSize: previewSize,
            );
          }).toList();

          if (scaledPoints.length > 1) {
            final Path path = Path()
              ..moveTo(scaledPoints[0].dx, scaledPoints[0].dy);
            for (int i = 1; i < scaledPoints.length; i++) {
              path.lineTo(scaledPoints[i].dx, scaledPoints[i].dy);
            }
            canvas.drawPath(path, paint);
          }
        }
      }
    }
  }

  Rect _scaleRect({
    required Rect rect,
    required Size imageSize,
    required Size previewSize,
  }) {
    final double scaleX = previewSize.width / imageSize.width;
    final double scaleY = previewSize.height / imageSize.height;

    return Rect.fromLTRB(
      rect.left * scaleX,
      rect.top * scaleY,
      rect.right * scaleX,
      rect.bottom * scaleY,
    );
  }

  Offset _scalePoint({
    required Offset point,
    required Size imageSize,
    required Size previewSize,
  }) {
    final double scaleX = previewSize.width / imageSize.width;
    final double scaleY = previewSize.height / imageSize.height;

    return Offset(point.dx * scaleX, point.dy * scaleY);
  }

  @override
  bool shouldRepaint(FaceOverlayPainter oldDelegate) {
    return oldDelegate.faces != faces;
  }
}
