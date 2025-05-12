import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart' as permission;
// import 'package:image_gallery_saver/image_gallery_saver.dart';
import '../config/design_system.dart';
import '../models/personnel_model.dart';
import '../providers/personnel_provider.dart';
import '../widgets/platform_aware_widgets.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/fancy_bottom_nav_bar.dart';
import '../widgets/security_pattern_painter.dart';
import '../widgets/advanced_camera_widget.dart';
import '../services/enhanced_facial_recognition_service.dart';
import '../services/optimized_face_recognition_service.dart';
import '../providers/auth_provider.dart';

import 'personnel_registration_screen.dart';
import 'personnel_edit_screen.dart';
import 'personnel_identification_result_screen.dart';

class FacialVerificationScreen extends StatefulWidget {
  final int initialTabIndex;
  final File? initialImage;

  const FacialVerificationScreen({
    Key? key,
    this.initialTabIndex = 0,
    this.initialImage,
  }) : super(key: key);

  @override
  State<FacialVerificationScreen> createState() =>
      _FacialVerificationScreenState();
}

class _FacialVerificationScreenState extends State<FacialVerificationScreen> {
  int _currentIndex = 0;
  final _armyNumberController = TextEditingController();
  final _searchController = TextEditingController();
  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();

    // Set initial tab index
    _currentIndex = widget.initialTabIndex;

    // Set initial image if provided
    if (widget.initialImage != null) {
      _selectedImage = widget.initialImage;
      // Process the image for facial verification
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _identifyPersonnelFromImage(widget.initialImage!);
        _processImageForVerification();
      });
    }

    // Initialize personnel provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final personnelProvider =
          Provider.of<PersonnelProvider>(context, listen: false);
      personnelProvider.initialize();
    });
  }

  @override
  void dispose() {
    _armyNumberController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Take a photo using the camera
  Future<void> _takePhoto() async {
    try {
      // Request camera permission first
      final status = await permission.Permission.camera.request();
      if (status.isDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Camera permission is required to take photos'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Use image picker to take a photo with improved error handling
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 80,
      );

      if (photo != null) {
        // Verify the file exists and has content
        final file = File(photo.path);
        if (await file.exists()) {
          final fileSize = await file.length();
          if (fileSize <= 0) {
            throw Exception('Captured image is empty (0 bytes)');
          }

          if (mounted) {
            setState(() {
              _selectedImage = file;
            });

            // Process the image for facial verification
            _identifyPersonnelFromImage(file);
            _processImageForVerification();
          }
        } else {
          throw Exception('Captured image file does not exist');
        }
      }
    } catch (e) {
      debugPrint('Error taking photo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Camera error: ${e.toString()}'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _takePhoto,
              textColor: Colors.white,
            ),
          ),
        );
      }
    }
  }

  // Process video for verification
  Future<void> _processVideoForVerification() async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Processing video for facial verification...'),
          backgroundColor: Colors.blue,
        ),
      );
    }

    // Simulate processing delay
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Video processing complete. Facial verification successful!'),
          backgroundColor: Colors.green,
        ),
      );

      // Identify personnel from video (simulated)
      final personnelProvider =
          Provider.of<PersonnelProvider>(context, listen: false);
      await personnelProvider.loadAllPersonnel();
      final Personnel? identifiedPersonnel =
          personnelProvider.allPersonnel.isNotEmpty
              ? personnelProvider.allPersonnel.first
              : null;

      if (identifiedPersonnel != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PersonnelIdentificationResultScreen(
              capturedImage: _selectedImage!,
              identifiedPersonnel: identifiedPersonnel,
              savedImagePath: _selectedImage!.path,
              confidence: 0.85,
              isVideo: true,
            ),
          ),
        );
      }
    }
  }

  // Pick an image from gallery
  Future<void> _pickImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });

      // Process the image for facial verification
      _identifyPersonnelFromImage(File(image.path));
    }
  }

  // Pick a printed or displayed photo for recognition
  Future<void> _pickPrintedPhoto() async {
    try {
      // Show information dialog first
      if (mounted) {
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Printed Photo Recognition'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'This feature is optimized for:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('• ID cards and printed photos'),
                  Text('• Photos displayed on other screens'),
                  Text('• Documents with personnel photos'),
                  SizedBox(height: 12),
                  Text(
                    'For best results:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('• Ensure good lighting'),
                  Text('• Avoid glare and reflections'),
                  Text('• Keep the photo flat and centered'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('CANCEL'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('CONTINUE'),
                ),
              ],
            );
          },
        ).then((value) async {
          if (value == true) {
            final XFile? image = await _imagePicker.pickImage(
              source: ImageSource.camera,
              preferredCameraDevice: CameraDevice.rear,
              imageQuality: 90,
            );

            if (image != null && mounted) {
              setState(() {
                _selectedImage = File(image.path);
              });

              // Process the printed photo for recognition
              _identifyPersonnelFromPrintedPhoto(File(image.path));
            }
          }
        });
      }
    } catch (e) {
      debugPrint('Error picking printed photo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Identify personnel from a printed or displayed photo
  Future<void> _identifyPersonnelFromPrintedPhoto(File imageFile) async {
    // Cache the personnel list before processing to avoid disposal issues
    List<Personnel> personnelList = [];

    try {
      // Get the personnel list safely
      if (mounted) {
        final personnelProvider =
            Provider.of<PersonnelProvider>(context, listen: false);
        // Make sure the personnel list is loaded
        if (personnelProvider.allPersonnel.isEmpty) {
          await personnelProvider.loadAllPersonnel();
        }
        personnelList = List.from(personnelProvider.allPersonnel);
      }

      // Show loading dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Processing Printed Photo'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  StreamBuilder<String>(
                    stream:
                        Stream.periodic(const Duration(milliseconds: 800), (i) {
                      final messages = [
                        'Enhancing image quality...',
                        'Detecting printed face...',
                        'Extracting features...',
                        'Compensating for print artifacts...',
                        'Matching with database...',
                        'Verifying identity...',
                      ];
                      return messages[i % messages.length];
                    }),
                    builder: (context, snapshot) {
                      return Text(
                        snapshot.data ?? 'Processing Printed Photo...',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Text('This may take a few moments',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search, size: 16, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Searching database of ${personnelList.length} personnel',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[700],
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }

      // Use the optimized face recognition service for printed photos
      final optimizedService = OptimizedFaceRecognitionService();
      await optimizedService.initialize();

      // Process the printed photo
      final result = await optimizedService.identifyFromPrintedPhoto(
        imageFile,
        personnelList,
      );

      // Close the dialog
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      // Extract personnel and confidence from result
      final Personnel? identifiedPersonnel =
          result != null ? result['personnel'] as Personnel? : null;
      final double confidence =
          result != null ? result['confidence'] as double : 0.0;
      final String matchQuality = result != null
          ? result['match_quality'] as String? ?? 'unknown'
          : 'none';

      // Show appropriate message based on match quality
      if (mounted) {
        if (identifiedPersonnel == null) {
          // No match found
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No matching personnel found in database.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          // Match found - navigate to result screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PersonnelIdentificationResultScreen(
                capturedImage: imageFile,
                identifiedPersonnel: identifiedPersonnel,
                savedImagePath: imageFile.path,
                confidence: confidence,
                matchQuality: matchQuality,
                sourceType: 'printed_photo',
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error in printed photo recognition: $e');

      // Close the dialog if it's open
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing printed photo: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Pick a video from gallery
  Future<void> _pickVideo() async {
    final XFile? video = await _imagePicker.pickVideo(
      source: ImageSource.gallery,
    );

    if (video != null) {
      // Process the video for facial verification
      setState(() {
        _selectedImage = File(video.path);
      });
      _processVideoForVerification();
    }
  }

  // Process image for facial verification
  void _processImageForVerification() {
    // This is kept for backward compatibility
    // The actual processing is now done in _identifyPersonnelFromImage
  }

  // Identify personnel from image using enhanced facial recognition
  Future<void> _identifyPersonnelFromImage(File imageFile) async {
    // Cache the personnel list before processing to avoid disposal issues
    List<Personnel> personnelList = [];

    try {
      // Get the personnel list safely
      if (mounted) {
        final personnelProvider =
            Provider.of<PersonnelProvider>(context, listen: false);
        // Make sure the personnel list is loaded
        if (personnelProvider.allPersonnel.isEmpty) {
          await personnelProvider.loadAllPersonnel();
        }
        personnelList = List.from(personnelProvider.allPersonnel);
      }

      // Use the enhanced facial recognition service for better accuracy
      final enhancedFacialRecognitionService =
          EnhancedFacialRecognitionService();

      // Initialize the service if needed
      await enhancedFacialRecognitionService.initialize();

      // Show loading dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Face Recognition in Progress'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  StreamBuilder<String>(
                    stream:
                        Stream.periodic(const Duration(milliseconds: 800), (i) {
                      final messages = [
                        'Analyzing facial features...',
                        'Extracting biometric data...',
                        'Comparing with database...',
                        'Calculating match confidence...',
                        'Verifying identity...',
                      ];
                      return messages[i % messages.length];
                    }),
                    builder: (context, snapshot) {
                      return Text(
                        snapshot.data ?? 'Processing Face Recognition...',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Text('This may take a few moments',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search, size: 16, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Searching database of ${personnelList.length} personnel',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[700],
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );

        // Also show a snackbar for additional feedback
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Processing advanced facial recognition...'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Verify the image file exists and has content
      if (!await imageFile.exists()) {
        throw Exception('Image file does not exist: ${imageFile.path}');
      }

      final fileSize = await imageFile.length();
      if (fileSize <= 0) {
        throw Exception('Image file is empty (0 bytes): ${imageFile.path}');
      }

      // Log file details for debugging
      debugPrint(
          'Processing image with enhanced recognition: ${imageFile.path}, size: $fileSize bytes');

      // Identify personnel from image using the cached personnel list and enhanced recognition
      final result = await enhancedFacialRecognitionService.identifyPersonnel(
        imageFile,
        personnelList,
      );

      // Extract personnel and confidence from result
      final Personnel? identifiedPersonnel =
          result != null ? result['personnel'] as Personnel? : null;
      final double confidence =
          result != null ? result['confidence'] as double : 0.0;
      final String matchQuality = result != null
          ? result['match_quality'] as String? ?? 'unknown'
          : 'none';
      final String matchMethod = result != null
          ? result['match_method'] as String? ?? 'unknown'
          : 'none';
      final String? warning =
          result != null ? result['warning'] as String? : null;
      final String? bestMatchName =
          result != null ? result['best_match_name'] as String? : null;
      final String? bestMatchArmyNumber =
          result != null ? result['best_match_army_number'] as String? : null;

      // Extract similarity metrics if available
      final Map<String, dynamic>? featureScores = result != null
          ? result['featureScores'] as Map<String, dynamic>?
          : null;
      final double? cosineSimilarity = featureScores != null
          ? featureScores['cosine_similarity'] as double?
          : null;
      final double? euclideanSimilarity = featureScores != null
          ? featureScores['euclidean_similarity'] as double?
          : null;
      final double? manhattanSimilarity = featureScores != null
          ? featureScores['manhattan_similarity'] as double?
          : null;

      // Log the result with detailed metrics
      if (identifiedPersonnel != null) {
        debugPrint('MATCH FOUND:');
        debugPrint(
            '  Personnel: ${identifiedPersonnel.fullName} (${identifiedPersonnel.armyNumber})');
        debugPrint('  Confidence: ${confidence.toStringAsFixed(4)}');
        debugPrint(
            '  Match method: $matchMethod, Match quality: $matchQuality');

        if (cosineSimilarity != null) {
          debugPrint(
              '  Cosine similarity: ${cosineSimilarity.toStringAsFixed(4)}');
        }
        if (euclideanSimilarity != null) {
          debugPrint(
              '  Euclidean similarity: ${euclideanSimilarity.toStringAsFixed(4)}');
        }
        if (manhattanSimilarity != null) {
          debugPrint(
              '  Manhattan similarity: ${manhattanSimilarity.toStringAsFixed(4)}');
        }

        if (warning != null) {
          debugPrint('  Warning: $warning');
        }

        // Log feature scores if available
        if (featureScores != null) {
          debugPrint('  Feature scores:');
          for (final entry in featureScores.entries) {
            if (entry.key != 'cosine_similarity' &&
                entry.key != 'euclidean_similarity' &&
                entry.key != 'manhattan_similarity') {
              debugPrint('    ${entry.key}: ${entry.value.toStringAsFixed(4)}');
            }
          }
        }
      } else {
        debugPrint('NO MATCH FOUND:');
        debugPrint('  Best confidence: ${confidence.toStringAsFixed(4)}');

        if (cosineSimilarity != null) {
          debugPrint(
              '  Cosine similarity: ${cosineSimilarity.toStringAsFixed(4)}');
        }
        if (euclideanSimilarity != null) {
          debugPrint(
              '  Euclidean similarity: ${euclideanSimilarity.toStringAsFixed(4)}');
        }
        if (manhattanSimilarity != null) {
          debugPrint(
              '  Manhattan similarity: ${manhattanSimilarity.toStringAsFixed(4)}');
        }

        if (bestMatchName != null) {
          debugPrint(
              '  Best match (below threshold): $bestMatchName ($bestMatchArmyNumber)');
        }
      }

      // Show appropriate message based on match quality
      if (mounted) {
        if (identifiedPersonnel == null) {
          // No match found
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No matching personnel found in database.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        } else if (matchQuality == 'medium') {
          // Medium confidence match
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Possible match found (${(confidence * 100).toStringAsFixed(1)}%). Verify manually.'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        } else if (matchQuality == 'low') {
          // Low confidence match
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Low confidence match (${(confidence * 100).toStringAsFixed(1)}%). Verify carefully.'),
              backgroundColor: Colors.deepOrange,
              duration: const Duration(seconds: 3),
            ),
          );
        } else if (matchQuality == 'high') {
          // High confidence match
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Match found: ${identifiedPersonnel.fullName} (${(confidence * 100).toStringAsFixed(1)}%)'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }

      // Log all personnel in the database for debugging
      debugPrint('PERSONNEL IN DATABASE:');
      debugPrint('Total personnel: ${personnelList.length}');
      int personnelWithPhotos = 0;
      for (var person in personnelList) {
        final hasPhoto = person.photoUrl != null && person.photoUrl!.isNotEmpty;
        if (hasPhoto) {
          final photoFile = File(person.photoUrl!);
          final photoExists = photoFile.existsSync();
          final photoSize = photoExists ? photoFile.lengthSync() : 0;
          debugPrint(
              '  ${person.fullName} (${person.armyNumber}) - Photo: ${hasPhoto ? 'Yes' : 'No'}, Exists: $photoExists, Size: $photoSize bytes');
          if (photoExists && photoSize > 0) {
            personnelWithPhotos++;
          }
        } else {
          debugPrint('  ${person.fullName} (${person.armyNumber}) - Photo: No');
        }
      }
      debugPrint(
          'Personnel with valid photos: $personnelWithPhotos / ${personnelList.length}');

      // Add a warning if no personnel have photos
      if (personnelWithPhotos == 0) {
        debugPrint(
            'WARNING: No personnel have valid photos in the database. Face recognition will not work!');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'No personnel photos found in database. Please add photos to enable face recognition.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
            ),
          );
        }
      }

      // Save image with metadata
      final savedImagePath =
          await enhancedFacialRecognitionService.saveImageWithMetadata(
        imageFile,
        identifiedPersonnel,
        {
          'captureMethod': 'camera',
          'captureTime': DateTime.now().toIso8601String(),
          'deviceInfo': 'DBWFR App',
          'confidence': confidence.toString(),
          'recognitionMethod': 'enhanced_python',
          'adminInfo': await _getAdminInfo() ?? 'Unknown Admin',
        },
      );

      if (mounted) {
        // Close the loading dialog if it's still open
        Navigator.of(context, rootNavigator: true).pop();

        // Navigate to identification result screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PersonnelIdentificationResultScreen(
              capturedImage: imageFile,
              identifiedPersonnel: identifiedPersonnel,
              savedImagePath: savedImagePath,
              confidence: confidence,
              matchQuality: matchQuality,
              bestMatchName: bestMatchName,
              bestMatchArmyNumber: bestMatchArmyNumber,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error in facial verification: $e');

      if (mounted) {
        // Close the loading dialog if it's still open
        try {
          Navigator.of(context, rootNavigator: true).pop();
        } catch (dialogError) {
          debugPrint('Error closing dialog: $dialogError');
        }

        // Show user-friendly error message
        String errorMessage = 'An error occurred during facial verification.';

        if (e.toString().contains('not supported')) {
          errorMessage =
              'Image format not supported. Please try a different image.';
        } else if (e.toString().contains('file does not exist')) {
          errorMessage =
              'Image file not found. Please try again with a different image.';
        } else if (e.toString().contains('empty')) {
          errorMessage =
              'The selected image appears to be empty. Please try a different image.';
        } else if (e.toString().contains('timed out')) {
          errorMessage =
              'Processing timed out. Please try again with a smaller image.';
        }

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _pickImage(),
            ),
          ),
        );
      }
    }
  }

  // Verify by army number
  Future<void> _verifyByArmyNumber() async {
    final armyNumber = _armyNumberController.text.trim();

    if (armyNumber.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter an army number'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final personnelProvider =
        Provider.of<PersonnelProvider>(context, listen: false);
    final personnel =
        await personnelProvider.getPersonnelByArmyNumber(armyNumber);

    if (!mounted) return;

    if (personnel != null) {
      personnelProvider.setSelectedPersonnel(personnel);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Personnel found: ${personnel.fullName}'),
          backgroundColor: Colors.green,
        ),
      );

      // Show personnel details in a dialog
      _showPersonnelDetailsDialog(personnel);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Personnel not found with this army number'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Show personnel details dialog
  void _showPersonnelDetailsDialog(Personnel personnel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Personnel Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (personnel.photoUrl != null)
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: FileImage(File(personnel.photoUrl!)),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: DesignSystem.primaryColor.withValues(alpha: 26),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 60,
                    color: DesignSystem.primaryColor,
                  ),
                ),
              SizedBox(height: DesignSystem.adjustedSpacingMedium),
              _buildDetailRow('Name', personnel.fullName),
              _buildDetailRow('Initials', personnel.initials),
              _buildDetailRow('Army Number', personnel.armyNumber),
              _buildDetailRow('Rank', personnel.rank.displayName),
              _buildDetailRow('Unit', personnel.unit),
              _buildDetailRow('Corps', personnel.corps.displayName),
              _buildDetailRow('Category', _getCategoryText(personnel.category)),
              _buildDetailRow('Service Status',
                  _getServiceStatusText(personnel.serviceStatus)),
              _buildDetailRow(
                  'Verification Status', _getStatusText(personnel.status)),
              _buildDetailRow(
                  'Registered', _formatDate(personnel.dateRegistered)),
              if (personnel.lastVerified != null)
                _buildDetailRow(
                    'Last Verified', _formatDate(personnel.lastVerified!)),
              if (personnel.dateOfBirth != null)
                _buildDetailRow(
                    'Date of Birth', _formatDate(personnel.dateOfBirth!)),
              if (personnel.enlistmentDate != null) ...[
                _buildDetailRow(
                    'Enlistment Date', _formatDate(personnel.enlistmentDate!)),
                _buildDetailRow(
                    'Years of Service', '${personnel.yearsOfService} years'),
              ],
              if (personnel.notes != null && personnel.notes!.isNotEmpty)
                _buildDetailRow('Notes', personnel.notes!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _editPersonnel(personnel);
            },
            child: const Text('Edit'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _verifyPersonnel(personnel);
            },
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }

  // Edit personnel
  void _editPersonnel(Personnel personnel) {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => PersonnelEditScreen(personnel: personnel),
      ),
    )
        .then((updated) {
      if (updated == true && mounted) {
        // Refresh personnel list
        final personnelProvider =
            Provider.of<PersonnelProvider>(context, listen: false);
        personnelProvider.loadAllPersonnel();
      }
    });
  }

  // Verify personnel
  Future<void> _verifyPersonnel(Personnel personnel) async {
    final personnelProvider =
        Provider.of<PersonnelProvider>(context, listen: false);

    try {
      await personnelProvider.updateVerificationStatus(
        personnel.id,
        VerificationStatus.verified,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${personnel.fullName} has been verified'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Build detail row
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: DesignSystem.adjustedSpacingSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: DesignSystem.fontWeightBold,
                color: DesignSystem.textSecondaryColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: DesignSystem.fontWeightMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Get category text
  String _getCategoryText(PersonnelCategory category) {
    switch (category) {
      case PersonnelCategory.officerMale:
        return 'Officer (Male)';
      case PersonnelCategory.officerFemale:
        return 'Officer (Female)';
      case PersonnelCategory.soldierMale:
        return 'Soldier (Male)';
      case PersonnelCategory.soldierFemale:
        return 'Soldier (Female)';
    }
  }

  // Get status text
  String _getStatusText(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.pending:
        return 'Pending';
      case VerificationStatus.verified:
        return 'Verified';
      case VerificationStatus.rejected:
        return 'Rejected';
    }
  }

  // Get service status text
  String _getServiceStatusText(ServiceStatus status) {
    switch (status) {
      case ServiceStatus.active:
        return 'Active';
      case ServiceStatus.retired:
        return 'Retired';
      case ServiceStatus.resigned:
        return 'Resigned';
      case ServiceStatus.awol:
        return 'AWOL (Absent Without Leave)';
      case ServiceStatus.deserted:
        return 'Deserted';
      case ServiceStatus.dismissed:
        return 'Dismissed';
      case ServiceStatus.discharged:
        return 'Discharged';
      case ServiceStatus.deceased:
        return 'Deceased';
    }
  }

  // Get service status color
  Color _getServiceStatusColor(ServiceStatus status) {
    switch (status) {
      case ServiceStatus.active:
        return Colors.green;
      case ServiceStatus.retired:
        return Colors.blue;
      case ServiceStatus.resigned:
        return Colors.purple;
      case ServiceStatus.awol:
        return Colors.orange;
      case ServiceStatus.deserted:
        return Colors.deepOrange;
      case ServiceStatus.dismissed:
        return Colors.red;
      case ServiceStatus.discharged:
        return Colors.teal;
      case ServiceStatus.deceased:
        return Colors.grey;
    }
  }

  // Format date
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Show error message safely
  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Handle video capture - simplified version
  Future<void> _captureVideo() async {
    try {
      // Use image picker to record a video
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.camera,
      );

      if (video != null && mounted) {
        setState(() {
          _selectedImage = File(video.path);
        });

        // Process the video for verification
        _processVideoForVerification();
      }
    } catch (e) {
      debugPrint('Error recording video: $e');
      _showErrorMessage('Error recording video: ${e.toString()}');
    }
  }

  // Get current admin info for tracking changes
  Future<String?> _getAdminInfo() async {
    try {
      if (!mounted) return null;

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = await authProvider.getCurrentUser();

      if (currentUser != null) {
        return '${currentUser.rank} ${currentUser.fullName} (${currentUser.armyNumber ?? "Unknown"})';
      }
      return null;
    } catch (e) {
      debugPrint('Error getting admin info: $e');
      return null;
    }
  }

  // Build camera verification tab with face detection
  Widget _buildCameraVerificationTab() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_selectedImage != null)
                Container(
                  width: isLargeScreen ? 300 : 200,
                  height: isLargeScreen ? 300 : 200,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(DesignSystem.borderRadiusMedium),
                    image: DecorationImage(
                      image: FileImage(_selectedImage!),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 51),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  width: isLargeScreen ? 300 : 200,
                  height: isLargeScreen ? 300 : 200,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(DesignSystem.borderRadiusMedium),
                    color: DesignSystem.primaryColor.withValues(alpha: 26),
                    border: Border.all(
                      color: DesignSystem.primaryColor.withValues(alpha: 77),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 26),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Security pattern background
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                            DesignSystem.borderRadiusMedium - 2),
                        child: CustomPaint(
                          painter: SecurityPatternPainter(
                            gridSpacing: 15,
                            gridColor:
                                DesignSystem.lightBlue.withValues(alpha: 51),
                          ),
                          size: Size(isLargeScreen ? 300 : 200,
                              isLargeScreen ? 300 : 200),
                        ),
                      ),
                      // Camera icon
                      Icon(
                        Icons.camera_alt,
                        size: isLargeScreen ? 100 : 80,
                        color: DesignSystem.primaryColor,
                      ),
                      // Face outline guide
                      Positioned.fill(
                        child: Center(
                          child: Container(
                            width: isLargeScreen ? 180 : 120,
                            height: isLargeScreen ? 180 : 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: DesignSystem.accentColor
                                    .withValues(alpha: 128),
                                width: 2,
                                style: BorderStyle.solid,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: DesignSystem.adjustedSpacingLarge),
              Wrap(
                spacing: DesignSystem.adjustedSpacingMedium,
                runSpacing: DesignSystem.adjustedSpacingMedium,
                alignment: WrapAlignment.center,
                children: [
                  PlatformButton(
                    text: 'TAKE PHOTO',
                    onPressed: () async {
                      // Check camera permission before taking photo
                      final status = await permission.Permission.camera.status;
                      if (status.isGranted) {
                        _takePhoto();
                      } else {
                        // Request permission
                        final result =
                            await permission.Permission.camera.request();
                        if (result.isGranted) {
                          _takePhoto();
                        } else if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Camera permission is required'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    icon: Icons.camera_alt,
                    isFullWidth: false,
                  ),
                ],
              ),
              SizedBox(height: DesignSystem.adjustedSpacingMedium),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: DesignSystem.adjustedSpacingMedium,
                  vertical: DesignSystem.adjustedSpacingSmall,
                ),
                decoration: BoxDecoration(
                  color: DesignSystem.primaryColor.withValues(alpha: 26),
                  borderRadius:
                      BorderRadius.circular(DesignSystem.borderRadiusSmall),
                ),
                child: PlatformText(
                  'Position the face in the center of the frame for best results',
                  style: TextStyle(
                    color: DesignSystem.textSecondaryColor,
                    fontSize: DesignSystem.adjustedFontSizeSmall,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: DesignSystem.adjustedSpacingMedium),
              if (_selectedImage == null)
                PlatformText(
                  'Tap the button to take a photo for verification',
                  style: TextStyle(
                    color: DesignSystem.textSecondaryColor,
                    fontSize: DesignSystem.adjustedFontSizeSmall,
                  ),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        );
      },
    );
  }

  // Build photo verification tab
  Widget _buildPhotoVerificationTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_selectedImage != null)
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(DesignSystem.borderRadiusMedium),
                image: DecorationImage(
                  image: FileImage(_selectedImage!),
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(DesignSystem.borderRadiusMedium),
                color: DesignSystem.primaryColor.withValues(alpha: 26),
              ),
              child: const Icon(
                Icons.photo,
                size: 80,
                color: DesignSystem.primaryColor,
              ),
            ),
          SizedBox(height: DesignSystem.adjustedSpacingLarge),
          Wrap(
            spacing: DesignSystem.adjustedSpacingMedium,
            runSpacing: DesignSystem.adjustedSpacingMedium,
            alignment: WrapAlignment.center,
            children: [
              PlatformButton(
                text: 'SELECT PHOTO',
                onPressed: _pickImage,
                icon: Icons.photo_library,
                isFullWidth: false,
              ),
              PlatformButton(
                text: 'SCAN ID/PHOTO',
                onPressed: _pickPrintedPhoto,
                icon: Icons.document_scanner,
                buttonType: PlatformButtonType.secondary,
                isFullWidth: false,
              ),
            ],
          ),
          SizedBox(height: DesignSystem.adjustedSpacingMedium),
          PlatformText(
            'Select a clear photo of the face',
            style: TextStyle(
              color: DesignSystem.textSecondaryColor,
              fontSize: DesignSystem.adjustedFontSizeSmall,
            ),
          ),
        ],
      ),
    );
  }

  // Build video verification tab with enhanced UI
  Widget _buildVideoVerificationTab() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_selectedImage != null)
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: isLargeScreen ? 300 : 200,
                      height: isLargeScreen ? 300 : 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                            DesignSystem.borderRadiusMedium),
                        image: DecorationImage(
                          image: FileImage(_selectedImage!),
                          fit: BoxFit.cover,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 51),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                    ),
                    // Play button overlay
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 128),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ],
                )
              else
                Container(
                  width: isLargeScreen ? 300 : 200,
                  height: isLargeScreen ? 300 : 200,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(DesignSystem.borderRadiusMedium),
                    color: DesignSystem.primaryColor.withValues(alpha: 26),
                    border: Border.all(
                      color: DesignSystem.primaryColor.withValues(alpha: 77),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 26),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Security pattern background
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                            DesignSystem.borderRadiusMedium - 2),
                        child: CustomPaint(
                          painter: SecurityPatternPainter(
                            gridSpacing: 15,
                            gridColor:
                                DesignSystem.lightBlue.withValues(alpha: 51),
                          ),
                          size: Size(isLargeScreen ? 300 : 200,
                              isLargeScreen ? 300 : 200),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.videocam,
                            size: isLargeScreen ? 80 : 60,
                            color: DesignSystem.primaryColor,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Video Verification',
                            style: TextStyle(
                              color: DesignSystem.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: isLargeScreen ? 18 : 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              SizedBox(height: DesignSystem.adjustedSpacingLarge),
              Wrap(
                spacing: DesignSystem.adjustedSpacingMedium,
                runSpacing: DesignSystem.adjustedSpacingMedium,
                alignment: WrapAlignment.center,
                children: [
                  PlatformButton(
                    text: 'RECORD VIDEO',
                    onPressed: _captureVideo,
                    icon: Icons.videocam,
                    isFullWidth: false,
                  ),
                  PlatformButton(
                    text: 'SELECT VIDEO',
                    onPressed: _pickVideo,
                    icon: Icons.video_library,
                    buttonType: PlatformButtonType.secondary,
                    isFullWidth: false,
                  ),
                ],
              ),
              SizedBox(height: DesignSystem.adjustedSpacingMedium),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: DesignSystem.adjustedSpacingMedium,
                  vertical: DesignSystem.adjustedSpacingSmall,
                ),
                decoration: BoxDecoration(
                  color: DesignSystem.primaryColor.withValues(alpha: 26),
                  borderRadius:
                      BorderRadius.circular(DesignSystem.borderRadiusSmall),
                ),
                child: PlatformText(
                  'Record or select a video showing the face clearly for verification',
                  style: TextStyle(
                    color: DesignSystem.textSecondaryColor,
                    fontSize: DesignSystem.adjustedFontSizeSmall,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Build army number verification tab
  Widget _buildArmyNumberVerificationTab() {
    return Padding(
      padding: EdgeInsets.all(DesignSystem.adjustedSpacingLarge),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PlatformCard(
            child: Padding(
              padding: EdgeInsets.all(DesignSystem.adjustedSpacingMedium),
              child: Column(
                children: [
                  const Icon(
                    Icons.numbers,
                    size: 60,
                    color: DesignSystem.primaryColor,
                  ),
                  SizedBox(height: DesignSystem.adjustedSpacingMedium),
                  const PlatformText(
                    'Verify by Army Number',
                    isTitle: true,
                  ),
                  SizedBox(height: DesignSystem.adjustedSpacingLarge),
                  PlatformTextField(
                    controller: _armyNumberController,
                    label: 'Army Number',
                    prefixIcon: Icons.badge,
                    hint: 'e.g., N/12345 or 12NA/67/32451',
                  ),
                  SizedBox(height: DesignSystem.adjustedSpacingLarge),
                  PlatformButton(
                    text: 'VERIFY',
                    onPressed: _verifyByArmyNumber,
                    icon: Icons.search,
                    isFullWidth: true,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: DesignSystem.adjustedSpacingMedium),
          PlatformText(
            'Enter the army number to verify personnel',
            style: TextStyle(
              color: DesignSystem.textSecondaryColor,
              fontSize: DesignSystem.adjustedFontSizeSmall,
            ),
          ),
        ],
      ),
    );
  }

  // Build live recognition tab with enhanced functionality
  Widget _buildLiveRecognitionTab() {
    final personnelProvider = Provider.of<PersonnelProvider>(context);

    return Column(
      children: [
        // Camera preview with face detection
        Expanded(
          flex: 3,
          child: Padding(
            padding: EdgeInsets.all(DesignSystem.adjustedSpacingMedium),
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(DesignSystem.borderRadiusMedium),
              child: AdvancedCameraWidget(
                enableFaceTracking: true,
                showFaceTrackingOverlay: true,
                onFacesDetected: (faces) {
                  // Process detected faces
                  if (faces.isNotEmpty) {
                    // Auto-capture when a good face is detected
                    // This will trigger onPictureTaken
                  }
                },
                onPictureTaken: (imageFile) {
                  // Process the captured image for facial recognition
                  _processLiveRecognition(
                      File(imageFile.path), personnelProvider);
                },
              ),
            ),
          ),
        ),

        // Controls and status
        Padding(
          padding: EdgeInsets.all(DesignSystem.adjustedSpacingMedium),
          child: Column(
            children: [
              // Instructions
              Container(
                padding: EdgeInsets.all(DesignSystem.adjustedSpacingMedium),
                decoration: BoxDecoration(
                  color: DesignSystem.primaryColor.withValues(alpha: 26),
                  borderRadius:
                      BorderRadius.circular(DesignSystem.borderRadiusMedium),
                  border: Border.all(
                    color: DesignSystem.primaryColor.withValues(alpha: 51),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: DesignSystem.primaryColor,
                          size: 20,
                        ),
                        SizedBox(width: DesignSystem.adjustedSpacingSmall),
                        const Expanded(
                          child: Text(
                            'Live Recognition Instructions',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: DesignSystem.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: DesignSystem.adjustedSpacingSmall),
                    const Text(
                      '1. Position your face in the camera frame\n'
                      '2. Ensure good lighting and clear view\n'
                      '3. Hold still for best results\n'
                      '4. The system will automatically detect and verify your identity',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),

              SizedBox(height: DesignSystem.adjustedSpacingMedium),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: PlatformButton(
                      text: 'MANUAL CAPTURE',
                      onPressed: () {
                        // Manually trigger a photo capture
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Capturing image...'),
                            backgroundColor: Colors.blue,
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      icon: Icons.camera,
                      buttonType: PlatformButtonType.secondary,
                    ),
                  ),
                  SizedBox(width: DesignSystem.adjustedSpacingMedium),
                  Expanded(
                    child: PlatformButton(
                      text: 'ENHANCED MODE',
                      onPressed: () {
                        // Navigate to the dedicated live recognition screen
                        Navigator.pushNamed(context, '/live_recognition');
                      },
                      icon: Icons.face_retouching_natural,
                    ),
                  ),
                ],
              ),

              SizedBox(height: DesignSystem.adjustedSpacingMedium),

              // Sensitivity slider
              Row(
                children: [
                  const Text(
                    'Recognition Sensitivity:',
                    style: TextStyle(fontSize: 12),
                  ),
                  Expanded(
                    child: Slider(
                      value: 0.7, // Reduced sensitivity
                      min: 0.5,
                      max: 0.9,
                      divisions: 5,
                      label: 'Medium',
                      onChanged: (value) {
                        // Update sensitivity
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Process live recognition
  Future<void> _processLiveRecognition(
      File imageFile, PersonnelProvider personnelProvider) async {
    try {
      // Show processing indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Processing facial recognition...'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Get personnel list
      List<Personnel> personnelList = List.from(personnelProvider.allPersonnel);

      // Use enhanced facial recognition service
      final enhancedFacialRecognitionService =
          EnhancedFacialRecognitionService();
      await enhancedFacialRecognitionService.initialize();

      // Identify personnel
      final result = await enhancedFacialRecognitionService.identifyPersonnel(
        imageFile,
        personnelList,
      );

      // Extract personnel and confidence
      final Personnel? identifiedPersonnel =
          result != null ? result['personnel'] as Personnel : null;
      final double confidence =
          result != null ? result['confidence'] as double : 0.0;

      // Save image with metadata
      final savedImagePath =
          await enhancedFacialRecognitionService.saveImageWithMetadata(
        imageFile,
        identifiedPersonnel,
        {
          'captureMethod': 'live_recognition',
          'captureTime': DateTime.now().toIso8601String(),
          'deviceInfo': 'DBWFR App',
          'confidence': confidence.toString(),
          'recognitionMethod': 'enhanced_live',
          'adminInfo': await _getAdminInfo() ?? 'Unknown Admin',
        },
      );

      if (mounted) {
        // Navigate to result screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PersonnelIdentificationResultScreen(
              capturedImage: imageFile,
              identifiedPersonnel: identifiedPersonnel,
              savedImagePath: savedImagePath,
              confidence: confidence,
              isLiveCapture: true,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error in live facial recognition: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Build personnel database tab
  Widget _buildPersonnelDatabaseTab() {
    final personnelProvider = Provider.of<PersonnelProvider>(context);
    final personnel = personnelProvider.filteredPersonnel.isEmpty &&
            _searchController.text.isEmpty
        ? personnelProvider.allPersonnel
        : personnelProvider.filteredPersonnel;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(DesignSystem.adjustedSpacingMedium),
          child: Column(
            children: [
              PlatformTextField(
                controller: _searchController,
                label: 'Search Personnel',
                prefixIcon: Icons.search,
                hint: 'Search by name, rank, unit, or army number',
                onChanged: (value) {
                  personnelProvider.setSearchQuery(value);
                },
              ),
              SizedBox(height: DesignSystem.adjustedSpacingMedium),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCategoryFilterChip(
                      label: 'All',
                      isSelected: personnelProvider.selectedCategory == null,
                      onSelected: (_) {
                        personnelProvider.setSelectedCategory(null);
                      },
                    ),
                    SizedBox(width: DesignSystem.adjustedSpacingSmall),
                    _buildCategoryFilterChip(
                      label: 'Officers (Male)',
                      isSelected: personnelProvider.selectedCategory ==
                          PersonnelCategory.officerMale,
                      onSelected: (_) {
                        personnelProvider
                            .setSelectedCategory(PersonnelCategory.officerMale);
                      },
                    ),
                    SizedBox(width: DesignSystem.adjustedSpacingSmall),
                    _buildCategoryFilterChip(
                      label: 'Officers (Female)',
                      isSelected: personnelProvider.selectedCategory ==
                          PersonnelCategory.officerFemale,
                      onSelected: (_) {
                        personnelProvider.setSelectedCategory(
                            PersonnelCategory.officerFemale);
                      },
                    ),
                    SizedBox(width: DesignSystem.adjustedSpacingSmall),
                    _buildCategoryFilterChip(
                      label: 'Soldiers (Male)',
                      isSelected: personnelProvider.selectedCategory ==
                          PersonnelCategory.soldierMale,
                      onSelected: (_) {
                        personnelProvider
                            .setSelectedCategory(PersonnelCategory.soldierMale);
                      },
                    ),
                    SizedBox(width: DesignSystem.adjustedSpacingSmall),
                    _buildCategoryFilterChip(
                      label: 'Soldiers (Female)',
                      isSelected: personnelProvider.selectedCategory ==
                          PersonnelCategory.soldierFemale,
                      onSelected: (_) {
                        personnelProvider.setSelectedCategory(
                            PersonnelCategory.soldierFemale);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: personnelProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : personnel.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.person_off,
                            size: 60,
                            color: DesignSystem.textSecondaryColor,
                          ),
                          SizedBox(height: DesignSystem.adjustedSpacingMedium),
                          PlatformText(
                            'No personnel found',
                            style: TextStyle(
                              color: DesignSystem.textSecondaryColor,
                              fontSize: DesignSystem.adjustedFontSizeMedium,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: personnel.length,
                      itemBuilder: (context, index) {
                        final person = personnel[index];
                        return _buildPersonnelListItem(person);
                      },
                    ),
        ),
        Padding(
          padding: EdgeInsets.all(DesignSystem.adjustedSpacingMedium),
          child: PlatformButton(
            text: 'REGISTER NEW PERSONNEL',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PersonnelRegistrationScreen(),
                ),
              );
            },
            icon: Icons.person_add,
            isFullWidth: true,
          ),
        ),
      ],
    );
  }

  // Build category filter chip
  Widget _buildCategoryFilterChip({
    required String label,
    required bool isSelected,
    required Function(bool) onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      backgroundColor: Colors.white,
      selectedColor: DesignSystem.primaryColor.withValues(alpha: 51),
      checkmarkColor: DesignSystem.primaryColor,
      labelStyle: TextStyle(
        color: isSelected
            ? DesignSystem.primaryColor
            : DesignSystem.textPrimaryColor,
        fontWeight: isSelected
            ? DesignSystem.fontWeightBold
            : DesignSystem.fontWeightRegular,
      ),
    );
  }

  // Build personnel list item
  Widget _buildPersonnelListItem(Personnel personnel) {
    return PlatformCard(
      margin: EdgeInsets.symmetric(
        horizontal: DesignSystem.adjustedSpacingMedium,
        vertical: DesignSystem.adjustedSpacingSmall,
      ),
      onTap: () {
        final personnelProvider =
            Provider.of<PersonnelProvider>(context, listen: false);
        personnelProvider.setSelectedPersonnel(personnel);
        _showPersonnelDetailsDialog(personnel);
      },
      child: Padding(
        padding: EdgeInsets.all(DesignSystem.adjustedSpacingMedium),
        child: Row(
          children: [
            if (personnel.photoUrl != null)
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: FileImage(File(personnel.photoUrl!)),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: DesignSystem.primaryColor.withValues(alpha: 26),
                ),
                child: const Icon(
                  Icons.person,
                  size: 30,
                  color: DesignSystem.primaryColor,
                ),
              ),
            SizedBox(width: DesignSystem.adjustedSpacingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${personnel.rank.shortName} ${personnel.initials}',
                    style: TextStyle(
                      fontWeight: DesignSystem.fontWeightBold,
                      fontSize: DesignSystem.adjustedFontSizeMedium,
                    ),
                  ),
                  SizedBox(height: DesignSystem.adjustedSpacingSmall / 2),
                  Text(
                    personnel.fullName,
                    style: TextStyle(
                      color: DesignSystem.textSecondaryColor,
                      fontSize: DesignSystem.adjustedFontSizeSmall,
                    ),
                  ),
                  Text(
                    'Unit: ${personnel.unit}',
                    style: TextStyle(
                      color: DesignSystem.textSecondaryColor,
                      fontSize: DesignSystem.adjustedFontSizeSmall,
                    ),
                  ),
                  SizedBox(height: DesignSystem.adjustedSpacingSmall / 2),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: DesignSystem.adjustedSpacingSmall,
                          vertical: DesignSystem.adjustedSpacingSmall / 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getServiceStatusColor(personnel.serviceStatus)
                              .withValues(alpha: 26),
                          borderRadius: BorderRadius.circular(
                              DesignSystem.borderRadiusSmall),
                        ),
                        child: Text(
                          _getServiceStatusText(personnel.serviceStatus),
                          style: TextStyle(
                            color:
                                _getServiceStatusColor(personnel.serviceStatus),
                            fontSize: DesignSystem.adjustedFontSizeSmall * 0.9,
                            fontWeight: DesignSystem.fontWeightMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: DesignSystem.adjustedSpacingSmall / 2),
                  Text(
                    personnel.armyNumber,
                    style: TextStyle(
                      color: DesignSystem.primaryColor,
                      fontWeight: DesignSystem.fontWeightMedium,
                      fontSize: DesignSystem.adjustedFontSizeSmall,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: DesignSystem.adjustedSpacingSmall),
            _buildStatusIndicator(personnel.status),
          ],
        ),
      ),
    );
  }

  // Build status indicator
  Widget _buildStatusIndicator(VerificationStatus status) {
    Color color;
    IconData icon;
    String tooltip;

    switch (status) {
      case VerificationStatus.pending:
        color = Colors.orange;
        icon = Icons.pending;
        tooltip = 'Pending Verification';
        break;
      case VerificationStatus.verified:
        color = Colors.green;
        icon = Icons.verified_user;
        tooltip = 'Verified';
        break;
      case VerificationStatus.rejected:
        color = Colors.red;
        icon = Icons.cancel;
        tooltip = 'Rejected';
        break;
    }

    return Tooltip(
      message: tooltip,
      child: Container(
        padding: EdgeInsets.all(DesignSystem.adjustedSpacingSmall),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 26),
        ),
        child: Icon(
          icon,
          color: color,
          size: 24,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: AppBar(
        title: const Text('Facial Verification'),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? DesignSystem.darkAppBarColor
            : DesignSystem.lightAppBarColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      drawer: const CustomDrawer(),
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            _buildCameraVerificationTab(),
            _buildPhotoVerificationTab(),
            _buildVideoVerificationTab(),
            _buildArmyNumberVerificationTab(),
            _buildLiveRecognitionTab(),
            _buildPersonnelDatabaseTab(),
          ],
        ),
      ),
      bottomNavigationBar: FancyBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 5) {
            // Database tab
            // Navigate directly to personnel database screen
            Navigator.of(context).pushNamed('/personnel_database');
            return;
          }
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: DesignSystem.primaryColor,
        activeColor: DesignSystem.accentColor,
        inactiveColor: Colors.white.withAlpha(180),
        height: 75.0,
        iconSize: 22.0,
        activeIconSize: 28.0,
        fontSize: 11.0,
        activeFontSize: 13.0,
        items: const [
          FancyBottomNavItem(
            icon: Icons.camera_alt,
            label: 'Camera',
          ),
          FancyBottomNavItem(
            icon: Icons.photo,
            label: 'Photo',
          ),
          FancyBottomNavItem(
            icon: Icons.videocam,
            label: 'Video',
          ),
          FancyBottomNavItem(
            icon: Icons.numbers,
            label: 'Army No.',
          ),
          FancyBottomNavItem(
            icon: Icons.face_retouching_natural,
            label: 'Live Scan',
          ),
          FancyBottomNavItem(
            icon: Icons.people,
            label: 'Database',
          ),
        ],
      ),
    );
  }
}
