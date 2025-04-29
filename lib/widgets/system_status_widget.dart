import 'package:flutter/material.dart';
import '../config/design_system.dart';

class SystemStatusWidget extends StatelessWidget {
  final bool isOnline;
  final bool isDatabaseSynced;
  final String lastSyncTime;
  final int pendingUpdates;
  
  const SystemStatusWidget({
    Key? key,
    required this.isOnline,
    required this.isDatabaseSynced,
    required this.lastSyncTime,
    required this.pendingUpdates,
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
                    Icons.sync,
                    color: DesignSystem.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'System Status',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatusItem(
              'Connection Status',
              isOnline ? 'Online' : 'Offline',
              isOnline ? Icons.wifi : Icons.wifi_off,
              isOnline ? Colors.green : Colors.red,
              isDarkMode,
            ),
            const Divider(),
            _buildStatusItem(
              'Database Sync',
              isDatabaseSynced ? 'Synced' : 'Not Synced',
              isDatabaseSynced ? Icons.check_circle : Icons.sync_problem,
              isDatabaseSynced ? Colors.green : Colors.orange,
              isDarkMode,
            ),
            const Divider(),
            _buildStatusItem(
              'Last Sync',
              lastSyncTime,
              Icons.access_time,
              Colors.blue,
              isDarkMode,
            ),
            const Divider(),
            _buildStatusItem(
              'Pending Updates',
              pendingUpdates.toString(),
              Icons.update,
              pendingUpdates > 0 ? Colors.orange : Colors.green,
              isDarkMode,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDarkMode,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: isDarkMode 
                    ? Colors.white.withValues(alpha: 178) 
                    : Colors.black.withValues(alpha: 178),
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
