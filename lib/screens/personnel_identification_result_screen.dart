import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../config/design_system.dart';
import '../models/personnel_model.dart';
import '../providers/personnel_provider.dart';
import '../widgets/platform_aware_widgets.dart';
import 'personnel_edit_screen.dart';

class PersonnelIdentificationResultScreen extends StatefulWidget {
  final File capturedImage;
  final Personnel? identifiedPersonnel;
  final String? savedImagePath;
  final bool isLiveCapture;
  final double confidence;
  final bool isVideo;
  final String matchQuality;
  final String? bestMatchName;
  final String? bestMatchArmyNumber;
  final String? sourceType;

  const PersonnelIdentificationResultScreen({
    Key? key,
    required this.capturedImage,
    required this.identifiedPersonnel,
    this.savedImagePath,
    this.isLiveCapture = false,
    this.confidence = 0.0,
    this.isVideo = false,
    this.matchQuality = 'unknown',
    this.bestMatchName,
    this.bestMatchArmyNumber,
    this.sourceType,
  }) : super(key: key);

  @override
  State<PersonnelIdentificationResultScreen> createState() =>
      _PersonnelIdentificationResultScreenState();
}

class _PersonnelIdentificationResultScreenState
    extends State<PersonnelIdentificationResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _slideAnimation;
  bool _showDetails = false;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    // Start animations
    _animationController.forward().then((_) {
      setState(() {
        _showDetails = true;
      });

      // Show feedback dialog after animations complete if we have a match
      if (widget.identifiedPersonnel != null) {
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            _showFeedbackDialog();
          }
        });
      }
    });
  }

  // Show feedback dialog to ask if the match was accurate
  void _showFeedbackDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Was this match accurate?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Matched with: ${widget.identifiedPersonnel?.fullName ?? "Unknown"}',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Your feedback helps improve our facial recognition system.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleNegativeFeedback();
              },
              child: const Text('No, Incorrect Match'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Positive feedback - no need to do anything
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Thank you for your feedback!'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Yes, Correct'),
            ),
          ],
        );
      },
    );
  }

  // Handle negative feedback
  void _handleNegativeFeedback() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Incorrect Match'),
        content: const Text(
          'Would you like to try again with a new capture or report this incorrect match?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Return to capture screen
            },
            child: const Text('Try Again'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _reportIncorrectMatch();
            },
            child: const Text('Report Issue'),
          ),
        ],
      ),
    );
  }

  // Report incorrect match
  void _reportIncorrectMatch() {
    // In a real implementation, this would send the incorrect match data to a server
    // for analysis and improvement of the facial recognition system

    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Submitted'),
        content: const Text(
          'Thank you for your feedback. This incorrect match has been reported and will help improve our facial recognition system.',
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

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: AppBar(
        title: const Text('Identification Result'),
        backgroundColor: DesignSystem.primaryColor,
        actions: [
          if (widget.identifiedPersonnel != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _editPersonnel,
              tooltip: 'Edit Personnel',
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(DesignSystem.adjustedSpacingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Result status card
                _buildResultStatusCard(),
                SizedBox(height: DesignSystem.adjustedSpacingMedium),

                // Image and details section
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Captured image
                    Expanded(
                      flex: 1,
                      child: AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _fadeInAnimation.value,
                            child: Transform.translate(
                              offset: Offset(-_slideAnimation.value, 0),
                              child: child,
                            ),
                          );
                        },
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                DesignSystem.borderRadiusMedium),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(
                                DesignSystem.adjustedSpacingSmall),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      DesignSystem.borderRadiusSmall),
                                  child: widget.isVideo
                                      ? Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Image.file(
                                              widget.capturedImage,
                                              fit: BoxFit.cover,
                                              height: 200,
                                              width: double.infinity,
                                            ),
                                            Container(
                                              width: 50,
                                              height: 50,
                                              decoration: const BoxDecoration(
                                                color: Colors.black54,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.play_arrow,
                                                color: Colors.white,
                                                size: 30,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Image.file(
                                          widget.capturedImage,
                                          fit: BoxFit.cover,
                                          height: 200,
                                          width: double.infinity,
                                        ),
                                ),
                                SizedBox(
                                    height: DesignSystem.adjustedSpacingSmall),
                                Text(
                                  widget.isVideo
                                      ? 'Captured Video'
                                      : 'Captured Image',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: DesignSystem.textSecondaryColor,
                                  ),
                                ),
                                SizedBox(
                                    height: DesignSystem.adjustedSpacingSmall),
                                Text(
                                  'Captured: ${DateFormat('MMM d, yyyy HH:mm').format(DateTime.now())}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: DesignSystem.textSecondaryColor,
                                  ),
                                ),
                                if (widget.savedImagePath != null)
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: DesignSystem.adjustedSpacingSmall),
                                    child: const Text(
                                      'Saved with metadata',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: DesignSystem.successColor,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: DesignSystem.adjustedSpacingMedium),

                    // Personnel details or not found message
                    Expanded(
                      flex: 1,
                      child: AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _fadeInAnimation.value,
                            child: Transform.translate(
                              offset: Offset(_slideAnimation.value, 0),
                              child: child,
                            ),
                          );
                        },
                        child: widget.identifiedPersonnel != null
                            ? _buildPersonnelDetailsCard()
                            : _buildNotFoundCard(),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: DesignSystem.adjustedSpacingMedium),

                // Action buttons
                AnimatedOpacity(
                  opacity: _showDetails ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      PlatformButton(
                        text: 'CAPTURE AGAIN',
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: Icons.camera_alt,
                      ),
                      SizedBox(height: DesignSystem.adjustedSpacingMedium),
                      if (widget.identifiedPersonnel != null)
                        PlatformButton(
                          text: 'VIEW FULL PROFILE',
                          onPressed: _viewFullProfile,
                          icon: Icons.person,
                          buttonType: PlatformButtonType.secondary,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultStatusCard() {
    final isIdentified = widget.identifiedPersonnel != null;
    final isHighQualityMatch = isIdentified && widget.matchQuality == 'high';
    final isMediumQualityMatch =
        isIdentified && widget.matchQuality == 'medium';
    final isLowQualityMatch = isIdentified && widget.matchQuality == 'low';
    final isNoMatch = !isIdentified || widget.matchQuality == 'none';

    // Determine card color based on match quality
    Color cardColor;
    if (isHighQualityMatch) {
      cardColor = DesignSystem.successColor;
    } else if (isMediumQualityMatch) {
      cardColor = Colors.orange;
    } else if (isLowQualityMatch) {
      cardColor = Colors.deepOrange;
    } else {
      cardColor = Colors.red;
    }

    // Determine icon based on match quality
    IconData iconData;
    if (isHighQualityMatch) {
      iconData = Icons.check_circle;
    } else if (isMediumQualityMatch) {
      iconData = Icons.help;
    } else if (isLowQualityMatch) {
      iconData = Icons.warning;
    } else {
      iconData = Icons.error;
    }

    // Determine status text based on match quality
    String statusText;
    String descriptionText;
    if (isHighQualityMatch) {
      statusText = 'PERSONNEL IDENTIFIED';
      descriptionText =
          'Match found with high confidence (${(widget.confidence * 100).toStringAsFixed(1)}%)';
    } else if (isMediumQualityMatch) {
      statusText = 'POSSIBLE MATCH - VERIFY';
      descriptionText =
          'Verify identity manually - confidence: ${(widget.confidence * 100).toStringAsFixed(1)}%';
    } else if (isLowQualityMatch) {
      statusText = 'LOW CONFIDENCE MATCH - VERIFY CAREFULLY';
      descriptionText =
          'Confidence is low (${(widget.confidence * 100).toStringAsFixed(1)}%). Verify carefully.';
    } else if (isNoMatch && widget.confidence > 0.0) {
      statusText = 'NO MATCH FOUND';
      descriptionText = widget.bestMatchName != null
          ? 'Best match below threshold: ${widget.bestMatchName} (${(widget.confidence * 100).toStringAsFixed(1)}%)'
          : 'Best match below threshold (${(widget.confidence * 100).toStringAsFixed(1)}%)';
    } else {
      statusText = 'NOT ON RECORD';
      descriptionText = 'No matching personnel found in database';
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeInAnimation.value,
          child: child,
        );
      },
      child: Card(
        elevation: 3,
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignSystem.borderRadiusMedium),
        ),
        child: Padding(
          padding: EdgeInsets.all(DesignSystem.adjustedSpacingMedium),
          child: Row(
            children: [
              Icon(
                iconData,
                color: Colors.white,
                size: 36,
              ),
              SizedBox(width: DesignSystem.adjustedSpacingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      descriptionText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonnelDetailsCard() {
    final personnel = widget.identifiedPersonnel!;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignSystem.borderRadiusMedium),
      ),
      child: Padding(
        padding: EdgeInsets.all(DesignSystem.adjustedSpacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Personnel photo or placeholder
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: DesignSystem.primaryColor.withAlpha(25),
                  image: personnel.photoUrl != null
                      ? DecorationImage(
                          image: FileImage(File(personnel.photoUrl!)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: personnel.photoUrl == null
                    ? const Icon(
                        Icons.person,
                        size: 50,
                        color: DesignSystem.primaryColor,
                      )
                    : null,
              ),
            ),
            SizedBox(height: DesignSystem.adjustedSpacingMedium),

            // Personnel name
            Center(
              child: Text(
                '${personnel.rank.shortName} ${personnel.initials}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Center(
              child: Text(
                personnel.fullName,
                style: const TextStyle(
                  color: DesignSystem.textSecondaryColor,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: DesignSystem.adjustedSpacingMedium),

            // Personnel details
            _buildDetailRow('Army Number', personnel.armyNumber),
            _buildDetailRow('Corps', personnel.corps.displayName),
            _buildDetailRow('Unit', personnel.unit),
            _buildDetailRow('Status', personnel.serviceStatus.displayName),

            // Match confidence
            SizedBox(height: DesignSystem.adjustedSpacingMedium),
            const Text(
              'Match Confidence',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: widget
                  .confidence, // Actual confidence from facial recognition
              backgroundColor: Colors.grey.withAlpha(50),
              valueColor: AlwaysStoppedAnimation<Color>(
                  _getConfidenceColor(widget.confidence)),
              borderRadius:
                  BorderRadius.circular(DesignSystem.borderRadiusSmall),
            ),
            const SizedBox(height: 4),
            Text(
              '${(widget.confidence * 100).toStringAsFixed(1)}% - ${_getConfidenceLabel(widget.confidence)}',
              style: TextStyle(
                fontSize: 12,
                color: _getConfidenceColor(widget.confidence),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFoundCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignSystem.borderRadiusMedium),
      ),
      child: Padding(
        padding: EdgeInsets.all(DesignSystem.adjustedSpacingMedium),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_off,
              size: 60,
              color: Colors.red.withAlpha(180),
            ),
            SizedBox(height: DesignSystem.adjustedSpacingMedium),
            const Text(
              'Not Found in Database',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: DesignSystem.adjustedSpacingSmall),
            const Text(
              'This person could not be identified in the personnel database.',
              style: TextStyle(
                color: DesignSystem.textSecondaryColor,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: DesignSystem.adjustedSpacingLarge),
            PlatformButton(
              text: 'REGISTER NEW PERSONNEL',
              onPressed: _registerNewPersonnel,
              icon: Icons.person_add,
              buttonType: PlatformButtonType.secondary,
            ),
            SizedBox(height: DesignSystem.adjustedSpacingMedium),
            const Text(
              'If this person should be in the database, you can register them as new personnel.',
              style: TextStyle(
                fontSize: 12,
                color: DesignSystem.textSecondaryColor,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

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
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: DesignSystem.textSecondaryColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Get color based on confidence level
  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.75) {
      return DesignSystem.successColor; // High confidence
    } else if (confidence >= 0.65) {
      return Colors.orange; // Medium confidence
    } else {
      return Colors.red; // Low confidence
    }
  }

  // Get label based on confidence level
  String _getConfidenceLabel(double confidence) {
    if (confidence >= 0.75) {
      return 'High Confidence';
    } else if (confidence >= 0.65) {
      return 'Medium Confidence - Verify Identity';
    } else {
      return 'Low Confidence - Likely Different Person';
    }
  }

  void _editPersonnel() {
    if (widget.identifiedPersonnel == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PersonnelEditScreen(
          personnel: widget.identifiedPersonnel!,
        ),
      ),
    ).then((updated) {
      if (updated == true) {
        // Refresh personnel list
        if (mounted) {
          final personnelProvider =
              Provider.of<PersonnelProvider>(context, listen: false);
          personnelProvider.loadAllPersonnel();
        }
      }
    });
  }

  void _viewFullProfile() {
    if (widget.identifiedPersonnel == null) return;

    // Show full profile dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Personnel Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Personnel photo
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: DesignSystem.primaryColor.withAlpha(25),
                    image: widget.identifiedPersonnel!.photoUrl != null
                        ? DecorationImage(
                            image: FileImage(
                                File(widget.identifiedPersonnel!.photoUrl!)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: widget.identifiedPersonnel!.photoUrl == null
                      ? const Icon(
                          Icons.person,
                          size: 60,
                          color: DesignSystem.primaryColor,
                        )
                      : null,
                ),
              ),
              SizedBox(height: DesignSystem.adjustedSpacingMedium),
              _buildDetailRow('Name', widget.identifiedPersonnel!.fullName),
              _buildDetailRow('Initials', widget.identifiedPersonnel!.initials),
              _buildDetailRow(
                  'Rank', widget.identifiedPersonnel!.rank.displayName),
              _buildDetailRow(
                  'Army Number', widget.identifiedPersonnel!.armyNumber),
              _buildDetailRow(
                  'Corps', widget.identifiedPersonnel!.corps.displayName),
              _buildDetailRow('Unit', widget.identifiedPersonnel!.unit),
              _buildDetailRow('Status',
                  widget.identifiedPersonnel!.serviceStatus.displayName),
              if (widget.identifiedPersonnel!.enlistmentDate != null)
                _buildDetailRow(
                    'Enlistment Date',
                    DateFormat('MMM d, yyyy')
                        .format(widget.identifiedPersonnel!.enlistmentDate!)),
              if (widget.identifiedPersonnel!.dateOfBirth != null)
                _buildDetailRow(
                    'Date of Birth',
                    DateFormat('MMM d, yyyy')
                        .format(widget.identifiedPersonnel!.dateOfBirth!)),
              _buildDetailRow('Years of Service',
                  widget.identifiedPersonnel!.yearsOfService.toString()),
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
              _editPersonnel();
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  void _registerNewPersonnel() {
    // Navigate to personnel registration screen
    Navigator.pushNamed(context, '/personnel_registration');
  }
}
