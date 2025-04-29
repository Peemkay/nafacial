import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../services/python_facial_recognition_service.dart';

/// A controller for camera with WebSocket-based facial recognition
class WebSocketCameraController extends ChangeNotifier {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  CameraDescription? _selectedCamera;
  bool _isInitialized = false;
  bool _isProcessing = false;
  bool _isStreaming = false;
  Timer? _streamTimer;
  
  // Face detection results
  Map<String, dynamic>? _lastProcessedFrame;
  List<Map<String, dynamic>> _detectedFaces = [];
  
  // Python service
  final PythonFacialRecognitionService _pythonService;
  StreamSubscription? _pythonSubscription;
  
  // Getters
  CameraController? get cameraController => _cameraController;
  bool get isInitialized => _isInitialized;
  bool get isProcessing => _isProcessing;
  bool get isStreaming => _isStreaming;
  Map<String, dynamic>? get lastProcessedFrame => _lastProcessedFrame;
  List<Map<String, dynamic>> get detectedFaces => _detectedFaces;
  
  // Constructor
  WebSocketCameraController(this._pythonService) {
    _initialize();
  }
  
  /// Initialize the controller
  Future<void> _initialize() async {
    try {
      // Get available cameras
      _cameras = await availableCameras();
      
      if (_cameras != null && _cameras!.isNotEmpty) {
        // Select the first camera by default
        await selectCamera(_cameras!.first);
      }
      
      // Listen for processed frames from the Python service
      _pythonSubscription = _pythonService.processedFrameStream.listen(_handleProcessedFrame);
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing WebSocketCameraController: $e');
    }
  }
  
  /// Select a camera
  Future<void> selectCamera(CameraDescription camera) async {
    if (_cameraController != null) {
      await _cameraController!.dispose();
    }
    
    _selectedCamera = camera;
    
    // Initialize the camera controller
    _cameraController = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    
    try {
      await _cameraController!.initialize();
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }
  
  /// Start streaming frames to the Python service
  void startStreaming() {
    if (_isStreaming || _cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    
    _isStreaming = true;
    
    // Start a timer to capture frames periodically
    _streamTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      captureFrame();
    });
    
    notifyListeners();
  }
  
  /// Stop streaming
  void stopStreaming() {
    _isStreaming = false;
    _streamTimer?.cancel();
    _streamTimer = null;
    notifyListeners();
  }
  
  /// Capture a single frame and send it to the Python service
  Future<void> captureFrame() async {
    if (_isProcessing || _cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    
    _isProcessing = true;
    notifyListeners();
    
    try {
      // Capture an image
      final XFile imageFile = await _cameraController!.takePicture();
      
      // Convert to base64
      final bytes = await File(imageFile.path).readAsBytes();
      final base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      
      // Send to Python service
      await _pythonService.processFrame(base64Image);
    } catch (e) {
      debugPrint('Error capturing frame: $e');
    }
  }
  
  /// Handle processed frame from the Python service
  void _handleProcessedFrame(Map<String, dynamic> data) {
    _isProcessing = false;
    
    if (data.containsKey('error')) {
      debugPrint('Error from Python service: ${data['error']}');
      notifyListeners();
      return;
    }
    
    _lastProcessedFrame = data;
    
    // Update detected faces
    if (data.containsKey('faces')) {
      _detectedFaces = List<Map<String, dynamic>>.from(data['faces']);
    }
    
    notifyListeners();
  }
  
  /// Get the processed image as a widget
  Widget? getProcessedImageWidget() {
    if (_lastProcessedFrame == null || !_lastProcessedFrame!.containsKey('processed_frame')) {
      return null;
    }
    
    return Image.memory(
      base64Decode(_lastProcessedFrame!['processed_frame'].split(',')[1]),
      gaplessPlayback: true,
    );
  }
  
  /// Dispose of resources
  @override
  void dispose() {
    _streamTimer?.cancel();
    _pythonSubscription?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }
}
