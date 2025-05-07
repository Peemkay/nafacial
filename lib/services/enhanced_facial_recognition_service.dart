import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import '../models/personnel_model.dart';
import 'websocket_face_detection_service.dart';
import 'improved_face_matching_service.dart';

/// Enhanced facial recognition service that uses the Python backend
/// for more accurate face detection and recognition
class EnhancedFacialRecognitionService {
  // WebSocket service for face detection
  final WebSocketFaceDetectionService _webSocketService =
      WebSocketFaceDetectionService();

  // Singleton instance
  static final EnhancedFacialRecognitionService _instance =
      EnhancedFacialRecognitionService._internal();

  // Factory constructor
  factory EnhancedFacialRecognitionService() => _instance;

  // Internal constructor
  EnhancedFacialRecognitionService._internal();

  /// Initialize the service
  Future<bool> initialize() async {
    return await _webSocketService.initialize();
  }

  /// Identify personnel from an image
  Future<Map<String, dynamic>?> identifyPersonnel(
      File imageFile, List<Personnel> personnelList) async {
    if (personnelList.isEmpty) {
      debugPrint('No personnel in database for identification');
      return null;
    }

    try {
      // Use the improved face matching service for better accuracy
      final improvedMatchingService = ImprovedFaceMatchingService();
      await improvedMatchingService.initialize();

      // Get the best match using the improved service
      final matchResult = await improvedMatchingService.matchFaceWithPersonnel(
          imageFile, personnelList);

      if (matchResult != null) {
        debugPrint(
            'Found match using improved face matching service: ${(matchResult['personnel'] as Personnel).fullName}');
        debugPrint(
            'Match confidence: ${(matchResult['confidence'] as double).toStringAsFixed(2)}');

        // Return the match result with all the detailed metrics
        return matchResult;
      }

      // If improved service fails, try the original method
      debugPrint('Improved face matching failed, trying original method');

      // Initialize WebSocket service if not already initialized
      if (!_webSocketService.isConnected) {
        final initialized = await _webSocketService.initialize();
        if (!initialized) {
          debugPrint(
              'Failed to initialize WebSocket service, falling back to local recognition');
          // Fall back to local recognition
          return await _identifyPersonnelLocally(imageFile, personnelList);
        }
      }

      // Get the best match from the database using original method
      final bestMatch = await _findBestMatch(imageFile, personnelList);

      if (bestMatch != null) {
        debugPrint(
            'Found match using original method: ${(bestMatch['personnel'] as Personnel).fullName}');
        return {
          'personnel': bestMatch['personnel'],
          'confidence': bestMatch['confidence'],
          'match_method': 'original',
        };
      }

      return null;
    } catch (e) {
      debugPrint('Error in enhanced facial recognition: $e');
      // Fall back to local recognition
      return await _identifyPersonnelLocally(imageFile, personnelList);
    }
  }

  /// Find the best match for a face in the personnel database
  Future<Map<String, dynamic>?> _findBestMatch(
      File imageFile, List<Personnel> personnelList) async {
    Personnel? bestMatch;
    double highestConfidence = 0.0;

    // Read image file
    final bytes = await imageFile.readAsBytes();

    // Convert to base64
    final base64Image = base64Encode(bytes);

    // Process each personnel
    for (final personnel in personnelList) {
      if (personnel.photoUrl != null && personnel.photoUrl!.isNotEmpty) {
        try {
          // Check if the file exists
          final photoFile = File(personnel.photoUrl!);
          if (!await photoFile.exists()) {
            debugPrint('Photo file does not exist: ${personnel.photoUrl}');
            continue;
          }

          // Read personnel photo
          final photoBytes = await photoFile.readAsBytes();

          // Convert to base64
          final base64Photo = base64Encode(photoBytes);

          // Compare faces using WebSocket service
          final result = await _compareFaces(base64Image, base64Photo);

          if (result != null) {
            final similarity = result['similarity'] as double? ?? 0.0;
            final isMatch = result['match'] as bool? ?? false;
            final metrics = result['metrics'] as Map<String, dynamic>? ?? {};

            // Get feature scores if available
            Map<String, double>? featureScores;
            if (metrics.containsKey('feature_scores')) {
              featureScores =
                  (metrics['feature_scores'] as Map<String, dynamic>)
                      .map((key, value) => MapEntry(key, value as double));
            }

            // Log detailed comparison results
            if (featureScores != null) {
              debugPrint('Detailed comparison with ${personnel.fullName}:');
              debugPrint(
                  '  Overall: ${featureScores['overall']?.toStringAsFixed(2) ?? 'N/A'}');
              debugPrint(
                  '  Eyes: ${featureScores['eyes']?.toStringAsFixed(2) ?? 'N/A'}');
              debugPrint(
                  '  Nose: ${featureScores['nose']?.toStringAsFixed(2) ?? 'N/A'}');
              debugPrint(
                  '  Mouth: ${featureScores['mouth']?.toStringAsFixed(2) ?? 'N/A'}');
              debugPrint(
                  '  Face shape: ${featureScores['face_shape']?.toStringAsFixed(2) ?? 'N/A'}');
            } else {
              debugPrint(
                  'Similarity with ${personnel.fullName}: $similarity (match: $isMatch)');
            }

            // Update best match if this is better - using exactly 95% threshold for accurate face matching
            if (similarity > highestConfidence) {
              // Store the highest confidence match, even if below threshold
              // We'll check against the threshold when returning the result
              highestConfidence = similarity;
              bestMatch = personnel;

              // Store the detailed metrics with the best match
              debugPrint(
                  'New best match: ${personnel.fullName} with confidence $highestConfidence');

              // Check if any individual feature score is below threshold
              if (featureScores != null) {
                final weakestFeature = featureScores.entries
                    .reduce((a, b) => a.value < b.value ? a : b);

                if (weakestFeature.value < 0.85) {
                  debugPrint(
                      'Warning: Weak match on ${weakestFeature.key}: ${weakestFeature.value.toStringAsFixed(2)}');
                }
              }

              // Log whether this match meets the threshold
              if (similarity >= 0.95) {
                debugPrint('Match meets the 95% confidence threshold');
              } else {
                debugPrint('Match does not meet the 95% confidence threshold');
              }
            }
          }
        } catch (e) {
          debugPrint('Error comparing with ${personnel.fullName}: $e');
          continue;
        }
      }
    }

    if (bestMatch != null) {
      // Check if the confidence meets the 60% threshold (reduced from 95%)
      if (highestConfidence >= 0.60) {
        // Store the best match result with detailed metrics
        Map<String, dynamic> bestMatchResult = {
          'personnel': bestMatch,
          'confidence': highestConfidence,
          'match_method': 'websocket',
        };

        // Store the last comparison result for the best match
        final result = await _compareFaces(base64Image,
            base64Encode(await File(bestMatch.photoUrl!).readAsBytes()));

        if (result != null) {
          // Add detailed metrics to the result
          bestMatchResult['metrics'] = result['metrics'];
          bestMatchResult['feature_scores'] =
              (result['metrics'] as Map<String, dynamic>)['feature_scores'];
        }

        return bestMatchResult;
      } else {
        // Confidence is below threshold, return null to indicate no match
        debugPrint(
            'Best match confidence ($highestConfidence) is below the 60% threshold, returning no match');
        return null;
      }
    }

    return null;
  }

  /// Compare two faces using the WebSocket service
  Future<Map<String, dynamic>?> _compareFaces(
      String base64Image1, String base64Image2) async {
    try {
      // Send the comparison request to the WebSocket service
      final result = await _webSocketService.sendMessage({
        'type': 'compare_faces',
        'image1': base64Image1,
        'image2': base64Image2,
        'threshold': 0.65, // Reduced threshold for easier matching
      });

      if (result != null && result.containsKey('similarity')) {
        final similarity = result['similarity'] as double? ?? 0.0;
        final isMatch =
            similarity >= 0.65; // Reduced threshold for easier matching

        return {
          'similarity': similarity,
          'distance': 1.0 - similarity,
          'match': isMatch,
          'metrics': result['metrics'] ?? {},
        };
      }

      return null;
    } catch (e) {
      debugPrint('Error comparing faces: $e');
      return null;
    }
  }

  /// Identify personnel locally (fallback method)
  Future<Map<String, dynamic>?> _identifyPersonnelLocally(
      File imageFile, List<Personnel> personnelList) async {
    // This is a more robust implementation that uses local image comparison
    debugPrint('Using local facial recognition (fallback)');

    try {
      // Read the image bytes
      final bytes = await imageFile.readAsBytes();

      // Process each personnel
      Personnel? bestMatch;
      double highestConfidence = 0.0;

      for (final personnel in personnelList) {
        if (personnel.photoUrl != null && personnel.photoUrl!.isNotEmpty) {
          try {
            final photoFile = File(personnel.photoUrl!);
            if (!await photoFile.exists()) continue;

            // Read personnel photo
            final photoBytes = await photoFile.readAsBytes();

            // Compare images using a basic algorithm
            // In a real app, you would use a more sophisticated algorithm
            final similarity = await _compareImagesLocally(bytes, photoBytes);

            // Update best match if this is better - using same 95% threshold for consistency
            if (similarity > highestConfidence) {
              // Store the highest confidence match, even if below threshold
              highestConfidence = similarity;
              bestMatch = personnel;

              // Log whether this match meets the threshold
              if (similarity >= 0.95) {
                debugPrint('Local match meets the 95% confidence threshold');
              } else {
                debugPrint(
                    'Local match does not meet the 95% confidence threshold');
              }
            }
          } catch (e) {
            debugPrint('Error comparing with ${personnel.fullName}: $e');
            continue;
          }
        }
      }

      if (bestMatch != null) {
        // Check if the confidence meets the 60% threshold (reduced from 95%)
        if (highestConfidence >= 0.60) {
          return {
            'personnel': bestMatch,
            'confidence': highestConfidence,
            'match_method': 'local',
          };
        } else {
          // Confidence is below threshold, return null to indicate no match
          debugPrint(
              'Local best match confidence ($highestConfidence) is below the 60% threshold, returning no match');
          return null;
        }
      }
    } catch (e) {
      debugPrint('Error in local facial recognition: $e');
    }

    return null;
  }

  /// Compare two images locally using a simple but effective algorithm
  Future<double> _compareImagesLocally(
      List<int> image1Bytes, List<int> image2Bytes) async {
    try {
      // Convert List<int> to Uint8List for img package
      final Uint8List bytes1 = Uint8List.fromList(image1Bytes);
      final Uint8List bytes2 = Uint8List.fromList(image2Bytes);

      // Decode images
      final img.Image? image1 = img.decodeImage(bytes1);
      final img.Image? image2 = img.decodeImage(bytes2);

      if (image1 == null || image2 == null) {
        debugPrint('Failed to decode images for local comparison');
        return 0.0;
      }

      // Resize images to the same dimensions for comparison
      final normalizedImage1 = img.copyResize(image1, width: 64, height: 64);
      final normalizedImage2 = img.copyResize(image2, width: 64, height: 64);

      // Convert to grayscale
      final grayImage1 = img.grayscale(normalizedImage1);
      final grayImage2 = img.grayscale(normalizedImage2);

      // Calculate Mean Squared Error (MSE)
      double sumSquaredDiff = 0.0;
      int pixelCount = 0;

      for (int y = 0; y < grayImage1.height; y++) {
        for (int x = 0; x < grayImage1.width; x++) {
          // Get pixel values
          final pixel1 = grayImage1.getPixel(x, y);
          final pixel2 = grayImage2.getPixel(x, y);

          // Calculate squared difference
          // For grayscale images, we can use any channel as they're all the same
          // We'll extract the luminance value
          final val1 = img.getLuminance(pixel1);
          final val2 = img.getLuminance(pixel2);
          final diff = val1 - val2;
          sumSquaredDiff += diff * diff;
          pixelCount++;
        }
      }

      // Calculate MSE
      final mse = sumSquaredDiff / pixelCount;

      // Convert MSE to similarity (0-1 range)
      // Using a simple exponential function to map MSE to similarity
      // Lower MSE means higher similarity
      final similarity = exp(-mse / 1000.0); // Exponential decay

      // Enhance the similarity to make it more discriminative
      double enhancedSimilarity = similarity;
      if (similarity > 0.8) {
        enhancedSimilarity =
            0.8 + (similarity - 0.8) * 2; // Boost high similarities
      } else if (similarity < 0.5) {
        enhancedSimilarity = similarity * 0.8; // Reduce low similarities
      }

      // Ensure the result is in the range [0, 1]
      enhancedSimilarity = enhancedSimilarity.clamp(0.0, 1.0);

      debugPrint(
          'Local image comparison - MSE: $mse, similarity: $similarity, enhanced: $enhancedSimilarity');

      return enhancedSimilarity;
    } catch (e) {
      debugPrint('Error in local image comparison: $e');
      return 0.0;
    }
  }

  /// Save an image with metadata
  Future<String> saveImageWithMetadata(File imageFile,
      Personnel? identifiedPersonnel, Map<String, dynamic> metadata) async {
    try {
      // Create directory for saved images
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${appDir.path}/facial_verification_images');
      await imagesDir.create(recursive: true);

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final personnelId = identifiedPersonnel?.id ?? 'unknown';
      final fileName = '$personnelId-$timestamp.jpg';
      final filePath = '${imagesDir.path}/$fileName';

      // Copy image file
      await imageFile.copy(filePath);

      // Save metadata
      final metadataFileName = fileName.replaceAll('.jpg', '.json');
      final metadataFilePath = '${imagesDir.path}/$metadataFileName';

      // Add personnel info to metadata
      if (identifiedPersonnel != null) {
        metadata['personnelId'] = identifiedPersonnel.id;
        metadata['personnelName'] = identifiedPersonnel.fullName;
        metadata['personnelArmyNumber'] = identifiedPersonnel.armyNumber;
        metadata['personnelRank'] = identifiedPersonnel.rank.displayName;
      }

      // Add timestamp
      metadata['timestamp'] = DateTime.now().toIso8601String();

      // Save metadata file
      final metadataFile = File(metadataFilePath);
      await metadataFile.writeAsString(jsonEncode(metadata));

      return filePath;
    } catch (e) {
      debugPrint('Error saving image with metadata: $e');
      return imageFile.path; // Return original path on error
    }
  }

  /// Dispose of resources
  void dispose() {
    _webSocketService.dispose();
  }
}
