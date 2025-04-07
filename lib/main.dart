import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'config/theme.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Allow all orientations for responsive design
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const NAFacialApp());
}

class NAFacialApp extends StatelessWidget {
  const NAFacialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NAFacial',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const SplashScreen(),
      builder: (context, child) {
        // Apply a responsive layout wrapper to the entire app
        return MediaQuery(
          // Set text scaling to ensure consistent text sizes
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.0),
          ),
          child: child!,
        );
      },
    );
  }
}
