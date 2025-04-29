import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/design_system.dart';
import '../providers/personnel_provider.dart';
import '../providers/access_log_provider.dart';
import '../widgets/platform_aware_widgets.dart';
import '../utils/responsive_utils.dart';
import '../models/personnel_model.dart';
import '../models/access_log_model.dart';

// Enum for sorting personnel
enum SortField {
  name,
  rank,
  armyNumber,
  unit,
  corps,
  serviceStatus,
  dateRegistered,
  lastVerified,
  yearsOfService,
  dateOfBirth,
  enlistmentDate
}

// Enum for sort direction
enum SortDirection { ascending, descending }

// Enum for view modes
enum ViewMode { list, grid, details, cards, table, compact }

// Class to represent a sort configuration
class SortConfig {
  final SortField field;
  final SortDirection direction;

  SortConfig(this.field, this.direction);

  SortConfig copyWith({SortField? field, SortDirection? direction}) {
    return SortConfig(
      field ?? this.field,
      direction ?? this.direction,
    );
  }

  // For serialization
  Map<String, dynamic> toJson() {
    return {
      'field': field.toString().split('.').last,
      'direction': direction.toString().split('.').last,
    };
  }

  // For deserialization
  factory SortConfig.fromJson(Map<String, dynamic> json) {
    return SortConfig(
      SortField.values.firstWhere(
        (e) => e.toString().split('.').last == json['field'],
        orElse: () => SortField.name,
      ),
      SortDirection.values.firstWhere(
        (e) => e.toString().split('.').last == json['direction'],
        orElse: () => SortDirection.ascending,
      ),
    );
  }
}

// Class to represent a filter configuration
class FilterConfig {
  final String? searchQuery;
  final PersonnelCategory? category;
  final Rank? rank;
  final Corps? corps;
  final ServiceStatus? serviceStatus;
  final VerificationStatus? verificationStatus;
  final DateTime? enlistmentDateStart;
  final DateTime? enlistmentDateEnd;
  final int? yearsOfServiceMin;
  final int? yearsOfServiceMax;
  final String? unit;

  FilterConfig({
    this.searchQuery,
    this.category,
    this.rank,
    this.corps,
    this.serviceStatus,
    this.verificationStatus,
    this.enlistmentDateStart,
    this.enlistmentDateEnd,
    this.yearsOfServiceMin,
    this.yearsOfServiceMax,
    this.unit,
  });

  FilterConfig copyWith({
    String? searchQuery,
    PersonnelCategory? category,
    Rank? rank,
    Corps? corps,
    ServiceStatus? serviceStatus,
    VerificationStatus? verificationStatus,
    DateTime? enlistmentDateStart,
    DateTime? enlistmentDateEnd,
    int? yearsOfServiceMin,
    int? yearsOfServiceMax,
    String? unit,
    bool clearSearchQuery = false,
    bool clearCategory = false,
    bool clearRank = false,
    bool clearCorps = false,
    bool clearServiceStatus = false,
    bool clearVerificationStatus = false,
    bool clearEnlistmentDateStart = false,
    bool clearEnlistmentDateEnd = false,
    bool clearYearsOfServiceMin = false,
    bool clearYearsOfServiceMax = false,
    bool clearUnit = false,
  }) {
    return FilterConfig(
      searchQuery: clearSearchQuery ? null : searchQuery ?? this.searchQuery,
      category: clearCategory ? null : category ?? this.category,
      rank: clearRank ? null : rank ?? this.rank,
      corps: clearCorps ? null : corps ?? this.corps,
      serviceStatus:
          clearServiceStatus ? null : serviceStatus ?? this.serviceStatus,
      verificationStatus: clearVerificationStatus
          ? null
          : verificationStatus ?? this.verificationStatus,
      enlistmentDateStart: clearEnlistmentDateStart
          ? null
          : enlistmentDateStart ?? this.enlistmentDateStart,
      enlistmentDateEnd: clearEnlistmentDateEnd
          ? null
          : enlistmentDateEnd ?? this.enlistmentDateEnd,
      yearsOfServiceMin: clearYearsOfServiceMin
          ? null
          : yearsOfServiceMin ?? this.yearsOfServiceMin,
      yearsOfServiceMax: clearYearsOfServiceMax
          ? null
          : yearsOfServiceMax ?? this.yearsOfServiceMax,
      unit: clearUnit ? null : unit ?? this.unit,
    );
  }

  bool get isEmpty =>
      searchQuery == null &&
      category == null &&
      rank == null &&
      corps == null &&
      serviceStatus == null &&
      verificationStatus == null &&
      enlistmentDateStart == null &&
      enlistmentDateEnd == null &&
      yearsOfServiceMin == null &&
      yearsOfServiceMax == null &&
      unit == null;

  int get activeFilterCount {
    int count = 0;
    if (searchQuery != null && searchQuery!.isNotEmpty) count++;
    if (category != null) count++;
    if (rank != null) count++;
    if (corps != null) count++;
    if (serviceStatus != null) count++;
    if (verificationStatus != null) count++;
    if (enlistmentDateStart != null) count++;
    if (enlistmentDateEnd != null) count++;
    if (yearsOfServiceMin != null) count++;
    if (yearsOfServiceMax != null) count++;
    if (unit != null && unit!.isNotEmpty) count++;
    return count;
  }

  // For serialization
  Map<String, dynamic> toJson() {
    return {
      'searchQuery': searchQuery,
      'category': category?.toString().split('.').last,
      'rank': rank?.toString().split('.').last,
      'corps': corps?.toString().split('.').last,
      'serviceStatus': serviceStatus?.toString().split('.').last,
      'verificationStatus': verificationStatus?.toString().split('.').last,
      'enlistmentDateStart': enlistmentDateStart?.toIso8601String(),
      'enlistmentDateEnd': enlistmentDateEnd?.toIso8601String(),
      'yearsOfServiceMin': yearsOfServiceMin,
      'yearsOfServiceMax': yearsOfServiceMax,
      'unit': unit,
    };
  }

  // For deserialization
  factory FilterConfig.fromJson(Map<String, dynamic> json) {
    PersonnelCategory? category;
    if (json['category'] != null) {
      try {
        category = PersonnelCategory.values.firstWhere(
          (e) => e.toString().split('.').last == json['category'],
        );
      } catch (_) {}
    }

    Rank? rank;
    if (json['rank'] != null) {
      try {
        rank = Rank.values.firstWhere(
          (e) => e.toString().split('.').last == json['rank'],
        );
      } catch (_) {}
    }

    Corps? corps;
    if (json['corps'] != null) {
      try {
        corps = Corps.values.firstWhere(
          (e) => e.toString().split('.').last == json['corps'],
        );
      } catch (_) {}
    }

    ServiceStatus? serviceStatus;
    if (json['serviceStatus'] != null) {
      try {
        serviceStatus = ServiceStatus.values.firstWhere(
          (e) => e.toString().split('.').last == json['serviceStatus'],
        );
      } catch (_) {}
    }

    VerificationStatus? verificationStatus;
    if (json['verificationStatus'] != null) {
      try {
        verificationStatus = VerificationStatus.values.firstWhere(
          (e) => e.toString().split('.').last == json['verificationStatus'],
        );
      } catch (_) {}
    }

    return FilterConfig(
      searchQuery: json['searchQuery'],
      category: category,
      rank: rank,
      corps: corps,
      serviceStatus: serviceStatus,
      verificationStatus: verificationStatus,
      enlistmentDateStart: json['enlistmentDateStart'] != null
          ? DateTime.parse(json['enlistmentDateStart'])
          : null,
      enlistmentDateEnd: json['enlistmentDateEnd'] != null
          ? DateTime.parse(json['enlistmentDateEnd'])
          : null,
      yearsOfServiceMin: json['yearsOfServiceMin'],
      yearsOfServiceMax: json['yearsOfServiceMax'],
      unit: json['unit'],
    );
  }
}

// Class to represent a saved filter preset
class FilterPreset {
  final String name;
  final FilterConfig filterConfig;

  FilterPreset(this.name, this.filterConfig);

  // For serialization
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'filterConfig': filterConfig.toJson(),
    };
  }

  // For deserialization
  factory FilterPreset.fromJson(Map<String, dynamic> json) {
    return FilterPreset(
      json['name'],
      FilterConfig.fromJson(json['filterConfig']),
    );
  }
}

class PersonnelDatabaseScreen extends StatefulWidget {
  const PersonnelDatabaseScreen({Key? key}) : super(key: key);

  @override
  State<PersonnelDatabaseScreen> createState() =>
      _PersonnelDatabaseScreenState();
}

class _PersonnelDatabaseScreenState extends State<PersonnelDatabaseScreen> {
  // Filter configuration
  FilterConfig _filterConfig = FilterConfig();

  // List of saved filter presets
  List<FilterPreset> _filterPresets = [];

  // Primary sort configuration
  SortConfig _primarySort = SortConfig(SortField.name, SortDirection.ascending);

  // Secondary sort configuration (optional)
  SortConfig? _secondarySort;

  // View mode
  ViewMode _viewMode = ViewMode.list;

  // Show filter panel
  bool _showFilterPanel = false;

  // Show advanced options
  bool _showAdvancedOptions = false;

  // For backward compatibility
  String get _searchQuery => _filterConfig.searchQuery ?? '';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  // Load all saved preferences
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    // Load view mode
    final viewModeIndex = prefs.getInt('personnel_view_mode');
    if (viewModeIndex != null &&
        viewModeIndex >= 0 &&
        viewModeIndex < ViewMode.values.length) {
      setState(() {
        _viewMode = ViewMode.values[viewModeIndex];
      });
    }

    // Load sort configuration
    final sortFieldString = prefs.getString('personnel_sort_field');
    final sortDirection = prefs.getBool('personnel_sort_ascending');

    if (sortFieldString != null) {
      try {
        final sortField = SortField.values.firstWhere(
          (field) => field.toString().split('.').last == sortFieldString,
          orElse: () => SortField.name,
        );

        setState(() {
          _primarySort = SortConfig(
            sortField,
            sortDirection == false
                ? SortDirection.descending
                : SortDirection.ascending,
          );
        });
      } catch (e) {
        // Ignore errors and use default
      }
    }

    // Load filter presets
    final presetsJson = prefs.getString('personnel_filter_presets');
    if (presetsJson != null) {
      try {
        final List<dynamic> presetsList = jsonDecode(presetsJson);
        setState(() {
          _filterPresets =
              presetsList.map((json) => FilterPreset.fromJson(json)).toList();
        });
      } catch (e) {
        // Ignore errors and use empty list
      }
    }

    // Load last used filter
    final lastFilterJson = prefs.getString('personnel_last_filter');
    if (lastFilterJson != null) {
      try {
        setState(() {
          _filterConfig = FilterConfig.fromJson(jsonDecode(lastFilterJson));
        });
      } catch (e) {
        // Ignore errors and use default
      }
    }
  }

  // Save all preferences
  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();

    // Save view mode
    await prefs.setInt('personnel_view_mode', _viewMode.index);

    // Save sort configuration
    await prefs.setString(
        'personnel_sort_field', _primarySort.field.toString().split('.').last);
    await prefs.setBool('personnel_sort_ascending',
        _primarySort.direction == SortDirection.ascending);

    // Save filter presets
    final presetsJson =
        jsonEncode(_filterPresets.map((preset) => preset.toJson()).toList());
    await prefs.setString('personnel_filter_presets', presetsJson);

    // Save last used filter
    final lastFilterJson = jsonEncode(_filterConfig.toJson());
    await prefs.setString('personnel_last_filter', lastFilterJson);
  }

  // Save the current view mode preference
  Future<void> _saveViewModePreference(ViewMode mode) async {
    setState(() {
      _viewMode = mode;
    });
    await _savePreferences();
  }

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

  // Helper method to get sort field text
  String _getSortFieldText(SortField field) {
    switch (field) {
      case SortField.name:
        return 'Name';
      case SortField.rank:
        return 'Rank';
      case SortField.armyNumber:
        return 'Army Number';
      case SortField.unit:
        return 'Unit';
      case SortField.corps:
        return 'Corps';
      case SortField.serviceStatus:
        return 'Service Status';
      case SortField.dateRegistered:
        return 'Date Registered';
      case SortField.lastVerified:
        return 'Last Verified';
      case SortField.yearsOfService:
        return 'Years of Service';
      case SortField.dateOfBirth:
        return 'Date of Birth';
      case SortField.enlistmentDate:
        return 'Enlistment Date';
    }
  }

  // Helper method to compare personnel for sorting
  int _comparePersonnel(
      Personnel a, Personnel b, SortField field, SortDirection direction) {
    int result;

    switch (field) {
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
      case SortField.dateRegistered:
        result = a.dateRegistered.compareTo(b.dateRegistered);
        break;
      case SortField.lastVerified:
        // Handle null values for lastVerified
        if (a.lastVerified == null && b.lastVerified == null) {
          result = 0;
        } else if (a.lastVerified == null) {
          result = -1;
        } else if (b.lastVerified == null) {
          result = 1;
        } else {
          result = a.lastVerified!.compareTo(b.lastVerified!);
        }
        break;
      case SortField.yearsOfService:
        result = a.yearsOfService.compareTo(b.yearsOfService);
        break;
      case SortField.dateOfBirth:
        // Handle null values for dateOfBirth
        if (a.dateOfBirth == null && b.dateOfBirth == null) {
          result = 0;
        } else if (a.dateOfBirth == null) {
          result = -1;
        } else if (b.dateOfBirth == null) {
          result = 1;
        } else {
          result = a.dateOfBirth!.compareTo(b.dateOfBirth!);
        }
        break;
      case SortField.enlistmentDate:
        // Handle null values for enlistmentDate
        if (a.enlistmentDate == null && b.enlistmentDate == null) {
          result = 0;
        } else if (a.enlistmentDate == null) {
          result = -1;
        } else if (b.enlistmentDate == null) {
          result = 1;
        } else {
          result = a.enlistmentDate!.compareTo(b.enlistmentDate!);
        }
        break;
    }

    // Apply sort direction
    return direction == SortDirection.ascending ? result : -result;
  }

  // Helper method to get view mode text
  String _getViewModeText(ViewMode mode) {
    switch (mode) {
      case ViewMode.list:
        return 'List View';
      case ViewMode.grid:
        return 'Grid View';
      case ViewMode.details:
        return 'Details View';
      case ViewMode.cards:
        return 'Cards View';
      case ViewMode.table:
        return 'Table View';
      case ViewMode.compact:
        return 'Compact View';
    }
  }

  // Helper method to get view mode icon
  IconData _getViewModeIcon(ViewMode mode) {
    switch (mode) {
      case ViewMode.list:
        return Icons.view_list;
      case ViewMode.grid:
        return Icons.grid_view;
      case ViewMode.details:
        return Icons.view_agenda;
      case ViewMode.cards:
        return Icons.view_module;
      case ViewMode.table:
        return Icons.table_chart;
      case ViewMode.compact:
        return Icons.view_compact;
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
    // Create a temporary filter config to hold values during editing
    FilterConfig tempFilterConfig = _filterConfig;

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
                  // Search filter
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Search by name, army number, or unit',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    initialValue: tempFilterConfig.searchQuery,
                    onChanged: (value) {
                      // Update dialog state
                      setDialogState(() {
                        tempFilterConfig = tempFilterConfig.copyWith(
                          searchQuery: value.trim(),
                          clearSearchQuery: value.trim().isEmpty,
                        );
                      });
                      // Apply filter immediately to parent state
                      setState(() {
                        _filterConfig = tempFilterConfig;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

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
                        selected: tempFilterConfig.category == category,
                        onSelected: (selected) {
                          // Update dialog state
                          setDialogState(() {
                            tempFilterConfig = tempFilterConfig.copyWith(
                              category: selected ? category : null,
                              clearCategory: !selected,
                            );
                          });
                          // Apply filter immediately to parent state
                          setState(() {
                            _filterConfig = tempFilterConfig;
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
                        selected: tempFilterConfig.rank == rank,
                        onSelected: (selected) {
                          // Update dialog state
                          setDialogState(() {
                            tempFilterConfig = tempFilterConfig.copyWith(
                              rank: selected ? rank : null,
                              clearRank: !selected,
                            );
                          });
                          // Apply filter immediately to parent state
                          setState(() {
                            _filterConfig = tempFilterConfig;
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
                        selected: tempFilterConfig.corps == corps,
                        onSelected: (selected) {
                          // Update dialog state
                          setDialogState(() {
                            tempFilterConfig = tempFilterConfig.copyWith(
                              corps: selected ? corps : null,
                              clearCorps: !selected,
                            );
                          });
                          // Apply filter immediately to parent state
                          setState(() {
                            _filterConfig = tempFilterConfig;
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
                        selected: tempFilterConfig.serviceStatus == status,
                        onSelected: (selected) {
                          // Update dialog state
                          setDialogState(() {
                            tempFilterConfig = tempFilterConfig.copyWith(
                              serviceStatus: selected ? status : null,
                              clearServiceStatus: !selected,
                            );
                          });
                          // Apply filter immediately to parent state
                          setState(() {
                            _filterConfig = tempFilterConfig;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Verification status filter
                  const Text(
                    'Verification Status:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    children: VerificationStatus.values.map((status) {
                      return FilterChip(
                        label: Text(_getVerificationStatusText(status)),
                        selected: tempFilterConfig.verificationStatus == status,
                        onSelected: (selected) {
                          // Update dialog state
                          setDialogState(() {
                            tempFilterConfig = tempFilterConfig.copyWith(
                              verificationStatus: selected ? status : null,
                              clearVerificationStatus: !selected,
                            );
                          });
                          // Apply filter immediately to parent state
                          setState(() {
                            _filterConfig = tempFilterConfig;
                          });
                        },
                      );
                    }).toList(),
                  ),

                  // Advanced filters section
                  ExpansionTile(
                    title: const Text('Advanced Filters'),
                    initiallyExpanded: _showAdvancedOptions,
                    onExpansionChanged: (expanded) {
                      setState(() {
                        _showAdvancedOptions = expanded;
                      });
                    },
                    children: [
                      // Unit filter
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Unit',
                            hintText: 'Filter by unit',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          initialValue: tempFilterConfig.unit,
                          onChanged: (value) {
                            // Update dialog state
                            setDialogState(() {
                              tempFilterConfig = tempFilterConfig.copyWith(
                                unit: value.trim(),
                                clearUnit: value.trim().isEmpty,
                              );
                            });
                            // Apply filter immediately to parent state
                            setState(() {
                              _filterConfig = tempFilterConfig;
                            });
                          },
                        ),
                      ),

                      // Years of service range
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Min Years',
                                  hintText: 'Min',
                                ),
                                keyboardType: TextInputType.number,
                                initialValue: tempFilterConfig.yearsOfServiceMin
                                    ?.toString(),
                                onChanged: (value) {
                                  // Update dialog state
                                  setDialogState(() {
                                    tempFilterConfig =
                                        tempFilterConfig.copyWith(
                                      yearsOfServiceMin: value.isNotEmpty
                                          ? int.tryParse(value)
                                          : null,
                                      clearYearsOfServiceMin: value.isEmpty,
                                    );
                                  });
                                  // Apply filter immediately to parent state
                                  setState(() {
                                    _filterConfig = tempFilterConfig;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Max Years',
                                  hintText: 'Max',
                                ),
                                keyboardType: TextInputType.number,
                                initialValue: tempFilterConfig.yearsOfServiceMax
                                    ?.toString(),
                                onChanged: (value) {
                                  // Update dialog state
                                  setDialogState(() {
                                    tempFilterConfig =
                                        tempFilterConfig.copyWith(
                                      yearsOfServiceMax: value.isNotEmpty
                                          ? int.tryParse(value)
                                          : null,
                                      clearYearsOfServiceMax: value.isEmpty,
                                    );
                                  });
                                  // Apply filter immediately to parent state
                                  setState(() {
                                    _filterConfig = tempFilterConfig;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                    tempFilterConfig = FilterConfig();
                  });
                  // Apply to parent state
                  setState(() {
                    _filterConfig = FilterConfig();
                  });
                  // Save preferences
                  _savePreferences();
                },
                child: const Text('CLEAR ALL'),
              ),
              TextButton(
                onPressed: () {
                  // Save filter as preset
                  if (tempFilterConfig.activeFilterCount > 0) {
                    _showSaveFilterPresetDialog(context, tempFilterConfig);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cannot save empty filter'),
                      ),
                    );
                  }
                },
                child: const Text('SAVE FILTER'),
              ),
            ],
          );
        },
      ),
    );
  }

  // Show dialog to save filter preset
  void _showSaveFilterPresetDialog(
      BuildContext context, FilterConfig filterConfig) {
    String presetName = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Filter Preset'),
        content: TextField(
          decoration: const InputDecoration(
            labelText: 'Preset Name',
            hintText: 'Enter a name for this filter preset',
          ),
          onChanged: (value) {
            presetName = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              if (presetName.isNotEmpty) {
                setState(() {
                  _filterPresets.add(FilterPreset(presetName, filterConfig));
                });
                _savePreferences();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Filter preset "$presetName" saved'),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a name for the preset'),
                  ),
                );
              }
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }

  // Show sort dialog
  void _showSortDialog(BuildContext context) {
    // Create temporary sort config
    SortConfig tempPrimarySort = _primarySort;
    SortConfig? tempSecondarySort = _secondarySort;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Sort Personnel'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Primary sort
                  const Text(
                    'Primary Sort:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Field selection
                  DropdownButtonFormField<SortField>(
                    decoration: const InputDecoration(
                      labelText: 'Sort by',
                      border: OutlineInputBorder(),
                    ),
                    value: tempPrimarySort.field,
                    items: SortField.values.map((field) {
                      return DropdownMenuItem<SortField>(
                        value: field,
                        child: Text(_getSortFieldText(field)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          tempPrimarySort =
                              tempPrimarySort.copyWith(field: value);
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  // Direction selection
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<SortDirection>(
                          title: const Text('Ascending'),
                          value: SortDirection.ascending,
                          groupValue: tempPrimarySort.direction,
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() {
                                tempPrimarySort =
                                    tempPrimarySort.copyWith(direction: value);
                              });
                            }
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<SortDirection>(
                          title: const Text('Descending'),
                          value: SortDirection.descending,
                          groupValue: tempPrimarySort.direction,
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() {
                                tempPrimarySort =
                                    tempPrimarySort.copyWith(direction: value);
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),

                  const Divider(),

                  // Secondary sort (optional)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Secondary Sort:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Switch(
                        value: tempSecondarySort != null,
                        onChanged: (value) {
                          setDialogState(() {
                            if (value) {
                              // Enable secondary sort with a default that's different from primary
                              final availableFields = SortField.values
                                  .where(
                                      (field) => field != tempPrimarySort.field)
                                  .toList();

                              tempSecondarySort = SortConfig(
                                  availableFields.first,
                                  SortDirection.ascending);
                            } else {
                              // Disable secondary sort
                              tempSecondarySort = null;
                            }
                          });
                        },
                      ),
                    ],
                  ),

                  if (tempSecondarySort != null) ...[
                    const SizedBox(height: 8),

                    // Secondary field selection
                    DropdownButtonFormField<SortField>(
                      decoration: const InputDecoration(
                        labelText: 'Sort by',
                        border: OutlineInputBorder(),
                      ),
                      value: tempSecondarySort!.field,
                      items: SortField.values
                          .where((field) => field != tempPrimarySort.field)
                          .map((field) {
                        return DropdownMenuItem<SortField>(
                          value: field,
                          child: Text(_getSortFieldText(field)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            tempSecondarySort =
                                tempSecondarySort!.copyWith(field: value);
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 16),

                    // Secondary direction selection
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<SortDirection>(
                            title: const Text('Ascending'),
                            value: SortDirection.ascending,
                            groupValue: tempSecondarySort!.direction,
                            onChanged: (value) {
                              if (value != null) {
                                setDialogState(() {
                                  tempSecondarySort = tempSecondarySort!
                                      .copyWith(direction: value);
                                });
                              }
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<SortDirection>(
                            title: const Text('Descending'),
                            value: SortDirection.descending,
                            groupValue: tempSecondarySort!.direction,
                            onChanged: (value) {
                              if (value != null) {
                                setDialogState(() {
                                  tempSecondarySort = tempSecondarySort!
                                      .copyWith(direction: value);
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _primarySort = tempPrimarySort;
                    _secondarySort = tempSecondarySort;
                  });
                  _savePreferences();
                  Navigator.of(context).pop();
                },
                child: const Text('APPLY'),
              ),
            ],
          );
        },
      ),
    );
  }

  // Show view mode dialog
  void _showViewModeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select View Mode'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ViewMode>(
              title: const Text('List View'),
              subtitle: const Text('Compact list of personnel'),
              value: ViewMode.list,
              groupValue: _viewMode,
              secondary: const Icon(Icons.view_list),
              onChanged: (value) {
                setState(() {
                  _viewMode = value!;
                });
                _saveViewModePreference(value!);
                Navigator.of(context).pop();
              },
            ),
            RadioListTile<ViewMode>(
              title: const Text('Grid View'),
              subtitle: const Text('Grid of personnel cards'),
              value: ViewMode.grid,
              groupValue: _viewMode,
              secondary: const Icon(Icons.grid_view),
              onChanged: (value) {
                setState(() {
                  _viewMode = value!;
                });
                _saveViewModePreference(value!);
                Navigator.of(context).pop();
              },
            ),
            RadioListTile<ViewMode>(
              title: const Text('Details View'),
              subtitle: const Text('Detailed information'),
              value: ViewMode.details,
              groupValue: _viewMode,
              secondary: const Icon(Icons.view_agenda),
              onChanged: (value) {
                setState(() {
                  _viewMode = value!;
                });
                _saveViewModePreference(value!);
                Navigator.of(context).pop();
              },
            ),
            RadioListTile<ViewMode>(
              title: const Text('Cards View'),
              subtitle: const Text('Visual card layout'),
              value: ViewMode.cards,
              groupValue: _viewMode,
              secondary: const Icon(Icons.view_module),
              onChanged: (value) {
                setState(() {
                  _viewMode = value!;
                });
                _saveViewModePreference(value!);
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
      final matchesSearch = _filterConfig.searchQuery == null ||
          _filterConfig.searchQuery!.isEmpty ||
          personnel.fullName
              .toLowerCase()
              .contains(_filterConfig.searchQuery!.toLowerCase()) ||
          personnel.armyNumber
              .toLowerCase()
              .contains(_filterConfig.searchQuery!.toLowerCase()) ||
          personnel.unit
              .toLowerCase()
              .contains(_filterConfig.searchQuery!.toLowerCase());

      // Apply category filter
      final matchesCategory = _filterConfig.category == null ||
          personnel.category == _filterConfig.category;

      // Apply rank filter
      final matchesRank =
          _filterConfig.rank == null || personnel.rank == _filterConfig.rank;

      // Apply corps filter
      final matchesCorps =
          _filterConfig.corps == null || personnel.corps == _filterConfig.corps;

      // Apply service status filter
      final matchesServiceStatus = _filterConfig.serviceStatus == null ||
          personnel.serviceStatus == _filterConfig.serviceStatus;

      // Apply verification status filter
      final matchesVerificationStatus =
          _filterConfig.verificationStatus == null ||
              personnel.status == _filterConfig.verificationStatus;

      // Apply unit filter
      final matchesUnit = _filterConfig.unit == null ||
          _filterConfig.unit!.isEmpty ||
          personnel.unit
              .toLowerCase()
              .contains(_filterConfig.unit!.toLowerCase());

      // Apply years of service filter
      final matchesYearsOfService = (_filterConfig.yearsOfServiceMin == null ||
              personnel.yearsOfService >= _filterConfig.yearsOfServiceMin!) &&
          (_filterConfig.yearsOfServiceMax == null ||
              personnel.yearsOfService <= _filterConfig.yearsOfServiceMax!);

      return matchesSearch &&
          matchesCategory &&
          matchesRank &&
          matchesCorps &&
          matchesServiceStatus &&
          matchesVerificationStatus &&
          matchesUnit &&
          matchesYearsOfService;
    }).toList();

    // Sort the filtered list
    filteredPersonnel.sort((a, b) {
      int result;

      // Primary sort
      result =
          _comparePersonnel(a, b, _primarySort.field, _primarySort.direction);

      // Secondary sort if needed
      if (result == 0 && _secondarySort != null) {
        result = _comparePersonnel(
            a, b, _secondarySort!.field, _secondarySort!.direction);
      }

      return result;
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
                controller: TextEditingController(text: _searchQuery),
                onChanged: (value) {
                  setState(() {
                    // Update search query
                    _filterConfig = _filterConfig.copyWith(
                      searchQuery: value.trim(),
                      clearSearchQuery: value.trim().isEmpty,
                    );
                  });
                },
              ),
              const SizedBox(height: 16),

              // Filter, sort, and view controls
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
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: Icon(_getViewModeIcon(_viewMode)),
                      label: const Text('View'),
                      onPressed: () => _showViewModeDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DesignSystem.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              // Filter panel
              if (_filterConfig.activeFilterCount > 0 || _showFilterPanel)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: _showFilterPanel ? null : 50,
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with filter count and toggle
                        InkWell(
                          onTap: () {
                            setState(() {
                              _showFilterPanel = !_showFilterPanel;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            child: Row(
                              children: [
                                Text(
                                  'Active Filters (${_filterConfig.activeFilterCount})',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                if (_filterConfig.activeFilterCount > 0)
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _filterConfig = FilterConfig();
                                      });
                                      _savePreferences();
                                    },
                                    child: const Text('Clear All'),
                                  ),
                                IconButton(
                                  icon: Icon(_showFilterPanel
                                      ? Icons.expand_less
                                      : Icons.expand_more),
                                  onPressed: () {
                                    setState(() {
                                      _showFilterPanel = !_showFilterPanel;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Filter chips
                        if (_showFilterPanel)
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 16.0, right: 16.0, bottom: 16.0),
                            child: Wrap(
                              spacing: 8.0,
                              runSpacing: 8.0,
                              children: [
                                if (_filterConfig.searchQuery != null &&
                                    _filterConfig.searchQuery!.isNotEmpty)
                                  Chip(
                                    avatar: const Icon(Icons.search, size: 16),
                                    label: Text(
                                        'Search: ${_filterConfig.searchQuery}'),
                                    deleteIcon:
                                        const Icon(Icons.close, size: 16),
                                    backgroundColor:
                                        DesignSystem.primaryColor.withAlpha(50),
                                    deleteIconColor: DesignSystem.primaryColor,
                                    onDeleted: () {
                                      setState(() {
                                        _filterConfig = _filterConfig.copyWith(
                                          clearSearchQuery: true,
                                        );
                                      });
                                    },
                                  ),
                                if (_filterConfig.category != null)
                                  Chip(
                                    avatar:
                                        const Icon(Icons.category, size: 16),
                                    label: Text(_getCategoryText(
                                        _filterConfig.category!)),
                                    deleteIcon:
                                        const Icon(Icons.close, size: 16),
                                    backgroundColor:
                                        DesignSystem.primaryColor.withAlpha(50),
                                    deleteIconColor: DesignSystem.primaryColor,
                                    onDeleted: () {
                                      setState(() {
                                        _filterConfig = _filterConfig.copyWith(
                                          clearCategory: true,
                                        );
                                      });
                                    },
                                  ),
                                if (_filterConfig.rank != null)
                                  Chip(
                                    avatar: const Icon(Icons.military_tech,
                                        size: 16),
                                    label: Text(_filterConfig.rank!.shortName),
                                    deleteIcon:
                                        const Icon(Icons.close, size: 16),
                                    backgroundColor:
                                        DesignSystem.primaryColor.withAlpha(50),
                                    deleteIconColor: DesignSystem.primaryColor,
                                    onDeleted: () {
                                      setState(() {
                                        _filterConfig = _filterConfig.copyWith(
                                          clearRank: true,
                                        );
                                      });
                                    },
                                  ),
                                if (_filterConfig.corps != null)
                                  Chip(
                                    avatar: const Icon(Icons.group, size: 16),
                                    label: Text(
                                        _getCorpsText(_filterConfig.corps!)),
                                    deleteIcon:
                                        const Icon(Icons.close, size: 16),
                                    backgroundColor:
                                        DesignSystem.primaryColor.withAlpha(50),
                                    deleteIconColor: DesignSystem.primaryColor,
                                    onDeleted: () {
                                      setState(() {
                                        _filterConfig = _filterConfig.copyWith(
                                          clearCorps: true,
                                        );
                                      });
                                    },
                                  ),
                                if (_filterConfig.serviceStatus != null)
                                  Chip(
                                    avatar: const Icon(Icons.work, size: 16),
                                    label: Text(_filterConfig
                                        .serviceStatus!.displayName),
                                    deleteIcon:
                                        const Icon(Icons.close, size: 16),
                                    backgroundColor:
                                        DesignSystem.primaryColor.withAlpha(50),
                                    deleteIconColor: DesignSystem.primaryColor,
                                    onDeleted: () {
                                      setState(() {
                                        _filterConfig = _filterConfig.copyWith(
                                          clearServiceStatus: true,
                                        );
                                      });
                                    },
                                  ),
                                if (_filterConfig.verificationStatus != null)
                                  Chip(
                                    avatar: const Icon(Icons.verified_user,
                                        size: 16),
                                    label: Text(_getVerificationStatusText(
                                        _filterConfig.verificationStatus!)),
                                    deleteIcon:
                                        const Icon(Icons.close, size: 16),
                                    backgroundColor:
                                        DesignSystem.primaryColor.withAlpha(50),
                                    deleteIconColor: DesignSystem.primaryColor,
                                    onDeleted: () {
                                      setState(() {
                                        _filterConfig = _filterConfig.copyWith(
                                          clearVerificationStatus: true,
                                        );
                                      });
                                    },
                                  ),
                                if (_filterConfig.unit != null &&
                                    _filterConfig.unit!.isNotEmpty)
                                  Chip(
                                    avatar:
                                        const Icon(Icons.business, size: 16),
                                    label: Text('Unit: ${_filterConfig.unit}'),
                                    deleteIcon:
                                        const Icon(Icons.close, size: 16),
                                    backgroundColor:
                                        DesignSystem.primaryColor.withAlpha(50),
                                    deleteIconColor: DesignSystem.primaryColor,
                                    onDeleted: () {
                                      setState(() {
                                        _filterConfig = _filterConfig.copyWith(
                                          clearUnit: true,
                                        );
                                      });
                                    },
                                  ),
                                if (_filterConfig.yearsOfServiceMin != null)
                                  Chip(
                                    avatar: const Icon(Icons.timer, size: 16),
                                    label: Text(
                                        'Min Years: ${_filterConfig.yearsOfServiceMin}'),
                                    deleteIcon:
                                        const Icon(Icons.close, size: 16),
                                    backgroundColor:
                                        DesignSystem.primaryColor.withAlpha(50),
                                    deleteIconColor: DesignSystem.primaryColor,
                                    onDeleted: () {
                                      setState(() {
                                        _filterConfig = _filterConfig.copyWith(
                                          clearYearsOfServiceMin: true,
                                        );
                                      });
                                    },
                                  ),
                                if (_filterConfig.yearsOfServiceMax != null)
                                  Chip(
                                    avatar:
                                        const Icon(Icons.timer_off, size: 16),
                                    label: Text(
                                        'Max Years: ${_filterConfig.yearsOfServiceMax}'),
                                    deleteIcon:
                                        const Icon(Icons.close, size: 16),
                                    backgroundColor:
                                        DesignSystem.primaryColor.withAlpha(50),
                                    deleteIconColor: DesignSystem.primaryColor,
                                    onDeleted: () {
                                      setState(() {
                                        _filterConfig = _filterConfig.copyWith(
                                          clearYearsOfServiceMax: true,
                                        );
                                      });
                                    },
                                  ),
                              ],
                            ),
                          ),

                        // Filter presets
                        if (_showFilterPanel && _filterPresets.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 16.0, right: 16.0, bottom: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Saved Filters:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: _filterPresets.map((preset) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: ActionChip(
                                          label: Text(preset.name),
                                          onPressed: () {
                                            setState(() {
                                              _filterConfig =
                                                  preset.filterConfig;
                                            });
                                            _savePreferences();
                                          },
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

              // Active filters and sorting display
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Always display current sorting
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.sort, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        const Text('Sorting:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        Chip(
                          backgroundColor:
                              DesignSystem.secondaryColor.withAlpha(50),
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_getSortFieldText(_primarySort.field)),
                              const SizedBox(width: 4),
                              Icon(
                                _primarySort.direction ==
                                        SortDirection.ascending
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                size: 16,
                                color: DesignSystem.secondaryColor,
                              ),
                            ],
                          ),
                          onDeleted: () => _showSortDialog(context),
                          deleteIconColor: DesignSystem.secondaryColor,
                        ),
                        if (_secondarySort != null) ...[
                          const SizedBox(width: 8),
                          Chip(
                            backgroundColor:
                                DesignSystem.secondaryColor.withAlpha(30),
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(_getSortFieldText(_secondarySort!.field)),
                                const SizedBox(width: 4),
                                Icon(
                                  _secondarySort!.direction ==
                                          SortDirection.ascending
                                      ? Icons.arrow_upward
                                      : Icons.arrow_downward,
                                  size: 16,
                                  color: DesignSystem.secondaryColor,
                                ),
                              ],
                            ),
                            onDeleted: () => _showSortDialog(context),
                            deleteIconColor: DesignSystem.secondaryColor,
                          ),
                        ],
                      ],
                    ),

                    // Display current view mode
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(_getViewModeIcon(_viewMode),
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        const Text('View Mode:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        Chip(
                          backgroundColor:
                              DesignSystem.accentColor.withAlpha(50),
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_getViewModeText(_viewMode)),
                              const SizedBox(width: 4),
                              Icon(
                                _getViewModeIcon(_viewMode),
                                size: 16,
                                color: DesignSystem.accentColor,
                              ),
                            ],
                          ),
                          onDeleted: () => _showViewModeDialog(context),
                          deleteIconColor: DesignSystem.accentColor,
                        ),
                      ],
                    ),

                    // Export button
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.download,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        const Text('Export:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.file_download, size: 16),
                          label: Text(
                              'Export ${filteredPersonnel.length} Records'),
                          onPressed: filteredPersonnel.isEmpty
                              ? null
                              : () => _exportToCSV(filteredPersonnel),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DesignSystem.accentColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            textStyle: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Personnel list
              Expanded(
                child: Builder(builder: (context) {
                  // Use the already filtered and sorted personnel list
                  if (filteredPersonnel.isEmpty) {
                    return Center(
                      child: PlatformText(
                        _filterConfig.activeFilterCount > 0
                            ? 'No personnel found matching the current filters'
                            : 'No personnel records found',
                        style: const TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    );
                  }

                  // Choose the appropriate view based on the selected view mode
                  switch (_viewMode) {
                    case ViewMode.list:
                      return _buildListView(filteredPersonnel, context);
                    case ViewMode.grid:
                      return _buildGridView(
                          filteredPersonnel, context, isDesktop, isTablet);
                    case ViewMode.details:
                      return _buildDetailsView(filteredPersonnel, context);
                    case ViewMode.cards:
                      return _buildCardsView(
                          filteredPersonnel, context, isDesktop, isTablet);
                    case ViewMode.table:
                      // Fallback to list view until table view is implemented
                      return _buildListView(filteredPersonnel, context);
                    case ViewMode.compact:
                      // Fallback to list view until compact view is implemented
                      return _buildListView(filteredPersonnel, context);
                  }
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

  // Build list view (default view)
  Widget _buildListView(List<Personnel> personnel, BuildContext context) {
    return ListView.builder(
      itemCount: personnel.length,
      itemBuilder: (context, index) {
        final person = personnel[index];
        return PlatformCard(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: DesignSystem.primaryColor.withAlpha(50),
              child: person.photoUrl != null
                  ? ClipOval(
                      child: person.photoUrl!.startsWith('http')
                          ? Image.network(
                              person.photoUrl!,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.person);
                              },
                            )
                          : Image.file(
                              File(
                                  person.photoUrl!.replaceFirst('file://', '')),
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.person);
                              },
                            ),
                    )
                  : const Icon(Icons.person),
            ),
            title: PlatformText(
              '${person.rank.shortName} ${person.initials}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PlatformText(
                  person.fullName,
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                ),
                PlatformText(
                  person.armyNumber,
                  style: const TextStyle(
                    fontSize: 12,
                    color: DesignSystem.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                _buildServiceStatusChip(person.serviceStatus),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Verification status indicator
                Tooltip(
                  message: _getVerificationStatusText(person.status),
                  child: Icon(
                    person.status == VerificationStatus.verified
                        ? Icons.verified_user
                        : person.status == VerificationStatus.rejected
                            ? Icons.cancel
                            : Icons.pending,
                    color: person.status == VerificationStatus.verified
                        ? Colors.green
                        : person.status == VerificationStatus.rejected
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
                        arguments: {'personnelId': person.id},
                      );
                    } else if (value == 'verify') {
                      _showVerificationDialog(context, person);
                    } else if (value == 'status') {
                      _showServiceStatusDialog(context, person);
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
                arguments: {'personnelId': person.id},
              );
            },
          ),
        );
      },
    );
  }

  // Build grid view
  Widget _buildGridView(List<Personnel> personnel, BuildContext context,
      bool isDesktop, bool isTablet) {
    final crossAxisCount = isDesktop
        ? 4
        : isTablet
            ? 3
            : 2;

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.75,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: personnel.length,
      itemBuilder: (context, index) {
        final person = personnel[index];
        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/personnel_detail',
              arguments: {'personnelId': person.id},
            );
          },
          child: PlatformCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 12),
                // Photo
                CircleAvatar(
                  radius: 40,
                  backgroundColor: DesignSystem.primaryColor.withAlpha(50),
                  child: person.photoUrl != null
                      ? ClipOval(
                          child: person.photoUrl!.startsWith('http')
                              ? Image.network(
                                  person.photoUrl!,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.person, size: 40);
                                  },
                                )
                              : Image.file(
                                  File(person.photoUrl!
                                      .replaceFirst('file://', '')),
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.person, size: 40);
                                  },
                                ),
                        )
                      : const Icon(Icons.person, size: 40),
                ),
                const SizedBox(height: 12),
                // Name and rank
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    children: [
                      Text(
                        '${person.rank.shortName} ${person.initials}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        person.fullName,
                        style: const TextStyle(fontSize: 12),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        person.armyNumber,
                        style: const TextStyle(
                          fontSize: 12,
                          color: DesignSystem.textSecondaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      _buildServiceStatusChip(person.serviceStatus),
                    ],
                  ),
                ),
                const Spacer(),
                // Actions
                Container(
                  decoration: BoxDecoration(
                    color: DesignSystem.primaryColor.withAlpha(20),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 18),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/edit_personnel',
                            arguments: {'personnelId': person.id},
                          );
                        },
                        tooltip: 'Edit',
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(8),
                      ),
                      IconButton(
                        icon: Icon(
                          person.status == VerificationStatus.verified
                              ? Icons.verified_user
                              : person.status == VerificationStatus.rejected
                                  ? Icons.cancel
                                  : Icons.pending,
                          size: 18,
                          color: person.status == VerificationStatus.verified
                              ? Colors.green
                              : person.status == VerificationStatus.rejected
                                  ? Colors.red
                                  : Colors.orange,
                        ),
                        onPressed: () =>
                            _showVerificationDialog(context, person),
                        tooltip: _getVerificationStatusText(person.status),
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(8),
                      ),
                      IconButton(
                        icon: const Icon(Icons.work, size: 18),
                        onPressed: () =>
                            _showServiceStatusDialog(context, person),
                        tooltip: 'Update Status',
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(8),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Build details view
  Widget _buildDetailsView(List<Personnel> personnel, BuildContext context) {
    return ListView.builder(
      itemCount: personnel.length,
      itemBuilder: (context, index) {
        final person = personnel[index];
        return PlatformCard(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with photo and basic info
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Photo
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: DesignSystem.primaryColor.withAlpha(50),
                      child: person.photoUrl != null
                          ? ClipOval(
                              child: person.photoUrl!.startsWith('http')
                                  ? Image.network(
                                      person.photoUrl!,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Icon(Icons.person,
                                            size: 40);
                                      },
                                    )
                                  : Image.file(
                                      File(person.photoUrl!
                                          .replaceFirst('file://', '')),
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Icon(Icons.person,
                                            size: 40);
                                      },
                                    ),
                            )
                          : const Icon(Icons.person, size: 40),
                    ),
                    const SizedBox(width: 16),
                    // Basic info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${person.rank.shortName} ${person.initials}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Tooltip(
                                message:
                                    _getVerificationStatusText(person.status),
                                child: Icon(
                                  person.status == VerificationStatus.verified
                                      ? Icons.verified_user
                                      : person.status ==
                                              VerificationStatus.rejected
                                          ? Icons.cancel
                                          : Icons.pending,
                                  color: person.status ==
                                          VerificationStatus.verified
                                      ? Colors.green
                                      : person.status ==
                                              VerificationStatus.rejected
                                          ? Colors.red
                                          : Colors.orange,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            person.fullName,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Army Number: ${person.armyNumber}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: DesignSystem.textSecondaryColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildServiceStatusChip(person.serviceStatus),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                // Detailed information
                _buildDetailRow('Unit', person.unit),
                _buildDetailRow('Corps', _getCorpsText(person.corps)),
                _buildDetailRow('Category', _getCategoryText(person.category)),
                if (person.enlistmentDate != null)
                  _buildDetailRow('Enlistment Date',
                      person.enlistmentDate!.toString().split(' ')[0]),
                if (person.dateOfBirth != null)
                  _buildDetailRow('Date of Birth',
                      person.dateOfBirth!.toString().split(' ')[0]),
                _buildDetailRow(
                    'Years of Service', '${person.yearsOfService} years'),
                // Actions
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Edit'),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/edit_personnel',
                          arguments: {'personnelId': person.id},
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      icon: const Icon(Icons.verified_user, size: 16),
                      label: const Text('Verify'),
                      onPressed: () => _showVerificationDialog(context, person),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      icon: const Icon(Icons.work, size: 16),
                      label: const Text('Status'),
                      onPressed: () =>
                          _showServiceStatusDialog(context, person),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Build cards view
  Widget _buildCardsView(List<Personnel> personnel, BuildContext context,
      bool isDesktop, bool isTablet) {
    final crossAxisCount = isDesktop
        ? 3
        : isTablet
            ? 2
            : 1;

    return LayoutBuilder(builder: (context, constraints) {
      // Adjust grid parameters based on available width
      final width = constraints.maxWidth;
      final isNarrow = width < 600;

      // Determine optimal crossAxisCount and childAspectRatio
      final adjustedCrossAxisCount = isNarrow ? 1 : crossAxisCount;
      final adjustedChildAspectRatio = isNarrow ? 2.0 : 1.5;

      return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: adjustedCrossAxisCount,
          childAspectRatio: adjustedChildAspectRatio,
          crossAxisSpacing: isNarrow ? 8 : 16,
          mainAxisSpacing: isNarrow ? 8 : 16,
        ),
        itemCount: personnel.length,
        itemBuilder: (context, index) {
          final person = personnel[index];
          final color = [
            Colors.blue,
            Colors.green,
            Colors.orange,
            Colors.purple,
            Colors.teal
          ][index % 5];

          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/personnel_detail',
                arguments: {'personnelId': person.id},
              );
            },
            child: PlatformCard(
              child: Stack(
                children: [
                  // Background design
                  Positioned(
                    right: -20,
                    bottom: -20,
                    child: Icon(
                      Icons.shield,
                      size: 120,
                      color: color.withAlpha(30),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: color.withAlpha(50),
                              child: person.photoUrl != null
                                  ? ClipOval(
                                      child: person.photoUrl!.startsWith('http')
                                          ? Image.network(
                                              person.photoUrl!,
                                              width: 40,
                                              height: 40,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return const Icon(Icons.person);
                                              },
                                            )
                                          : Image.file(
                                              File(person.photoUrl!
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
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${person.rank.shortName} ${person.initials}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    person.fullName,
                                    style: const TextStyle(fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              person.status == VerificationStatus.verified
                                  ? Icons.verified_user
                                  : person.status == VerificationStatus.rejected
                                      ? Icons.cancel
                                      : Icons.pending,
                              color: person.status ==
                                      VerificationStatus.verified
                                  ? Colors.green
                                  : person.status == VerificationStatus.rejected
                                      ? Colors.red
                                      : Colors.orange,
                              size: 16,
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        // Details
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Army Number',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: DesignSystem.textSecondaryColor,
                                    ),
                                  ),
                                  Text(
                                    person.armyNumber,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Unit',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: DesignSystem.textSecondaryColor,
                                    ),
                                  ),
                                  Text(
                                    person.unit,
                                    style: const TextStyle(fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Corps',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: DesignSystem.textSecondaryColor,
                                    ),
                                  ),
                                  Text(
                                    _getCorpsText(person.corps),
                                    style: const TextStyle(fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Status',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: DesignSystem.textSecondaryColor,
                                    ),
                                  ),
                                  _buildServiceStatusChip(person.serviceStatus),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  // Helper method to build a detail row for the details view
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  // Build service status chip
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
      case ServiceStatus.discharged:
        chipColor = Colors.teal;
        break;
      case ServiceStatus.deceased:
        chipColor = Colors.black;
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
      case ServiceStatus.discharged:
        return Colors.teal;
      case ServiceStatus.deceased:
        return Colors.black;
    }
  }

  // Export personnel data to CSV
  Future<void> _exportToCSV(List<Personnel> personnel) async {
    if (personnel.isEmpty) {
      return;
    }

    // Create CSV header
    final StringBuffer csvContent = StringBuffer();
    csvContent.writeln(
        'Army Number,Rank,Name,Initials,Category,Corps,Unit,Service Status,'
        'Verification Status,Years of Service,Enlistment Date,Date of Birth,'
        'Date Registered,Last Verified');

    // Add personnel data
    for (final person in personnel) {
      final String enlistmentDate = person.enlistmentDate != null
          ? '${person.enlistmentDate!.year}-${person.enlistmentDate!.month}-${person.enlistmentDate!.day}'
          : '';

      final String dateOfBirth = person.dateOfBirth != null
          ? '${person.dateOfBirth!.year}-${person.dateOfBirth!.month}-${person.dateOfBirth!.day}'
          : '';

      final String lastVerified = person.lastVerified != null
          ? '${person.lastVerified!.year}-${person.lastVerified!.month}-${person.lastVerified!.day}'
          : '';

      final String dateRegistered =
          '${person.dateRegistered.year}-${person.dateRegistered.month}-${person.dateRegistered.day}';

      csvContent.writeln(
          '"${person.armyNumber}","${person.rank.displayName}","${person.fullName}",'
          '"${person.initials}","${_getCategoryText(person.category)}",'
          '"${_getCorpsText(person.corps)}","${person.unit}",'
          '"${person.serviceStatus.displayName}","${_getVerificationStatusText(person.status)}",'
          '"${person.yearsOfService}","$enlistmentDate","$dateOfBirth",'
          '"$dateRegistered","$lastVerified"');
    }

    try {
      // Get the downloads directory
      final String downloadsPath = await _getDownloadsPath();
      final String timestamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .replaceAll('.', '-');
      final String filePath = '$downloadsPath/personnel_data_$timestamp.csv';

      // Write the file
      final File file = File(filePath);
      await file.writeAsString(csvContent.toString());

      // Show success message
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exported ${personnel.length} records to $filePath'),
          action: SnackBarAction(
            label: 'Open Folder',
            onPressed: () {
              // Open the downloads folder
              launchUrl(Uri.file(downloadsPath),
                  mode: LaunchMode.platformDefault);
            },
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to export data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Get downloads path
  Future<String> _getDownloadsPath() async {
    if (Platform.isWindows) {
      // On Windows, use the Downloads folder
      final String home = Platform.environment['USERPROFILE'] ?? '';
      return '$home\\Downloads';
    } else {
      // For other platforms, use the app's documents directory
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    }
  }
}
