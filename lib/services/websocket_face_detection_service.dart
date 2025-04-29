import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path_provider/path_provider.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Service for WebSocket-based face detection
class WebSocketFaceDetectionService {
  // WebSocket connection
  WebSocketChannel? _channel;

  // Server process
  static Process? _pythonProcess;

  // Connection status
  bool _isConnected = false;
  bool _isConnecting = false;
  bool _isServerRunning = false;
  bool _isPythonAvailable = false;

  // Available models
  List<String> _availableModels = [];

  // Stream controllers
  final StreamController<List<Face>> _facesStreamController =
      StreamController<List<Face>>.broadcast();

  // Getters
  Stream<List<Face>> get facesStream => _facesStreamController.stream;
  bool get isConnected => _isConnected;
  bool get isServerRunning => _isServerRunning;
  List<String> get availableModels => _availableModels;

  // Singleton instance
  static final WebSocketFaceDetectionService _instance =
      WebSocketFaceDetectionService._internal();

  // Factory constructor
  factory WebSocketFaceDetectionService() => _instance;

  // Internal constructor
  WebSocketFaceDetectionService._internal();

  /// Initialize the service
  Future<bool> initialize({String host = 'localhost', int port = 5002}) async {
    if (_isConnected) return true;
    if (_isConnecting) return false;

    _isConnecting = true;

    try {
      // Check if Python is available
      await _checkPythonAvailability();

      // Try to connect to the server
      final bool connected = await _connectToServer(host, port);

      if (!connected && _isPythonAvailable) {
        // If connection failed but Python is available, try to start the server
        await _startPythonServer();

        // Wait for server to start
        await Future.delayed(const Duration(seconds: 2));

        // Try to connect again
        return await _connectToServer(host, port);
      }

      return connected;
    } catch (e) {
      debugPrint('Error initializing WebSocket face detection service: $e');
      return false;
    } finally {
      _isConnecting = false;
    }
  }

  /// Check if Python is available
  Future<void> _checkPythonAvailability() async {
    try {
      final result = await Process.run('python', ['--version']);
      if (result.exitCode == 0) {
        debugPrint('Python is available: ${result.stdout}');
        _isPythonAvailable = true;
      } else {
        debugPrint('Python is not available: ${result.stderr}');
        _isPythonAvailable = false;
      }
    } catch (e) {
      debugPrint('Error checking Python: $e');
      _isPythonAvailable = false;
    }
  }

  /// Connect to the WebSocket server
  Future<bool> _connectToServer(String host, int port) async {
    try {
      // Close existing connection if any
      await disconnect();

      // Create a new connection
      final uri = Uri.parse('ws://$host:$port');
      _channel = IOWebSocketChannel.connect(uri);

      // Listen for messages
      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDone,
        cancelOnError: false,
      );

      // Send a ping to check if the server is running
      _channel!.sink.add(jsonEncode({
        'type': 'ping',
        'timestamp': DateTime.now().toIso8601String(),
      }));

      // Wait for response
      final completer = Completer<bool>();

      // Set a timeout
      Timer(const Duration(seconds: 3), () {
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      });

      // Listen for the first message
      StreamSubscription? subscription;
      subscription = _channel!.stream.listen((message) {
        try {
          final data = jsonDecode(message);
          if (data['type'] == 'info' || data['type'] == 'pong') {
            _isConnected = true;
            _isServerRunning = true;

            // Get available models
            if (data['available_models'] != null) {
              _availableModels = List<String>.from(data['available_models']);
            }

            if (!completer.isCompleted) {
              completer.complete(true);
            }
          }
        } catch (e) {
          debugPrint('Error parsing message: $e');
        }

        subscription?.cancel();
      }, onError: (e) {
        if (!completer.isCompleted) {
          completer.complete(false);
        }
        subscription?.cancel();
      }, onDone: () {
        if (!completer.isCompleted) {
          completer.complete(false);
        }
        subscription?.cancel();
      }, cancelOnError: true);

      return await completer.future;
    } catch (e) {
      debugPrint('Error connecting to WebSocket server: $e');
      return false;
    }
  }

  /// Start the Python server
  Future<void> _startPythonServer() async {
    if (!_isPythonAvailable) return;

    try {
      // Get the path to the Python script
      final scriptPath = await _getPythonScriptPath();

      // Start the Python process
      debugPrint('Starting Python server from: $scriptPath');

      // Use a different port if running on web
      const port = kIsWeb ? 5002 : 5001;

      // Start the Python process
      _pythonProcess = await Process.start(
        'python',
        [scriptPath, port.toString()],
        runInShell: true,
      );

      // Listen for stdout and stderr
      _pythonProcess!.stdout.transform(utf8.decoder).listen((data) {
        debugPrint('Python stdout: $data');
      });

      _pythonProcess!.stderr.transform(utf8.decoder).listen((data) {
        debugPrint('Python stderr: $data');
      });

      _isServerRunning = true;
    } catch (e) {
      debugPrint('Error starting Python server: $e');
    }
  }

  /// Get the path to the Python script
  Future<String> _getPythonScriptPath() async {
    if (kIsWeb) {
      return 'python/websocket_face_detection_service.py';
    }

    // For desktop/mobile, use the app's documents directory
    final appDir = await getApplicationDocumentsDirectory();
    final pythonDir = Directory('${appDir.path}/python');
    final scriptPath = '${pythonDir.path}/websocket_face_detection_service.py';

    // Check if script exists
    final scriptFile = File(scriptPath);
    if (await scriptFile.exists()) {
      return scriptPath;
    }

    // Script doesn't exist, return the path in the project directory
    return 'python/websocket_face_detection_service.py';
  }

  /// Handle incoming WebSocket messages
  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message);
      final messageType = data['type'];

      switch (messageType) {
        case 'detection_result':
          _handleDetectionResult(data);
          break;
        case 'error':
          debugPrint('WebSocket error: ${data['message']}');
          break;
        case 'info':
          debugPrint('WebSocket info: ${data['message']}');
          if (data['available_models'] != null) {
            _availableModels = List<String>.from(data['available_models']);
          }
          break;
        case 'pong':
          // Ping response, do nothing
          break;
        default:
          debugPrint('Unknown message type: $messageType');
      }
    } catch (e) {
      debugPrint('Error handling WebSocket message: $e');
    }
  }

  /// Handle detection result
  void _handleDetectionResult(Map<String, dynamic> data) {
    try {
      final List<dynamic> facesData = data['faces'];
      final List<Face> faces = [];

      for (final faceData in facesData) {
        final face = _convertToMLKitFace(faceData);
        faces.add(face);
      }

      // Emit the faces
      _facesStreamController.add(faces);
    } catch (e) {
      debugPrint('Error handling detection result: $e');
    }
  }

  /// Convert JSON face data to ML Kit Face
  Face _convertToMLKitFace(Map<String, dynamic> faceData) {
    final x = faceData['x'] as int;
    final y = faceData['y'] as int;
    final width = faceData['width'] as int;
    final height = faceData['height'] as int;
    final confidence = faceData['confidence'] as double? ?? 1.0;

    // Create a Face object with the same properties as ML Kit
    return Face(
      boundingBox: Rect.fromLTWH(
        x.toDouble(),
        y.toDouble(),
        width.toDouble(),
        height.toDouble(),
      ),
      landmarks: const {},
      contours: const {},
      trackingId: 0,
    );
  }

  /// Handle WebSocket errors
  void _handleError(error) {
    debugPrint('WebSocket error: $error');
    _isConnected = false;
  }

  /// Handle WebSocket connection closed
  void _handleDone() {
    debugPrint('WebSocket connection closed');
    _isConnected = false;
  }

  /// Detect faces in an image
  Future<List<Face>> detectFaces(XFile imageFile,
      {String model = 'haar'}) async {
    if (!_isConnected) {
      await initialize();
      if (!_isConnected) {
        // Fall back to ML Kit if WebSocket is not available
        return _detectFacesWithMLKit(imageFile);
      }
    }

    try {
      // Read image file
      final bytes = await imageFile.readAsBytes();

      // Convert to base64
      final base64Image = base64Encode(bytes);

      // Create a completer to wait for the result
      final completer = Completer<List<Face>>();

      // Listen for the next detection result
      StreamSubscription? subscription;
      subscription = facesStream.listen((faces) {
        if (!completer.isCompleted) {
          completer.complete(faces);
        }
        subscription?.cancel();
      }, onError: (e) {
        if (!completer.isCompleted) {
          completer.completeError(e);
        }
        subscription?.cancel();
      }, cancelOnError: true);

      // Set a timeout
      Timer(const Duration(seconds: 5), () {
        if (!completer.isCompleted) {
          completer.complete(<Face>[]);
          subscription?.cancel();
        }
      });

      // Send the request
      _channel!.sink.add(jsonEncode({
        'type': 'detect_faces',
        'image': base64Image,
        'model': model,
        'min_confidence': 0.5,
      }));

      // Wait for the result
      return await completer.future;
    } catch (e) {
      debugPrint('Error detecting faces with WebSocket: $e');
      // Fall back to ML Kit
      return _detectFacesWithMLKit(imageFile);
    }
  }

  /// Detect faces using ML Kit (fallback)
  Future<List<Face>> _detectFacesWithMLKit(XFile imageFile) async {
    try {
      // Create face detector
      final options = FaceDetectorOptions(
        enableContours: true,
        enableClassification: true,
        enableTracking: true,
        performanceMode: FaceDetectorMode.accurate,
        minFaceSize: 0.15,
      );

      final faceDetector = FaceDetector(options: options);

      // Process the image
      final inputImage = InputImage.fromFilePath(imageFile.path);
      final faces = await faceDetector.processImage(inputImage);

      // Close the detector
      faceDetector.close();

      return faces;
    } catch (e) {
      debugPrint('Error detecting faces with ML Kit: $e');
      return [];
    }
  }

  /// Process a camera image for real-time face detection
  Future<void> processImage(
      CameraImage cameraImage, CameraDescription camera) async {
    if (!_isConnected) return;

    try {
      // Convert CameraImage to base64
      final base64Image =
          await _convertCameraImageToBase64(cameraImage, camera);

      // Send the request
      _channel!.sink.add(jsonEncode({
        'type': 'detect_faces',
        'image': base64Image,
        'model': _availableModels.contains('mediapipe') ? 'mediapipe' : 'haar',
        'min_confidence': 0.5,
      }));
    } catch (e) {
      debugPrint('Error processing camera image: $e');
    }
  }

  /// Convert CameraImage to base64
  Future<String> _convertCameraImageToBase64(
      CameraImage cameraImage, CameraDescription camera) async {
    try {
      // This is a simplified conversion - in a real app, you'd need to
      // handle different image formats and camera orientations
      if (cameraImage.format.group == ImageFormatGroup.yuv420) {
        // Get image dimensions (not used directly but kept for future enhancements)
        // final width = cameraImage.width;
        // final height = cameraImage.height;

        // Create a simple representation (this is not accurate for all devices)
        final bytes = cameraImage.planes[0].bytes;

        // Convert to base64
        return base64Encode(bytes);
      } else {
        throw Exception(
            'Unsupported image format: ${cameraImage.format.group}');
      }
    } catch (e) {
      debugPrint('Error converting camera image to base64: $e');
      rethrow;
    }
  }

  /// Send a ping to keep the connection alive
  void ping() {
    if (_isConnected) {
      _channel!.sink.add(jsonEncode({
        'type': 'ping',
        'timestamp': DateTime.now().toIso8601String(),
      }));
    }
  }

  /// Disconnect from the WebSocket server
  Future<void> disconnect() async {
    if (_channel != null) {
      await _channel!.sink.close();
      _channel = null;
    }
    _isConnected = false;
  }

  /// Dispose of resources
  void dispose() {
    disconnect();
    _facesStreamController.close();

    if (_pythonProcess != null) {
      _pythonProcess!.kill();
      _pythonProcess = null;
    }
    _isServerRunning = false;
  }
}
