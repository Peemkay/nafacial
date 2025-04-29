import 'package:flutter/material.dart';
import '../config/design_system.dart';

class UserActivitySummary extends StatelessWidget {
  final int totalScans;
  final int successfulScans;
  final int failedScans;
  
  const UserActivitySummary({
    Key? key,
    required this.totalScans,
    required this.successfulScans,
    required this.failedScans,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: DesignSystem.primaryColor.withValues(alpha: 26),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.bar_chart,
                    color: DesignSystem.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Activity Summary',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  'Total',
                  totalScans.toString(),
                  Icons.people,
                  DesignSystem.primaryColor,
                  isDarkMode,
                ),
                _buildStatItem(
                  context,
                  'Success',
                  successfulScans.toString(),
                  Icons.check_circle,
                  Colors.green,
                  isDarkMode,
                ),
                _buildStatItem(
                  context,
                  'Failed',
                  failedScans.toString(),
                  Icons.error,
                  Colors.red,
                  isDarkMode,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDarkMode,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 26),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDarkMode 
                ? Colors.white.withValues(alpha: 178) 
                : Colors.black.withValues(alpha: 178),
          ),
        ),
      ],
    );
  }
}
