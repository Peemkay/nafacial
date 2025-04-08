import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:permission_handler/permission_handler.dart';
import '../config/design_system.dart';

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
      performanceMode: FaceDetectorMode.accurate,
    ),
  );
  List<Face>? _detectedFaces;
  Size? _imageSize;
  Timer? _detectionTimer;
  int _framesWithFace = 0;
  int _requiredFramesWithFace = 5; // Adjust based on sensitivity

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
    final CameraController? cameraController = _cameraController;

    // App state changed before we got the chance to initialize the camera
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _detectionTimer?.cancel();
    _cameraController?.dispose();
    _faceDetector.close();
    super.dispose();
  }

  /// Switch to a different camera
  Future<void> switchCamera(CameraDescription cameraDescription) async {
    if (_cameraController == null) return;

    // Stop current camera and timer
    _detectionTimer?.cancel();
    await _cameraController!.dispose();

    // Initialize new camera
    _cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.yuv420
          : ImageFormatGroup.bgra8888,
    );

    try {
      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });

        // Restart face detection
        _startFaceDetection();
      }
    } catch (e) {
      print('Error switching camera: $e');
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
    _cameras = await availableCameras();

    if (_cameras == null || _cameras!.isEmpty) {
      return;
    }

    // Notify parent about available cameras if callback is provided
    if (widget.onCamerasAvailable != null) {
      widget.onCamerasAvailable!(_cameras!);
    }

    // Use the provided camera, front camera, or first available camera
    final selectedCamera = widget.initialCamera ??
        _cameras!.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
          orElse: () => _cameras!.first,
        );

    _cameraController = CameraController(
      selectedCamera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.yuv420
          : ImageFormatGroup.bgra8888,
    );

    await _cameraController!.initialize();

    if (!mounted) return;

    setState(() {
      _isCameraInitialized = true;
    });

    // Start face detection
    _startFaceDetection();
  }

  void _startFaceDetection() {
    _detectionTimer?.cancel();
    _detectionTimer =
        Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (!_isProcessingFrame &&
          _cameraController != null &&
          _cameraController!.value.isInitialized) {
        _processImage();
      }
    });
  }

  Future<void> _processImage() async {
    if (_isProcessingFrame) return;
    _isProcessingFrame = true;

    try {
      final XFile imageFile = await _cameraController!.takePicture();
      final inputImage = InputImage.fromFilePath(imageFile.path);
      _imageSize = Size(
        _cameraController!.value.previewSize!.height,
        _cameraController!.value.previewSize!.width,
      );

      final faces = await _faceDetector.processImage(inputImage);

      if (mounted) {
        setState(() {
          _detectedFaces = faces;
        });

        if (faces.isNotEmpty) {
          _framesWithFace++;
          if (_framesWithFace >= _requiredFramesWithFace) {
            // We have detected a face consistently for the required number of frames
            widget.onFaceDetected(File(imageFile.path), faces);
            _framesWithFace = 0; // Reset counter
          }
        } else {
          _framesWithFace = 0; // Reset counter if no face detected
        }
      }
    } catch (e) {
      debugPrint('Error processing image: $e');
    } finally {
      _isProcessingFrame = false;
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
