import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Service for advanced camera features including face tracking and focus light
class AdvancedCameraService {
  /// The camera controller
  CameraController? _cameraController;

  /// Get the camera controller
  CameraController? get cameraController => _cameraController;

  /// The face detector
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableClassification: true,
      enableTracking: true,
      performanceMode: FaceDetectorMode.fast,
      minFaceSize: 0.1,
    ),
  );

  /// Whether the torch is on
  bool _isTorchOn = false;

  /// Whether face tracking is enabled
  bool _isFaceTrackingEnabled = true;

  /// The current zoom level
  double _currentZoom = 1.0;

  /// The maximum zoom level
  double _maxZoom = 1.0;

  /// The minimum zoom level
  double _minZoom = 1.0;

  /// The current exposure offset
  double _currentExposureOffset = 0.0;

  /// The maximum exposure offset
  double _maxExposureOffset = 0.0;

  /// The minimum exposure offset
  double _minExposureOffset = 0.0;

  /// Stream controller for face detection events
  final StreamController<List<Face>> _facesStreamController =
      StreamController<List<Face>>.broadcast();

  /// Stream of detected faces
  Stream<List<Face>> get facesStream => _facesStreamController.stream;

  /// Timer for face detection
  Timer? _faceDetectionTimer;

  /// Whether the camera is initialized
  bool get isInitialized => _cameraController?.value.isInitialized ?? false;

  /// Whether the torch is on
  bool get isTorchOn => _isTorchOn;

  /// Whether face tracking is enabled
  bool get isFaceTrackingEnabled => _isFaceTrackingEnabled;

  /// The current zoom level
  double get currentZoom => _currentZoom;

  /// The maximum zoom level
  double get maxZoom => _maxZoom;

  /// The minimum zoom level
  double get minZoom => _minZoom;

  /// The current exposure offset
  double get currentExposureOffset => _currentExposureOffset;

  /// The maximum exposure offset
  double get maxExposureOffset => _maxExposureOffset;

  /// The minimum exposure offset
  double get minExposureOffset => _minExposureOffset;

  /// Initialize the camera
  Future<void> initialize({
    ResolutionPreset resolution = ResolutionPreset.high,
    CameraLensDirection lensDirection = CameraLensDirection.back,
  }) async {
    // Find the requested camera
    final cameras = await availableCameras();

    if (cameras.isEmpty) {
      throw CameraException(
          'No cameras available', 'No cameras were found on this device');
    }

    // Find the requested camera
    CameraDescription? camera;
    for (final cam in cameras) {
      if (cam.lensDirection == lensDirection) {
        camera = cam;
        break;
      }
    }

    // If the requested camera is not found, use the first camera
    camera ??= cameras.first;

    // Create and initialize the camera controller
    _cameraController = CameraController(
      camera,
      resolution,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    // Initialize the camera
    await _cameraController!.initialize();

    // Get the camera capabilities
    if (!kIsWeb) {
      _maxZoom = await _cameraController!.getMaxZoomLevel();
      _minZoom = await _cameraController!.getMinZoomLevel();
      _maxExposureOffset = await _cameraController!.getMaxExposureOffset();
      _minExposureOffset = await _cameraController!.getMinExposureOffset();
    }

    // Start face detection if enabled
    if (_isFaceTrackingEnabled) {
      _startFaceDetection();
    }
  }

  /// Dispose of resources
  void dispose() {
    _stopFaceDetection();
    _faceDetector.close();
    _cameraController?.dispose();
    _facesStreamController.close();
  }

  /// Toggle the torch
  Future<void> toggleTorch() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      _isTorchOn = !_isTorchOn;
      await _cameraController!.setFlashMode(
        _isTorchOn ? FlashMode.torch : FlashMode.off,
      );
    } catch (e) {
      debugPrint('Error toggling torch: $e');
    }
  }

  /// Set the torch mode
  Future<void> setTorch(bool isOn) async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      _isTorchOn = isOn;
      await _cameraController!.setFlashMode(
        _isTorchOn ? FlashMode.torch : FlashMode.off,
      );
    } catch (e) {
      debugPrint('Error setting torch: $e');
    }
  }

  /// Toggle face tracking
  void toggleFaceTracking() {
    _isFaceTrackingEnabled = !_isFaceTrackingEnabled;

    if (_isFaceTrackingEnabled) {
      _startFaceDetection();
    } else {
      _stopFaceDetection();
    }
  }

  /// Set face tracking
  void setFaceTracking(bool isEnabled) {
    if (_isFaceTrackingEnabled == isEnabled) {
      return;
    }

    _isFaceTrackingEnabled = isEnabled;

    if (_isFaceTrackingEnabled) {
      _startFaceDetection();
    } else {
      _stopFaceDetection();
    }
  }

  /// Set zoom level
  Future<void> setZoom(double zoom) async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      // Ensure zoom is within bounds
      zoom = zoom.clamp(_minZoom, _maxZoom);

      await _cameraController!.setZoomLevel(zoom);
      _currentZoom = zoom;
    } catch (e) {
      debugPrint('Error setting zoom: $e');
    }
  }

  /// Set exposure offset
  Future<void> setExposureOffset(double offset) async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      // Ensure offset is within bounds
      offset = offset.clamp(_minExposureOffset, _maxExposureOffset);

      await _cameraController!.setExposureOffset(offset);
      _currentExposureOffset = offset;
    } catch (e) {
      debugPrint('Error setting exposure offset: $e');
    }
  }

  /// Take a picture
  Future<XFile?> takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return null;
    }

    try {
      // Temporarily pause face detection
      final wasTrackingEnabled = _isFaceTrackingEnabled;
      if (wasTrackingEnabled) {
        _stopFaceDetection();
      }

      // Take the picture
      final XFile file = await _cameraController!.takePicture();

      // Resume face detection if it was enabled
      if (wasTrackingEnabled) {
        _startFaceDetection();
      }

      return file;
    } catch (e) {
      debugPrint('Error taking picture: $e');
      return null;
    }
  }

  /// Start video recording
  Future<void> startVideoRecording() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      await _cameraController!.startVideoRecording();
    } catch (e) {
      debugPrint('Error starting video recording: $e');
    }
  }

  /// Stop video recording
  Future<XFile?> stopVideoRecording() async {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized ||
        !_cameraController!.value.isRecordingVideo) {
      return null;
    }

    try {
      final XFile file = await _cameraController!.stopVideoRecording();
      return file;
    } catch (e) {
      debugPrint('Error stopping video recording: $e');
      return null;
    }
  }

  /// Start face detection
  void _startFaceDetection() {
    _stopFaceDetection(); // Stop any existing detection

    // Start a timer to detect faces periodically
    _faceDetectionTimer = Timer.periodic(
      const Duration(milliseconds: 200),
      (_) => _detectFaces(),
    );
  }

  /// Stop face detection
  void _stopFaceDetection() {
    _faceDetectionTimer?.cancel();
    _faceDetectionTimer = null;
  }

  /// Detect faces in the current camera frame
  Future<void> _detectFaces() async {
    // Skip if camera is not ready or face tracking is disabled
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized ||
        _cameraController!.value.isTakingPicture ||
        !_isFaceTrackingEnabled) {
      return;
    }

    try {
      // Capture a frame from the camera
      XFile? imageFile;
      try {
        imageFile = await _cameraController!.takePicture();
      } catch (e) {
        debugPrint('Error taking picture for face detection: $e');
        return; // Exit early if we can't take a picture
      }

      // We already checked for null above, but keep this for safety

      // Process the image for face detection
      List<Face> faces = [];
      try {
        final inputImage = InputImage.fromFilePath(imageFile.path);
        faces = await _faceDetector.processImage(inputImage);
      } catch (e) {
        debugPrint('Error processing image for face detection: $e');
      } finally {
        // Always try to delete the temporary file
        try {
          if (File(imageFile.path).existsSync()) {
            File(imageFile.path).deleteSync();
          }
        } catch (e) {
          debugPrint('Error deleting temporary file: $e');
        }
      }

      // Emit the detected faces if stream is still open
      if (!_facesStreamController.isClosed) {
        _facesStreamController.add(faces);
      }

      // Auto-focus on the face if a face is detected and not on web
      if (faces.isNotEmpty &&
          !kIsWeb &&
          _cameraController != null &&
          _cameraController!.value.isInitialized) {
        try {
          // Get the center of the first face
          final face = faces.first;
          final faceCenter = Offset(
            face.boundingBox.left + face.boundingBox.width / 2,
            face.boundingBox.top + face.boundingBox.height / 2,
          );

          // Make sure we have a valid preview size
          final previewSize = _cameraController!.value.previewSize;
          if (previewSize == null ||
              previewSize.width <= 0 ||
              previewSize.height <= 0) {
            return;
          }

          // Convert to normalized coordinates (0.0 to 1.0)
          final normalizedX = faceCenter.dx / previewSize.width;
          final normalizedY = faceCenter.dy / previewSize.height;

          // Ensure coordinates are within valid range
          if (normalizedX >= 0 &&
              normalizedX <= 1 &&
              normalizedY >= 0 &&
              normalizedY <= 1) {
            // Set focus point
            await _cameraController!
                .setFocusPoint(Offset(normalizedX, normalizedY));
            await _cameraController!
                .setExposurePoint(Offset(normalizedX, normalizedY));

            // Turn on the torch in low light conditions if a face is detected
            // Use the current exposure offset value we're tracking
            if (_currentExposureOffset < -1.0 && !_isTorchOn) {
              await setTorch(true);
            } else if (_currentExposureOffset >= -1.0 && _isTorchOn) {
              await setTorch(false);
            }
          }
        } catch (e) {
          debugPrint('Error setting focus or exposure: $e');
        }
      }
    } catch (e) {
      debugPrint('Error in face detection: $e');
    }
  }

  /// Save an image to the gallery
  Future<String?> saveImageToGallery(XFile imageFile) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final galleryDir = Directory('${appDir.path}/Gallery');

      // Create the gallery directory if it doesn't exist
      if (!await galleryDir.exists()) {
        await galleryDir.create(recursive: true);
      }

      // Generate a unique filename
      final fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedPath = path.join(galleryDir.path, fileName);

      // Copy the image to the gallery
      await File(imageFile.path).copy(savedPath);

      return savedPath;
    } catch (e) {
      debugPrint('Error saving image to gallery: $e');
      return null;
    }
  }

  /// Save a video to the gallery
  Future<String?> saveVideoToGallery(XFile videoFile) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final galleryDir = Directory('${appDir.path}/Gallery');

      // Create the gallery directory if it doesn't exist
      if (!await galleryDir.exists()) {
        await galleryDir.create(recursive: true);
      }

      // Generate a unique filename
      final fileName = 'video_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final savedPath = path.join(galleryDir.path, fileName);

      // Copy the video to the gallery
      await File(videoFile.path).copy(savedPath);

      return savedPath;
    } catch (e) {
      debugPrint('Error saving video to gallery: $e');
      return null;
    }
  }
}
