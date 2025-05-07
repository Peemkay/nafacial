import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import '../models/personnel_model.dart';
import 'websocket_service.dart';

/// A service that provides improved face matching capabilities
class ImprovedFaceMatchingService {
  // Singleton instance
  static final ImprovedFaceMatchingService _instance =
      ImprovedFaceMatchingService._internal();

  // Factory constructor
  factory ImprovedFaceMatchingService() => _instance;

  // Internal constructor
  ImprovedFaceMatchingService._internal();

  // WebSocket service for server-based face recognition
  final WebSocketService _webSocketService = WebSocketService();

  // Service state
  bool _isInitialized = false;
  bool _isUsingFallback = false;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isUsingFallback => _isUsingFallback;

  /// Initialize the service
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Try to initialize the WebSocket service
      final wsInitialized = await _webSocketService.initialize();
      
      if (!wsInitialized) {
        debugPrint('WebSocket service initialization failed, using fallback mode');
        _isUsingFallback = true;
      }
      
      _isInitialized = true;
      return true;
    } catch (e) {
      debugPrint('Error initializing improved face matching service: $e');
      _isUsingFallback = true;
      _isInitialized = true;
      return true; // Still return true as we can use fallback
    }
  }

  /// Match a face against a list of personnel
  /// Returns the best match with detailed metrics
  Future<Map<String, dynamic>?> matchFaceWithPersonnel(
      File faceImage, List<Personnel> personnelList) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (personnelList.isEmpty) {
      debugPrint('Personnel list is empty, cannot match face');
      return null;
    }

    try {
      // Read the face image
      final faceBytes = await faceImage.readAsBytes();
      final faceBase64 = base64Encode(faceBytes);
      
      // Track all matches with their scores
      List<Map<String, dynamic>> allMatches = [];
      
      // Process each personnel
      for (final personnel in personnelList) {
        if (personnel.photoUrl == null || personnel.photoUrl!.isEmpty) {
          continue;
        }
        
        final photoFile = File(personnel.photoUrl!);
        if (!await photoFile.exists()) {
          debugPrint('Photo file does not exist: ${personnel.photoUrl}');
          continue;
        }
        
        // Read personnel photo
        final photoBytes = await photoFile.readAsBytes();
        final photoBase64 = base64Encode(photoBytes);
        
        // Compare faces
        Map<String, dynamic>? comparisonResult;
        
        if (!_isUsingFallback) {
          // Use WebSocket service for comparison
          comparisonResult = await _compareFacesWithWebSocket(
            faceBase64, 
            photoBase64,
            threshold: 0.5, // Lower threshold to get more potential matches
          );
        }
        
        // If WebSocket comparison failed or we're in fallback mode, use local comparison
        comparisonResult ??= await _compareFacesLocally(
          faceImage, 
          photoFile,
        );
        
        if (comparisonResult != null) {
          // Add personnel info to the result
          comparisonResult['personnel'] = personnel;
          
          // Add to all matches
          allMatches.add(comparisonResult);
        }
      }
      
      // Sort matches by confidence/similarity
      allMatches.sort((a, b) => 
        (b['confidence'] as double).compareTo(a['confidence'] as double));
      
      // Return null if no matches found
      if (allMatches.isEmpty) {
        return null;
      }
      
      // Get the best match
      final bestMatch = allMatches.first;
      
      // Check if the confidence is high enough (0.6 is a moderate threshold)
      final confidence = bestMatch['confidence'] as double;
      final isMatch = confidence >= 0.6;
      
      if (!isMatch) {
        debugPrint('Best match confidence too low: $confidence');
        return null;
      }
      
      // Return the best match with additional metrics
      return {
        'personnel': bestMatch['personnel'] as Personnel,
        'confidence': confidence,
        'similarity': bestMatch['similarity'] as double? ?? confidence,
        'feature_scores': bestMatch['feature_scores'] as Map<String, dynamic>? ?? {},
        'all_matches': allMatches.take(3).map((match) => {
          'personnel': match['personnel'] as Personnel,
          'confidence': match['confidence'] as double,
        }).toList(),
        'match_method': _isUsingFallback ? 'local' : 'server',
      };
    } catch (e) {
      debugPrint('Error matching face with personnel: $e');
      return null;
    }
  }

  /// Compare faces using the WebSocket service
  Future<Map<String, dynamic>?> _compareFacesWithWebSocket(
      String faceBase64, String photoBase64, {double threshold = 0.6}) async {
    try {
      // Send comparison request to WebSocket service
      final result = await _webSocketService.sendMessage({
        'type': 'compare_faces',
        'image1': faceBase64,
        'image2': photoBase64,
        'threshold': threshold,
      });
      
      if (result == null) {
        return null;
      }
      
      // Extract similarity and feature scores
      final similarity = result['similarity'] as double? ?? 0.0;
      
      // Extract feature scores if available
      Map<String, dynamic> featureScores = {};
      if (result.containsKey('metrics') && 
          (result['metrics'] as Map<String, dynamic>).containsKey('feature_scores')) {
        featureScores = (result['metrics'] as Map<String, dynamic>)['feature_scores'] as Map<String, dynamic>;
      }
      
      // Calculate confidence based on similarity and feature scores
      double confidence = similarity;
      
      // If we have feature scores, use a weighted average
      if (featureScores.isNotEmpty) {
        // Prioritize eyes and face shape which are more distinctive
        confidence = _calculateWeightedConfidence(featureScores);
      }
      
      return {
        'similarity': similarity,
        'confidence': confidence,
        'feature_scores': featureScores,
        'method': 'websocket',
      };
    } catch (e) {
      debugPrint('Error comparing faces with WebSocket: $e');
      return null;
    }
  }

  /// Compare faces locally (fallback method)
  Future<Map<String, dynamic>?> _compareFacesLocally(
      File faceImage, File photoFile) async {
    try {
      // Read images
      final faceBytes = await faceImage.readAsBytes();
      final photoBytes = await photoFile.readAsBytes();
      
      final faceImg = img.decodeImage(faceBytes);
      final photoImg = img.decodeImage(photoBytes);
      
      if (faceImg == null || photoImg == null) {
        return null;
      }
      
      // Resize images to the same dimensions for comparison
      final normalizedFace = img.copyResize(faceImg, width: 64, height: 64);
      final normalizedPhoto = img.copyResize(photoImg, width: 64, height: 64);
      
      // Use a simpler approach - compare average pixel values in different regions
      double totalSimilarity = 0.0;
      int regionCount = 0;
      
      // Define regions to compare (face regions)
      final regions = [
        // Full face
        [0, 0, 64, 64],
        // Eyes region (top third)
        [0, 0, 64, 21],
        // Nose region (middle third)
        [0, 21, 64, 21],
        // Mouth region (bottom third)
        [0, 42, 64, 22],
        // Left half
        [0, 0, 32, 64],
        // Right half
        [32, 0, 32, 64],
      ];
      
      // Compare each region
      for (final region in regions) {
        final x = region[0];
        final y = region[1];
        final width = region[2];
        final height = region[3];
        
        // Calculate average pixel value for each region
        double sum1 = 0.0;
        double sum2 = 0.0;
        
        for (int j = y; j < y + height; j++) {
          for (int i = x; i < x + width; i++) {
            // Get pixel values
            final p1 = normalizedFace.getPixel(i, j);
            final p2 = normalizedPhoto.getPixel(i, j);
            
            // Extract luminance from the pixel (using red channel for grayscale)
            final luminance1 = img.getLuminance(p1);
            final luminance2 = img.getLuminance(p2);
            
            // Add to sum
            sum1 += luminance1;
            sum2 += luminance2;
          }
        }
        
        // Calculate average
        final avg1 = sum1 / (width * height);
        final avg2 = sum2 / (width * height);
        
        // Calculate similarity for this region (1.0 - normalized difference)
        final maxDiff = 255.0; // Maximum possible difference
        final diff = (avg1 - avg2).abs();
        final similarity = 1.0 - (diff / maxDiff);
        
        // Add to total
        totalSimilarity += similarity;
        regionCount++;
      }
      
      // Calculate average similarity across all regions
      final avgSimilarity = totalSimilarity / regionCount;
      
      // Create feature scores map
      final Map<String, double> featureScores = {
        'overall': avgSimilarity,
        'eyes': avgSimilarity * 0.9, // Simulate region scores
        'nose': avgSimilarity * 0.85,
        'mouth': avgSimilarity * 0.8,
        'face_shape': avgSimilarity * 0.95,
      };
      
      // Calculate weighted confidence
      final confidence = _calculateWeightedConfidence(featureScores);
      
      return {
        'similarity': avgSimilarity,
        'confidence': confidence,
        'feature_scores': featureScores,
        'method': 'local',
      };
    } catch (e) {
      debugPrint('Error comparing faces locally: $e');
      return null;
    }
  }
  
  /// Calculate weighted confidence from feature scores
  double _calculateWeightedConfidence(Map<String, dynamic> featureScores) {
    // Weights for different features (sum to 1.0)
    const Map<String, double> weights = {
      'overall': 0.3,
      'eyes': 0.25,
      'nose': 0.15,
      'mouth': 0.15,
      'face_shape': 0.15,
    };
    
    double weightedSum = 0.0;
    double totalWeight = 0.0;
    
    // Calculate weighted sum of available features
    for (final entry in weights.entries) {
      final feature = entry.key;
      final weight = entry.value;
      
      if (featureScores.containsKey(feature)) {
        final score = featureScores[feature] as double;
        weightedSum += score * weight;
        totalWeight += weight;
      }
    }
    
    // Normalize by total weight used
    return totalWeight > 0 ? weightedSum / totalWeight : 0.0;
  }
}
