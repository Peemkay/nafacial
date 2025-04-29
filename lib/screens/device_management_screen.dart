import 'package:flutter/material.dart';
import '../config/design_system.dart';
import '../widgets/platform_aware_widgets.dart';
import '../models/device_model.dart';

class DeviceManagementScreen extends StatefulWidget {
  const DeviceManagementScreen({Key? key}) : super(key: key);

  @override
  State<DeviceManagementScreen> createState() => _DeviceManagementScreenState();
}

class _DeviceManagementScreenState extends State<DeviceManagementScreen> {
  final List<Device> _devices = [
    Device(
      id: '1',
      name: 'Gate 1 Scanner',
      type: DeviceType.scanner,
      status: DeviceStatus.active,
      lastSync: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    Device(
      id: '2',
      name: 'Admin Building Camera',
      type: DeviceType.camera,
      status: DeviceStatus.inactive,
      lastSync: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    // Add more sample devices
  ];

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: AppBar(
        title: const Text('Device Management'),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? DesignSystem.darkAppBarColor
            : DesignSystem.lightAppBarColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshDevices,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDeviceStats(),
          Expanded(
            child: _buildDeviceList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDeviceDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDeviceStats() {
    final activeDevices =
        _devices.where((d) => d.status == DeviceStatus.active).length;
    final totalDevices = _devices.length;

    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              'Total Devices',
              totalDevices.toString(),
              Icons.devices,
              Colors.blue,
            ),
            _buildStatItem(
              'Active Devices',
              activeDevices.toString(),
              Icons.check_circle,
              Colors.green,
            ),
            _buildStatItem(
              'Inactive Devices',
              (totalDevices - activeDevices).toString(),
              Icons.error,
              Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(label),
      ],
    );
  }

  Widget _buildDeviceList() {
    return ListView.builder(
      itemCount: _devices.length,
      itemBuilder: (context, index) {
        final device = _devices[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: ListTile(
            leading: Icon(
              device.type == DeviceType.scanner
                  ? Icons.scanner
                  : Icons.camera_alt,
              color: device.status == DeviceStatus.active
                  ? Colors.green
                  : Colors.grey,
            ),
            title: Text(device.name),
            subtitle: Text(
              'Last sync: ${_formatDateTime(device.lastSync)}',
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) => _handleDeviceAction(value, device),
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('Edit'),
                ),
                const PopupMenuItem(
                  value: 'sync',
                  child: Text('Sync Now'),
                ),
                const PopupMenuItem(
                  value: 'disable',
                  child: Text('Disable'),
                ),
                const PopupMenuItem(
                  value: 'remove',
                  child: Text('Remove'),
                ),
              ],
            ),
            onTap: () => _showDeviceDetails(context, device),
          ),
        );
      },
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _refreshDevices() {
    // Implement device refresh logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Refreshing devices...'),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Devices'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('Show Scanners'),
              value: true,
              onChanged: (bool? value) {},
            ),
            CheckboxListTile(
              title: const Text('Show Cameras'),
              value: true,
              onChanged: (bool? value) {},
            ),
            CheckboxListTile(
              title: const Text('Show Active Only'),
              value: false,
              onChanged: (bool? value) {},
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
              // Apply filters
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showAddDeviceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Device'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Device Name',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<DeviceType>(
              decoration: const InputDecoration(
                labelText: 'Device Type',
              ),
              value: DeviceType.scanner,
              items: DeviceType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.toString().split('.').last),
                );
              }).toList(),
              onChanged: (DeviceType? value) {},
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
              // Add device logic
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Device added successfully'),
                ),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _handleDeviceAction(String action, Device device) {
    switch (action) {
      case 'edit':
        _showEditDeviceDialog(context, device);
        break;
      case 'sync':
        _syncDevice(device);
        break;
      case 'disable':
        _toggleDeviceStatus(device);
        break;
      case 'remove':
        _showRemoveDeviceDialog(context, device);
        break;
    }
  }

  void _showEditDeviceDialog(BuildContext context, Device device) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Device'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Device Name',
              ),
              controller: TextEditingController(text: device.name),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<DeviceType>(
              decoration: const InputDecoration(
                labelText: 'Device Type',
              ),
              value: device.type,
              items: DeviceType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.toString().split('.').last),
                );
              }).toList(),
              onChanged: (DeviceType? value) {},
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
              // Update device logic
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Device updated successfully'),
                ),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _syncDevice(Device device) {
    // Implement device sync logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Syncing ${device.name}...'),
      ),
    );
  }

  void _toggleDeviceStatus(Device device) {
    setState(() {
      final index = _devices.indexOf(device);
      _devices[index] = device.copyWith(
        status: device.status == DeviceStatus.active
            ? DeviceStatus.inactive
            : DeviceStatus.active,
      );
    });
  }

  void _showRemoveDeviceDialog(BuildContext context, Device device) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Device'),
        content: Text('Are you sure you want to remove ${device.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              setState(() {
                _devices.remove(device);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Device removed successfully'),
                ),
              );
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _showDeviceDetails(BuildContext context, Device device) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(device.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${device.type.toString().split('.').last}'),
            Text('Status: ${device.status.toString().split('.').last}'),
            Text('Last Sync: ${_formatDateTime(device.lastSync)}'),
            const SizedBox(height: 16),
            const Text('Connection History:'),
            // Add connection history widget here
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
