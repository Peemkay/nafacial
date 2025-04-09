import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path/path.dart' as path;

Future<void> main() async {
  final svg = File('assets/favicon/nafacial_logo_new.svg').readAsStringSync();
  final drawable = await svg.toPicture();
  
  final image = await drawable.toImage(1024, 1024); // High resolution for scaling
  final data = await image.toByteData(format: ImageByteFormat.png);
  
  if (data != null) {
    final bytes = data.buffer.asUint8List();
    File('assets/favicon/nafacial_logo.png').writeAsBytesSync(bytes);
    print('PNG file created successfully');
  }
}