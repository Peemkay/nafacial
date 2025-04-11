import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/design_system.dart';
import '../providers/personnel_provider.dart';
import '../providers/access_log_provider.dart';
import '../widgets/platform_aware_widgets.dart';
import '../utils/responsive_utils.dart';
import '../models/personnel_model.dart';
import '../models/access_log_model.dart';

// Enum for sorting personnel
enum SortField { name, rank, armyNumber, unit, corps, serviceStatus }

class PersonnelDatabaseScreen extends StatefulWidget {
  const PersonnelDatabaseScreen({Key? key}) : super(key: key);

  @override
  State<PersonnelDatabaseScreen> createState() =>
      _PersonnelDatabaseScreenState();
}

class _PersonnelDatabaseScreenState extends State<PersonnelDatabaseScreen> {
  // Search query
  String _searchQuery = '';

  // Filtering options
  PersonnelCategory? _selectedCategory;
  Rank? _selectedRank;
  Corps? _selectedCorps;
  ServiceStatus? _selectedServiceStatus;

  // Sorting options
  SortField _sortField = SortField.name;
  bool _sortAscending = true;

  // Helper method to get category text
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

  // Helper method to get corps text
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

  // Show filter dialog
  void _showFilterDialog(BuildContext context) {
    // Create temporary variables to hold filter values
    PersonnelCategory? tempCategory = _selectedCategory;
    Rank? tempRank = _selectedRank;
    Corps? tempCorps = _selectedCorps;
    ServiceStatus? tempServiceStatus = _selectedServiceStatus;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Filter Personnel'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category filter
                  const Text(
                    'Category:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    children: PersonnelCategory.values.map((category) {
                      return FilterChip(
                        label: Text(_getCategoryText(category)),
                        selected: tempCategory == category,
                        onSelected: (selected) {
                          // Update dialog state
                          setDialogState(() {
                            tempCategory = selected ? category : null;
                          });
                          // Apply filter immediately to parent state
                          setState(() {
                            _selectedCategory = tempCategory;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Rank filter
                  const Text(
                    'Rank:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    children: Rank.values.map((rank) {
                      return FilterChip(
                        label: Text(rank.shortName),
                        selected: tempRank == rank,
                        onSelected: (selected) {
                          // Update dialog state
                          setDialogState(() {
                            tempRank = selected ? rank : null;
                          });
                          // Apply filter immediately to parent state
                          setState(() {
                            _selectedRank = tempRank;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Corps filter
                  const Text(
                    'Corps:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    children: Corps.values.map((corps) {
                      return FilterChip(
                        label: Text(_getCorpsText(corps)),
                        selected: tempCorps == corps,
                        onSelected: (selected) {
                          // Update dialog state
                          setDialogState(() {
                            tempCorps = selected ? corps : null;
                          });
                          // Apply filter immediately to parent state
                          setState(() {
                            _selectedCorps = tempCorps;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Service status filter
                  const Text(
                    'Service Status:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    children: ServiceStatus.values.map((status) {
                      return FilterChip(
                        label: Text(status.displayName),
                        selected: tempServiceStatus == status,
                        onSelected: (selected) {
                          // Update dialog state
                          setDialogState(() {
                            tempServiceStatus = selected ? status : null;
                          });
                          // Apply filter immediately to parent state
                          setState(() {
                            _selectedServiceStatus = tempServiceStatus;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('CLOSE'),
              ),
              TextButton(
                onPressed: () {
                  // Clear all filters
                  setDialogState(() {
                    tempCategory = null;
                    tempRank = null;
                    tempCorps = null;
                    tempServiceStatus = null;
                  });
                  // Apply to parent state
                  setState(() {
                    _selectedCategory = null;
                    _selectedRank = null;
                    _selectedCorps = null;
                    _selectedServiceStatus = null;
                  });
                },
                child: const Text('CLEAR ALL'),
              ),
            ],
          );
        },
      ),
    );
  }

  // Show sort dialog
  void _showSortDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort Personnel'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<SortField>(
              title: const Text('Name'),
              value: SortField.name,
              groupValue: _sortField,
              onChanged: (value) {
                setState(() {
                  _sortField = value!;
                });
                Navigator.of(context).pop();
              },
            ),
            RadioListTile<SortField>(
              title: const Text('Rank'),
              value: SortField.rank,
              groupValue: _sortField,
              onChanged: (value) {
                setState(() {
                  _sortField = value!;
                });
                Navigator.of(context).pop();
              },
            ),
            RadioListTile<SortField>(
              title: const Text('Army Number'),
              value: SortField.armyNumber,
              groupValue: _sortField,
              onChanged: (value) {
                setState(() {
                  _sortField = value!;
                });
                Navigator.of(context).pop();
              },
            ),
            RadioListTile<SortField>(
              title: const Text('Unit'),
              value: SortField.unit,
              groupValue: _sortField,
              onChanged: (value) {
                setState(() {
                  _sortField = value!;
                });
                Navigator.of(context).pop();
              },
            ),
            RadioListTile<SortField>(
              title: const Text('Corps'),
              value: SortField.corps,
              groupValue: _sortField,
              onChanged: (value) {
                setState(() {
                  _sortField = value!;
                });
                Navigator.of(context).pop();
              },
            ),
            RadioListTile<SortField>(
              title: const Text('Service Status'),
              value: SortField.serviceStatus,
              groupValue: _sortField,
              onChanged: (value) {
                setState(() {
                  _sortField = value!;
                });
                Navigator.of(context).pop();
              },
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Ascending Order'),
              value: _sortAscending,
              onChanged: (value) {
                setState(() {
                  _sortAscending = value;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final personnelProvider = Provider.of<PersonnelProvider>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = ResponsiveUtils.isDesktop(context);
    final isTablet = ResponsiveUtils.isTablet(context);

    // Apply filters to personnel list
    final filteredPersonnel = personnelProvider.allPersonnel.where((personnel) {
      // Apply search filter
      final matchesSearch = _searchQuery.isEmpty ||
          personnel.fullName
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          personnel.armyNumber
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          personnel.unit.toLowerCase().contains(_searchQuery.toLowerCase());

      // Apply category filter
      final matchesCategory =
          _selectedCategory == null || personnel.category == _selectedCategory;

      // Apply rank filter
      final matchesRank =
          _selectedRank == null || personnel.rank == _selectedRank;

      // Apply corps filter
      final matchesCorps =
          _selectedCorps == null || personnel.corps == _selectedCorps;

      // Apply service status filter
      final matchesServiceStatus = _selectedServiceStatus == null ||
          personnel.serviceStatus == _selectedServiceStatus;

      return matchesSearch &&
          matchesCategory &&
          matchesRank &&
          matchesCorps &&
          matchesServiceStatus;
    }).toList();

    // Sort the filtered list
    filteredPersonnel.sort((a, b) {
      int result;

      switch (_sortField) {
        case SortField.name:
          result = a.fullName.compareTo(b.fullName);
          break;
        case SortField.rank:
          result = a.rank.index.compareTo(b.rank.index);
          break;
        case SortField.armyNumber:
          result = a.armyNumber.compareTo(b.armyNumber);
          break;
        case SortField.unit:
          result = a.unit.compareTo(b.unit);
          break;
        case SortField.corps:
          result = a.corps.index.compareTo(b.corps.index);
          break;
        case SortField.serviceStatus:
          result = a.serviceStatus.index.compareTo(b.serviceStatus.index);
          break;
      }

      return _sortAscending ? result : -result;
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personnel Database'),
        backgroundColor: isDarkMode
            ? DesignSystem.darkAppBarColor
            : DesignSystem.lightAppBarColor,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(DesignSystem.adjustedSpacingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              PlatformText(
                'Personnel Records',
                isTitle: true,
                style: TextStyle(
                  fontSize: isDesktop
                      ? 24
                      : isTablet
                          ? 20
                          : 18,
                ),
              ),
              const SizedBox(height: 16),

              // Search bar
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search by name or army number',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    // Update search query
                    _searchQuery = value.trim();
                  });
                },
              ),
              const SizedBox(height: 16),

              // Filter and sort controls
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.filter_list),
                      label: const Text('Filter'),
                      onPressed: () => _showFilterDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DesignSystem.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.sort),
                      label: const Text('Sort'),
                      onPressed: () => _showSortDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DesignSystem.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              // Active filters display
              if (_selectedCategory != null ||
                  _selectedRank != null ||
                  _selectedCorps != null ||
                  _selectedServiceStatus != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        if (_selectedCategory != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Chip(
                              label: Text(
                                  'Category: ${_getCategoryText(_selectedCategory!)}'),
                              onDeleted: () {
                                setState(() {
                                  _selectedCategory = null;
                                });
                              },
                            ),
                          ),
                        if (_selectedRank != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Chip(
                              label: Text('Rank: ${_selectedRank!.shortName}'),
                              onDeleted: () {
                                setState(() {
                                  _selectedRank = null;
                                });
                              },
                            ),
                          ),
                        if (_selectedCorps != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Chip(
                              label: Text(
                                  'Corps: ${_getCorpsText(_selectedCorps!)}'),
                              onDeleted: () {
                                setState(() {
                                  _selectedCorps = null;
                                });
                              },
                            ),
                          ),
                        if (_selectedServiceStatus != null)
                          Chip(
                            label: Text(
                                'Status: ${_selectedServiceStatus!.displayName}'),
                            onDeleted: () {
                              setState(() {
                                _selectedServiceStatus = null;
                              });
                            },
                          ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Personnel list
              Expanded(
                child: Builder(builder: (context) {
                  // Filter personnel based on search query
                  final filteredPersonnel = personnelProvider.allPersonnel
                      .where((p) =>
                          _searchQuery.isEmpty ||
                          p.fullName
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase()) ||
                          p.armyNumber
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase()))
                      .toList();

                  if (filteredPersonnel.isEmpty) {
                    return Center(
                      child: PlatformText(
                        _searchQuery.isNotEmpty
                            ? 'No personnel found matching "$_searchQuery"'
                            : 'No personnel records found',
                        style: const TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredPersonnel.length,
                    itemBuilder: (context, index) {
                      final personnel = filteredPersonnel[index];
                      return PlatformCard(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                DesignSystem.primaryColor.withAlpha(50),
                            child: personnel.photoUrl != null
                                ? ClipOval(
                                    child: personnel.photoUrl!
                                            .startsWith('http')
                                        ? Image.network(
                                            personnel.photoUrl!,
                                            width: 40,
                                            height: 40,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return const Icon(Icons.person);
                                            },
                                          )
                                        : Image.file(
                                            File(personnel.photoUrl!
                                                .replaceFirst('file://', '')),
                                            width: 40,
                                            height: 40,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return const Icon(Icons.person);
                                            },
                                          ),
                                  )
                                : const Icon(Icons.person),
                          ),
                          title: PlatformText(
                            '${personnel.rank.shortName} ${personnel.initials}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              PlatformText(
                                personnel.fullName,
                                style: const TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                              PlatformText(
                                personnel.armyNumber,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: DesignSystem.textSecondaryColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              _buildServiceStatusChip(personnel.serviceStatus),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Verification status indicator
                              Tooltip(
                                message: _getVerificationStatusText(
                                    personnel.status),
                                child: Icon(
                                  personnel.status ==
                                          VerificationStatus.verified
                                      ? Icons.verified_user
                                      : personnel.status ==
                                              VerificationStatus.rejected
                                          ? Icons.cancel
                                          : Icons.pending,
                                  color: personnel.status ==
                                          VerificationStatus.verified
                                      ? Colors.green
                                      : personnel.status ==
                                              VerificationStatus.rejected
                                          ? Colors.red
                                          : Colors.orange,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Popup menu for quick actions
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert, size: 16),
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    // Navigate to edit personnel screen
                                    Navigator.pushNamed(
                                      context,
                                      '/edit_personnel',
                                      arguments: {'personnelId': personnel.id},
                                    );
                                  } else if (value == 'verify') {
                                    _showVerificationDialog(context, personnel);
                                  } else if (value == 'status') {
                                    _showServiceStatusDialog(
                                        context, personnel);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem<String>(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, size: 16),
                                        SizedBox(width: 8),
                                        Text('Edit'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem<String>(
                                    value: 'verify',
                                    child: Row(
                                      children: [
                                        Icon(Icons.verified_user, size: 16),
                                        SizedBox(width: 8),
                                        Text('Verify'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem<String>(
                                    value: 'status',
                                    child: Row(
                                      children: [
                                        Icon(Icons.work, size: 16),
                                        SizedBox(width: 8),
                                        Text('Update Status'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          onTap: () {
                            // Navigate to personnel detail screen
                            Navigator.pushNamed(
                              context,
                              '/personnel_detail',
                              arguments: {'personnelId': personnel.id},
                            );
                          },
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to personnel registration screen
          Navigator.pushNamed(context, '/register_personnel');
        },
        backgroundColor: DesignSystem.primaryColor,
        child: const Icon(Icons.add),
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Get verification status text
  String _getVerificationStatusText(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.pending:
        return 'Pending Verification';
      case VerificationStatus.verified:
        return 'Verified';
      case VerificationStatus.rejected:
        return 'Verification Rejected';
    }
  }

  // Show verification dialog
  void _showVerificationDialog(BuildContext context, Personnel personnel) {
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
                      personnel,
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
                      personnel,
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
    Personnel personnel,
    VerificationStatus status,
  ) async {
    // Get a local reference to the context to avoid using it after async gaps
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final personnelProvider =
        Provider.of<PersonnelProvider>(context, listen: false);
    final accessLogProvider =
        Provider.of<AccessLogProvider>(context, listen: false);

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

  // Show service status dialog
  void _showServiceStatusDialog(BuildContext context, Personnel personnel) {
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
                  _updateServiceStatus(context, personnel, selectedStatus);
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
    Personnel personnel,
    ServiceStatus status,
  ) async {
    // Get a local reference to the context to avoid using it after async gaps
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final personnelProvider =
        Provider.of<PersonnelProvider>(context, listen: false);
    final accessLogProvider =
        Provider.of<AccessLogProvider>(context, listen: false);

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
