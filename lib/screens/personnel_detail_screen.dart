import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/design_system.dart';
import '../models/personnel_model.dart';
import '../models/access_log_model.dart';
import '../providers/personnel_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/access_log_provider.dart';
import '../widgets/platform_aware_widgets.dart';
import '../utils/date_utils.dart';

class PersonnelDetailScreen extends StatelessWidget {
  static const String routeName = '/personnel_detail';

  const PersonnelDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String personnelId = args['personnelId'];
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personnel Details'),
        backgroundColor: isDarkMode
            ? DesignSystem.darkAppBarColor
            : DesignSystem.lightAppBarColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // Edit button
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit personnel screen
              Navigator.pushNamed(
                context,
                '/edit_personnel',
                arguments: {'personnelId': personnelId},
              );
            },
          ),
          // Verify button
          IconButton(
            icon: const Icon(Icons.verified_user),
            onPressed: () {
              _showVerificationDialog(context, personnelId);
            },
          ),
          // Service status button
          IconButton(
            icon: const Icon(Icons.work),
            onPressed: () {
              _showServiceStatusDialog(context, personnelId);
            },
          ),
        ],
      ),
      body: Consumer<PersonnelProvider>(
        builder: (context, personnelProvider, child) {
          final personnel = personnelProvider.getPersonnelById(personnelId);

          if (personnel == null) {
            return const Center(
              child: Text('Personnel not found'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Personnel photo and basic info
                Center(
                  child: Column(
                    children: [
                      _buildPersonnelPhoto(personnel),
                      const SizedBox(height: 16),
                      Text(
                        '${personnel.rank.displayName} ${personnel.fullName}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        personnel.armyNumber,
                        style: TextStyle(
                          fontSize: 16,
                          color:
                              isDarkMode ? Colors.grey[300] : Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildServiceStatusChip(personnel.serviceStatus),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Personnel details
                _buildDetailCard(
                  context,
                  isDarkMode,
                  'Personal Information',
                  [
                    _buildDetailRow('Full Name', personnel.fullName),
                    _buildDetailRow('Initials', personnel.initials),
                    _buildDetailRow('Rank', personnel.rank.displayName),
                    _buildDetailRow('Army Number', personnel.armyNumber),
                    _buildDetailRow(
                        'Category', _getCategoryText(personnel.category)),
                    if (personnel.dateOfBirth != null)
                      _buildDetailRow(
                          'Date of Birth', formatDate(personnel.dateOfBirth!)),
                  ],
                ),

                const SizedBox(height: 16),

                _buildDetailCard(
                  context,
                  isDarkMode,
                  'Service Information',
                  [
                    _buildDetailRow('Corps', _getCorpsText(personnel.corps)),
                    _buildDetailRow('Unit', personnel.unit),
                    _buildDetailRow(
                        'Service Status', personnel.serviceStatus.displayName),
                    if (personnel.enlistmentDate != null)
                      _buildDetailRow('Enlistment Date',
                          formatDate(personnel.enlistmentDate!)),
                    _buildDetailRow('Years of Service',
                        '${personnel.yearsOfService} years'),
                  ],
                ),

                const SizedBox(height: 16),

                if (personnel.notes != null && personnel.notes!.isNotEmpty)
                  _buildDetailCard(
                    context,
                    isDarkMode,
                    'Additional Information',
                    [
                      _buildDetailRow('Notes', personnel.notes!),
                    ],
                  ),

                const SizedBox(height: 24),

                // Access history button
                Center(
                  child: PlatformButton(
                    text: 'View Access History',
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/access_logs',
                        arguments: {'personnelId': personnelId},
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPersonnelPhoto(Personnel personnel) {
    return Hero(
      tag: 'personnel-photo-${personnel.id}',
      child: CircleAvatar(
        radius: 60,
        backgroundColor: DesignSystem.primaryColor.withAlpha(50),
        child: personnel.photoUrl != null
            ? ClipOval(
                child: personnel.photoUrl!.startsWith('http')
                    ? Image.network(
                        personnel.photoUrl!,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.person, size: 60);
                        },
                      )
                    : Image.file(
                        File(personnel.photoUrl!.replaceFirst('file://', '')),
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.person, size: 60);
                        },
                      ),
              )
            : const Icon(Icons.person, size: 60),
      ),
    );
  }

  Widget _buildServiceStatusChip(ServiceStatus status) {
    Color chipColor;
    Color textColor = Colors.white;

    switch (status) {
      case ServiceStatus.active:
        chipColor = Colors.green;
        break;
      case ServiceStatus.retired:
        chipColor = Colors.blue;
        break;
      case ServiceStatus.resigned:
        chipColor = Colors.orange;
        break;
      case ServiceStatus.deserted:
        chipColor = Colors.grey;
        break;
      case ServiceStatus.awol:
        chipColor = Colors.red;
        break;
      case ServiceStatus.dismissed:
        chipColor = Colors.purple;
        break;
    }

    return Chip(
      label: Text(
        status.displayName,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: chipColor,
    );
  }

  Widget _buildDetailCard(BuildContext context, bool isDarkMode, String title,
      List<Widget> details) {
    return Card(
      elevation: 2,
      color:
          isDarkMode ? DesignSystem.darkCardColor : DesignSystem.lightCardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: DesignSystem.primaryColor,
              ),
            ),
            const Divider(),
            ...details,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

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

  String _getCorpsText(Corps corps) {
    switch (corps) {
      // Combat Arms
      case Corps.infantry:
        return 'Infantry';
      case Corps.armoured:
        return 'Armoured';
      case Corps.artillery:
        return 'Artillery';

      // Combat Support Arms
      case Corps.engineers:
        return 'Engineers';
      case Corps.signals:
        return 'Signals';
      case Corps.intelligence:
        return 'Intelligence';

      // Combat Service Support Arms
      case Corps.supplyAndTransport:
        return 'Supply & Transport';
      case Corps.medical:
        return 'Medical';
      case Corps.ordnance:
        return 'Ordnance';
      case Corps.electricalAndMechanical:
        return 'Electrical & Mechanical';
      case Corps.militaryPolice:
        return 'Military Police';

      // Administrative and Specialized Corps
      case Corps.education:
        return 'Education';
      case Corps.finance:
        return 'Finance';
      case Corps.physicalTraining:
        return 'Physical Training';
      case Corps.band:
        return 'Band';
      case Corps.chaplainServices:
        return 'Chaplain Services';
      case Corps.islamicAffairs:
        return 'Islamic Affairs';
      case Corps.publicRelations:
        return 'Public Relations';
      case Corps.legalServices:
        return 'Legal Services';
      case Corps.womensCorps:
        return 'Women\'s Corps';
    }
  }

  // Show verification dialog
  void _showVerificationDialog(BuildContext context, String personnelId) {
    final personnelProvider =
        Provider.of<PersonnelProvider>(context, listen: false);
    final personnel = personnelProvider.getPersonnelById(personnelId);

    if (personnel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Personnel not found')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verify Personnel'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${personnel.rank.displayName} ${personnel.fullName}'),
            Text('Army Number: ${personnel.armyNumber}'),
            Text(
                'Current Status: ${_getVerificationStatusText(personnel.status)}'),
            const SizedBox(height: 16),
            const Text('Update verification status:'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _updateVerificationStatus(
                      context,
                      personnelId,
                      VerificationStatus.verified,
                    );
                  },
                  child: const Text('Verify'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _updateVerificationStatus(
                      context,
                      personnelId,
                      VerificationStatus.rejected,
                    );
                  },
                  child: const Text('Reject'),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  // Update verification status
  Future<void> _updateVerificationStatus(
    BuildContext context,
    String personnelId,
    VerificationStatus status,
  ) async {
    // Get a local reference to the context to avoid using it after async gaps
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final personnelProvider =
        Provider.of<PersonnelProvider>(context, listen: false);
    final accessLogProvider =
        Provider.of<AccessLogProvider>(context, listen: false);
    final personnel = personnelProvider.getPersonnelById(personnelId);

    if (personnel == null) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Personnel not found')),
      );
      return;
    }

    // Update the personnel with the new status
    final updatedPersonnel = personnel.copyWith(
      status: status,
      lastVerified:
          status == VerificationStatus.verified ? DateTime.now() : null,
    );

    // Update personnel in database
    await personnelProvider.updatePersonnel(updatedPersonnel);

    // Create access log entry
    await accessLogProvider.addAccessLog(
      personnelId: personnel.id,
      personnelName: '${personnel.rank.displayName} ${personnel.fullName}',
      personnelArmyNumber: personnel.armyNumber,
      status: status == VerificationStatus.verified
          ? AccessLogStatus.verified
          : AccessLogStatus.denied,
      type: AccessLogType.verification,
      confidence: 1.0, // Manual verification has 100% confidence
      details:
          'Personnel verification status changed to ${status == VerificationStatus.verified ? "verified" : "rejected"}',
    );

    scaffoldMessenger.showSnackBar(
      SnackBar(
          content: Text(
              'Personnel ${status == VerificationStatus.verified ? 'verified' : 'rejected'}')),
    );
  }

  // Get verification status text
  String _getVerificationStatusText(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.pending:
        return 'Pending';
      case VerificationStatus.verified:
        return 'Verified';
      case VerificationStatus.rejected:
        return 'Rejected';
    }
  }

  // Show service status dialog
  void _showServiceStatusDialog(BuildContext context, String personnelId) {
    final personnelProvider =
        Provider.of<PersonnelProvider>(context, listen: false);
    final personnel = personnelProvider.getPersonnelById(personnelId);

    if (personnel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Personnel not found')),
      );
      return;
    }

    // Create a temporary variable to hold the selected status
    ServiceStatus selectedStatus = personnel.serviceStatus;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Update Service Status'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    'Name: ${personnel.rank.displayName} ${personnel.fullName}'),
                Text('Army Number: ${personnel.armyNumber}'),
                Text('Current Status: ${personnel.serviceStatus.displayName}'),
                const SizedBox(height: 16),
                const Text('Select new service status:'),
                const SizedBox(height: 8),
                // Service status options
                Wrap(
                  spacing: 8.0,
                  children: ServiceStatus.values.map((status) {
                    return FilterChip(
                      label: Text(status.displayName),
                      selected: selectedStatus == status,
                      onSelected: (selected) {
                        setState(() {
                          selectedStatus = status;
                        });
                      },
                      backgroundColor: _getServiceStatusColor(status),
                      labelStyle: const TextStyle(color: Colors.white),
                    );
                  }).toList(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _updateServiceStatus(context, personnelId, selectedStatus);
                },
                child: const Text('Update'),
              ),
            ],
          );
        },
      ),
    );
  }

  // Update service status
  Future<void> _updateServiceStatus(
    BuildContext context,
    String personnelId,
    ServiceStatus status,
  ) async {
    // Get a local reference to the context to avoid using it after async gaps
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final personnelProvider =
        Provider.of<PersonnelProvider>(context, listen: false);
    final accessLogProvider =
        Provider.of<AccessLogProvider>(context, listen: false);
    final personnel = personnelProvider.getPersonnelById(personnelId);

    if (personnel == null) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Personnel not found')),
      );
      return;
    }

    // Get the previous status for logging
    final previousStatus = personnel.serviceStatus;

    // Update the personnel with the new service status
    final updatedPersonnel = personnel.copyWith(
      serviceStatus: status,
    );

    // Update personnel in database
    await personnelProvider.updatePersonnel(updatedPersonnel);

    // Create access log entry
    await accessLogProvider.addAccessLog(
      personnelId: personnel.id,
      personnelName: '${personnel.rank.displayName} ${personnel.fullName}',
      personnelArmyNumber: personnel.armyNumber,
      status: AccessLogStatus.verified, // Status update is always verified
      type: AccessLogType.modification,
      confidence: 1.0, // Manual modification has 100% confidence
      details:
          'Service status changed from ${previousStatus.displayName} to ${status.displayName}',
    );

    scaffoldMessenger.showSnackBar(
      SnackBar(
          content: Text('Service status updated to ${status.displayName}')),
    );
  }

  // Get service status color
  Color _getServiceStatusColor(ServiceStatus status) {
    switch (status) {
      case ServiceStatus.active:
        return Colors.green;
      case ServiceStatus.retired:
        return Colors.blue;
      case ServiceStatus.resigned:
        return Colors.orange;
      case ServiceStatus.awol:
        return Colors.red;
      case ServiceStatus.deserted:
        return Colors.grey;
      case ServiceStatus.dismissed:
        return Colors.purple;
    }
  }
}
