import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
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
        if (comparisonResult == null) {
          comparisonResult = await _compareFacesLocally(
            faceImage, 
            photoFile,
          );
        }
        
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
      final normalizedFace = img.copyResize(faceImg, width: 128, height: 128);
      final normalizedPhoto = img.copyResize(photoImg, width: 128, height: 128);
      
      // Extract features from different regions of the face
      final Map<String, double> featureScores = {
        'overall': _compareHistograms(normalizedFace, normalizedPhoto),
        'eyes': _compareRegion(normalizedFace, normalizedPhoto, 0.2, 0.2, 0.6, 0.3),
        'nose': _compareRegion(normalizedFace, normalizedPhoto, 0.3, 0.3, 0.4, 0.3),
        'mouth': _compareRegion(normalizedFace, normalizedPhoto, 0.25, 0.6, 0.5, 0.3),
        'face_shape': _compareEdges(normalizedFace, normalizedPhoto),
      };
      
      // Calculate weighted confidence
      final confidence = _calculateWeightedConfidence(featureScores);
      
      return {
        'similarity': featureScores['overall']!,
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
  
  /// Compare histograms of two images
  double _compareHistograms(img.Image image1, img.Image image2) {
    // Convert to grayscale
    final gray1 = img.grayscale(image1);
    final gray2 = img.grayscale(image2);
    
    // Calculate histograms
    final hist1 = List<int>.filled(256, 0);
    final hist2 = List<int>.filled(256, 0);
    
    // Fill histograms
    for (int i = 0; i < gray1.length; i++) {
      hist1[gray1[i]]++;
      hist2[gray2[i]]++;
    }
    
    // Normalize histograms
    final norm1 = List<double>.filled(256, 0.0);
    final norm2 = List<double>.filled(256, 0.0);
    
    for (int i = 0; i < 256; i++) {
      norm1[i] = hist1[i] / gray1.length;
      norm2[i] = hist2[i] / gray2.length;
    }
    
    // Calculate correlation
    double correlation = 0.0;
    double sum1 = 0.0, sum2 = 0.0, sum12 = 0.0;
    
    for (int i = 0; i < 256; i++) {
      sum1 += norm1[i] * norm1[i];
      sum2 += norm2[i] * norm2[i];
      sum12 += norm1[i] * norm2[i];
    }
    
    if (sum1 > 0 && sum2 > 0) {
      correlation = sum12 / (sqrt(sum1) * sqrt(sum2));
    }
    
    return correlation;
  }
  
  /// Compare a specific region of two images
  double _compareRegion(img.Image image1, img.Image image2, 
      double x, double y, double width, double height) {
    // Calculate region boundaries
    final x1 = (x * image1.width).round();
    final y1 = (y * image1.height).round();
    final w = (width * image1.width).round();
    final h = (height * image1.height).round();
    
    // Extract regions
    final region1 = img.copyCrop(image1, x: x1, y: y1, width: w, height: h);
    final region2 = img.copyCrop(image2, x: x1, y: y1, width: w, height: h);
    
    // Compare histograms of the regions
    return _compareHistograms(region1, region2);
  }
  
  /// Compare edges of two images (for face shape comparison)
  double _compareEdges(img.Image image1, img.Image image2) {
    // Convert to grayscale
    final gray1 = img.grayscale(image1);
    final gray2 = img.grayscale(image2);
    
    // Simple edge detection (difference between adjacent pixels)
    final edges1 = List<int>.filled(gray1.length, 0);
    final edges2 = List<int>.filled(gray2.length, 0);
    
    for (int y = 1; y < image1.height; y++) {
      for (int x = 1; x < image1.width; x++) {
        final i = y * image1.width + x;
        final i_left = i - 1;
        final i_up = i - image1.width;
        
        // Horizontal and vertical differences
        final dx1 = (gray1[i] - gray1[i_left]).abs();
        final dy1 = (gray1[i] - gray1[i_up]).abs();
        final dx2 = (gray2[i] - gray2[i_left]).abs();
        final dy2 = (gray2[i] - gray2[i_up]).abs();
        
        // Store the maximum gradient
        edges1[i] = max(dx1, dy1);
        edges2[i] = max(dx2, dy2);
      }
    }
    
    // Compare edge histograms
    final edgeHist1 = List<int>.filled(256, 0);
    final edgeHist2 = List<int>.filled(256, 0);
    
    for (int i = 0; i < edges1.length; i++) {
      edgeHist1[edges1[i]]++;
      edgeHist2[edges2[i]]++;
    }
    
    // Calculate correlation
    double correlation = 0.0;
    double sum1 = 0.0, sum2 = 0.0, sum12 = 0.0;
    
    for (int i = 0; i < 256; i++) {
      final n1 = edgeHist1[i] / edges1.length;
      final n2 = edgeHist2[i] / edges2.length;
      
      sum1 += n1 * n1;
      sum2 += n2 * n2;
      sum12 += n1 * n2;
    }
    
    if (sum1 > 0 && sum2 > 0) {
      correlation = sum12 / (sqrt(sum1) * sqrt(sum2));
    }
    
    return correlation;
  }
}
