import 'dart:io';
import 'package:flutter/material.dart';
import 'logo_generator.dart';

/// This is a utility script to generate the app logo
/// Run this file to generate the logo and save it to the assets directory
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Create a simple app to render the logo
  runApp(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: LogoGenerator.buildLogo(),
        ),
      ),
    ),
  );

  // Wait for the UI to render
  await Future.delayed(const Duration(seconds: 1));

  try {
    // Generate the logo
    final filePath = await LogoGenerator.generateLogo();

    // Copy to assets directory
    const assetPath = 'assets/favicon/nafacial_logo.png';
    final assetFile = File(assetPath);
    await File(filePath).copy(assetPath);

    print('Logo generated and saved to $assetPath');
  } catch (e) {
    print('Error generating logo: $e');
  }

  // Exit the app
  exit(0);
}
