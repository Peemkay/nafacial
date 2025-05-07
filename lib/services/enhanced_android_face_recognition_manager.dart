import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/io.dart';
import 'package:url_launcher/url_launcher.dart';

/// Enhanced manager for the Android-specific face recognition server
/// This improved version handles Termux integration better and provides
/// more robust server management capabilities
class EnhancedAndroidFaceRecognitionManager {
  // Singleton instance
  static final EnhancedAndroidFaceRecognitionManager _instance =
      EnhancedAndroidFaceRecognitionManager._internal();

  // Factory constructor
  factory EnhancedAndroidFaceRecognitionManager() => _instance;

  // Internal constructor
  EnhancedAndroidFaceRecognitionManager._internal();

  // Server process
  Process? _serverProcess;
  
  // WebSocket connection
  IOWebSocketChannel? _wsChannel;
  
  // Server status
  bool _isServerRunning = false;
  bool _isServerInstalled = false;
  bool _isTermuxInstalled = false;
  bool _isInitialized = false;
  
  // Server health
  DateTime? _lastHeartbeat;
  Timer? _heartbeatTimer;
  Timer? _serverMonitorTimer;
  
  // Server info
  String _serverVersion = "Unknown";
  String _serverHost = "localhost";
  int _serverPort = 5001;
  
  // Installation paths
  String _termuxPath = "/data/data/com.termux/files/usr/bin";
  String _serverScriptPath = "";
  String _runScriptPath = "";
  String _setupScriptPath = "";
  
  // Getters
  bool get isServerRunning => _isServerRunning;
  bool get isServerInstalled => _isServerInstalled;
  bool get isTermuxInstalled => _isTermuxInstalled;
  bool get isInitialized => _isInitialized;
  String get serverVersion => _serverVersion;
  String get serverHost => _serverHost;
  int get serverPort => _serverPort;
  DateTime? get lastHeartbeat => _lastHeartbeat;

  /// Initialize the manager
  Future<void> initialize() async {
    if (!Platform.isAndroid) {
      debugPrint('Enhanced Android face recognition manager is only available on Android');
      return;
    }

    try {
      // Check if Termux is installed
      await _checkTermuxInstallation();
      
      // Set up paths
      await _setupPaths();
      
      // Check if the server is installed
      await _checkServerInstallation();
      
      // Check if the server is running
      await _checkServerStatus();
      
      // Start server monitoring if it's running
      if (_isServerRunning) {
        _startServerMonitoring();
      }
      
      _isInitialized = true;
      debugPrint('Enhanced Android face recognition manager initialized');
    } catch (e) {
      debugPrint('Error initializing Enhanced Android face recognition manager: $e');
    }
  }
  
  /// Set up paths for server files
  Future<void> _setupPaths() async {
    final appDir = await getApplicationDocumentsDirectory();
    final serverDir = Directory('${appDir.path}/nafacial/python');
    _serverScriptPath = '${serverDir.path}/android_face_recognition_server.py';
    _runScriptPath = '${appDir.path}/nafacial/run_server.sh';
    _setupScriptPath = '${appDir.path}/nafacial/setup_server.sh';
  }

  /// Check if Termux is installed
  Future<void> _checkTermuxInstallation() async {
    try {
      final termuxAppDir = Directory(_termuxPath);
      _isTermuxInstalled = await termuxAppDir.exists();
      debugPrint('Termux installed: $_isTermuxInstalled');
    } catch (e) {
      debugPrint('Error checking Termux installation: $e');
      _isTermuxInstalled = false;
    }
  }

  /// Check if the server is installed
  Future<void> _checkServerInstallation() async {
    try {
      final serverFile = File(_serverScriptPath);
      _isServerInstalled = await serverFile.exists();
      debugPrint('Android face recognition server installed: $_isServerInstalled');
    } catch (e) {
      debugPrint('Error checking server installation: $e');
      _isServerInstalled = false;
    }
  }

  /// Check if the server is running
  Future<void> _checkServerStatus() async {
    if (!_isServerInstalled) {
      _isServerRunning = false;
      return;
    }

    try {
      // Try to connect to the server via WebSocket
      final wsUrl = Uri.parse('ws://$_serverHost:$_serverPort');
      
      // Create a timeout for the connection attempt
      bool connectionTimedOut = false;
      Timer(const Duration(seconds: 2), () {
        connectionTimedOut = true;
      });
      
      // Try to connect
      while (!connectionTimedOut) {
        try {
          final socket = await WebSocket.connect(wsUrl.toString())
              .timeout(const Duration(seconds: 2));
          await socket.close();
          _isServerRunning = true;
          debugPrint('Server is running');
          return;
        } catch (e) {
          // Connection failed
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }
      
      _isServerRunning = false;
      debugPrint('Server is not running');
    } catch (e) {
      debugPrint('Error checking server status: $e');
      _isServerRunning = false;
    }
  }

  /// Install the server
  Future<bool> installServer() async {
    if (!Platform.isAndroid) return false;
    if (!_isTermuxInstalled) return false;

    try {
      // Create directories
      final appDir = await getApplicationDocumentsDirectory();
      final serverDir = Directory('${appDir.path}/nafacial/python');
      await serverDir.create(recursive: true);

      // Copy server file from assets
      final serverFile = File(_serverScriptPath);
      final serverContent = await rootBundle.loadString('assets/python/android_face_recognition_server.py');
      await serverFile.writeAsString(serverContent);

      // Create setup script
      final setupScriptFile = File(_setupScriptPath);
      await setupScriptFile.writeAsString('''
#!/bin/sh
# Setup script for Android Face Recognition Server

# Update package lists
pkg update -y

# Install required packages
pkg install -y python opencv numpy

# Install pip packages
pip install websockets

# Create directory structure
mkdir -p ~/nafacial/python

# Copy server file
cp ${_serverScriptPath} ~/nafacial/python/

# Create run script
cat > ~/nafacial/run_server.sh << 'EOF'
#!/bin/bash
cd ~/nafacial/python
python android_face_recognition_server.py 5001
EOF

# Make run script executable
chmod +x ~/nafacial/run_server.sh

echo "Setup complete!"
''');

      // Create run script
      final runScriptFile = File(_runScriptPath);
      await runScriptFile.writeAsString('''
#!/bin/sh
cd ${serverDir.path}
python android_face_recognition_server.py 5001
''');

      // Make scripts executable
      await Process.run('chmod', ['+x', setupScriptFile.path]);
      await Process.run('chmod', ['+x', runScriptFile.path]);

      _isServerInstalled = true;
      return true;
    } catch (e) {
      debugPrint('Error installing server: $e');
      return false;
    }
  }

  /// Start the server
  Future<bool> startServer() async {
    if (!Platform.isAndroid) return false;
    if (_isServerRunning) return true;
    if (!_isTermuxInstalled) return false;
    if (!_isServerInstalled) {
      final installed = await installServer();
      if (!installed) return false;
    }

    try {
      // Start the server using Termux
      _serverProcess = await Process.start(
        '$_termuxPath/bash',
        [_runScriptPath],
        runInShell: true,
      );

      // Listen for stdout and stderr
      _serverProcess!.stdout.listen((data) {
        final output = utf8.decode(data);
        debugPrint('Server stdout: $output');
      });

      _serverProcess!.stderr.listen((data) {
        final output = utf8.decode(data);
        debugPrint('Server stderr: $output');
      });

      // Wait for the server to start
      await Future.delayed(const Duration(seconds: 3));
      
      // Check if the server is running
      await _checkServerStatus();
      
      if (_isServerRunning) {
        // Start server monitoring
        _startServerMonitoring();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint('Error starting server: $e');
      return false;
    }
  }

  /// Stop the server
  Future<bool> stopServer() async {
    if (!_isServerRunning || _serverProcess == null) return true;

    try {
      // Stop server monitoring
      _stopServerMonitoring();
      
      // Kill the server process
      _serverProcess!.kill();
      
      // Wait for the process to terminate
      await Future.delayed(const Duration(seconds: 1));
      
      // Check if the server is still running
      await _checkServerStatus();
      
      return !_isServerRunning;
    } catch (e) {
      debugPrint('Error stopping server: $e');
      return false;
    }
  }

  /// Start server monitoring
  void _startServerMonitoring() {
    // Stop any existing monitoring
    _stopServerMonitoring();
    
    // Start heartbeat timer
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _sendHeartbeat();
    });
    
    // Start server monitor timer
    _serverMonitorTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkServerStatus();
    });
  }

  /// Stop server monitoring
  void _stopServerMonitoring() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    
    _serverMonitorTimer?.cancel();
    _serverMonitorTimer = null;
    
    _wsChannel?.sink.close();
    _wsChannel = null;
  }

  /// Send heartbeat to server
  Future<void> _sendHeartbeat() async {
    if (!_isServerRunning) return;
    
    try {
      // Connect to server if not connected
      if (_wsChannel == null) {
        final wsUrl = Uri.parse('ws://$_serverHost:$_serverPort');
        _wsChannel = IOWebSocketChannel.connect(wsUrl.toString());
      }
      
      // Send heartbeat message
      _wsChannel!.sink.add(json.encode({
        'type': 'ping',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      }));
      
      // Update last heartbeat time
      _lastHeartbeat = DateTime.now();
    } catch (e) {
      debugPrint('Error sending heartbeat: $e');
      _wsChannel?.sink.close();
      _wsChannel = null;
    }
  }

  /// Install Termux
  Future<bool> installTermux() async {
    final url = Uri.parse(
      'https://f-droid.org/packages/com.termux/',
    );
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
      return true;
    } else {
      debugPrint('Could not launch Termux installation URL');
      return false;
    }
  }

  /// Get server information
  Map<String, dynamic> getServerInfo() {
    return {
      'host': _serverHost,
      'port': _serverPort,
      'version': _serverVersion,
      'running': _isServerRunning,
      'installed': _isServerInstalled,
      'termux_installed': _isTermuxInstalled,
      'last_heartbeat': _lastHeartbeat?.toIso8601String(),
    };
  }

  /// Dispose of resources
  void dispose() {
    stopServer();
    _stopServerMonitoring();
  }
}
