import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/personnel_model.dart';

/// Service for communicating with the Python facial recognition server
class PythonFacialRecognitionService extends ChangeNotifier {
  static const String _serverUrl = 'ws://localhost:8765';
  static const int _reconnectDelay = 2000; // ms
  static const int _maxReconnectAttempts = 5;

  WebSocketChannel? _channel;
  bool _isConnected = false;
  bool _isServerRunning = false;
  Process? _serverProcess;
  int _reconnectAttempts = 0;
  StreamSubscription? _subscription;
  
  // Stream controller for processed frames
  final StreamController<Map<String, dynamic>> _processedFrameController = 
      StreamController<Map<String, dynamic>>.broadcast();
  
  // Stream for processed frames
  Stream<Map<String, dynamic>> get processedFrameStream => _processedFrameController.stream;
  
  // Status getters
  bool get isConnected => _isConnected;
  bool get isServerRunning => _isServerRunning;
  
  // Constructor
  PythonFacialRecognitionService() {
    _initialize();
  }
  
  /// Initialize the service
  Future<void> _initialize() async {
    try {
      // Check if Python is installed
      final result = await Process.run('python', ['--version']);
      if (result.exitCode != 0) {
        debugPrint('Python is not installed or not in PATH');
        return;
      }
      
      // Start the server if not already running
      await startServer();
      
      // Connect to the server
      await connectToServer();
    } catch (e) {
      debugPrint('Error initializing Python facial recognition service: $e');
    }
  }
  
  /// Start the Python server
  Future<void> startServer() async {
    if (_isServerRunning) return;
    
    try {
      // Get the path to the Python script
      final appDir = await getApplicationDocumentsDirectory();
      final scriptPath = '${appDir.path}/python/facial_recognition_server.py';
      
      // Check if the script exists
      final scriptFile = File(scriptPath);
      if (!await scriptFile.exists()) {
        // Copy the script from assets
        final scriptDir = Directory('${appDir.path}/python');
        if (!await scriptDir.exists()) {
          await scriptDir.create(recursive: true);
        }
        
        // Create the script file
        await scriptFile.writeAsString(await _getPythonScript());
        debugPrint('Created Python script at $scriptPath');
      }
      
      // Start the server process
      _serverProcess = await Process.start('python', [scriptPath]);
      _isServerRunning = true;
      
      // Log server output
      _serverProcess!.stdout.transform(utf8.decoder).listen((data) {
        debugPrint('Python server: $data');
      });
      
      _serverProcess!.stderr.transform(utf8.decoder).listen((data) {
        debugPrint('Python server error: $data');
      });
      
      // Wait for the server to start
      await Future.delayed(const Duration(seconds: 2));
      
      debugPrint('Python facial recognition server started');
      notifyListeners();
    } catch (e) {
      debugPrint('Error starting Python server: $e');
      _isServerRunning = false;
      notifyListeners();
    }
  }
  
  /// Connect to the WebSocket server
  Future<void> connectToServer() async {
    if (_isConnected) return;
    
    try {
      _channel = IOWebSocketChannel.connect(_serverUrl);
      _isConnected = true;
      _reconnectAttempts = 0;
      
      // Listen for messages from the server
      _subscription = _channel!.stream.listen(
        (message) {
          try {
            final data = jsonDecode(message);
            _processedFrameController.add(data);
          } catch (e) {
            debugPrint('Error parsing message from server: $e');
          }
        },
        onDone: () {
          _isConnected = false;
          _reconnect();
        },
        onError: (error) {
          debugPrint('WebSocket error: $error');
          _isConnected = false;
          _reconnect();
        },
      );
      
      debugPrint('Connected to Python facial recognition server');
      notifyListeners();
    } catch (e) {
      debugPrint('Error connecting to Python server: $e');
      _isConnected = false;
      _reconnect();
    }
  }
  
  /// Reconnect to the server
  Future<void> _reconnect() async {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      debugPrint('Max reconnect attempts reached');
      return;
    }
    
    _reconnectAttempts++;
    debugPrint('Reconnecting to server (attempt $_reconnectAttempts)...');
    
    await Future.delayed(const Duration(milliseconds: _reconnectDelay));
    await connectToServer();
  }
  
  /// Process a frame
  Future<void> processFrame(String base64Image) async {
    if (!_isConnected) {
      await connectToServer();
      if (!_isConnected) return;
    }
    
    try {
      final message = jsonEncode({
        'command': 'process_frame',
        'frame': base64Image,
      });
      
      _channel!.sink.add(message);
    } catch (e) {
      debugPrint('Error sending frame to server: $e');
    }
  }
  
  /// Get known faces
  Future<void> getKnownFaces() async {
    if (!_isConnected) {
      await connectToServer();
      if (!_isConnected) return;
    }
    
    try {
      final message = jsonEncode({
        'command': 'get_known_faces',
      });
      
      _channel!.sink.add(message);
    } catch (e) {
      debugPrint('Error getting known faces: $e');
    }
  }
  
  /// Add a face to the database
  Future<void> addFace(Personnel personnel, String base64Image) async {
    if (!_isConnected) {
      await connectToServer();
      if (!_isConnected) return;
    }
    
    try {
      final message = jsonEncode({
        'command': 'add_face',
        'name': personnel.fullName,
        'army_number': personnel.armyNumber,
        'image': base64Image,
      });
      
      _channel!.sink.add(message);
    } catch (e) {
      debugPrint('Error adding face: $e');
    }
  }
  
  /// Get the Python script content
  Future<String> _getPythonScript() async {
    // In a real app, you would load this from assets
    // For this example, we'll return a placeholder
    return '''
import asyncio
import json
import os
import cv2
import numpy as np
import websockets
import base64
from datetime import datetime
import time
import threading
import logging

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler("facial_recognition_server.log"),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger("FacialRecognitionServer")

# Try to import face_recognition, if not available, use MTCNN as fallback
try:
    import face_recognition
    USING_FACE_RECOGNITION = True
    logger.info("Using face_recognition library")
except ImportError:
    try:
        from mtcnn import MTCNN
        detector = MTCNN()
        USING_FACE_RECOGNITION = False
        logger.info("Using MTCNN library")
    except ImportError:
        logger.error("Neither face_recognition nor MTCNN is available. Please install one of them.")
        raise ImportError("Neither face_recognition nor MTCNN is available. Please install one of them.")

# Global variables
known_face_encodings = []
known_face_metadata = []
processing_frame = False
last_face_locations = []
last_face_encodings = []
last_face_names = []
last_face_timestamps = []

# Configuration
TOLERANCE = 0.6  # Lower is more strict
FRAME_THICKNESS = 2
FONT_THICKNESS = 2
MODEL = "hog"  # Options: "hog" (CPU) or "cnn" (GPU)
PORT = 8765
SAVE_UNKNOWN_FACES = True
UNKNOWN_FACES_DIR = "unknown_faces"

# Create directory for unknown faces if it doesn't exist
if SAVE_UNKNOWN_FACES and not os.path.exists(UNKNOWN_FACES_DIR):
    os.makedirs(UNKNOWN_FACES_DIR)

def load_known_faces(directory="known_faces"):
    """
    Load known faces from the specified directory
    """
    global known_face_encodings, known_face_metadata
    
    if not os.path.exists(directory):
        logger.warning(f"Directory {directory} does not exist. Creating it.")
        os.makedirs(directory)
        return
    
    logger.info(f"Loading known faces from {directory}")
    
    for filename in os.listdir(directory):
        if filename.endswith(".jpg") or filename.endswith(".png"):
            # Extract metadata from filename
            name = os.path.splitext(filename)[0]
            
            # Load image
            image_path = os.path.join(directory, filename)
            image = face_recognition.load_image_file(image_path)
            
            # Get face encoding
            encodings = face_recognition.face_encodings(image)
            
            if len(encodings) > 0:
                # Add to known faces
                known_face_encodings.append(encodings[0])
                
                # Create metadata
                metadata = {
                    "name": name,
                    "image_path": image_path,
                    "last_seen": None,
                    "seen_count": 0,
                    "seen_frames": 0
                }
                known_face_metadata.append(metadata)
                logger.info(f"Loaded {name}")
            else:
                logger.warning(f"No face found in {filename}")
    
    logger.info(f"Loaded {len(known_face_encodings)} known faces")

def save_unknown_face(face_image, face_location):
    """
    Save an unknown face for later review
    """
    if not SAVE_UNKNOWN_FACES:
        return
    
    # Create a unique filename with timestamp
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    filename = f"unknown_{timestamp}.jpg"
    filepath = os.path.join(UNKNOWN_FACES_DIR, filename)
    
    # Extract face from image
    top, right, bottom, left = face_location
    face_image = face_image[top:bottom, left:right]
    
    # Save the face
    cv2.imwrite(filepath, cv2.cvtColor(face_image, cv2.COLOR_RGB2BGR))
    logger.info(f"Saved unknown face to {filepath}")

def process_frame(frame_data):
    """
    Process a frame to detect and recognize faces
    """
    global processing_frame, last_face_locations, last_face_encodings, last_face_names, last_face_timestamps
    
    if processing_frame:
        return None
    
    processing_frame = True
    
    try:
        # Decode base64 image
        img_bytes = base64.b64decode(frame_data.split(',')[1])
        img_np = np.frombuffer(img_bytes, dtype=np.uint8)
        frame = cv2.imdecode(img_np, cv2.IMREAD_COLOR)
        
        # Convert BGR to RGB
        rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        
        # Detect faces
        if USING_FACE_RECOGNITION:
            # Use face_recognition library
            face_locations = face_recognition.face_locations(rgb_frame, model=MODEL)
            face_encodings = face_recognition.face_encodings(rgb_frame, face_locations)
        else:
            # Use MTCNN as fallback
            results = detector.detect_faces(rgb_frame)
            face_locations = []
            face_encodings = []
            
            for result in results:
                x, y, width, height = result['box']
                face_locations.append((y, x + width, y + height, x))  # Convert to face_recognition format
                # Note: MTCNN doesn't provide encodings, so we'll just use empty placeholders
                face_encodings.append([])
        
        # Reset results
        last_face_locations = []
        last_face_names = []
        last_face_timestamps = []
        
        # Process each face
        for i, (face_location, face_encoding) in enumerate(zip(face_locations, face_encodings)):
            name = "Unknown"
            confidence = 0.0
            
            if USING_FACE_RECOGNITION and len(known_face_encodings) > 0:
                # Compare with known faces
                matches = face_recognition.compare_faces(known_face_encodings, face_encoding, TOLERANCE)
                
                # Calculate face distances
                face_distances = face_recognition.face_distance(known_face_encodings, face_encoding)
                
                if len(face_distances) > 0:
                    best_match_index = np.argmin(face_distances)
                    confidence = 1 - face_distances[best_match_index]
                    
                    if matches[best_match_index]:
                        name = known_face_metadata[best_match_index]["name"]
                        
                        # Update metadata
                        known_face_metadata[best_match_index]["last_seen"] = datetime.now().isoformat()
                        known_face_metadata[best_match_index]["seen_count"] += 1
                        known_face_metadata[best_match_index]["seen_frames"] += 1
            
            # Save unknown faces
            if name == "Unknown" and SAVE_UNKNOWN_FACES:
                save_unknown_face(rgb_frame, face_location)
            
            # Store results
            last_face_locations.append(face_location)
            last_face_names.append(name)
            last_face_timestamps.append(datetime.now().isoformat())
            
            # Draw rectangle and name on frame
            top, right, bottom, left = face_location
            cv2.rectangle(frame, (left, top), (right, bottom), (0, 255, 0), FRAME_THICKNESS)
            
            # Draw a label with a name below the face
            cv2.rectangle(frame, (left, bottom - 35), (right, bottom), (0, 255, 0), cv2.FILLED)
            cv2.putText(frame, f"{name} ({confidence:.2f})", (left + 6, bottom - 6), 
                        cv2.FONT_HERSHEY_DUPLEX, 0.8, (255, 255, 255), FONT_THICKNESS)
        
        # Convert back to base64 for sending
        _, buffer = cv2.imencode('.jpg', frame)
        processed_frame = base64.b64encode(buffer).decode('utf-8')
        
        # Prepare results
        results = {
            "processed_frame": f"data:image/jpeg;base64,{processed_frame}",
            "face_count": len(face_locations),
            "faces": []
        }
        
        # Add face details
        for i, (location, name, timestamp) in enumerate(zip(last_face_locations, last_face_names, last_face_timestamps)):
            top, right, bottom, left = location
            face_data = {
                "id": i,
                "name": name,
                "timestamp": timestamp,
                "location": {
                    "top": top,
                    "right": right,
                    "bottom": bottom,
                    "left": left
                }
            }
            results["faces"].append(face_data)
        
        processing_frame = False
        return results
    
    except Exception as e:
        logger.error(f"Error processing frame: {str(e)}")
        processing_frame = False
        return {"error": str(e)}

async def websocket_handler(websocket, path):
    """
    Handle WebSocket connections
    """
    logger.info(f"Client connected: {websocket.remote_address}")
    
    try:
        async for message in websocket:
            try:
                data = json.loads(message)
                command = data.get("command")
                
                if command == "process_frame":
                    frame_data = data.get("frame")
                    results = process_frame(frame_data)
                    await websocket.send(json.dumps(results))
                
                elif command == "get_known_faces":
                    response = {
                        "known_faces": [
                            {
                                "name": metadata["name"],
                                "last_seen": metadata["last_seen"],
                                "seen_count": metadata["seen_count"]
                            }
                            for metadata in known_face_metadata
                        ]
                    }
                    await websocket.send(json.dumps(response))
                
                elif command == "add_face":
                    # TODO: Implement adding a new face to the database
                    pass
                
                else:
                    await websocket.send(json.dumps({"error": f"Unknown command: {command}"}))
            
            except json.JSONDecodeError:
                await websocket.send(json.dumps({"error": "Invalid JSON"}))
            
            except Exception as e:
                logger.error(f"Error handling message: {str(e)}")
                await websocket.send(json.dumps({"error": str(e)}))
    
    except websockets.exceptions.ConnectionClosed:
        logger.info(f"Client disconnected: {websocket.remote_address}")

async def main():
    """
    Main function to start the WebSocket server
    """
    # Load known faces
    if USING_FACE_RECOGNITION:
        load_known_faces()
    
    # Start WebSocket server
    server = await websockets.serve(websocket_handler, "localhost", PORT)
    logger.info(f"WebSocket server started on ws://localhost:{PORT}")
    
    # Keep the server running
    await server.wait_closed()

if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        logger.info("Server stopped by user")
    except Exception as e:
        logger.error(f"Server error: {str(e)}")
''';
  }
  
  /// Dispose of resources
  @override
  void dispose() {
    _subscription?.cancel();
    _channel?.sink.close();
    _serverProcess?.kill();
    _processedFrameController.close();
    super.dispose();
  }
}
