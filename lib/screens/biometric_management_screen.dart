import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/design_system.dart';
import '../models/biometric_device.dart';
import '../services/biometric_service.dart';
import '../utils/platform_utils.dart';
import '../widgets/app_bar_with_back_button.dart';

class BiometricManagementScreen extends StatefulWidget {
  static const String routeName = '/biometric-management';

  const BiometricManagementScreen({Key? key}) : super(key: key);

  @override
  State<BiometricManagementScreen> createState() =>
      _BiometricManagementScreenState();
}

class _BiometricManagementScreenState extends State<BiometricManagementScreen> {
  final BiometricService _biometricService = BiometricService();
  StreamSubscription<List<BiometricDevice>>? _devicesSubscription;
  List<BiometricDevice> _devices = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeBiometrics();
  }

  Future<void> _initializeBiometrics() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Initialize the biometric service
      await _biometricService.initialize();

      // Listen for device changes
      _devicesSubscription = _biometricService.devicesStream.listen((devices) {
        setState(() {
          _devices = devices;
        });
      });

      // Get initial devices
      setState(() {
        _devices = _biometricService.availableDevices;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize biometrics: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _devicesSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = MediaQuery.of(context).size.width >= 1100;
    final isTablet = MediaQuery.of(context).size.width >= 650 &&
        MediaQuery.of(context).size.width < 1100;

    return Scaffold(
      appBar: AppBarWithBackButton(
        title: 'Biometric Management',
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      body: _buildBody(context, isDarkMode, isDesktop, isTablet),
    );
  }

  Widget _buildBody(
      BuildContext context, bool isDarkMode, bool isDesktop, bool isTablet) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _initializeBiometrics,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_devices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fingerprint_outlined,
              color: isDarkMode ? Colors.white54 : Colors.black38,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'No Biometric Devices Found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'No biometric devices were detected on this device. Please connect a biometric device and try again.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _initializeBiometrics,
              icon: const Icon(Icons.refresh),
              label: const Text('Scan for Devices'),
            ),
          ],
        ),
      );
    }

    // Layout for desktop/tablet
    if (isDesktop || isTablet) {
      return Row(
        children: [
          // Left panel - Device list
          SizedBox(
            width: isDesktop ? 350 : 250,
            child: _buildDeviceList(isDarkMode),
          ),
          // Vertical divider
          VerticalDivider(
            width: 1,
            thickness: 1,
            color: isDarkMode ? Colors.white12 : Colors.black12,
          ),
          // Right panel - Device details and actions
          Expanded(
            child: _buildDeviceDetails(isDarkMode),
          ),
        ],
      );
    }

    // Layout for mobile
    return Column(
      children: [
        // Device list
        Expanded(
          flex: 2,
          child: _buildDeviceList(isDarkMode),
        ),
        // Horizontal divider
        Divider(
          height: 1,
          thickness: 1,
          color: isDarkMode ? Colors.white12 : Colors.black12,
        ),
        // Device details and actions
        Expanded(
          flex: 3,
          child: _buildDeviceDetails(isDarkMode),
        ),
      ],
    );
  }

  Widget _buildDeviceList(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available Devices',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _initializeBiometrics,
                tooltip: 'Refresh Devices',
              ),
            ],
          ),
        ),
        // Device list
        Expanded(
          child: ListView.builder(
            itemCount: _devices.length,
            itemBuilder: (context, index) {
              final device = _devices[index];
              final isSelected =
                  _biometricService.currentDevice?.id == device.id;

              return ListTile(
                leading: _getDeviceIcon(device.type),
                title: Text(device.name),
                subtitle: Text(
                  _getDeviceTypeString(device.type) +
                      (device.isBuiltIn ? ' (Built-in)' : ''),
                ),
                trailing: device.isConnected
                    ? Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 16,
                      )
                    : Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 16,
                      ),
                selected: isSelected,
                selectedTileColor:
                    isDarkMode ? Colors.white10 : Colors.blue.withOpacity(0.1),
                onTap: () {
                  if (device.isConnected) {
                    _biometricService.selectDevice(device);
                    setState(() {}); // Refresh UI
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceDetails(bool isDarkMode) {
    final currentDevice = _biometricService.currentDevice;

    if (currentDevice == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.touch_app_outlined,
              color: isDarkMode ? Colors.white38 : Colors.black26,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'No Device Selected',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Select a biometric device from the list to view details and perform actions.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Device header
          Row(
            children: [
              _getDeviceIcon(currentDevice.type, size: 48),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentDevice.name,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    Text(
                      _getDeviceTypeString(currentDevice.type) +
                          (currentDevice.isBuiltIn ? ' (Built-in)' : ''),
                      style: TextStyle(
                        fontSize: 16,
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: currentDevice.isConnected
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: currentDevice.isConnected
                        ? Colors.green
                        : Colors.red,
                    width: 1,
                  ),
                ),
                child: Text(
                  currentDevice.isConnected ? 'Connected' : 'Disconnected',
                  style: TextStyle(
                    color: currentDevice.isConnected ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Device information
          Text(
            'Device Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            isDarkMode,
            [
              _buildInfoRow('Device ID', currentDevice.id),
              _buildInfoRow('Connection Type',
                  currentDevice.connectionType ?? 'Internal'),
              _buildInfoRow('Built-in',
                  currentDevice.isBuiltIn ? 'Yes' : 'No'),
            ],
          ),
          const SizedBox(height: 32),

          // Actions
          Text(
            'Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildActionButton(
                context,
                'Test Authentication',
                Icons.fingerprint,
                Colors.blue,
                _testAuthentication,
                isDarkMode,
              ),
              _buildActionButton(
                context,
                'Enroll Biometric',
                Icons.person_add,
                Colors.green,
                _enrollBiometric,
                isDarkMode,
              ),
              _buildActionButton(
                context,
                'Verify Biometric',
                Icons.verified_user,
                Colors.orange,
                _verifyBiometric,
                isDarkMode,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(bool isDarkMode, List<Widget> children) {
    return Card(
      elevation: 0,
      color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDarkMode ? Colors.white24 : Colors.black12,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
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

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
    bool isDarkMode,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Future<void> _testAuthentication() async {
    try {
      final result = await _biometricService.authenticate(
        reason: 'Testing biometric authentication',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result
                ? 'Authentication successful!'
                : 'Authentication failed or canceled.',
          ),
          backgroundColor: result ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _enrollBiometric() async {
    // In a real app, this would capture biometric data and enroll it
    // For this example, we'll just show a dialog
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enroll Biometric'),
        content: const Text(
            'In a real implementation, this would capture and enroll a biometric template.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _verifyBiometric() async {
    // In a real app, this would capture biometric data and verify it
    // For this example, we'll just show a dialog
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verify Biometric'),
        content: const Text(
            'In a real implementation, this would capture and verify a biometric sample against a stored template.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Icon _getDeviceIcon(BiometricDeviceType type, {double size = 24}) {
    switch (type) {
      case BiometricDeviceType.fingerprint:
        return Icon(
          Icons.fingerprint,
          size: size,
          color: Colors.blue,
        );
      case BiometricDeviceType.facial:
        return Icon(
          Icons.face,
          size: size,
          color: Colors.green,
        );
      case BiometricDeviceType.iris:
        return Icon(
          Icons.remove_red_eye,
          size: size,
          color: Colors.purple,
        );
      case BiometricDeviceType.multimodal:
        return Icon(
          Icons.security,
          size: size,
          color: Colors.orange,
        );
      case BiometricDeviceType.other:
      default:
        return Icon(
          Icons.devices_other,
          size: size,
          color: Colors.grey,
        );
    }
  }

  String _getDeviceTypeString(BiometricDeviceType type) {
    switch (type) {
      case BiometricDeviceType.fingerprint:
        return 'Fingerprint Scanner';
      case BiometricDeviceType.facial:
        return 'Facial Recognition';
      case BiometricDeviceType.iris:
        return 'Iris Scanner';
      case BiometricDeviceType.multimodal:
        return 'Multimodal Biometric';
      case BiometricDeviceType.other:
      default:
        return 'Other Biometric Device';
    }
  }
}
