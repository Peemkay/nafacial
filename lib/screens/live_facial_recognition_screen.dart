import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:provider/provider.dart';
import '../config/design_system.dart';
import '../models/personnel_model.dart';
import '../providers/personnel_provider.dart';
import '../services/facial_recognition_service.dart';
import '../widgets/face_detection_camera.dart';
import 'personnel_identification_result_screen.dart';
import '../widgets/platform_aware_widgets.dart';

class LiveFacialRecognitionScreen extends StatefulWidget {
  const LiveFacialRecognitionScreen({Key? key}) : super(key: key);

  @override
  State<LiveFacialRecognitionScreen> createState() =>
      _LiveFacialRecognitionScreenState();
}

class _LiveFacialRecognitionScreenState
    extends State<LiveFacialRecognitionScreen> {
  File? _capturedImage;
  List<Face>? _detectedFaces;
  bool _isProcessing = false;
  double _sensitivity = 0.7; // Default sensitivity (0.0 to 1.0)
  bool _showFaceOverlay = true;
  Personnel? _matchedPersonnel;

  @override
  Widget build(BuildContext context) {
    final personnelProvider = Provider.of<PersonnelProvider>(context);

    return PlatformScaffold(
      appBar: AppBar(
        title: const Text('Live Facial Recognition'),
        backgroundColor: DesignSystem.primaryColor,
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
          padding: EdgeInsets.all(DesignSystem.adjustedSpacingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Camera preview with face detection
              Expanded(
                flex: 3,
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(DesignSystem.borderRadiusMedium),
                  child: FaceDetectionCamera(
                    sensitivity: _sensitivity,
                    showFaceOverlay: _showFaceOverlay,
                    onFaceDetected: (image, faces) {
                      if (!_isProcessing &&
                          image != null &&
                          faces != null &&
                          faces.isNotEmpty) {
                        _processFaceDetection(image, faces, personnelProvider);
                      }
                    },
                  ),
                ),
              ),

              SizedBox(height: DesignSystem.adjustedSpacingMedium),

              // Status and controls
              Expanded(
                flex: 2,
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(DesignSystem.borderRadiusMedium),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(DesignSystem.adjustedSpacingMedium),
                    child: _isProcessing
                        ? _buildProcessingView()
                        : _matchedPersonnel != null
                            ? _buildMatchResultView()
                            : _buildInstructionsView(),
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
                  ? Icon(
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
                    _matchedPersonnel!.fullName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${_matchedPersonnel!.rank.displayName} - ${_matchedPersonnel!.corps.shortName}',
                    style: TextStyle(
                      color: DesignSystem.textSecondaryColor,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Army Number: ${_matchedPersonnel!.armyNumber}',
                    style: TextStyle(
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

        // Verification status
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: DesignSystem.adjustedSpacingMedium,
            vertical: DesignSystem.adjustedSpacingSmall,
          ),
          decoration: BoxDecoration(
            color: Colors.green.withAlpha(25),
            borderRadius: BorderRadius.circular(DesignSystem.borderRadiusSmall),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Verified',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
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
      children: [
        Icon(
          Icons.face,
          size: 48,
          color: DesignSystem.primaryColor,
        ),
        SizedBox(height: DesignSystem.adjustedSpacingMedium),
        const Text(
          'Position your face in the camera',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: DesignSystem.adjustedSpacingSmall),
        Text(
          'The system will automatically detect and verify your identity',
          style: TextStyle(
            color: DesignSystem.textSecondaryColor,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: DesignSystem.adjustedSpacingMedium),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lightbulb_outline,
              size: 16,
              color: DesignSystem.warningColor,
            ),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                'Ensure good lighting and a clear view of your face',
                style: TextStyle(
                  color: DesignSystem.warningColor,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _processFaceDetection(
      File image, List<Face> faces, PersonnelProvider personnelProvider) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Use the facial recognition service to identify personnel
      final facialRecognitionService = FacialRecognitionService();

      // Identify personnel from image
      final result = await facialRecognitionService.identifyPersonnel(
        image,
        personnelProvider.allPersonnel,
      );

      // Extract personnel and confidence from result
      final Personnel? identifiedPersonnel =
          result != null ? result['personnel'] as Personnel : null;
      final double confidence =
          result != null ? result['confidence'] as double : 0.0;

      // Save image with metadata
      final savedImagePath =
          await facialRecognitionService.saveImageWithMetadata(
        image,
        identifiedPersonnel,
        {
          'captureMethod': 'live_recognition',
          'captureTime': DateTime.now().toIso8601String(),
          'deviceInfo': 'NAFacial App',
          'sensitivity': _sensitivity.toString(),
          'faceCount': faces.length.toString(),
        },
      );

      if (!mounted) return;

      if (identifiedPersonnel != null) {
        // Show result in the current screen
        setState(() {
          _matchedPersonnel = identifiedPersonnel;
          _isProcessing = false;
        });
      } else {
        // Navigate to the identification result screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PersonnelIdentificationResultScreen(
              capturedImage: image,
              identifiedPersonnel: null,
              savedImagePath: savedImagePath,
              isLiveCapture: true,
              confidence: confidence,
            ),
          ),
        ).then((_) {
          if (mounted) {
            setState(() {
              _isProcessing = false;
            });
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _resetRecognition() {
    setState(() {
      _capturedImage = null;
      _detectedFaces = null;
      _matchedPersonnel = null;
    });
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
              style: TextStyle(
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
            Text(
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
