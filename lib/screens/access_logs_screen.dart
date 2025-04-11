import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../config/design_system.dart';
import '../models/access_log_model.dart';
import '../providers/access_log_provider.dart';
import '../widgets/platform_aware_widgets.dart';

class AccessLogsScreen extends StatefulWidget {
  const AccessLogsScreen({Key? key}) : super(key: key);

  @override
  State<AccessLogsScreen> createState() => _AccessLogsScreenState();
}

class _AccessLogsScreenState extends State<AccessLogsScreen> {
  String _searchQuery = '';
  AccessLogType? _selectedType;
  AccessLogStatus? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    // Load access logs when screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final accessLogProvider =
          Provider.of<AccessLogProvider>(context, listen: false);
      accessLogProvider.loadAccessLogs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final accessLogProvider = Provider.of<AccessLogProvider>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Apply filters to logs
    final filteredLogs = accessLogProvider.accessLogs.where((log) {
      // Apply search filter
      final matchesSearch = _searchQuery.isEmpty ||
          (log.personnelName
                  ?.toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ??
              false) ||
          (log.personnelArmyNumber
                  ?.toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ??
              false) ||
          (log.adminName?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
              false) ||
          (log.adminArmyNumber
                  ?.toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ??
              false) ||
          (log.details?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
              false);

      // Apply type filter
      final matchesType = _selectedType == null || log.type == _selectedType;

      // Apply status filter
      final matchesStatus =
          _selectedStatus == null || log.status == _selectedStatus;

      // Apply date range filter
      final matchesDateRange = (_startDate == null ||
              log.timestamp.isAfter(_startDate!)) &&
          (_endDate == null ||
              log.timestamp.isBefore(_endDate!.add(const Duration(days: 1))));

      return matchesSearch && matchesType && matchesStatus && matchesDateRange;
    }).toList();

    return PlatformScaffold(
      appBar: AppBar(
        title: const Text('Access Logs'),
        backgroundColor: isDarkMode
            ? DesignSystem.darkAppBarColor
            : DesignSystem.lightAppBarColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
            tooltip: 'Filter logs',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              accessLogProvider.loadAccessLogs();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Logs refreshed'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            tooltip: 'Refresh logs',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: PlatformTextField(
              label: 'Search logs',
              prefixIcon: Icons.search,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Filter chips
          if (_selectedType != null ||
              _selectedStatus != null ||
              _startDate != null ||
              _endDate != null)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  if (_selectedType != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Chip(
                        label: Text('Type: ${_getTypeText(_selectedType!)}'),
                        onDeleted: () {
                          setState(() {
                            _selectedType = null;
                          });
                        },
                      ),
                    ),
                  if (_selectedStatus != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Chip(
                        label:
                            Text('Status: ${_getStatusText(_selectedStatus!)}'),
                        onDeleted: () {
                          setState(() {
                            _selectedStatus = null;
                          });
                        },
                      ),
                    ),
                  if (_startDate != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Chip(
                        label: Text(
                            'From: ${DateFormat('dd/MM/yyyy').format(_startDate!)}'),
                        onDeleted: () {
                          setState(() {
                            _startDate = null;
                          });
                        },
                      ),
                    ),
                  if (_endDate != null)
                    Chip(
                      label: Text(
                          'To: ${DateFormat('dd/MM/yyyy').format(_endDate!)}'),
                      onDeleted: () {
                        setState(() {
                          _endDate = null;
                        });
                      },
                    ),
                ],
              ),
            ),

          // Logs list
          Expanded(
            child: filteredLogs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history_toggle_off,
                          size: 64,
                          color: isDarkMode
                              ? DesignSystem.darkTextSecondaryColor
                              : DesignSystem.lightTextSecondaryColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No access logs found',
                          style: TextStyle(
                            fontSize: 18,
                            color: isDarkMode
                                ? DesignSystem.darkTextSecondaryColor
                                : DesignSystem.lightTextSecondaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isNotEmpty ||
                                  _selectedType != null ||
                                  _selectedStatus != null ||
                                  _startDate != null ||
                                  _endDate != null
                              ? 'Try adjusting your filters'
                              : 'Access logs will appear here when personnel are verified',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDarkMode
                                ? DesignSystem.darkTextSecondaryColor
                                : DesignSystem.lightTextSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: filteredLogs.length,
                    itemBuilder: (context, index) {
                      final log = filteredLogs[index];
                      return _buildLogItem(context, log, isDarkMode);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogItem(BuildContext context, AccessLog log, bool isDarkMode) {
    // Format date
    final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(log.timestamp);

    // Determine status color
    Color statusColor;
    switch (log.status) {
      case AccessLogStatus.verified:
        statusColor = Colors.green;
        break;
      case AccessLogStatus.unverified:
        statusColor = Colors.orange;
        break;
      case AccessLogStatus.denied:
        statusColor = Colors.red;
        break;
      default:
        statusColor = DesignSystem.primaryColor;
    }

    // Determine type icon
    IconData typeIcon;
    switch (log.type) {
      case AccessLogType.login:
        typeIcon = Icons.login;
        break;
      case AccessLogType.logout:
        typeIcon = Icons.logout;
        break;
      case AccessLogType.verification:
        typeIcon = Icons.verified_user;
        break;
      case AccessLogType.registration:
        typeIcon = Icons.person_add;
        break;
      case AccessLogType.modification:
        typeIcon = Icons.edit;
        break;
      case AccessLogType.deletion:
        typeIcon = Icons.delete;
        break;
      default:
        typeIcon = Icons.history;
    }

    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withAlpha(25),
          child: Icon(
            typeIcon,
            color: statusColor,
          ),
        ),
        title: Text(
          log.personnelName ?? 'Unknown Person',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(log.personnelArmyNumber ?? 'N/A'),
            Row(
              children: [
                Icon(typeIcon, size: 12, color: statusColor),
                const SizedBox(width: 4),
                Text(
                  '${_getTypeText(log.type)} - ${_getStatusText(log.status)}',
                  style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 12),
                ),
              ],
            ),
            Text(
              formattedDate,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Personnel ID', log.personnelId ?? 'N/A'),
                _buildInfoRow('Army Number', log.personnelArmyNumber ?? 'N/A'),
                _buildInfoRow('Type', _getTypeText(log.type)),
                _buildInfoRow('Status', _getStatusText(log.status)),
                _buildInfoRow(
                    'Timestamp',
                    DateFormat('MMMM dd, yyyy - HH:mm:ss')
                        .format(log.timestamp)),
                if (log.details != null) _buildInfoRow('Details', log.details!),
                if (log.adminName != null)
                  _buildInfoRow('Admin',
                      '${log.adminName} (${log.adminArmyNumber ?? 'N/A'})'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Type:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(_getTypeText(log.type)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Status:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _getStatusText(log.status),
                          style: TextStyle(
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Filter Logs'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type filter
                  const Text(
                    'Type:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    children: AccessLogType.values.map((type) {
                      return FilterChip(
                        label: Text(_getTypeText(type)),
                        selected: _selectedType == type,
                        onSelected: (selected) {
                          setState(() {
                            _selectedType = selected ? type : null;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Status filter
                  const Text(
                    'Status:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    children: AccessLogStatus.values.map((status) {
                      return FilterChip(
                        label: Text(_getStatusText(status)),
                        selected: _selectedStatus == status,
                        onSelected: (selected) {
                          setState(() {
                            _selectedStatus = selected ? status : null;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Date range filter
                  const Text(
                    'Date Range:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _startDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              setState(() {
                                _startDate = date;
                              });
                            }
                          },
                          child: Text(_startDate == null
                              ? 'Start Date'
                              : DateFormat('dd/MM/yyyy').format(_startDate!)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextButton(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _endDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              setState(() {
                                _endDate = date;
                              });
                            }
                          },
                          child: Text(_endDate == null
                              ? 'End Date'
                              : DateFormat('dd/MM/yyyy').format(_endDate!)),
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
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    // Update the parent state with the filter values
                    // from the dialog's state
                    _selectedType = _selectedType;
                    _selectedStatus = _selectedStatus;
                    _startDate = _startDate;
                    _endDate = _endDate;
                  });
                  Navigator.of(context).pop();
                },
                child: const Text('APPLY'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedType = null;
                    _selectedStatus = null;
                    _startDate = null;
                    _endDate = null;
                  });
                  setState(() {
                    _selectedType = null;
                    _selectedStatus = null;
                    _startDate = null;
                    _endDate = null;
                  });
                },
                child: const Text('CLEAR'),
              ),
            ],
          );
        },
      ),
    );
  }

  String _getTypeText(AccessLogType type) {
    switch (type) {
      case AccessLogType.login:
        return 'Login';
      case AccessLogType.logout:
        return 'Logout';
      case AccessLogType.verification:
        return 'Verification';
      case AccessLogType.registration:
        return 'Registration';
      case AccessLogType.modification:
        return 'Modification';
      case AccessLogType.deletion:
        return 'Deletion';
      default:
        return 'Unknown';
    }
  }

  String _getStatusText(AccessLogStatus status) {
    switch (status) {
      case AccessLogStatus.verified:
        return 'Verified';
      case AccessLogStatus.unverified:
        return 'Unverified';
      case AccessLogStatus.denied:
        return 'Denied';
      default:
        return 'Unknown';
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
