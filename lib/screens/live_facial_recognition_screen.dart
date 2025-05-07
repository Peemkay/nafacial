import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/design_system.dart';
import '../models/personnel_model.dart';
import '../models/face_model.dart';
import '../providers/personnel_provider.dart';
import '../services/enhanced_facial_recognition_service.dart';
import '../widgets/platform_aware_widgets.dart';
import '../widgets/advanced_camera_widget.dart';

class LiveFacialRecognitionScreen extends StatefulWidget {
  const LiveFacialRecognitionScreen({Key? key}) : super(key: key);

  @override
  State<LiveFacialRecognitionScreen> createState() =>
      _LiveFacialRecognitionScreenState();
}

class _LiveFacialRecognitionScreenState
    extends State<LiveFacialRecognitionScreen> {
  // State variables
  bool _isProcessing = false;
  double _sensitivity =
      0.6; // Reduced sensitivity for easier matching (0.0 to 1.0)
  bool _showFaceOverlay = true;
  Personnel? _matchedPersonnel;
  double _confidence = 0.0; // Store the confidence level
  Map<String, double>? _featureScores; // Store detailed feature scores
  bool _showDetailedMetrics = false; // Toggle for showing detailed metrics

  @override
  Widget build(BuildContext context) {
    final personnelProvider = Provider.of<PersonnelProvider>(context);

    return PlatformScaffold(
      appBar: AppBar(
        title: const Text('Live Facial Recognition'),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? DesignSystem.darkAppBarColor
            : DesignSystem.lightAppBarColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettingsDialog,
            tooltip: 'Settings',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(DesignSystem.adjustedSpacingSmall),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Camera preview with face detection
              Expanded(
                flex: 3,
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(DesignSystem.borderRadiusMedium),
                  child: AdvancedCameraWidget(
                    enableFaceTracking: true,
                    showFaceTrackingOverlay: _showFaceOverlay,
                    onFacesDetected: (List<Face> faces) {
                      if (!_isProcessing && faces.isNotEmpty) {
                        _onFacesDetected(faces, personnelProvider);
                      }
                    },
                    onPictureTaken: (imageFile) {
                      if (!_isProcessing) {
                        _processImage(File(imageFile.path), personnelProvider);
                      }
                    },
                  ),
                ),
              ),

              SizedBox(height: DesignSystem.adjustedSpacingSmall),

              // Status and controls
              Expanded(
                flex: 2,
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(DesignSystem.borderRadiusMedium),
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding:
                          EdgeInsets.all(DesignSystem.adjustedSpacingSmall),
                      child: _isProcessing
                          ? _buildProcessingView()
                          : _matchedPersonnel != null
                              ? _buildMatchResultView()
                              : _buildInstructionsView(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProcessingView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(),
        SizedBox(height: DesignSystem.adjustedSpacingMedium),
        const Text(
          'Processing facial recognition...',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMatchResultView() {
    // Get confidence from the result
    double confidence = 0.0;
    if (_matchedPersonnel != null) {
      // Get the confidence from the _confidence field
      confidence = _confidence;
    }

    // Determine verification status based on confidence
    bool isConfidentMatch = confidence >= 0.95;
    bool isPossibleMatch = confidence >= 0.85 && confidence < 0.95;
    bool isNoMatch = confidence < 0.85;

    // Determine status color and icon
    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (isConfidentMatch) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      statusText = 'Verified';
    } else if (isPossibleMatch) {
      statusColor = Colors.orange;
      statusIcon = Icons.help;
      statusText = 'Possible Match - Verify Identity';
    } else {
      statusColor = Colors.red;
      statusIcon = Icons.error;
      statusText = 'No Match - Different Person';
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            // Personnel photo or placeholder
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: DesignSystem.primaryColor.withAlpha(25),
                image: _matchedPersonnel!.photoUrl != null
                    ? DecorationImage(
                        image: FileImage(File(_matchedPersonnel!.photoUrl!)),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _matchedPersonnel!.photoUrl == null
                  ? const Icon(
                      Icons.person,
                      size: 30,
                      color: DesignSystem.primaryColor,
                    )
                  : null,
            ),
            SizedBox(width: DesignSystem.adjustedSpacingMedium),

            // Personnel details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_matchedPersonnel!.rank.shortName} ${_matchedPersonnel!.initials}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    _matchedPersonnel!.fullName,
                    style: const TextStyle(
                      color: DesignSystem.textSecondaryColor,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Army Number: ${_matchedPersonnel!.armyNumber}',
                    style: const TextStyle(
                      color: DesignSystem.textSecondaryColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: DesignSystem.adjustedSpacingMedium),

        // Confidence indicator
        Row(
          children: [
            const Text(
              'Confidence:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            SizedBox(width: DesignSystem.adjustedSpacingSmall),
            Expanded(
              child: LinearProgressIndicator(
                value: confidence,
                backgroundColor: Colors.grey.withAlpha(50),
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                borderRadius:
                    BorderRadius.circular(DesignSystem.borderRadiusSmall),
              ),
            ),
            SizedBox(width: DesignSystem.adjustedSpacingSmall),
            Text(
              '${(confidence * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ],
        ),
        SizedBox(height: DesignSystem.adjustedSpacingSmall),

        // Toggle for detailed metrics
        if (_featureScores != null)
          GestureDetector(
            onTap: () {
              setState(() {
                _showDetailedMetrics = !_showDetailedMetrics;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _showDetailedMetrics
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 16,
                  color: DesignSystem.textSecondaryColor,
                ),
                const SizedBox(width: 4),
                Text(
                  _showDetailedMetrics ? 'Hide Details' : 'Show Details',
                  style: const TextStyle(
                    fontSize: 12,
                    color: DesignSystem.textSecondaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

        // Detailed feature scores
        if (_showDetailedMetrics && _featureScores != null)
          Padding(
            padding: EdgeInsets.symmetric(
                vertical: DesignSystem.adjustedSpacingSmall),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Feature Comparison:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                ..._featureScores!.entries.map((entry) {
                  // Skip the overall score as it's already shown
                  if (entry.key == 'overall') return const SizedBox.shrink();

                  // Determine color based on score
                  Color scoreColor;
                  if (entry.value >= 0.95) {
                    scoreColor = Colors.green;
                  } else if (entry.value >= 0.85) {
                    scoreColor = Colors.orange;
                  } else {
                    scoreColor = Colors.red;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 80,
                          child: Text(
                            '${entry.key.split('_').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ')}:',
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                        Expanded(
                          child: LinearProgressIndicator(
                            value: entry.value,
                            backgroundColor: Colors.grey.withAlpha(30),
                            valueColor:
                                AlwaysStoppedAnimation<Color>(scoreColor),
                            borderRadius: BorderRadius.circular(
                                DesignSystem.borderRadiusSmall),
                            minHeight: 6,
                          ),
                        ),
                        SizedBox(width: DesignSystem.adjustedSpacingSmall),
                        Text(
                          '${(entry.value * 100).toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: scoreColor,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        SizedBox(height: DesignSystem.adjustedSpacingSmall),

        // Verification status
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: DesignSystem.adjustedSpacingMedium,
            vertical: DesignSystem.adjustedSpacingSmall,
          ),
          decoration: BoxDecoration(
            color: statusColor.withAlpha(25),
            borderRadius: BorderRadius.circular(DesignSystem.borderRadiusSmall),
            border: Border.all(color: statusColor.withAlpha(50)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                statusIcon,
                color: statusColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        if (isPossibleMatch || isNoMatch)
          Padding(
            padding: EdgeInsets.only(top: DesignSystem.adjustedSpacingSmall),
            child: Text(
              isNoMatch
                  ? 'Confidence too low. This is likely a different person.'
                  : 'Confidence below 95%. Please verify identity manually.',
              style: TextStyle(
                fontSize: 12,
                color: statusColor,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),

        SizedBox(height: DesignSystem.adjustedSpacingMedium),

        // Reset button
        PlatformButton(
          text: 'SCAN AGAIN',
          onPressed: _resetRecognition,
          icon: Icons.refresh,
          isFullWidth: false,
        ),
      ],
    );
  }

  Widget _buildInstructionsView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.face,
          size: 40,
          color: DesignSystem.primaryColor,
        ),
        const SizedBox(height: 8),
        const Text(
          'Position your face in the camera',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        const Text(
          'The system will automatically detect and verify your identity',
          style: TextStyle(
            color: DesignSystem.textSecondaryColor,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lightbulb_outline,
              size: 14,
              color: DesignSystem.warningColor,
            ),
            SizedBox(width: 4),
            Flexible(
              child: Text(
                'Ensure good lighting and a clear view of your face',
                style: TextStyle(
                  color: DesignSystem.warningColor,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withAlpha(25),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withAlpha(75)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tips:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '• Look directly at camera\n• Move closer\n• Ensure good lighting\n• Remove glasses\n• Face forward',
                style: TextStyle(fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Removed unused method

  void _resetRecognition() {
    setState(() {
      _matchedPersonnel = null;
      _confidence = 0.0;
      _featureScores = null;
      _showDetailedMetrics = false;
    });
  }

  /// Process faces detected by the advanced camera
  void _onFacesDetected(List<Face> faces, PersonnelProvider personnelProvider) {
    if (_isProcessing || faces.isEmpty) return;

    // Use the first detected face for recognition
    final face = faces.first;

    // Skip small faces or faces with low confidence
    final boundingBox = face.boundingBox;
    if (boundingBox.width < 100 || boundingBox.height < 100) {
      return;
    }

    // We don't process the face here, just wait for the camera to take a picture
    // when a good face is detected. The picture will be processed in _processImage.
  }

  /// Process an image captured by the camera
  Future<void> _processImage(
      File image, PersonnelProvider personnelProvider) async {
    if (_isProcessing) return;

    // Check if the file exists and is valid
    if (!await image.exists() || await image.length() == 0) {
      debugPrint('Invalid image file: ${image.path}');
      return;
    }

    setState(() {
      _isProcessing = true;
      _matchedPersonnel = null; // Reset previous match
    });

    try {
      // Verify the image file exists and has content first
      if (!await image.exists()) {
        throw Exception('Image file does not exist: ${image.path}');
      }

      final fileSize = await image.length();
      if (fileSize <= 0) {
        throw Exception('Image file is empty (0 bytes): ${image.path}');
      }

      debugPrint('Processing image: ${image.path}, size: $fileSize bytes');

      // Cache personnel list to avoid disposal issues
      final List<Personnel> personnelList = [];
      try {
        // Use a try-catch specifically for the personnel list access
        personnelList.addAll(personnelProvider.allPersonnel);
        debugPrint(
            'Successfully cached ${personnelList.length} personnel records');
      } catch (personnelError) {
        debugPrint('Error accessing personnel list: $personnelError');
        // Continue with empty list rather than crashing
      }

      if (personnelList.isEmpty) {
        debugPrint('Warning: No personnel records available for comparison');
      }

      // Perform facial recognition with timeout protection using enhanced service
      final enhancedFacialRecognitionService =
          EnhancedFacialRecognitionService();
      // Initialize the service
      await enhancedFacialRecognitionService.initialize();

      Map<String, dynamic>? result;

      try {
        result = await enhancedFacialRecognitionService
            .identifyPersonnel(
          image,
          personnelList,
        )
            .timeout(const Duration(seconds: 10), onTimeout: () {
          throw TimeoutException(
              'Facial recognition timed out after 10 seconds');
        });
      } catch (recognitionError) {
        debugPrint('Error during facial recognition: $recognitionError');
        // Re-throw to be caught by the outer try-catch
        rethrow;
      }

      // Save image with metadata
      final Personnel? identifiedPersonnel =
          result != null ? result['personnel'] as Personnel : null;

      try {
        await enhancedFacialRecognitionService.saveImageWithMetadata(
          image,
          identifiedPersonnel,
          {
            'captureMethod': 'live_recognition',
            'captureTime': DateTime.now().toIso8601String(),
            'deviceInfo': 'NAFacial App',
            'sensitivity': _sensitivity.toString(),
            'recognitionMethod': 'enhanced_python',
          },
        );
      } catch (saveError) {
        // Just log the error but don't fail the whole process
        debugPrint('Error saving image metadata: $saveError');
      }

      if (mounted) {
        setState(() {
          _isProcessing = false;
          if (result != null) {
            _matchedPersonnel = result['personnel'] as Personnel;
            // Store the confidence value
            _confidence = result['confidence'] as double? ?? 0.88;

            // Store feature scores if available
            if (result.containsKey('feature_scores')) {
              _featureScores =
                  (result['feature_scores'] as Map<String, dynamic>)
                      .map((key, value) => MapEntry(key, value as double));

              // Log detailed feature scores
              debugPrint('Feature scores for ${_matchedPersonnel!.fullName}:');
              _featureScores!.forEach((feature, score) {
                debugPrint('  $feature: ${score.toStringAsFixed(2)}');
              });
            } else {
              _featureScores = null;
            }

            debugPrint(
                'Successfully identified: ${_matchedPersonnel!.fullName} with confidence: ${_confidence.toStringAsFixed(2)}');
          } else {
            _matchedPersonnel = null;
            _confidence = 0.0;
            _featureScores = null;
            debugPrint('No personnel match found');
          }
        });
      }
    } catch (e) {
      debugPrint('Error in facial recognition process: $e');
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });

        // Show more detailed error message to user
        String errorMessage = 'Recognition failed';

        if (e is TimeoutException) {
          errorMessage = 'Recognition timed out. Please try again.';
        } else if (e.toString().contains('Camera')) {
          errorMessage = 'Camera error. Please restart the app.';
        } else if (e.toString().contains('Permission')) {
          errorMessage = 'Camera permission denied. Please check app settings.';
        } else if (e.toString().contains('file')) {
          errorMessage = 'Error processing image file. Please try again.';
        } else {
          // Generic error with some details
          errorMessage = 'Recognition failed: ${e.toString().split(':').first}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () {
                // Clear the current state and allow retrying
                setState(() {
                  _isProcessing = false;
                  _matchedPersonnel = null;
                });
              },
            ),
          ),
        );
      }
    }
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recognition Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sensitivity slider
            const Text(
              'Sensitivity',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Slider(
              value: _sensitivity,
              min: 0.0,
              max: 1.0,
              divisions: 10,
              label: _getSensitivityLabel(),
              onChanged: (value) {
                setState(() {
                  _sensitivity = value;
                });
              },
            ),
            Text(
              _getSensitivityDescription(),
              style: const TextStyle(
                fontSize: 12,
                color: DesignSystem.textSecondaryColor,
              ),
            ),
            SizedBox(height: DesignSystem.adjustedSpacingMedium),

            // Show face overlay toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Show Face Overlay',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Switch(
                  value: _showFaceOverlay,
                  onChanged: (value) {
                    setState(() {
                      _showFaceOverlay = value;
                    });
                  },
                  activeColor: DesignSystem.primaryColor,
                ),
              ],
            ),
            const Text(
              'Display visual indicators for detected facial features',
              style: TextStyle(
                fontSize: 12,
                color: DesignSystem.textSecondaryColor,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _getSensitivityLabel() {
    if (_sensitivity < 0.3) return 'Low';
    if (_sensitivity < 0.7) return 'Medium';
    return 'High';
  }

  String _getSensitivityDescription() {
    if (_sensitivity < 0.3) {
      return 'Lower sensitivity may result in fewer false positives but might miss some faces';
    }
    if (_sensitivity < 0.7) {
      return 'Balanced sensitivity for most environments';
    }
    return 'Higher sensitivity detects faces more quickly but may increase false positives';
  }
}
