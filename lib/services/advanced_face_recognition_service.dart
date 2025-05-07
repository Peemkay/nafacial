import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Offset, Rect;
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import '../models/face_model.dart';

/// A simplified advanced face recognition service using image processing
class AdvancedFaceRecognitionService {
  // Singleton instance
  static final AdvancedFaceRecognitionService _instance =
      AdvancedFaceRecognitionService._internal();

  // Factory constructor
  factory AdvancedFaceRecognitionService() => _instance;

  // Internal constructor
  AdvancedFaceRecognitionService._internal();

  // Status
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // Stream controllers
  final StreamController<List<Face>> _facesStreamController =
      StreamController<List<Face>>.broadcast();

  // Getters
  Stream<List<Face>> get facesStream => _facesStreamController.stream;

  // Face detection parameters
  final double _minFaceSize = 0.15; // Minimum face size relative to image
  final double _confidenceThreshold =
      0.5; // Reduced confidence threshold for face detection

  /// Initialize the service
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      _isInitialized = true;
      debugPrint('Advanced face recognition service initialized');
      return true;
    } catch (e) {
      debugPrint('Error initializing advanced face recognition service: $e');
      return false;
    }
  }

  /// Detect faces in an image file using basic image processing
  Future<List<Face>> detectFaces(XFile imageFile) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Read the image file
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        debugPrint('Failed to decode image');
        return [];
      }

      // Use a simple algorithm to detect faces
      final faces = _detectFacesInImage(image);

      // Emit the faces
      _facesStreamController.add(faces);

      return faces;
    } catch (e) {
      debugPrint('Error detecting faces: $e');
      return [];
    }
  }

  /// Detect faces in an image using basic image processing
  List<Face> _detectFacesInImage(img.Image image) {
    // For simplicity, we'll assume there's a face in the center of the image
    // In a real implementation, you would use more sophisticated algorithms

    // Calculate face size based on image dimensions
    final faceWidth = image.width * 0.6; // 60% of image width
    final faceHeight = image.height * 0.6; // 60% of image height

    // Calculate face position (centered)
    final faceX = (image.width - faceWidth) / 2;
    final faceY = (image.height - faceHeight) / 2;

    // Create a bounding box for the face
    final boundingBox = Rect.fromLTWH(faceX, faceY, faceWidth, faceHeight);

    // Generate a random tracking ID
    final trackingId = Random().nextInt(1000);

    // Create a face object
    final face = Face(
      boundingBox: boundingBox,
      trackingId: trackingId,
      // Add default values for other properties
      headEulerAngleY: 0.0,
      headEulerAngleZ: 0.0,
      leftEyeOpenProbability: 1.0,
      rightEyeOpenProbability: 1.0,
      smilingProbability: 0.5,
    );

    return [face];
  }

  /// Process a camera image for real-time face detection
  Future<List<Face>> processImage(
      CameraImage cameraImage, CameraDescription camera) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Convert CameraImage to regular image
      final image = _convertCameraImageToImage(cameraImage, camera);

      if (image == null) {
        return [];
      }

      // Detect faces using a simple algorithm
      final faces = _detectFacesInImage(image);

      // Emit the faces
      _facesStreamController.add(faces);

      return faces;
    } catch (e) {
      debugPrint('Error processing camera image: $e');
      return [];
    }
  }

  /// Convert CameraImage to regular Image
  img.Image? _convertCameraImageToImage(
      CameraImage cameraImage, CameraDescription camera) {
    try {
      // Handle YUV_420_888 format (most common)
      if (cameraImage.format.group == ImageFormatGroup.yuv420) {
        return _convertYUV420ToImage(cameraImage, camera);
      }
      // Handle other formats if needed
      else {
        debugPrint('Unsupported image format: ${cameraImage.format.group}');
        return null;
      }
    } catch (e) {
      debugPrint('Error converting camera image: $e');
      return null;
    }
  }

  /// Convert YUV_420_888 format to Image
  img.Image _convertYUV420ToImage(
      CameraImage cameraImage, CameraDescription camera) {
    final width = cameraImage.width;
    final height = cameraImage.height;

    // Create image buffer
    final image = img.Image(width: width, height: height);

    // Convert YUV to RGB
    final yBuffer = cameraImage.planes[0].bytes;
    final uBuffer = cameraImage.planes[1].bytes;
    final vBuffer = cameraImage.planes[2].bytes;

    final yRowStride = cameraImage.planes[0].bytesPerRow;
    final uvRowStride = cameraImage.planes[1].bytesPerRow;
    final uvPixelStride = cameraImage.planes[1].bytesPerPixel!;

    for (int h = 0; h < height; h++) {
      for (int w = 0; w < width; w++) {
        final yIndex = h * yRowStride + w;
        final uvIndex = (h ~/ 2) * uvRowStride + (w ~/ 2) * uvPixelStride;

        final y = yBuffer[yIndex];
        final u = uBuffer[uvIndex];
        final v = vBuffer[uvIndex];

        // Convert YUV to RGB
        int r = (y + 1.402 * (v - 128)).round();
        int g = (y - 0.344136 * (u - 128) - 0.714136 * (v - 128)).round();
        int b = (y + 1.772 * (u - 128)).round();

        // Clamp RGB values
        r = r.clamp(0, 255);
        g = g.clamp(0, 255);
        b = b.clamp(0, 255);

        // Set pixel color
        image.setPixelRgba(w, h, r, g, b, 255);
      }
    }

    // Rotate image based on camera orientation
    if (camera.lensDirection == CameraLensDirection.front) {
      return img.flipHorizontal(image);
    } else {
      return image;
    }
  }

  /// Compare two face images and return a similarity score
  Future<Map<String, dynamic>> compareFaces(
      File face1File, File face2File) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Read the images
      final bytes1 = await face1File.readAsBytes();
      final bytes2 = await face2File.readAsBytes();

      final image1 = img.decodeImage(bytes1);
      final image2 = img.decodeImage(bytes2);

      if (image1 == null || image2 == null) {
        return {
          'similarity': 0.0,
          'distance': 1.0,
          'match': false,
          'error': 'Failed to decode one or both images',
        };
      }

      // Detect faces in both images
      final faces1 = _detectFacesInImage(image1);
      final faces2 = _detectFacesInImage(image2);

      if (faces1.isEmpty || faces2.isEmpty) {
        return {
          'similarity': 0.0,
          'distance': 1.0,
          'match': false,
          'error': 'No faces detected in one or both images',
        };
      }

      // Get the first face from each image
      final face1 = faces1.first;
      final face2 = faces2.first;

      // Extract face features for comparison
      final features1 = _extractFaceFeatures(image1, face1);
      final features2 = _extractFaceFeatures(image2, face2);

      // Compare features
      final similarity = _calculateSimilarity(features1, features2);
      final distance = 1.0 - similarity;
      final match = similarity >= 0.75; // Threshold for face matching

      return {
        'similarity': similarity,
        'distance': distance,
        'match': match,
        'metrics': {
          'similarity': similarity,
          'distance': distance,
        }
      };
    } catch (e) {
      debugPrint('Error comparing faces: $e');
      return {
        'similarity': 0.0,
        'distance': 1.0,
        'match': false,
        'error': e.toString(),
      };
    }
  }

  /// Extract features from a face for comparison
  Map<String, dynamic> _extractFaceFeatures(img.Image image, Face face) {
    // Extract the face region from the image
    final boundingBox = face.boundingBox;
    // Create a cropped version of the image
    final faceImage = img.copyResize(
      image,
      width: boundingBox.width.toInt(),
      height: boundingBox.height.toInt(),
    );

    // Calculate basic features
    final aspectRatio = boundingBox.width / boundingBox.height;

    // Calculate average color in different regions
    final topHalf = _calculateAverageColor(
        faceImage, 0, 0, faceImage.width, faceImage.height ~/ 2);
    final bottomHalf = _calculateAverageColor(faceImage, 0,
        faceImage.height ~/ 2, faceImage.width, faceImage.height ~/ 2);
    final leftHalf = _calculateAverageColor(
        faceImage, 0, 0, faceImage.width ~/ 2, faceImage.height);
    final rightHalf = _calculateAverageColor(faceImage, faceImage.width ~/ 2, 0,
        faceImage.width ~/ 2, faceImage.height);

    return {
      'boundingBox': {
        'width': boundingBox.width,
        'height': boundingBox.height,
        'aspectRatio': aspectRatio,
      },
      'colorFeatures': {
        'topHalf': topHalf,
        'bottomHalf': bottomHalf,
        'leftHalf': leftHalf,
        'rightHalf': rightHalf,
      },
      'trackingId': face.trackingId,
    };
  }

  /// Calculate average color in a region of an image
  Map<String, int> _calculateAverageColor(
      img.Image image, int x, int y, int width, int height) {
    double totalR = 0, totalG = 0, totalB = 0;
    final pixelCount = width * height;

    for (int j = y; j < y + height; j++) {
      for (int i = x; i < x + width; i++) {
        if (i < image.width && j < image.height) {
          // Get pixel color
          final pixel = image.getPixel(i, j);
          // The image package returns a Pixel object, extract RGB values
          final r = pixel.r.toDouble();
          final g = pixel.g.toDouble();
          final b = pixel.b.toDouble();

          totalR += r;
          totalG += g;
          totalB += b;
        }
      }
    }

    return {
      'r': (totalR / pixelCount).round(),
      'g': (totalG / pixelCount).round(),
      'b': (totalB / pixelCount).round(),
    };
  }

  /// Calculate similarity between two sets of face features
  double _calculateSimilarity(
      Map<String, dynamic> features1, Map<String, dynamic> features2) {
    // Compare aspect ratios
    final aspectRatio1 = features1['boundingBox']['aspectRatio'];
    final aspectRatio2 = features2['boundingBox']['aspectRatio'];
    final aspectRatioDiff = (aspectRatio1 - aspectRatio2).abs();
    final aspectRatioSimilarity = 1.0 - (aspectRatioDiff / 1.0).clamp(0.0, 1.0);

    // Compare color features
    final colorSimilarity = _calculateColorSimilarity(
      features1['colorFeatures'],
      features2['colorFeatures'],
    );

    // Weighted combination of similarities
    return 0.3 * aspectRatioSimilarity + 0.7 * colorSimilarity;
  }

  /// Calculate similarity between color features
  double _calculateColorSimilarity(
      Map<String, dynamic> colors1, Map<String, dynamic> colors2) {
    double totalSimilarity = 0.0;
    final regions = ['topHalf', 'bottomHalf', 'leftHalf', 'rightHalf'];

    for (final region in regions) {
      final color1 = colors1[region];
      final color2 = colors2[region];

      // Calculate Euclidean distance between colors
      final rDiff = (color1['r'] - color2['r']).abs();
      final gDiff = (color1['g'] - color2['g']).abs();
      final bDiff = (color1['b'] - color2['b']).abs();

      final distance = sqrt(rDiff * rDiff + gDiff * gDiff + bDiff * bDiff);
      final maxDistance = sqrt(3 * 255 * 255); // Maximum possible distance

      // Convert distance to similarity (0-1)
      final similarity = 1.0 - (distance / maxDistance);
      totalSimilarity += similarity;
    }

    return totalSimilarity / regions.length;
  }

  /// Dispose of resources
  void dispose() {
    _facesStreamController.close();
  }
}
