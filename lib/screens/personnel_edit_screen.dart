import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../config/design_system.dart';
import '../models/personnel_model.dart';
import '../providers/personnel_provider.dart';
import '../widgets/platform_aware_widgets.dart';
import '../widgets/custom_drawer.dart';

class PersonnelEditScreen extends StatefulWidget {
  final Personnel personnel;

  const PersonnelEditScreen({Key? key, required this.personnel})
      : super(key: key);

  @override
  State<PersonnelEditScreen> createState() => _PersonnelEditScreenState();
}

class _PersonnelEditScreenState extends State<PersonnelEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _initialsController = TextEditingController();
  final _unitController = TextEditingController();
  final _notesController = TextEditingController();

  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();

  late Rank _selectedRank;
  late Corps _selectedCorps;
  late ServiceStatus _selectedServiceStatus;
  DateTime? _selectedDateOfBirth;
  DateTime? _selectedEnlistmentDate;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing data
    _fullNameController.text = widget.personnel.fullName;
    _initialsController.text = widget.personnel.initials;
    _unitController.text = widget.personnel.unit;
    _notesController.text = widget.personnel.notes ?? '';

    // Initialize selected values
    _selectedRank = widget.personnel.rank;
    _selectedCorps = widget.personnel.corps;
    _selectedServiceStatus = widget.personnel.serviceStatus;
    _selectedDateOfBirth = widget.personnel.dateOfBirth;
    _selectedEnlistmentDate = widget.personnel.enlistmentDate;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _unitController.dispose();
    _notesController.dispose();
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
    }
  }

  // Format date for display
  String _formatDate(DateTime? date) {
    if (date == null) return 'Not set';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // Pick date
  Future<void> _pickDate(bool isDateOfBirth) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isDateOfBirth
          ? _selectedDateOfBirth ?? DateTime(1990)
          : _selectedEnlistmentDate ?? DateTime(2010),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: DesignSystem.primaryColor,
              onPrimary: Colors.white,
              onSurface: DesignSystem.textPrimaryColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: DesignSystem.primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isDateOfBirth) {
          _selectedDateOfBirth = picked;
        } else {
          _selectedEnlistmentDate = picked;
        }
      });
    }
  }

  // Get corps items for dropdown
  List<DropdownMenuItem<Corps>> _getCorpsItems() {
    // Create separate lists for different corps categories
    final combatArms = [
      Corps.infantry,
      Corps.armoured,
      Corps.artillery,
    ];

    final combatSupportArms = [
      Corps.engineers,
      Corps.signals,
      Corps.intelligence,
    ];

    final combatServiceSupportArms = [
      Corps.supplyAndTransport,
      Corps.medical,
      Corps.ordnance,
      Corps.electricalAndMechanical,
      Corps.militaryPolice,
    ];

    final administrativeAndSpecializedCorps = [
      Corps.education,
      Corps.finance,
      Corps.physicalTraining,
      Corps.band,
      Corps.chaplainServices,
      Corps.islamicAffairs,
      Corps.publicRelations,
      Corps.legalServices,
      Corps.womensCorps,
    ];

    // Create dropdown items with headers
    List<DropdownMenuItem<Corps>> items = [];

    // Add Combat Arms header
    items.add(
      DropdownMenuItem<Corps>(
        enabled: false,
        child: Text(
          'COMBAT ARMS',
          style: TextStyle(
            color: DesignSystem.primaryColor,
            fontWeight: DesignSystem.fontWeightBold,
            fontSize: DesignSystem.adjustedFontSizeSmall,
          ),
        ),
      ),
    );

    // Add Combat Arms
    items.addAll(
      combatArms.map((corps) => DropdownMenuItem<Corps>(
            value: corps,
            child: Text(corps.displayName),
          )),
    );

    // Add divider
    items.add(
      DropdownMenuItem<Corps>(
        enabled: false,
        child: Divider(),
      ),
    );

    // Add Combat Support Arms header
    items.add(
      DropdownMenuItem<Corps>(
        enabled: false,
        child: Text(
          'COMBAT SUPPORT ARMS',
          style: TextStyle(
            color: DesignSystem.primaryColor,
            fontWeight: DesignSystem.fontWeightBold,
            fontSize: DesignSystem.adjustedFontSizeSmall,
          ),
        ),
      ),
    );

    // Add Combat Support Arms
    items.addAll(
      combatSupportArms.map((corps) => DropdownMenuItem<Corps>(
            value: corps,
            child: Text(corps.displayName),
          )),
    );

    // Add divider
    items.add(
      DropdownMenuItem<Corps>(
        enabled: false,
        child: Divider(),
      ),
    );

    // Add Combat Service Support Arms header
    items.add(
      DropdownMenuItem<Corps>(
        enabled: false,
        child: Text(
          'COMBAT SERVICE SUPPORT ARMS',
          style: TextStyle(
            color: DesignSystem.primaryColor,
            fontWeight: DesignSystem.fontWeightBold,
            fontSize: DesignSystem.adjustedFontSizeSmall,
          ),
        ),
      ),
    );

    // Add Combat Service Support Arms
    items.addAll(
      combatServiceSupportArms.map((corps) => DropdownMenuItem<Corps>(
            value: corps,
            child: Text(corps.displayName),
          )),
    );

    // Add divider
    items.add(
      DropdownMenuItem<Corps>(
        enabled: false,
        child: Divider(),
      ),
    );

    // Add Administrative and Specialized Corps header
    items.add(
      DropdownMenuItem<Corps>(
        enabled: false,
        child: Text(
          'ADMINISTRATIVE AND SPECIALIZED CORPS',
          style: TextStyle(
            color: DesignSystem.primaryColor,
            fontWeight: DesignSystem.fontWeightBold,
            fontSize: DesignSystem.adjustedFontSizeSmall,
          ),
        ),
      ),
    );

    // Add Administrative and Specialized Corps
    items.addAll(
      administrativeAndSpecializedCorps.map((corps) => DropdownMenuItem<Corps>(
            value: corps,
            child: Text(corps.displayName),
          )),
    );

    return items;
  }

  // Get rank items for dropdown
  List<DropdownMenuItem<Rank>> _getRankItems() {
    // Create separate lists for officer and soldier ranks
    final officerRanks = [
      Rank.general,
      Rank.lieutenantGeneral,
      Rank.majorGeneral,
      Rank.brigadierGeneral,
      Rank.colonel,
      Rank.lieutenantColonel,
      Rank.major,
      Rank.captain,
      Rank.lieutenant,
      Rank.secondLieutenant,
    ];

    final soldierRanks = [
      Rank.warrantOfficerClass1,
      Rank.warrantOfficerClass2,
      Rank.staffSergeant,
      Rank.sergeant,
      Rank.corporal,
      Rank.lanceCorporal,
      Rank.private,
    ];

    // Create dropdown items with headers
    List<DropdownMenuItem<Rank>> items = [];

    // Add officer header
    items.add(
      DropdownMenuItem<Rank>(
        enabled: false,
        child: Text(
          'OFFICERS',
          style: TextStyle(
            color: DesignSystem.primaryColor,
            fontWeight: DesignSystem.fontWeightBold,
            fontSize: DesignSystem.adjustedFontSizeSmall,
          ),
        ),
      ),
    );

    // Add officer ranks
    items.addAll(
      officerRanks.map((rank) => DropdownMenuItem<Rank>(
            value: rank,
            child: Text(rank.displayName),
          )),
    );

    // Add divider
    items.add(
      DropdownMenuItem<Rank>(
        enabled: false,
        child: Divider(),
      ),
    );

    // Add soldier header
    items.add(
      DropdownMenuItem<Rank>(
        enabled: false,
        child: Text(
          'SOLDIERS',
          style: TextStyle(
            color: DesignSystem.primaryColor,
            fontWeight: DesignSystem.fontWeightBold,
            fontSize: DesignSystem.adjustedFontSizeSmall,
          ),
        ),
      ),
    );

    // Add soldier ranks
    items.addAll(
      soldierRanks.map((rank) => DropdownMenuItem<Rank>(
            value: rank,
            child: Text(rank.displayName),
          )),
    );

    return items;
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

  // Update personnel
  Future<void> _updatePersonnel() async {
    if (_formKey.currentState?.validate() ?? false) {
      final personnelProvider =
          Provider.of<PersonnelProvider>(context, listen: false);

      try {
        // Create updated personnel
        final updatedPersonnel = widget.personnel.copyWith(
          fullName: _fullNameController.text.trim(),
          initials: _initialsController.text.trim(),
          rank: _selectedRank,
          unit: _unitController.text.trim(),
          corps: _selectedCorps,
          notes: _notesController.text.trim(),
          serviceStatus: _selectedServiceStatus,
          dateOfBirth: _selectedDateOfBirth,
          enlistmentDate: _selectedEnlistmentDate,
        );

        // Update personnel
        final result =
            await personnelProvider.updatePersonnel(updatedPersonnel);

        // Save photo if selected
        if (result != null && _selectedImage != null) {
          await personnelProvider.savePersonnelPhoto(
            result.id,
            _selectedImage!,
          );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Personnel updated successfully'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate back to previous screen
          Navigator.of(context)
              .pop(true); // Return true to indicate update was successful
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final personnelProvider = Provider.of<PersonnelProvider>(context);

    return PlatformScaffold(
      appBar: AppBar(
        title: const Text('Edit Personnel'),
        backgroundColor: DesignSystem.primaryColor,
      ),
      drawer: const CustomDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(DesignSystem.adjustedSpacingLarge),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Photo section
                  Center(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _selectedImage == null &&
                                      widget.personnel.photoUrl == null
                                  ? DesignSystem.primaryColor.withOpacity(0.1)
                                  : null,
                              image: _selectedImage != null
                                  ? DecorationImage(
                                      image: FileImage(_selectedImage!),
                                      fit: BoxFit.cover,
                                    )
                                  : widget.personnel.photoUrl != null
                                      ? DecorationImage(
                                          image: FileImage(
                                              File(widget.personnel.photoUrl!)),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                            ),
                            child: _selectedImage == null &&
                                    widget.personnel.photoUrl == null
                                ? Icon(
                                    Icons.add_a_photo,
                                    size: 60,
                                    color: DesignSystem.primaryColor,
                                  )
                                : null,
                          ),
                        ),
                        SizedBox(height: DesignSystem.adjustedSpacingMedium),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            PlatformButton(
                              text: 'CAMERA',
                              onPressed: _takePhoto,
                              icon: Icons.camera_alt,
                              isSmall: true,
                              isPrimary: false,
                            ),
                            SizedBox(width: DesignSystem.adjustedSpacingMedium),
                            PlatformButton(
                              text: 'GALLERY',
                              onPressed: _pickImage,
                              icon: Icons.photo_library,
                              isSmall: true,
                              isPrimary: false,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: DesignSystem.adjustedSpacingLarge),

                  // Personnel Information
                  PlatformText(
                    'Personnel Information',
                    isTitle: true,
                  ),
                  SizedBox(height: DesignSystem.adjustedSpacingMedium),

                  // Army Number (read-only)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Army Number',
                        style: TextStyle(
                          color: DesignSystem.textSecondaryColor,
                          fontSize: DesignSystem.adjustedFontSizeSmall,
                        ),
                      ),
                      SizedBox(height: DesignSystem.adjustedSpacingSmall),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: DesignSystem.adjustedSpacingMedium,
                          vertical: DesignSystem.adjustedSpacingMedium,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                              DesignSystem.borderRadiusSmall),
                          border: Border.all(color: Colors.grey.shade300),
                          color: Colors.grey.shade100,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.badge,
                              color: DesignSystem.textSecondaryColor,
                              size: 20,
                            ),
                            SizedBox(width: DesignSystem.adjustedSpacingMedium),
                            Text(
                              widget.personnel.armyNumber,
                              style: TextStyle(
                                color: DesignSystem.textSecondaryColor,
                                fontSize: DesignSystem.adjustedFontSizeMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: DesignSystem.adjustedSpacingMedium),

                  // Full Name
                  PlatformTextField(
                    controller: _fullNameController,
                    label: 'Full Name',
                    prefixIcon: Icons.person,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter full name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: DesignSystem.adjustedSpacingMedium),

                  // Initials
                  PlatformTextField(
                    controller: _initialsController,
                    label: 'Initials',
                    prefixIcon: Icons.short_text,
                    hint: 'e.g., IM Yunusa (Officer) or Ibrahim MY (Soldier)',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter initials';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: DesignSystem.adjustedSpacingMedium),

                  // Rank
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rank',
                        style: TextStyle(
                          color: DesignSystem.textSecondaryColor,
                          fontSize: DesignSystem.adjustedFontSizeSmall,
                        ),
                      ),
                      SizedBox(height: DesignSystem.adjustedSpacingSmall),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: DesignSystem.adjustedSpacingMedium,
                          vertical: DesignSystem.adjustedSpacingSmall,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                              DesignSystem.borderRadiusSmall),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<Rank>(
                            isExpanded: true,
                            value: _selectedRank,
                            icon: const Icon(Icons.arrow_drop_down),
                            iconSize: 24,
                            elevation: 16,
                            style: TextStyle(
                              color: DesignSystem.textPrimaryColor,
                              fontSize: DesignSystem.adjustedFontSizeMedium,
                            ),
                            onChanged: (Rank? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedRank = newValue;
                                });
                              }
                            },
                            items: _getRankItems(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: DesignSystem.adjustedSpacingMedium),

                  // Unit
                  PlatformTextField(
                    controller: _unitController,
                    label: 'Unit',
                    prefixIcon: Icons.business,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter unit';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: DesignSystem.adjustedSpacingMedium),

                  // Corps
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Corps',
                        style: TextStyle(
                          color: DesignSystem.textSecondaryColor,
                          fontSize: DesignSystem.adjustedFontSizeSmall,
                        ),
                      ),
                      SizedBox(height: DesignSystem.adjustedSpacingSmall),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: DesignSystem.adjustedSpacingMedium,
                          vertical: DesignSystem.adjustedSpacingSmall,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                              DesignSystem.borderRadiusSmall),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<Corps>(
                            isExpanded: true,
                            value: _selectedCorps,
                            icon: const Icon(Icons.arrow_drop_down),
                            iconSize: 24,
                            elevation: 16,
                            style: TextStyle(
                              color: DesignSystem.textPrimaryColor,
                              fontSize: DesignSystem.adjustedFontSizeMedium,
                            ),
                            onChanged: (Corps? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedCorps = newValue;
                                });
                              }
                            },
                            items: _getCorpsItems(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: DesignSystem.adjustedSpacingMedium),

                  // Service Status
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Service Status',
                        style: TextStyle(
                          color: DesignSystem.textSecondaryColor,
                          fontSize: DesignSystem.adjustedFontSizeSmall,
                        ),
                      ),
                      SizedBox(height: DesignSystem.adjustedSpacingSmall),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: DesignSystem.adjustedSpacingMedium,
                          vertical: DesignSystem.adjustedSpacingSmall,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                              DesignSystem.borderRadiusSmall),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<ServiceStatus>(
                            isExpanded: true,
                            value: _selectedServiceStatus,
                            icon: const Icon(Icons.arrow_drop_down),
                            iconSize: 24,
                            elevation: 16,
                            style: TextStyle(
                              color: DesignSystem.textPrimaryColor,
                              fontSize: DesignSystem.adjustedFontSizeMedium,
                            ),
                            onChanged: (ServiceStatus? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedServiceStatus = newValue;
                                });
                              }
                            },
                            items: ServiceStatus.values
                                .map<DropdownMenuItem<ServiceStatus>>(
                                    (ServiceStatus value) {
                              return DropdownMenuItem<ServiceStatus>(
                                value: value,
                                child: Text(_getServiceStatusText(value)),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: DesignSystem.adjustedSpacingMedium),

                  // Date of Birth
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date of Birth',
                        style: TextStyle(
                          color: DesignSystem.textSecondaryColor,
                          fontSize: DesignSystem.adjustedFontSizeSmall,
                        ),
                      ),
                      SizedBox(height: DesignSystem.adjustedSpacingSmall),
                      InkWell(
                        onTap: () => _pickDate(true),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: DesignSystem.adjustedSpacingMedium,
                            vertical: DesignSystem.adjustedSpacingMedium,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                DesignSystem.borderRadiusSmall),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: DesignSystem.textSecondaryColor,
                                size: 20,
                              ),
                              SizedBox(
                                  width: DesignSystem.adjustedSpacingMedium),
                              Text(
                                _formatDate(_selectedDateOfBirth),
                                style: TextStyle(
                                  color: DesignSystem.textPrimaryColor,
                                  fontSize: DesignSystem.adjustedFontSizeMedium,
                                ),
                              ),
                              Spacer(),
                              Icon(
                                Icons.arrow_drop_down,
                                color: DesignSystem.textSecondaryColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: DesignSystem.adjustedSpacingMedium),

                  // Enlistment Date
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enlistment Date',
                        style: TextStyle(
                          color: DesignSystem.textSecondaryColor,
                          fontSize: DesignSystem.adjustedFontSizeSmall,
                        ),
                      ),
                      SizedBox(height: DesignSystem.adjustedSpacingSmall),
                      InkWell(
                        onTap: () => _pickDate(false),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: DesignSystem.adjustedSpacingMedium,
                            vertical: DesignSystem.adjustedSpacingMedium,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                DesignSystem.borderRadiusSmall),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: DesignSystem.textSecondaryColor,
                                size: 20,
                              ),
                              SizedBox(
                                  width: DesignSystem.adjustedSpacingMedium),
                              Text(
                                _formatDate(_selectedEnlistmentDate),
                                style: TextStyle(
                                  color: DesignSystem.textPrimaryColor,
                                  fontSize: DesignSystem.adjustedFontSizeMedium,
                                ),
                              ),
                              Spacer(),
                              Icon(
                                Icons.arrow_drop_down,
                                color: DesignSystem.textSecondaryColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: DesignSystem.adjustedSpacingMedium),

                  // Years of Service (calculated)
                  if (_selectedEnlistmentDate != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Years of Service',
                          style: TextStyle(
                            color: DesignSystem.textSecondaryColor,
                            fontSize: DesignSystem.adjustedFontSizeSmall,
                          ),
                        ),
                        SizedBox(height: DesignSystem.adjustedSpacingSmall),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: DesignSystem.adjustedSpacingMedium,
                            vertical: DesignSystem.adjustedSpacingMedium,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                DesignSystem.borderRadiusSmall),
                            color: DesignSystem.primaryColor.withOpacity(0.1),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.military_tech,
                                color: DesignSystem.primaryColor,
                                size: 20,
                              ),
                              SizedBox(
                                  width: DesignSystem.adjustedSpacingMedium),
                              Text(
                                '${_calculateYearsOfService(_selectedEnlistmentDate!)} years',
                                style: TextStyle(
                                  color: DesignSystem.primaryColor,
                                  fontWeight: DesignSystem.fontWeightBold,
                                  fontSize: DesignSystem.adjustedFontSizeMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: DesignSystem.adjustedSpacingMedium),
                      ],
                    ),

                  // Notes
                  PlatformTextField(
                    controller: _notesController,
                    label: 'Notes (Optional)',
                    prefixIcon: Icons.note,
                    maxLines: 3,
                  ),
                  SizedBox(height: DesignSystem.adjustedSpacingLarge),

                  // Update button
                  PlatformButton(
                    text: 'UPDATE PERSONNEL',
                    onPressed:
                        personnelProvider.isLoading ? null : _updatePersonnel,
                    icon: Icons.save,
                    isFullWidth: true,
                  ),

                  if (personnelProvider.error != null) ...[
                    SizedBox(height: DesignSystem.adjustedSpacingMedium),
                    Text(
                      personnelProvider.error!,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: DesignSystem.adjustedFontSizeSmall,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Calculate years of service
  int _calculateYearsOfService(DateTime enlistmentDate) {
    final now = DateTime.now();
    final years = now.year - enlistmentDate.year;

    // Adjust for month and day
    if (now.month < enlistmentDate.month ||
        (now.month == enlistmentDate.month && now.day < enlistmentDate.day)) {
      return years - 1;
    }

    return years;
  }
}
