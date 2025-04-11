import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../services/advanced_camera_service.dart';
import '../config/design_system.dart';

/// A widget that displays a camera with advanced features
class AdvancedCameraWidget extends StatefulWidget {
  /// Callback when a picture is taken
  final Function(XFile)? onPictureTaken;

  /// Callback when a video is recorded
  final Function(XFile)? onVideoRecorded;

  /// Callback when a face is detected
  final Function(List<Face>)? onFacesDetected;

  /// Whether to enable face tracking
  final bool enableFaceTracking;

  /// Whether to show the face tracking overlay
  final bool showFaceTrackingOverlay;

  /// Whether to show the camera controls
  final bool showControls;

  /// The camera lens direction
  final CameraLensDirection lensDirection;

  /// The camera resolution
  final ResolutionPreset resolution;

  const AdvancedCameraWidget({
    Key? key,
    this.onPictureTaken,
    this.onVideoRecorded,
    this.onFacesDetected,
    this.enableFaceTracking = true,
    this.showFaceTrackingOverlay = true,
    this.showControls = true,
    this.lensDirection = CameraLensDirection.back,
    this.resolution = ResolutionPreset.high,
  }) : super(key: key);

  @override
  State<AdvancedCameraWidget> createState() => _AdvancedCameraWidgetState();
}

class _AdvancedCameraWidgetState extends State<AdvancedCameraWidget>
    with WidgetsBindingObserver {
  /// The advanced camera service
  final AdvancedCameraService _cameraService = AdvancedCameraService();

  /// Whether the camera is initializing
  bool _isInitializing = true;

  /// Whether the camera is recording video
  bool _isRecordingVideo = false;

  /// The detected faces
  List<Face> _faces = [];

  /// Subscription to the faces stream
  StreamSubscription<List<Face>>? _facesSubscription;

  /// The size of the preview
  Size? _previewSize;

  /// Error message to display if camera initialization fails
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _facesSubscription?.cancel();
    _cameraService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize the camera
    if (!_cameraService.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _cameraService.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  /// Initialize the camera
  Future<void> _initializeCamera() async {
    setState(() {
      _isInitializing = true;
    });

    try {
      await _cameraService
          .initialize(
        resolution: widget.resolution,
        lensDirection: widget.lensDirection,
      )
          .timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException(
              'Camera initialization timed out after 15 seconds');
        },
      );

      // Set face tracking
      _cameraService.setFaceTracking(widget.enableFaceTracking);

      // Listen for face detection events with error handling
      _facesSubscription = _cameraService.facesStream.listen(
        (faces) {
          if (mounted) {
            setState(() {
              _faces = faces;
            });
            widget.onFacesDetected?.call(faces);
          }
        },
        onError: (error) {
          debugPrint('Error in face detection stream: $error');
          // Continue listening despite errors
        },
      );

      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      if (mounted) {
        setState(() {
          _isInitializing = false;
          // Show error message
          _errorMessage =
              'Camera initialization failed: ${e.toString().split('Exception:').last}';
        });
      }
    }
  }

  /// Take a picture
  Future<void> takePicture() async {
    if (_isInitializing || _isRecordingVideo) {
      return;
    }

    try {
      final XFile? imageFile = await _cameraService.takePicture();

      if (imageFile != null && widget.onPictureTaken != null) {
        widget.onPictureTaken!(imageFile);
      }
    } catch (e) {
      debugPrint('Error taking picture: $e');
    }
  }

  /// Toggle video recording
  Future<void> toggleVideoRecording() async {
    if (_isInitializing) {
      return;
    }

    try {
      if (_isRecordingVideo) {
        final XFile? videoFile = await _cameraService.stopVideoRecording();

        setState(() {
          _isRecordingVideo = false;
        });

        if (videoFile != null && widget.onVideoRecorded != null) {
          widget.onVideoRecorded!(videoFile);
        }
      } else {
        await _cameraService.startVideoRecording();

        setState(() {
          _isRecordingVideo = true;
        });
      }
    } catch (e) {
      debugPrint('Error toggling video recording: $e');
    }
  }

  /// Toggle the torch
  Future<void> toggleTorch() async {
    await _cameraService.toggleTorch();
    setState(() {});
  }

  /// Toggle face tracking
  void toggleFaceTracking() {
    _cameraService.toggleFaceTracking();
    setState(() {});
  }

  /// Set zoom level
  Future<void> setZoom(double zoom) async {
    await _cameraService.setZoom(zoom);
    setState(() {});
  }

  /// Set exposure offset
  Future<void> setExposureOffset(double offset) async {
    await _cameraService.setExposureOffset(offset);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Show error message if camera initialization failed
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Camera Error',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _errorMessage = null;
                    _isInitializing = true;
                  });
                  _initializeCamera();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Camera preview
        _buildCameraPreview(),

        // Face tracking overlay
        if (widget.showFaceTrackingOverlay && _faces.isNotEmpty)
          _buildFaceTrackingOverlay(),

        // Camera controls
        if (widget.showControls) _buildCameraControls(),
      ],
    );
  }

  /// Build the camera preview
  Widget _buildCameraPreview() {
    // Check if camera controller is initialized
    if (_cameraService.cameraController == null ||
        !_cameraService.isInitialized) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Initializing camera...'),
          ],
        ),
      );
    }

    try {
      return AspectRatio(
        aspectRatio: 1 / _cameraService.cameraController!.value.aspectRatio,
        child: CameraPreview(
          _cameraService.cameraController!,
          child: LayoutBuilder(
            builder: (context, constraints) {
              _previewSize = Size(
                constraints.maxWidth,
                constraints.maxHeight,
              );
              return GestureDetector(
                onTapDown: (details) => _onTapToFocus(details),
                behavior: HitTestBehavior.opaque,
              );
            },
          ),
        ),
      );
    } catch (e) {
      // Handle any errors that might occur when building the camera preview
      debugPrint('Error building camera preview: $e');
      return Center(
        child: Text(
          'Camera preview error: ${e.toString().split('Exception:').last}',
          textAlign: TextAlign.center,
        ),
      );
    }
  }

  /// Build the face tracking overlay
  Widget _buildFaceTrackingOverlay() {
    if (_previewSize == null) {
      return const SizedBox.shrink();
    }

    return CustomPaint(
      painter: FaceTrackingPainter(
        faces: _faces,
        imageSize: _previewSize!,
        rotation: InputImageRotation.rotation0deg,
      ),
    );
  }

  /// Build the camera controls
  Widget _buildCameraControls() {
    return SafeArea(
      child: Column(
        children: [
          // Top controls
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Torch toggle
                IconButton(
                  icon: Icon(
                    _cameraService.isTorchOn ? Icons.flash_on : Icons.flash_off,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: toggleTorch,
                ),

                // Face tracking toggle
                IconButton(
                  icon: Icon(
                    _cameraService.isFaceTrackingEnabled
                        ? Icons.face
                        : Icons.face_outlined,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: toggleFaceTracking,
                ),
              ],
            ),
          ),

          const Spacer(),

          // Bottom controls
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Zoom slider
                Expanded(
                  child: Slider(
                    value: _cameraService.currentZoom,
                    min: _cameraService.minZoom,
                    max: _cameraService.maxZoom,
                    onChanged: setZoom,
                    activeColor: DesignSystem.primaryColor,
                  ),
                ),

                // Capture button
                GestureDetector(
                  onTap: takePicture,
                  onLongPress: toggleVideoRecording,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isRecordingVideo ? Colors.red : Colors.white,
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                    ),
                    child: _isRecordingVideo
                        ? const Icon(
                            Icons.stop,
                            color: Colors.white,
                            size: 32,
                          )
                        : const Icon(
                            Icons.camera_alt,
                            color: Colors.black,
                            size: 32,
                          ),
                  ),
                ),

                // Exposure slider
                Expanded(
                  child: Slider(
                    value: _cameraService.currentExposureOffset,
                    min: _cameraService.minExposureOffset,
                    max: _cameraService.maxExposureOffset,
                    onChanged: setExposureOffset,
                    activeColor: DesignSystem.accentColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Handle tap to focus
  void _onTapToFocus(TapDownDetails details) {
    if (_cameraService.cameraController == null ||
        !_cameraService.isInitialized ||
        kIsWeb) {
      return;
    }

    final offset = details.localPosition;

    // Convert tap coordinates to normalized coordinates (0.0 to 1.0)
    final double x = offset.dx / _previewSize!.width;
    final double y = offset.dy / _previewSize!.height;

    // Set focus and exposure points
    _cameraService.cameraController!.setFocusPoint(Offset(x, y));
    _cameraService.cameraController!.setExposurePoint(Offset(x, y));

    // Show focus animation
    setState(() {});
  }
}

/// Painter for face tracking overlay
class FaceTrackingPainter extends CustomPainter {
  /// The detected faces
  final List<Face> faces;

  /// The size of the image
  final Size imageSize;

  /// The rotation of the image
  final InputImageRotation rotation;

  FaceTrackingPainter({
    required this.faces,
    required this.imageSize,
    required this.rotation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.green;

    final Paint landmarkPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.blue
      ..strokeWidth = 3.0;

    for (final Face face in faces) {
      // Scale face bounding box to canvas size
      final Rect faceRect = _scaleRect(
        rect: face.boundingBox,
        imageSize: imageSize,
        canvasSize: size,
      );

      // Draw face bounding box
      canvas.drawRect(faceRect, paint);

      // Draw face contours
      for (final faceContour in face.contours.entries) {
        final points = faceContour.value?.points;
        if (points != null) {
          for (final point in points) {
            final Offset pointOffset = Offset(
              point.x.toDouble() * (size.width / imageSize.width),
              point.y.toDouble() * (size.height / imageSize.height),
            );
            canvas.drawCircle(pointOffset, 2, landmarkPaint);
          }
        }
      }

      // Draw face landmarks
      for (final landmark in face.landmarks.entries) {
        final landmarkPoint = landmark.value;
        if (landmarkPoint != null) {
          final Offset pointOffset = Offset(
            landmarkPoint.position.x.toDouble() *
                (size.width / imageSize.width),
            landmarkPoint.position.y.toDouble() *
                (size.height / imageSize.height),
          );
          canvas.drawCircle(pointOffset, 4, landmarkPaint);
        }
      }

      // Draw face tracking ID
      if (face.trackingId != null) {
        final TextSpan span = TextSpan(
          text: 'ID: ${face.trackingId}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            backgroundColor: Colors.black54,
          ),
        );
        final TextPainter textPainter = TextPainter(
          text: span,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(faceRect.left, faceRect.top - 20),
        );
      }
    }
  }

  @override
  bool shouldRepaint(FaceTrackingPainter oldDelegate) {
    return oldDelegate.faces != faces;
  }

  /// Scale a rectangle from image coordinates to canvas coordinates
  Rect _scaleRect({
    required Rect rect,
    required Size imageSize,
    required Size canvasSize,
  }) {
    final double scaleX = canvasSize.width / imageSize.width;
    final double scaleY = canvasSize.height / imageSize.height;

    return Rect.fromLTRB(
      rect.left * scaleX,
      rect.top * scaleY,
      rect.right * scaleX,
      rect.bottom * scaleY,
    );
  }

  // This method is no longer needed as we're calculating the offset directly
}
