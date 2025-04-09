import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import '../config/theme.dart';

/// Utility class to generate the app logo as a PNG file
class LogoGenerator {
  static final GlobalKey _logoKey = GlobalKey();

  /// Generate the app logo and save it as a PNG file
  static Future<String> generateLogo() async {
    // Create a RepaintBoundary with the logo
    final RenderRepaintBoundary boundary =
        _logoKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

    // Convert to image
    final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) {
      throw Exception('Failed to convert logo to PNG');
    }

    final Uint8List pngBytes = byteData.buffer.asUint8List();

    // Save to file
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/nafacial_logo.png';
    final file = File(filePath);
    await file.writeAsBytes(pngBytes);

    return filePath;
  }

  /// Widget that renders the logo
  static Widget buildLogo() {
    return RepaintBoundary(
      key: _logoKey,
      child: Container(
        width: 512,
        height: 512,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(
            colors: [
              Color(0xB3001F3F), // primaryColor with 0.7 opacity
              Color(0xFF001F3F), // primaryColor
            ],
            center: Alignment.center,
            radius: 0.8,
          ),
          border: Border.all(
            color: AppTheme.yellow,
            width: 4,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.security,
                color: AppTheme.yellow,
                size: 150,
              ),
              const SizedBox(height: 30),
              const Text(
                "NAFacial",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
