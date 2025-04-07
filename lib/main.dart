import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/personnel_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/facial_verification_screen.dart';

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PersonnelProvider()),
      ],
      child: MaterialApp(
        title: 'NAFacial',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/facial_verification': (context) => const FacialVerificationScreen(),
        },
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
      ),
    );
  }
}
