import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

/// A service for communicating with a WebSocket server
class WebSocketService {
  // Singleton instance
  static final WebSocketService _instance = WebSocketService._internal();

  // Factory constructor
  factory WebSocketService() => _instance;

  // Internal constructor
  WebSocketService._internal();

  // WebSocket channel
  WebSocketChannel? _channel;
  
  // Connection state
  bool _isConnected = false;
  bool _isInitialized = false;
  
  // Message handling
  final StreamController<Map<String, dynamic>> _messageController = 
      StreamController<Map<String, dynamic>>.broadcast();
  
  // Getters
  bool get isConnected => _isConnected;
  bool get isInitialized => _isInitialized;
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  
  /// Initialize the WebSocket service
  Future<bool> initialize() async {
    if (_isInitialized) return _isConnected;
    
    try {
      // Connect to the WebSocket server
      await connect();
      _isInitialized = true;
      return _isConnected;
    } catch (e) {
      debugPrint('Error initializing WebSocket service: $e');
      _isInitialized = true;
      return false;
    }
  }
  
  /// Connect to the WebSocket server
  Future<bool> connect() async {
    if (_isConnected) return true;
    
    try {
      // Default to localhost for development
      final uri = Uri.parse('ws://localhost:8765');
      
      // Create the WebSocket channel
      _channel = IOWebSocketChannel.connect(uri);
      
      // Listen for messages
      _channel!.stream.listen(
        (message) {
          try {
            final Map<String, dynamic> data = jsonDecode(message);
            _messageController.add(data);
          } catch (e) {
            debugPrint('Error parsing WebSocket message: $e');
          }
        },
        onDone: () {
          _isConnected = false;
          debugPrint('WebSocket connection closed');
        },
        onError: (error) {
          _isConnected = false;
          debugPrint('WebSocket error: $error');
        },
      );
      
      _isConnected = true;
      return true;
    } catch (e) {
      debugPrint('Error connecting to WebSocket server: $e');
      _isConnected = false;
      return false;
    }
  }
  
  /// Disconnect from the WebSocket server
  Future<void> disconnect() async {
    if (_channel != null) {
      await _channel!.sink.close();
      _isConnected = false;
    }
  }
  
  /// Send a message to the WebSocket server
  Future<Map<String, dynamic>?> sendMessage(Map<String, dynamic> message) async {
    if (!_isConnected) {
      final connected = await connect();
      if (!connected) {
        return null;
      }
    }
    
    try {
      // Create a completer to wait for the response
      final completer = Completer<Map<String, dynamic>>();
      
      // Add a message ID for tracking
      final messageId = DateTime.now().millisecondsSinceEpoch.toString();
      message['id'] = messageId;
      
      // Listen for the response with the matching ID
      final subscription = messageStream.listen((response) {
        if (response['id'] == messageId) {
          completer.complete(response);
        }
      });
      
      // Send the message
      _channel!.sink.add(jsonEncode(message));
      
      // Wait for the response with a timeout
      final result = await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          subscription.cancel();
          return {'error': 'Timeout waiting for response'};
        },
      );
      
      // Cancel the subscription
      subscription.cancel();
      
      return result;
    } catch (e) {
      debugPrint('Error sending WebSocket message: $e');
      return null;
    }
  }
  
  /// Dispose of the WebSocket service
  void dispose() {
    disconnect();
    _messageController.close();
  }
}
