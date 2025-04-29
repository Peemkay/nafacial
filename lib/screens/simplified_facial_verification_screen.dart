import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../config/design_system.dart';
import '../models/personnel_model.dart';
import '../providers/personnel_provider.dart';
import '../providers/theme_provider.dart';
import '../services/simplified_facial_recognition_service.dart';
import '../widgets/platform_aware_widgets.dart';
import '../widgets/platform_image.dart';
import '../widgets/animated_gradient_button.dart';
import 'personnel_identification_result_screen.dart';

/// A simplified facial verification screen that doesn't use camera functionality
class SimplifiedFacialVerificationScreen extends StatefulWidget {
  final File? initialImage;

  const SimplifiedFacialVerificationScreen({Key? key, this.initialImage})
      : super(key: key);

  @override
  State<SimplifiedFacialVerificationScreen> createState() =>
      _SimplifiedFacialVerificationScreenState();
}

class _SimplifiedFacialVerificationScreenState
    extends State<SimplifiedFacialVerificationScreen>
    with SingleTickerProviderStateMixin {
  // Facial recognition service
  final SimplifiedFacialRecognitionService _facialRecognitionService =
      SimplifiedFacialRecognitionService();

  // UI state
  File? _selectedImage;
  bool _isProcessing = false;
  String? _processingStatus;

  // Animation controller for UI effects
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Set initial image if provided
    if (widget.initialImage != null) {
      _selectedImage = widget.initialImage;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _facialRecognitionService.dispose();
    super.dispose();
  }

  /// Pick image from gallery
  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? file = await picker.pickImage(source: ImageSource.gallery);

      if (file != null) {
        setState(() {
          _selectedImage = File(file.path);
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  /// Identify personnel from image
  Future<void> _identifyPersonnel() async {
    if (_selectedImage == null) return;

    setState(() {
      _isProcessing = true;
      _processingStatus = 'Identifying personnel...';
    });

    try {
      // Get personnel list
      final personnelProvider =
          Provider.of<PersonnelProvider>(context, listen: false);
      final List<Personnel> personnelList = personnelProvider.allPersonnel;

      // Identify personnel
      final result = await _facialRecognitionService.identifyPersonnel(
        _selectedImage!,
        personnelList,
      );

      if (!mounted) return;

      if (result != null) {
        // Navigate to result screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PersonnelIdentificationResultScreen(
              capturedImage: _selectedImage!,
              identifiedPersonnel: result['personnel'],
              confidence: result['confidence'],
              isLiveCapture: false,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No matching personnel found'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error identifying personnel: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _processingStatus = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return PlatformScaffold(
      appBar: AppBar(
        title: const Text('Facial Verification'),
        backgroundColor: isDarkMode
            ? DesignSystem.darkAppBarColor
            : DesignSystem.lightAppBarColor,
        elevation: 0,
        actions: [
          // Help button
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              _showHelpDialog();
            },
            tooltip: 'Help',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Main content
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius:
                      BorderRadius.circular(DesignSystem.borderRadiusMedium),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(
                            DesignSystem.borderRadiusMedium),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Image
                            PlatformImage(
                              imageSource: _selectedImage!.path,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                      )
                    : const Center(
                        child: Text(
                          'No image selected',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
              ),
            ),

            // Action buttons
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Pick image button
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DesignSystem.secondaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  // Identify button
                  AnimatedGradientButton(
                    onPressed:
                        _selectedImage != null ? _identifyPersonnel : null,
                    icon: Icons.person_search,
                    label: 'Identify',
                    animationController: _animationController,
                    isEnabled: _selectedImage != null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show help dialog
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Facial Verification Help'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'How to use:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• Select a photo from your gallery'),
              Text('• The system will try to identify the person in the photo'),
              Text('• If a match is found, you will see the personnel details'),
              SizedBox(height: 8),
              Text(
                'Tips:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• Use clear, well-lit photos for best results'),
              Text('• Make sure the face is clearly visible'),
              Text('• Avoid photos with multiple people'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
