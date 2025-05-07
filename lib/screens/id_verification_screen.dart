import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:provider/provider.dart';
import '../config/design_system.dart';
import '../models/personnel_model.dart';
import '../providers/personnel_provider.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/advanced_camera_widget.dart';

class IDVerificationScreen extends StatefulWidget {
  static const String routeName = '/id_verification';

  const IDVerificationScreen({Key? key}) : super(key: key);

  @override
  State<IDVerificationScreen> createState() => _IDVerificationScreenState();
}

class _IDVerificationScreenState extends State<IDVerificationScreen> {
  final TextRecognizer _textRecognizer = TextRecognizer();
  bool _isProcessing = false;
  bool _showCamera = true;
  File? _capturedImage;
  Map<String, String>? _extractedData;
  Personnel? _matchedPersonnel;
  double _matchConfidence = 0.0;
  String? _errorMessage;

  @override
  void dispose() {
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ID Card Verification'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetVerification,
            tooltip: 'Reset',
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(DesignSystem.adjustedSpacingSmall),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Instructions or camera preview
              Expanded(
                flex: 3,
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(DesignSystem.borderRadiusMedium),
                  ),
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(DesignSystem.borderRadiusMedium),
                    child: _showCamera
                        ? _buildCameraPreview()
                        : _buildCapturedImagePreview(),
                  ),
                ),
              ),

              SizedBox(height: DesignSystem.adjustedSpacingSmall),

              // Results or controls
              Expanded(
                flex: 2,
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(DesignSystem.borderRadiusMedium),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(DesignSystem.adjustedSpacingSmall),
                    child: _isProcessing
                        ? _buildProcessingView()
                        : _matchedPersonnel != null
                            ? _buildMatchResultView()
                            : _extractedData != null
                                ? _buildExtractedDataView()
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

  Widget _buildCameraPreview() {
    return Stack(
      children: [
        AdvancedCameraWidget(
          enableFaceTracking: false,
          showFaceTrackingOverlay: false,
          onPictureTaken: (imageFile) {
            if (!_isProcessing) {
              _processIDCard(File(imageFile.path));
            }
          },
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white,
                width: 2.0,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Center(
            child: Text(
              'Position ID card within the frame',
              style: TextStyle(
                color: Colors.white,
                backgroundColor: Colors.black54,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCapturedImagePreview() {
    return Stack(
      children: [
        if (_capturedImage != null)
          Image.file(
            _capturedImage!,
            fit: BoxFit.contain,
            width: double.infinity,
            height: double.infinity,
          ),
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Center(
            child: ElevatedButton.icon(
              onPressed: _resetVerification,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Scan Another ID'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProcessingView() {
    return const Center(
      child: LoadingIndicator(
        message: 'Processing ID card...',
      ),
    );
  }

  Widget _buildInstructionsView() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.credit_card,
            size: 48,
            color: DesignSystem.primaryColor,
          ),
          const SizedBox(height: 16),
          const Text(
            'Nigerian Army ID Card Verification',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Position the ID card within the frame and ensure all details are clearly visible.',
            style: TextStyle(
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              // This is handled by the camera widget
            },
            icon: const Icon(Icons.camera_alt),
            label: const Text('Capture ID Card'),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExtractedDataView() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Extracted ID Card Data',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ..._extractedData!.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${entry.key}: ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Text(entry.value),
                  ),
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _verifyIDWithDatabase,
                icon: const Icon(Icons.verified_user),
                label: const Text('Verify ID'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
              OutlinedButton.icon(
                onPressed: _resetVerification,
                icon: const Icon(Icons.refresh),
                label: const Text('Rescan'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMatchResultView() {
    // Determine verification status based on confidence
    bool isConfidentMatch = _matchConfidence >= 0.85;
    bool isPossibleMatch = _matchConfidence >= 0.70 && _matchConfidence < 0.85;
    bool isNoMatch = _matchConfidence < 0.70;

    // Determine status color and icon
    Color statusColor;
    IconData statusIcon;

    if (isConfidentMatch) {
      statusColor = Colors.green;
      statusIcon = Icons.verified_user;
    } else if (isPossibleMatch) {
      statusColor = Colors.orange;
      statusIcon = Icons.help_outline;
    } else {
      statusColor = Colors.red;
      statusIcon = Icons.cancel_outlined;
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                statusIcon,
                color: statusColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isConfidentMatch
                      ? 'ID Verified Successfully'
                      : isPossibleMatch
                          ? 'Possible ID Match'
                          : 'ID Verification Failed',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_matchedPersonnel != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Personnel photo
                if (_matchedPersonnel!.photoUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(_matchedPersonnel!.photoUrl!),
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  )
                else
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
                const SizedBox(width: 16),
                // Personnel details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_matchedPersonnel!.rank.shortName} ${_matchedPersonnel!.fullName}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Army Number: ${_matchedPersonnel!.armyNumber}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Unit: ${_matchedPersonnel!.unit}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Corps: ${_matchedPersonnel!.corps.displayName}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Match Confidence: ${(_matchConfidence * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 14,
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isPossibleMatch || isNoMatch)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  isNoMatch
                      ? 'ID details do not match any personnel record.'
                      : 'Some ID details match but verification is not confident.',
                  style: TextStyle(
                    fontSize: 12,
                    color: statusColor,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                onPressed: _resetVerification,
                icon: const Icon(Icons.refresh),
                label: const Text('Verify Another ID'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _processIDCard(File imageFile) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _showCamera = false;
      _capturedImage = imageFile;
      _extractedData = null;
      _matchedPersonnel = null;
      _matchConfidence = 0.0;
      _errorMessage = null;
    });

    try {
      // Process the image with ML Kit Text Recognition
      final inputImage = InputImage.fromFile(imageFile);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      // Extract relevant information from the recognized text
      final extractedData = _extractIDCardData(recognizedText.text);

      setState(() {
        _isProcessing = false;
        _extractedData = extractedData;
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _errorMessage = 'Error processing ID card: $e';
      });
    }
  }

  Map<String, String> _extractIDCardData(String text) {
    // Initialize the data map
    Map<String, String> data = {};

    // Convert text to lowercase for case-insensitive matching
    final lowerText = text.toLowerCase();

    // Extract Army Number (P/No)
    final armyNumberRegex =
        RegExp(r'p/no[:\s]*([a-zA-Z0-9/-]+)', caseSensitive: false);
    final armyNumberMatch = armyNumberRegex.firstMatch(lowerText);
    if (armyNumberMatch != null && armyNumberMatch.groupCount >= 1) {
      data['Army Number'] = armyNumberMatch.group(1)!.trim().toUpperCase();
    }

    // Extract Rank and Name
    final rankNameRegex =
        RegExp(r'rank[:\s]*(.*?)(?=blood|p/no|dob|$)', caseSensitive: false);
    final rankNameMatch = rankNameRegex.firstMatch(lowerText);
    if (rankNameMatch != null && rankNameMatch.groupCount >= 1) {
      final rankNameText = rankNameMatch.group(1)!.trim();

      // Try to separate rank from name
      final rankParts = rankNameText.split(' ');
      if (rankParts.length > 1) {
        data['Rank'] = rankParts[0].toUpperCase();
        data['Name'] = rankParts.sublist(1).join(' ').toUpperCase();
      } else {
        data['Rank/Name'] = rankNameText.toUpperCase();
      }
    }

    // Extract Blood Group
    final bloodGroupRegex =
        RegExp(r'blood[:\s]*([a-z0-9+\-]+)', caseSensitive: false);
    final bloodGroupMatch = bloodGroupRegex.firstMatch(lowerText);
    if (bloodGroupMatch != null && bloodGroupMatch.groupCount >= 1) {
      data['Blood Group'] = bloodGroupMatch.group(1)!.trim().toUpperCase();
    }

    // Extract Date of Birth
    final dobRegex = RegExp(r'dob[:\s]*(\d{1,2}[-/\.]\d{1,2}[-/\.]\d{2,4})',
        caseSensitive: false);
    final dobMatch = dobRegex.firstMatch(lowerText);
    if (dobMatch != null && dobMatch.groupCount >= 1) {
      data['Date of Birth'] = dobMatch.group(1)!.trim();
    }

    // Extract Issuance Date
    final issuanceRegex = RegExp(
        r'issued[:\s]*(\d{1,2}[-/\.]\d{1,2}[-/\.]\d{2,4})',
        caseSensitive: false);
    final issuanceMatch = issuanceRegex.firstMatch(lowerText);
    if (issuanceMatch != null && issuanceMatch.groupCount >= 1) {
      data['Issued'] = issuanceMatch.group(1)!.trim();
    }

    // Extract Expiry Date
    final expiryRegex = RegExp(
        r'expires[:\s]*(\d{1,2}[-/\.]\d{1,2}[-/\.]\d{2,4})',
        caseSensitive: false);
    final expiryMatch = expiryRegex.firstMatch(lowerText);
    if (expiryMatch != null && expiryMatch.groupCount >= 1) {
      data['Expires'] = expiryMatch.group(1)!.trim();
    }

    // Extract Serial Number
    final serialRegex =
        RegExp(r'serial[:\s]*([a-zA-Z0-9]+)', caseSensitive: false);
    final serialMatch = serialRegex.firstMatch(lowerText);
    if (serialMatch != null && serialMatch.groupCount >= 1) {
      data['Serial No'] = serialMatch.group(1)!.trim().toUpperCase();
    }

    return data;
  }

  void _verifyIDWithDatabase() async {
    if (_extractedData == null || _extractedData!.isEmpty) {
      setState(() {
        _errorMessage = 'No data extracted from ID card';
      });
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final personnelProvider =
          Provider.of<PersonnelProvider>(context, listen: false);
      final allPersonnel = personnelProvider.allPersonnel;

      // Find matching personnel based on Army Number
      Personnel? matchedPersonnel;
      double highestConfidence = 0.0;

      if (_extractedData!.containsKey('Army Number')) {
        final idArmyNumber = _extractedData!['Army Number']!;

        // Look for exact match by army number
        for (final personnel in allPersonnel) {
          if (personnel.armyNumber.toUpperCase() == idArmyNumber) {
            matchedPersonnel = personnel;
            highestConfidence = 1.0;
            break;
          }
        }

        // If no exact match, look for partial matches
        if (matchedPersonnel == null) {
          for (final personnel in allPersonnel) {
            // Calculate similarity between ID army number and personnel army number
            final similarity = _calculateStringSimilarity(
              personnel.armyNumber.toUpperCase(),
              idArmyNumber,
            );

            if (similarity > highestConfidence && similarity > 0.7) {
              matchedPersonnel = personnel;
              highestConfidence = similarity;
            }
          }
        }
      }

      setState(() {
        _isProcessing = false;
        _matchedPersonnel = matchedPersonnel;
        _matchConfidence = highestConfidence;
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _errorMessage = 'Error verifying ID: $e';
      });
    }
  }

  double _calculateStringSimilarity(String s1, String s2) {
    if (s1 == s2) return 1.0;
    if (s1.isEmpty || s2.isEmpty) return 0.0;

    // Calculate Levenshtein distance
    final int len1 = s1.length;
    final int len2 = s2.length;
    final List<List<int>> d =
        List.generate(len1 + 1, (i) => List.generate(len2 + 1, (j) => 0));

    for (int i = 0; i <= len1; i++) {
      d[i][0] = i;
    }

    for (int j = 0; j <= len2; j++) {
      d[0][j] = j;
    }

    for (int i = 1; i <= len1; i++) {
      for (int j = 1; j <= len2; j++) {
        final int cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        d[i][j] = [
          d[i - 1][j] + 1, // deletion
          d[i][j - 1] + 1, // insertion
          d[i - 1][j - 1] + cost // substitution
        ].reduce((curr, next) => curr < next ? curr : next);
      }
    }

    // Convert distance to similarity score (0 to 1)
    final int maxLen = len1 > len2 ? len1 : len2;
    return 1.0 - (d[len1][len2] / maxLen);
  }

  void _resetVerification() {
    setState(() {
      _showCamera = true;
      _capturedImage = null;
      _extractedData = null;
      _matchedPersonnel = null;
      _matchConfidence = 0.0;
      _errorMessage = null;
    });
  }
}
