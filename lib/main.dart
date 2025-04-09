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
import 'services/app_shortcuts_service.dart';
import 'services/button_service.dart';
import 'widgets/banner_notification.dart';
import 'widgets/light_theme_wrapper.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen_new.dart' as home;
import 'screens/facial_verification_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/live_facial_recognition_screen.dart';
import 'screens/personnel_registration_screen.dart';
import 'screens/gallery_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/biometric_management_screen.dart';

// Global navigator key for accessing navigator from anywhere
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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

// Method channel for handling app shortcuts
const MethodChannel _shortcutsChannel =
    MethodChannel('com.example.nafacial/shortcuts');

class NAFacialApp extends StatefulWidget {
  const NAFacialApp({super.key});

  @override
  State<NAFacialApp> createState() => _NAFacialAppState();
}

class _NAFacialAppState extends State<NAFacialApp> {
  final AppShortcutsService _shortcutsService = AppShortcutsService();
  String? _initialRoute;

  @override
  void initState() {
    super.initState();
    _initializeShortcuts();
  }

  Future<void> _initializeShortcuts() async {
    // Set up method channel listener for navigation
    _shortcutsChannel.setMethodCallHandler((call) async {
      if (call.method == 'navigateTo') {
        final route = call.arguments as String;
        _navigateToRoute(route);
      }
    });

    // Check for initial route from shortcuts
    try {
      final initialRoute =
          await _shortcutsChannel.invokeMethod<String>('getInitialRoute');
      if (initialRoute != null && mounted) {
        setState(() {
          _initialRoute = initialRoute;
        });
      }
    } catch (e) {
      debugPrint('Error getting initial route: $e');
    }

    // Initialize button service for hardware button camera launch
    await _initializeButtonService();
  }

  Future<void> _initializeButtonService() async {
    try {
      final result = await ButtonService.startButtonService();
      debugPrint('Button service initialized: $result');
    } catch (e) {
      debugPrint('Error initializing button service: $e');
    }
  }

  void _navigateToRoute(String route) {
    // Use a navigator key to access the navigator from anywhere
    if (navigatorKey.currentState != null) {
      navigatorKey.currentState!.pushNamed('/$route');
    }
  }

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
          navigatorKey: navigatorKey,
          initialRoute: _initialRoute ?? '/splash',
          routes: {
            // Always use light theme for splash, login, and registration screens
            '/splash': (context) =>
                const LightThemeWrapper(child: SplashScreen()),
            '/login': (context) =>
                const LightThemeWrapper(child: LoginScreen()),
            '/home': (context) => const home.HomeScreen(),
            '/facial_verification': (context) =>
                const FacialVerificationScreen(),
            '/settings': (context) => const SettingsScreen(),
            '/live_recognition': (context) =>
                const LiveFacialRecognitionScreen(),
            '/register_personnel': (context) =>
                const LightThemeWrapper(child: PersonnelRegistrationScreen()),
            '/gallery': (context) => const GalleryScreen(),
            // Registration screen also uses light theme
            '/register': (context) =>
                const LightThemeWrapper(child: RegistrationScreen()),
            '/profile': (context) => const ProfileScreen(),
            '/biometric_management': (context) =>
                const BiometricManagementScreen(),
          },
          builder: (context, child) {
            // Apply a responsive layout wrapper to the entire app
            return BannerNotificationManager(
              child: MediaQuery(
                // Set text scaling to ensure consistent text sizes
                data: MediaQuery.of(context).copyWith(
                  textScaler: const TextScaler.linear(1.0),
                ),
                child: Builder(
                  builder: (context) {
                    // Initialize app shortcuts
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _shortcutsService.initialize(context);
                    });
                    return child!;
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
