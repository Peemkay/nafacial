import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../config/design_system.dart';
import '../models/personnel_model.dart';
import '../providers/personnel_provider.dart';
import '../services/facial_recognition_service.dart';
import '../widgets/platform_aware_widgets.dart';
import 'personnel_edit_screen.dart';

class PersonnelIdentificationResultScreen extends StatefulWidget {
  final File capturedImage;
  final Personnel? identifiedPersonnel;
  final String? savedImagePath;
  final bool isLiveCapture;
  final double confidence;

  const PersonnelIdentificationResultScreen({
    Key? key,
    required this.capturedImage,
    required this.identifiedPersonnel,
    this.savedImagePath,
    this.isLiveCapture = false,
    this.confidence = 0.0,
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
    });
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
                                  child: Image.file(
                                    widget.capturedImage,
                                    fit: BoxFit.cover,
                                    height: 200,
                                    width: double.infinity,
                                  ),
                                ),
                                SizedBox(
                                    height: DesignSystem.adjustedSpacingSmall),
                                Text(
                                  'Captured Image',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: DesignSystem.textSecondaryColor,
                                  ),
                                ),
                                SizedBox(
                                    height: DesignSystem.adjustedSpacingSmall),
                                Text(
                                  'Captured: ${DateFormat('MMM d, yyyy HH:mm').format(DateTime.now())}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: DesignSystem.textSecondaryColor,
                                  ),
                                ),
                                if (widget.savedImagePath != null)
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: DesignSystem.adjustedSpacingSmall),
                                    child: Text(
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
        color: isIdentified ? DesignSystem.successColor : Colors.red,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignSystem.borderRadiusMedium),
        ),
        child: Padding(
          padding: EdgeInsets.all(DesignSystem.adjustedSpacingMedium),
          child: Row(
            children: [
              Icon(
                isIdentified ? Icons.check_circle : Icons.error,
                color: Colors.white,
                size: 36,
              ),
              SizedBox(width: DesignSystem.adjustedSpacingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isIdentified ? 'PERSONNEL IDENTIFIED' : 'NOT ON RECORD',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isIdentified
                          ? 'Match found in personnel database'
                          : 'No matching personnel found in database',
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
                    ? Icon(
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
                personnel.fullName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Center(
              child: Text(
                personnel.rank.displayName,
                style: TextStyle(
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
            Text(
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
            Text(
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
              style: TextStyle(
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
    if (confidence >= 0.85) {
      return DesignSystem.successColor; // High confidence
    } else if (confidence >= 0.70) {
      return Colors.orange; // Medium confidence
    } else {
      return Colors.red; // Low confidence
    }
  }

  // Get label based on confidence level
  String _getConfidenceLabel(double confidence) {
    if (confidence >= 0.85) {
      return 'High Confidence';
    } else if (confidence >= 0.70) {
      return 'Medium Confidence';
    } else {
      return 'Low Confidence';
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
                      ? Icon(
                          Icons.person,
                          size: 60,
                          color: DesignSystem.primaryColor,
                        )
                      : null,
                ),
              ),
              SizedBox(height: DesignSystem.adjustedSpacingMedium),
              _buildDetailRow('Name', widget.identifiedPersonnel!.fullName),
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
              if (widget.identifiedPersonnel!.yearsOfService != null)
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
