import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../config/design_system.dart';
import '../models/personnel_model.dart';
import '../providers/personnel_provider.dart';
import '../widgets/platform_aware_widgets.dart';
import 'personnel_registration_screen.dart';
import 'personnel_edit_screen.dart';

class FacialVerificationScreen extends StatefulWidget {
  final int initialTabIndex;

  const FacialVerificationScreen({Key? key, this.initialTabIndex = 0})
      : super(key: key);

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
    final XFile? photo = await _imagePicker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      imageQuality: 80,
    );

    if (photo != null) {
      setState(() {
        _selectedImage = File(photo.path);
      });

      // Process the image for facial verification
      _processImageForVerification();
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
      _processImageForVerification();
    }
  }

  // Pick a video from gallery
  Future<void> _pickVideo() async {
    final XFile? video = await _imagePicker.pickVideo(
      source: ImageSource.gallery,
    );

    if (video != null) {
      // Process the video for facial verification
      _processVideoForVerification(File(video.path));
    }
  }

  // Process image for facial verification
  void _processImageForVerification() {
    // In a real app, this would use a facial recognition API
    // For now, we'll just show a success message

    if (_selectedImage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Facial verification in progress...'),
          backgroundColor: Colors.blue,
        ),
      );

      // Simulate processing delay
      Future.delayed(const Duration(seconds: 2), () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Facial verification successful!'),
            backgroundColor: Colors.green,
          ),
        );
      });
    }
  }

  // Process video for facial verification
  void _processVideoForVerification(File videoFile) {
    // In a real app, this would extract frames and use a facial recognition API
    // For now, we'll just show a success message

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Video processing in progress...'),
        backgroundColor: Colors.blue,
      ),
    );

    // Simulate processing delay
    Future.delayed(const Duration(seconds: 3), () {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Video processing complete. Facial verification successful!'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  // Verify by army number
  Future<void> _verifyByArmyNumber() async {
    final armyNumber = _armyNumberController.text.trim();

    if (armyNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an army number'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final personnelProvider =
        Provider.of<PersonnelProvider>(context, listen: false);
    final personnel =
        await personnelProvider.getPersonnelByArmyNumber(armyNumber);

    if (personnel != null) {
      personnelProvider.setSelectedPersonnel(personnel);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Personnel found: ${personnel.fullName}'),
          backgroundColor: Colors.green,
        ),
      );

      // Show personnel details in a dialog
      if (mounted) {
        _showPersonnelDetailsDialog(personnel);
      }
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
        title: Text('Personnel Details'),
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
                    color: DesignSystem.primaryColor.withOpacity(0.1),
                  ),
                  child: Icon(
                    Icons.person,
                    size: 60,
                    color: DesignSystem.primaryColor,
                  ),
                ),
              SizedBox(height: DesignSystem.adjustedSpacingMedium),
              _buildDetailRow('Name', personnel.fullName),
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
            child: Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _editPersonnel(personnel);
            },
            child: Text('Edit'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _verifyPersonnel(personnel);
            },
            child: Text('Verify'),
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
      if (updated == true) {
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${personnel.fullName} has been verified'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
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
              style: TextStyle(
                fontWeight: DesignSystem.fontWeightBold,
                color: DesignSystem.textSecondaryColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
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
    }
  }

  // Format date
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Build camera verification tab
  Widget _buildCameraVerificationTab() {
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
                color: DesignSystem.primaryColor.withOpacity(0.1),
              ),
              child: Icon(
                Icons.camera_alt,
                size: 80,
                color: DesignSystem.primaryColor,
              ),
            ),
          SizedBox(height: DesignSystem.adjustedSpacingLarge),
          PlatformButton(
            text: 'TAKE PHOTO',
            onPressed: _takePhoto,
            icon: Icons.camera_alt,
            isFullWidth: false,
          ),
          SizedBox(height: DesignSystem.adjustedSpacingMedium),
          PlatformText(
            'Position the face in the center of the frame',
            style: TextStyle(
              color: DesignSystem.textSecondaryColor,
              fontSize: DesignSystem.adjustedFontSizeSmall,
            ),
          ),
        ],
      ),
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
                color: DesignSystem.primaryColor.withOpacity(0.1),
              ),
              child: Icon(
                Icons.photo,
                size: 80,
                color: DesignSystem.primaryColor,
              ),
            ),
          SizedBox(height: DesignSystem.adjustedSpacingLarge),
          PlatformButton(
            text: 'SELECT PHOTO',
            onPressed: _pickImage,
            icon: Icons.photo_library,
            isFullWidth: false,
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

  // Build video verification tab
  Widget _buildVideoVerificationTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(DesignSystem.borderRadiusMedium),
              color: DesignSystem.primaryColor.withOpacity(0.1),
            ),
            child: Icon(
              Icons.videocam,
              size: 80,
              color: DesignSystem.primaryColor,
            ),
          ),
          SizedBox(height: DesignSystem.adjustedSpacingLarge),
          PlatformButton(
            text: 'SELECT VIDEO',
            onPressed: _pickVideo,
            icon: Icons.video_library,
            isFullWidth: false,
          ),
          SizedBox(height: DesignSystem.adjustedSpacingMedium),
          PlatformText(
            'Select a video showing the face clearly',
            style: TextStyle(
              color: DesignSystem.textSecondaryColor,
              fontSize: DesignSystem.adjustedFontSizeSmall,
            ),
          ),
        ],
      ),
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
                  Icon(
                    Icons.numbers,
                    size: 60,
                    color: DesignSystem.primaryColor,
                  ),
                  SizedBox(height: DesignSystem.adjustedSpacingMedium),
                  PlatformText(
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
                          Icon(
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
      selectedColor: DesignSystem.primaryColor.withOpacity(0.2),
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
                  color: DesignSystem.primaryColor.withOpacity(0.1),
                ),
                child: Icon(
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
                    personnel.fullName,
                    style: TextStyle(
                      fontWeight: DesignSystem.fontWeightBold,
                      fontSize: DesignSystem.adjustedFontSizeMedium,
                    ),
                  ),
                  SizedBox(height: DesignSystem.adjustedSpacingSmall / 2),
                  Text(
                    '${personnel.rank.displayName} - ${personnel.corps.shortName}',
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
                              .withOpacity(0.1),
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
          color: color.withOpacity(0.1),
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
        backgroundColor: DesignSystem.primaryColor,
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            _buildCameraVerificationTab(),
            _buildPhotoVerificationTab(),
            _buildVideoVerificationTab(),
            _buildArmyNumberVerificationTab(),
            _buildPersonnelDatabaseTab(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: DesignSystem.primaryColor,
        selectedItemColor: DesignSystem.accentColor,
        unselectedItemColor: Colors.white.withOpacity(0.7),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Camera',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo),
            label: 'Photo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.videocam),
            label: 'Video',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.numbers),
            label: 'Army No.',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Database',
          ),
        ],
      ),
    );
  }
}
