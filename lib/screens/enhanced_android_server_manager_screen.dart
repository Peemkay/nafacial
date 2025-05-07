import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/design_system.dart';
import '../services/enhanced_android_face_recognition_manager.dart';
import '../widgets/platform_aware_widgets.dart';

class EnhancedAndroidServerManagerScreen extends StatefulWidget {
  const EnhancedAndroidServerManagerScreen({Key? key}) : super(key: key);

  @override
  State<EnhancedAndroidServerManagerScreen> createState() =>
      _EnhancedAndroidServerManagerScreenState();
}

class _EnhancedAndroidServerManagerScreenState
    extends State<EnhancedAndroidServerManagerScreen> with SingleTickerProviderStateMixin {
  final EnhancedAndroidFaceRecognitionManager _serverManager =
      EnhancedAndroidFaceRecognitionManager();
  bool _isLoading = false;
  bool _isServerInstalled = false;
  bool _isServerRunning = false;
  bool _isTermuxInstalled = false;
  String _statusMessage = "Checking server status...";
  String _logMessages = "";
  DateTime? _lastHeartbeat;
  Timer? _refreshTimer;
  late TabController _tabController;
  
  // Server metrics
  int _totalRequests = 0;
  int _successfulRequests = 0;
  double _averageResponseTime = 0.0;
  String _serverUptime = "0m";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _checkServerStatus();
    
    // Set up periodic refresh
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        _refreshServerStatus();
      }
    });
  }
  
  @override
  void dispose() {
    _refreshTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _checkServerStatus() async {
    if (!Platform.isAndroid) {
      setState(() {
        _statusMessage = "This feature is only available on Android devices";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = "Checking server status...";
    });

    try {
      // Initialize server manager
      await _serverManager.initialize();
      
      setState(() {
        _isServerInstalled = _serverManager.isServerInstalled;
        _isServerRunning = _serverManager.isServerRunning;
        _isTermuxInstalled = _serverManager.isTermuxInstalled;
        _lastHeartbeat = _serverManager.lastHeartbeat;
        
        if (!_isTermuxInstalled) {
          _statusMessage = "Termux is not installed";
        } else if (!_isServerInstalled) {
          _statusMessage = "Server is not installed";
        } else if (_isServerRunning) {
          _statusMessage = "Server is running";
          _updateServerMetrics();
        } else {
          _statusMessage = "Server is not running";
        }
      });
    } catch (e) {
      setState(() {
        _statusMessage = "Error checking server status: $e";
        _addToLog("Error: $e");
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _refreshServerStatus() async {
    if (!mounted) return;
    
    try {
      // Check if the server is running
      await _serverManager.initialize();
      
      setState(() {
        _isServerInstalled = _serverManager.isServerInstalled;
        _isServerRunning = _serverManager.isServerRunning;
        _isTermuxInstalled = _serverManager.isTermuxInstalled;
        _lastHeartbeat = _serverManager.lastHeartbeat;
        
        if (_isServerRunning) {
          _statusMessage = "Server is running";
          _updateServerMetrics();
        } else if (!_isTermuxInstalled) {
          _statusMessage = "Termux is not installed";
        } else if (!_isServerInstalled) {
          _statusMessage = "Server is not installed";
        } else {
          _statusMessage = "Server is not running";
        }
      });
    } catch (e) {
      // Don't update UI on refresh errors
      debugPrint('Error refreshing server status: $e');
    }
  }
  
  void _updateServerMetrics() {
    // In a real implementation, these would come from the server
    // For now, we'll simulate some metrics
    setState(() {
      _totalRequests = _totalRequests + (DateTime.now().second % 3);
      _successfulRequests = (_totalRequests * 0.95).round();
      _averageResponseTime = 120 + (DateTime.now().millisecond % 100);
      
      if (_isServerRunning && _lastHeartbeat != null) {
        final uptime = DateTime.now().difference(_lastHeartbeat!);
        if (uptime.inHours > 0) {
          _serverUptime = "${uptime.inHours}h ${uptime.inMinutes % 60}m";
        } else {
          _serverUptime = "${uptime.inMinutes}m ${uptime.inSeconds % 60}s";
        }
      } else {
        _serverUptime = "0m";
      }
    });
  }

  Future<void> _installTermux() async {
    setState(() {
      _isLoading = true;
      _statusMessage = "Opening Termux installation page...";
      _addToLog("Opening Termux installation page...");
    });

    try {
      final success = await _serverManager.installTermux();
      
      setState(() {
        if (success) {
          _statusMessage = "Termux installation page opened";
          _addToLog("Termux installation page opened. Please install Termux and return to this app.");
        } else {
          _statusMessage = "Failed to open Termux installation page";
          _addToLog("Failed to open Termux installation page");
        }
      });
    } catch (e) {
      setState(() {
        _statusMessage = "Error installing Termux: $e";
        _addToLog("Error: $e");
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _installServer() async {
    if (!Platform.isAndroid) return;
    if (!_isTermuxInstalled) {
      _showTermuxNotInstalledDialog();
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = "Installing server...";
      _addToLog("Installing server...");
    });

    try {
      final success = await _serverManager.installServer();

      setState(() {
        if (success) {
          _isServerInstalled = true;
          _statusMessage = "Server installed successfully";
          _addToLog("Server installed successfully");
        } else {
          _statusMessage = "Failed to install server";
          _addToLog("Failed to install server");
        }
      });
    } catch (e) {
      setState(() {
        _statusMessage = "Error installing server: $e";
        _addToLog("Error: $e");
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _startServer() async {
    if (!Platform.isAndroid) return;
    if (!_isTermuxInstalled) {
      _showTermuxNotInstalledDialog();
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = "Starting server...";
      _addToLog("Starting server...");
    });

    try {
      final success = await _serverManager.startServer();

      setState(() {
        if (success) {
          _isServerRunning = true;
          _statusMessage = "Server started successfully";
          _addToLog("Server started successfully");
          _lastHeartbeat = DateTime.now();
        } else {
          _statusMessage = "Failed to start server";
          _addToLog("Failed to start server");
        }
      });
    } catch (e) {
      setState(() {
        _statusMessage = "Error starting server: $e";
        _addToLog("Error: $e");
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _stopServer() async {
    if (!Platform.isAndroid) return;

    setState(() {
      _isLoading = true;
      _statusMessage = "Stopping server...";
      _addToLog("Stopping server...");
    });

    try {
      final success = await _serverManager.stopServer();

      setState(() {
        if (success) {
          _isServerRunning = false;
          _statusMessage = "Server stopped successfully";
          _addToLog("Server stopped successfully");
        } else {
          _statusMessage = "Failed to stop server";
          _addToLog("Failed to stop server");
        }
      });
    } catch (e) {
      setState(() {
        _statusMessage = "Error stopping server: $e";
        _addToLog("Error: $e");
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showTermuxNotInstalledDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Termux Required'),
        content: const Text(
          'Termux is required to run the face recognition server on your device. '
          'Would you like to install Termux from F-Droid?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _installTermux();
            },
            child: const Text('INSTALL'),
          ),
        ],
      ),
    );
  }
  
  void _addToLog(String message) {
    final timestamp = DateTime.now().toString().substring(11, 19);
    setState(() {
      _logMessages = "[$timestamp] $message\n$_logMessages";
    });
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: AppBar(
        title: const Text('Android Server Manager'),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? DesignSystem.darkAppBarColor
            : DesignSystem.lightAppBarColor,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Status'),
            Tab(text: 'Logs'),
            Tab(text: 'Help'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStatusTab(),
          _buildLogsTab(),
          _buildHelpTab(),
        ],
      ),
    );
  }
  
  Widget _buildStatusTab() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(DesignSystem.adjustedSpacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Server status card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignSystem.borderRadiusMedium),
              ),
              child: Padding(
                padding: EdgeInsets.all(DesignSystem.adjustedSpacingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Server Status',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(
                                _isServerRunning
                                    ? Icons.check_circle
                                    : Icons.error,
                                color: _isServerRunning
                                    ? Colors.green
                                    : Colors.red,
                              ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildStatusItem('Status', _statusMessage),
                    _buildStatusItem('Termux Installed', _isTermuxInstalled ? 'Yes' : 'No'),
                    _buildStatusItem('Server Installed', _isServerInstalled ? 'Yes' : 'No'),
                    _buildStatusItem('Server Running', _isServerRunning ? 'Yes' : 'No'),
                    if (_isServerRunning && _lastHeartbeat != null)
                      _buildStatusItem('Last Heartbeat', _lastHeartbeat.toString()),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Server metrics card (only shown when server is running)
            if (_isServerRunning)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DesignSystem.borderRadiusMedium),
                ),
                child: Padding(
                  padding: EdgeInsets.all(DesignSystem.adjustedSpacingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Server Metrics',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildMetricItem('Total Requests', _totalRequests.toString()),
                      _buildMetricItem('Successful Requests', _successfulRequests.toString()),
                      _buildMetricItem('Success Rate', 
                          '${(_totalRequests > 0 ? (_successfulRequests / _totalRequests * 100).toStringAsFixed(1) : "0.0")}%'),
                      _buildMetricItem('Avg. Response Time', '${_averageResponseTime.toStringAsFixed(1)} ms'),
                      _buildMetricItem('Uptime', _serverUptime),
                    ],
                  ),
                ),
              ),
            
            const SizedBox(height: 16),
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (!_isTermuxInstalled)
                  Expanded(
                    child: PlatformButton(
                      text: 'Install Termux',
                      onPressed: _isLoading ? null : _installTermux,
                      icon: Icons.download,
                      isFullWidth: true,
                    ),
                  ),
                if (_isTermuxInstalled && !_isServerInstalled)
                  Expanded(
                    child: PlatformButton(
                      text: 'Install Server',
                      onPressed: _isLoading ? null : _installServer,
                      icon: Icons.download,
                      isFullWidth: true,
                    ),
                  ),
                if (_isServerInstalled && !_isServerRunning)
                  Expanded(
                    child: PlatformButton(
                      text: 'Start Server',
                      onPressed: _isLoading ? null : _startServer,
                      icon: Icons.play_arrow,
                      isFullWidth: true,
                    ),
                  ),
                if (_isServerRunning)
                  Expanded(
                    child: PlatformButton(
                      text: 'Stop Server',
                      onPressed: _isLoading ? null : _stopServer,
                      icon: Icons.stop,
                      isFullWidth: true,
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Refresh button
            PlatformButton(
              text: 'Refresh Status',
              onPressed: _isLoading ? null : _checkServerStatus,
              icon: Icons.refresh,
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLogsTab() {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(DesignSystem.adjustedSpacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Server Logs',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.clear_all),
                  onPressed: () {
                    setState(() {
                      _logMessages = "";
                    });
                  },
                  tooltip: 'Clear logs',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(DesignSystem.borderRadiusSmall),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _logMessages.isEmpty
                        ? "No logs available. Start the server to see logs."
                        : _logMessages,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.green
                          : Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHelpTab() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(DesignSystem.adjustedSpacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Android Face Recognition Server',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'The Android Face Recognition Server allows you to run advanced face recognition directly on your device without requiring an internet connection.',
            ),
            const SizedBox(height: 16),
            const Text(
              'Setup Instructions:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '1. Install Termux from F-Droid (not Play Store)\n'
              '2. Install the server using the "Install Server" button\n'
              '3. Start the server using the "Start Server" button\n'
              '4. Keep Termux running in the background',
            ),
            const SizedBox(height: 16),
            const Text(
              'Troubleshooting:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '• If the server fails to start, try reinstalling it\n'
              '• Make sure Termux has storage permissions\n'
              '• Disable battery optimization for Termux\n'
              '• Check the logs tab for error messages',
            ),
            const SizedBox(height: 16),
            PlatformButton(
              text: 'Open Termux Documentation',
              onPressed: () async {
                final url = Uri.parse('https://wiki.termux.com/wiki/Main_Page');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
              icon: Icons.open_in_browser,
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatusItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(value),
        ],
      ),
    );
  }
  
  Widget _buildMetricItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
