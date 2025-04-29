import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/design_system.dart';
import '../models/personnel_model.dart';
import '../providers/theme_provider.dart';

/// A card widget to display personnel information
class PersonnelInfoCard extends StatelessWidget {
  final Personnel personnel;

  const PersonnelInfoCard({
    Key? key,
    required this.personnel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: isDarkMode ? DesignSystem.darkCardColor : DesignSystem.lightCardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name and rank
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: DesignSystem.primaryColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    personnel.rank ?? 'N/A',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    personnel.fullName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Army number
            _buildInfoRow(
              icon: Icons.badge,
              label: 'Army Number',
              value: personnel.armyNumber ?? 'N/A',
              isDarkMode: isDarkMode,
            ),

            // Service status
            _buildInfoRow(
              icon: Icons.work,
              label: 'Service Status',
              value: personnel.serviceStatus ?? 'Active',
              valueColor: _getServiceStatusColor(personnel.serviceStatus),
              isDarkMode: isDarkMode,
            ),

            // Enlistment date
            if (personnel.enlistmentDate != null)
              _buildInfoRow(
                icon: Icons.calendar_today,
                label: 'Enlistment Date',
                value: personnel.enlistmentDate!,
                isDarkMode: isDarkMode,
              ),

            // Years of service
            _buildInfoRow(
              icon: Icons.access_time,
              label: 'Years of Service',
              value: '${personnel.yearsOfService} years',
              isDarkMode: isDarkMode,
            ),

            // Date of birth
            if (personnel.dateOfBirth != null)
              _buildInfoRow(
                icon: Icons.cake,
                label: 'Date of Birth',
                value: personnel.dateOfBirth!,
                isDarkMode: isDarkMode,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    required bool isDarkMode,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: isDarkMode ? Colors.white70 : Colors.black54,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color? _getServiceStatusColor(String? status) {
    if (status == null) return null;
    
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'retired':
      case 'resigned':
        return Colors.blue;
      case 'awol':
      case 'deserted':
        return Colors.red;
      case 'discharged':
      case 'dismissed':
        return Colors.orange;
      case 'deceased':
        return Colors.grey;
      default:
        return null;
    }
  }
}
