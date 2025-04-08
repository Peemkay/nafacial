import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/design_system.dart';
import '../models/personnel_model.dart';
import '../providers/personnel_provider.dart';
import '../services/facial_recognition_service.dart';
import '../widgets/platform_aware_widgets.dart';
import '../widgets/webcam_access.dart';
import 'personnel_identification_result_screen.dart';

class WebcamCaptureScreen extends StatefulWidget {
  const WebcamCaptureScreen({Key? key}) : super(key: key);

  @override
  State<WebcamCaptureScreen> createState() => _WebcamCaptureScreenState();
}

class _WebcamCaptureScreenState extends State<WebcamCaptureScreen> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: AppBar(
        title: const Text('External Camera'),
        backgroundColor: DesignSystem.primaryColor,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Use your external camera to capture an image for facial verification',
                style: const TextStyle(
                  fontSize: 16,
                  color: DesignSystem.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _isProcessing
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text(
                              'Processing facial recognition...',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    : WebcamAccess(
                        onImageCaptured: _processImage,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processImage(File imageFile) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final personnelProvider =
          Provider.of<PersonnelProvider>(context, listen: false);
      final facialRecognitionService = FacialRecognitionService();

      // Identify personnel from image
      final result = await facialRecognitionService.identifyPersonnel(
        imageFile,
        personnelProvider.allPersonnel,
      );

      // Extract personnel and confidence from result
      final personnel =
          result != null ? result['personnel'] as Personnel : null;
      final double confidence =
          result != null ? result['confidence'] as double : 0.0;

      // Save image with metadata
      final savedImagePath =
          await facialRecognitionService.saveImageWithMetadata(
        imageFile,
        personnel,
        {
          'captureMethod': 'external_camera',
          'captureTime': DateTime.now().toIso8601String(),
          'deviceInfo': 'NAFacial App - External Camera',
          'confidence': confidence.toString(),
        },
      );

      if (mounted) {
        setState(() {
          _isProcessing = false;
        });

        // Navigate to result screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PersonnelIdentificationResultScreen(
              capturedImage: imageFile,
              identifiedPersonnel: personnel,
              savedImagePath: savedImagePath,
              confidence: confidence,
            ),
          ),
        );
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
}
