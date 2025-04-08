import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'config/app_themes.dart';
import 'providers/auth_provider.dart';
import 'providers/personnel_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/quick_actions_provider.dart';
import 'providers/access_log_provider.dart';
import 'providers/version_provider.dart';
import 'services/notification_service.dart';
import 'widgets/banner_notification.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/facial_verification_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/live_facial_recognition_screen.dart';
import 'screens/personnel_registration_screen.dart';
import 'screens/gallery_screen.dart';

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
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => QuickActionsProvider()),
        ChangeNotifierProvider(create: (_) => AccessLogProvider()),
        ChangeNotifierProvider(create: (_) => VersionProvider()),
        ChangeNotifierProvider(create: (_) => NotificationService()),
        ChangeNotifierProxyProvider<NotificationService, PersonnelProvider>(
          create: (context) => PersonnelProvider(),
          update: (context, notificationService, previous) =>
              PersonnelProvider(notificationService: notificationService),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) => MaterialApp(
          title: 'NAFacial',
          debugShowCheckedModeBanner: false,
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          themeMode: themeProvider.themeMode,
          initialRoute: '/splash',
          routes: {
            '/splash': (context) => const SplashScreen(),
            '/login': (context) => const LoginScreen(),
            '/home': (context) => const HomeScreen(),
            '/facial_verification': (context) =>
                const FacialVerificationScreen(),
            '/settings': (context) => const SettingsScreen(),
            '/live_recognition': (context) =>
                const LiveFacialRecognitionScreen(),
            '/register_personnel': (context) =>
                const PersonnelRegistrationScreen(),
            '/gallery': (context) => const GalleryScreen(),
          },
          builder: (context, child) {
            // Apply a responsive layout wrapper to the entire app
            return BannerNotificationManager(
              child: MediaQuery(
                // Set text scaling to ensure consistent text sizes
                data: MediaQuery.of(context).copyWith(
                  textScaler: const TextScaler.linear(1.0),
                ),
                child: child!,
              ),
            );
          },
        ),
      ),
    );
  }
}
