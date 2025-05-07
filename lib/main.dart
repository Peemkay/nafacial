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
import 'providers/notification_service.dart';
import 'providers/rank_provider.dart';
import 'providers/analytics_provider.dart';
import 'services/app_shortcuts_service.dart';
import 'services/button_service.dart';
import 'services/admin_auth_service.dart';
import 'services/secure_route_navigator.dart';
import 'widgets/banner_notification.dart';
import 'widgets/light_theme_wrapper.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen_new.dart' as home;
import 'screens/facial_verification_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/live_facial_recognition_screen.dart';
import 'screens/personnel_registration_screen.dart';
import 'screens/personnel_edit_screen.dart';
import 'screens/gallery_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/biometric_management_screen.dart';
import 'screens/app_roadmap_screen.dart';
import 'screens/personnel_database_screen.dart';
import 'screens/personnel_detail_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/access_logs_screen.dart';
import 'screens/about_screen.dart';
import 'screens/contact_screen.dart';
import 'screens/terms_screen.dart';
import 'screens/privacy_screen.dart';
import 'screens/device_management_screen.dart';
import 'screens/id_management_screen.dart';
import 'screens/rank_management_screen.dart';
import 'screens/analytics_dashboard_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/activity_summary_screen.dart';
import 'screens/enhanced_recognition_demo_screen.dart';
import 'screens/android_server_manager_screen.dart';
import 'screens/theme_preview_screen.dart';

// Global navigator key for accessing navigator from anywhere
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Set preferred orientations to portrait by default
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    // Only allow landscape when explicitly requested by user
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

  // Initialize services
  final AdminAuthService _adminAuthService = AdminAuthService();
  final SecureRouteNavigator _secureNavigator = SecureRouteNavigator();

  @override
  void initState() {
    super.initState();
    _initializeShortcuts();
    _initializeServices();
  }

  // Initialize services
  Future<void> _initializeServices() async {
    await _adminAuthService.initialize();
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
      final context = navigatorKey.currentState!.context;

      // Check if route requires admin verification
      if (_secureNavigator.requiresAdminVerification('/$route')) {
        // Use secure navigator for admin routes
        _secureNavigator.navigateTo(context, '/$route');
      } else {
        // Use regular navigation for non-admin routes
        navigatorKey.currentState!.pushNamed('/$route');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provide the navigator key to be accessible throughout the app
        Provider<GlobalKey<NavigatorState>>.value(value: navigatorKey),

        // Core providers
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => VersionProvider()),

        // Service providers
        ChangeNotifierProvider(
          create: (_) => NotificationService(),
          lazy: false, // Initialize immediately
        ),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => QuickActionsProvider()),
        ChangeNotifierProvider(create: (_) => AccessLogProvider()),
        ChangeNotifierProvider(create: (_) => RankProvider()),

        // Dependent providers
        ChangeNotifierProxyProvider<NotificationService, PersonnelProvider>(
          create: (context) => PersonnelProvider(),
          update: (context, notificationService, previous) {
            // Return previous instance if it exists to preserve state
            if (previous != null) {
              return previous;
            }
            return PersonnelProvider(notificationService: notificationService);
          },
          lazy: false, // Initialize immediately
        ),
        ChangeNotifierProvider(create: (_) => AnalyticsProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) => FutureBuilder<List<ThemeData>>(
          // Get dynamic themes based on user preferences
          future: Future.wait([
            AppThemes.getDynamicLightTheme(
              useDynamicColors: themeProvider.useDynamicColors,
              colorSchemeIndex: themeProvider.selectedColorScheme,
            ),
            AppThemes.getDynamicDarkTheme(
              useDynamicColors: themeProvider.useDynamicColors,
              colorSchemeIndex: themeProvider.selectedColorScheme,
            ),
          ]),
          // Use static themes as fallback while loading
          builder: (context, snapshot) {
            final ThemeData lightTheme =
                snapshot.hasData ? snapshot.data![0] : AppThemes.lightTheme;

            final ThemeData darkTheme =
                snapshot.hasData ? snapshot.data![1] : AppThemes.darkTheme;

            return MaterialApp(
              title: 'NAFacial',
              debugShowCheckedModeBanner: false,
              theme: lightTheme,
              darkTheme: darkTheme,
              themeMode: themeProvider.themeMode,
              navigatorKey: navigatorKey,
              initialRoute: _initialRoute ?? '/splash',
              // Use home property for the initial route
              home: const LightThemeWrapper(child: SplashScreen()),
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
                '/register_personnel': (context) => const LightThemeWrapper(
                    child: PersonnelRegistrationScreen()),
                '/gallery': (context) => const GalleryScreen(),
                // Registration screen also uses light theme
                '/register': (context) =>
                    const LightThemeWrapper(child: RegistrationScreen()),
                '/profile': (context) => const ProfileScreen(),
                '/biometric_management': (context) =>
                    const BiometricManagementScreen(),

                // New routes for additional features
                '/personnel_database': (context) =>
                    const PersonnelDatabaseScreen(),
                '/personnel_detail': (context) => const PersonnelDetailScreen(),
                '/edit_personnel': (context) {
                  final args = ModalRoute.of(context)!.settings.arguments
                      as Map<String, dynamic>;
                  final personnelId = args['personnelId'];
                  final personnelProvider =
                      Provider.of<PersonnelProvider>(context, listen: false);
                  final personnel =
                      personnelProvider.getPersonnelById(personnelId);
                  if (personnel == null) {
                    return const Scaffold(
                        body: Center(child: Text('Personnel not found')));
                  }
                  return PersonnelEditScreen(personnel: personnel);
                },
                '/access_logs': (context) => const AccessLogsScreen(),
                '/access_control': (context) =>
                    const Scaffold(body: Center(child: Text('Access Control'))),
                '/id_management': (context) => const IDManagementScreen(),
                '/rank_management': (context) => const RankManagementScreen(),
                '/analytics': (context) => const AnalyticsDashboardScreen(),
                '/statistics': (context) => const StatisticsScreen(),
                '/activity_summary': (context) => const ActivitySummaryScreen(),
                '/check_updates': (context) =>
                    const Scaffold(body: Center(child: Text('Check Updates'))),
                '/app_roadmap': (context) => const AppRoadmapScreen(),
                '/notifications': (context) => const NotificationsScreen(),
                '/device_management': (context) =>
                    const DeviceManagementScreen(),

                // Android-specific screens
                '/android_server_manager': (context) =>
                    const AndroidServerManagerScreen(),
                '/enhanced_recognition': (context) =>
                    const EnhancedRecognitionDemoScreen(),

                // Info pages
                '/about': (context) => const AboutScreen(),
                '/contact': (context) => const ContactScreen(),
                '/terms': (context) => const TermsScreen(),
                '/privacy': (context) => const PrivacyScreen(),

                // Theme customization
                '/theme_preview': (context) => const ThemePreviewScreen(),
              },
              builder: (context, child) {
                // Apply a responsive layout wrapper to the entire app
                return Consumer<NotificationService>(
                  builder: (context, notificationService, _) {
                    return BannerNotificationManager(
                      notificationService:
                          notificationService, // Pass the service directly
                      child: MediaQuery(
                        // Set text scaling to ensure consistent text sizes
                        data: MediaQuery.of(context).copyWith(
                          textScaler: const TextScaler.linear(1.0),
                        ),
                        child: Builder(
                          // Add a unique key to fix the GlobalKey duplication issue
                          key: const Key('app_shortcuts_builder'),
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
                );
              },
            );
          },
        ),
      ),
    );
  }
}
