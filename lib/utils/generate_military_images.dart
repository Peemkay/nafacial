import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/rendering.dart';

/// Utility class to generate placeholder military technology images
/// This is used for development purposes only
class MilitaryImageGenerator {
  static final Random _random = Random();
  
  /// Generate a set of military technology placeholder images
  static Future<void> generateImages() async {
    final directory = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${directory.path}/assets/images');
    
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }
    
    // Generate each image
    await _generateImage(
      'military_facial_scan.png', 
      Colors.green, 
      Icons.face_retouching_natural,
      imagesDir.path
    );
    
    await _generateImage(
      'military_neural_network.png', 
      Colors.blue, 
      Icons.psychology,
      imagesDir.path
    );
    
    await _generateImage(
      'military_biometric.png', 
      Colors.purple, 
      Icons.fingerprint,
      imagesDir.path
    );
    
    await _generateImage(
      'military_encryption.png', 
      Colors.red, 
      Icons.security,
      imagesDir.path
    );
    
    await _generateImage(
      'military_surveillance.png', 
      Colors.orange, 
      Icons.shield,
      imagesDir.path
    );
    
    print('Generated military technology images at ${imagesDir.path}');
  }
  
  /// Generate a single image with military-themed design
  static Future<void> _generateImage(
    String filename, 
    Color baseColor, 
    IconData icon,
    String outputPath
  ) async {
    // Create a recorder to capture the drawing
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    
    // Define the size of the image
    const size = Size(400, 300);
    
    // Draw background
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          baseColor.withOpacity(0.7),
          baseColor.withOpacity(0.3),
          Colors.black.withOpacity(0.8),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    
    // Draw grid lines for tech effect
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1;
    
    for (var i = 0; i < size.width; i += 20) {
      canvas.drawLine(
        Offset(i.toDouble(), 0), 
        Offset(i.toDouble(), size.height), 
        gridPaint
      );
    }
    
    for (var i = 0; i < size.height; i += 20) {
      canvas.drawLine(
        Offset(0, i.toDouble()), 
        Offset(size.width, i.toDouble()), 
        gridPaint
      );
    }
    
    // Draw random tech circles
    for (var i = 0; i < 20; i++) {
      final circlePaint = Paint()
        ..color = baseColor.withOpacity(_random.nextDouble() * 0.3 + 0.1)
        ..style = PaintingStyle.fill;
      
      final x = _random.nextDouble() * size.width;
      final y = _random.nextDouble() * size.height;
      final radius = _random.nextDouble() * 30 + 5;
      
      canvas.drawCircle(Offset(x, y), radius, circlePaint);
    }
    
    // Draw icon
    final iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: 100,
          fontFamily: icon.fontFamily,
          color: Colors.white.withOpacity(0.7),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    iconPainter.layout();
    iconPainter.paint(
      canvas, 
      Offset(
        (size.width - iconPainter.width) / 2, 
        (size.height - iconPainter.height) / 2
      )
    );
    
    // Draw "Nigerian Army" text
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Nigerian Army Signals',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white.withOpacity(0.8),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    textPainter.paint(
      canvas, 
      Offset(
        (size.width - textPainter.width) / 2, 
        size.height - textPainter.height - 20
      )
    );
    
    // End recording and convert to image
    final picture = recorder.endRecording();
    final img = await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final buffer = byteData!.buffer.asUint8List();
    
    // Save the image
    final file = File('$outputPath/$filename');
    await file.writeAsBytes(buffer);
  }
}
