import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../config/design_system.dart';
import '../models/personnel_model.dart';
import '../providers/auth_provider.dart';
import '../providers/personnel_provider.dart';
import '../providers/quick_actions_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/version_provider.dart';

// Removed fancy_bottom_nav_bar import
import '../widgets/platform_aware_widgets.dart';
import '../widgets/enhanced_security_features_slider.dart';
import '../widgets/quick_face_recognition_widget.dart';
import '../widgets/user_activity_summary.dart';
import '../widgets/system_status_widget.dart';

class EnhancedHomeScreen extends StatefulWidget {
  const EnhancedHomeScreen({Key? key}) : super(key: key);

  @override
  State<EnhancedHomeScreen> createState() => _EnhancedHomeScreenState();
}

class _EnhancedHomeScreenState extends State<EnhancedHomeScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ImagePicker _picker = ImagePicker();

  // Animation controller for various animations
  late AnimationController _animationController;

  // Face detection variables
  final bool _isFaceDetectionAvailable = !kIsWeb;
  List<Face> _detectedFaces = [];

  // User activity metrics
  int _totalVerifications = 0;
  int _todayVerifications = 0;
  int _totalPersonnel = 0;
  double _systemAccuracy = 0.0;

  // Recently viewed personnel
  List<Personnel> _recentPersonnel = [];

  // System status
  bool _isSystemHealthy = true;
  String _lastUpdateTime = '';
  int _databaseSize = 0;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller with slower animation to reduce CPU usage
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500), // Slower animation
    )..repeat(reverse: true);

    // Use a staggered approach to loading data to reduce initial lag
    _loadInitialData();
  }

  // Load data in a staggered approach to reduce lag
  Future<void> _loadInitialData() async {
    // First load essential data
    await _loadUserMetrics();

    // Then load non-essential data with delays
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _loadSystemStatus();
      }
    });

    // Initialize personnel provider last
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        final personnelProvider =
            Provider.of<PersonnelProvider>(context, listen: false);
        personnelProvider.initialize().then((_) {
          if (mounted) {
            _loadRecentPersonnel();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Load user metrics from shared preferences
  Future<void> _loadUserMetrics() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      setState(() {
        _totalVerifications = prefs.getInt('total_verifications') ?? 0;
        _todayVerifications = prefs.getInt('today_verifications') ?? 0;
        _totalPersonnel = prefs.getInt('total_personnel') ?? 0;
        _systemAccuracy = prefs.getDouble('system_accuracy') ?? 85.7;
      });
    } catch (e) {
      debugPrint('Error loading user metrics: $e');
    }
  }

  // Load system status
  Future<void> _loadSystemStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      setState(() {
        _isSystemHealthy = prefs.getBool('system_healthy') ?? true;
        _lastUpdateTime = prefs.getString('last_update_time') ??
            DateFormat('yyyy-MM-dd HH:mm')
                .format(DateTime.now().subtract(const Duration(days: 3)));
        _databaseSize = prefs.getInt('database_size') ?? 1024;
      });
    } catch (e) {
      debugPrint('Error loading system status: $e');
    }
  }

  // Load recently viewed personnel
  Future<void> _loadRecentPersonnel() async {
    try {
      final personnelProvider =
          Provider.of<PersonnelProvider>(context, listen: false);
      final allPersonnel = personnelProvider.allPersonnel;

      if (allPersonnel.isNotEmpty) {
        // For demo purposes, just take a few random personnel
        final random = math.Random();
        final recentCount = math.min(3, allPersonnel.length);
        final recentIndices = List.generate(
          allPersonnel.length,
          (index) => index,
        )..shuffle(random);

        setState(() {
          _recentPersonnel = recentIndices
              .take(recentCount)
              .map((index) => allPersonnel[index])
              .toList();
        });
      }
    } catch (e) {
      debugPrint('Error loading recent personnel: $e');
    }
  }

  // Handle quick action tap
  void _handleQuickActionTap(BuildContext context, QuickAction action) {
    debugPrint('Tapped on quick action: ${action.id}');

    switch (action.id) {
      case 'facial_verification':
        Navigator.pushNamed(context, '/facial_verification');
        break;
      case 'live_recognition':
        Navigator.pushNamed(context, '/live_recognition');
        break;
      case 'personnel_database':
        Navigator.pushNamed(context, '/personnel_database');
        break;
      case 'access_logs':
        Navigator.pushNamed(context, '/access_logs');
        break;
      case 'register_personnel':
        Navigator.pushNamed(context, '/register_personnel');
        break;
      case 'settings':
        Navigator.pushNamed(context, '/settings');
        break;
      case 'gallery':
        _openGallery(context);
        break;
      case 'notifications':
        Navigator.pushNamed(context, '/notifications');
        break;
      case 'biometric_management':
        Navigator.pushNamed(context, '/biometric_management');
        break;
      case 'windows_camera_test':
        Navigator.pushNamed(context, '/windows_camera_test');
        break;
      default:
        // For any other actions, use the route property from the action
        if (action.route.isNotEmpty) {
          Navigator.pushNamed(context, action.route);
        } else {
          debugPrint('No route defined for action: ${action.id}');
          // Show a snackbar to inform the user
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${action.title} feature coming soon!'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
        break;
    }
  }

  // Open gallery for image selection
  Future<void> _openGallery(BuildContext context) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null && mounted) {
        // Navigate to unified facial verification with the selected image
        Navigator.pushNamed(
          context,
          '/facial_verification',
          arguments: {'initialImage': File(image.path)},
        );
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  // Build the admin profile section
  Widget _buildAdminProfileSection(BuildContext context, bool isDarkMode) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? DesignSystem.darkNavyBlue : DesignSystem.navyBlue,
        borderRadius: BorderRadius.circular(DesignSystem.borderRadiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 26),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Adjust avatar size based on available width
          final isNarrow = constraints.maxWidth < 300;
          final avatarRadius = isNarrow ? 20.0 : 30.0;
          final iconSize = isNarrow ? 20.0 : 30.0;
          final imageSize = isNarrow ? 40.0 : 60.0;

          return Row(
            children: [
              // Admin avatar
              CircleAvatar(
                radius: avatarRadius,
                backgroundColor:
                    isDarkMode ? DesignSystem.darkCyan : DesignSystem.skyBlue,
                child: user?.photoUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(avatarRadius),
                        child: Image.file(
                          File(user!.photoUrl!),
                          width: imageSize,
                          height: imageSize,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.person,
                              size: iconSize,
                              color: Colors.white,
                            );
                          },
                        ),
                      )
                    : Icon(
                        Icons.person,
                        size: iconSize,
                        color: Colors.white,
                      ),
              ),
              SizedBox(width: isNarrow ? 8 : 16),
              // Admin info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.fullName ?? 'Admin User',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isNarrow
                            ? DesignSystem.adjustedFontSizeMedium
                            : DesignSystem.adjustedFontSizeLarge,
                        fontWeight: DesignSystem.fontWeightSemiBold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.armyNumber ?? 'No Army Number',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 204),
                        fontSize: DesignSystem.adjustedFontSizeSmall,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Admin',
                      style: TextStyle(
                        color: isDarkMode
                            ? DesignSystem.darkAccentColor
                            : DesignSystem.accentColor,
                        fontSize: DesignSystem.adjustedFontSizeXSmall,
                        fontWeight: DesignSystem.fontWeightMedium,
                      ),
                    ),
                  ],
                ),
              ),
              // Admin actions - wrap in a Flexible widget to allow shrinking
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white),
                      onPressed: () =>
                          Navigator.pushNamed(context, '/settings'),
                      iconSize: isNarrow ? 20 : 24,
                      padding: EdgeInsets.all(isNarrow ? 4 : 8),
                      constraints: BoxConstraints(
                          minWidth: isNarrow ? 32 : 40,
                          minHeight: isNarrow ? 32 : 40),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white),
                      onPressed: () => _showLogoutConfirmation(context),
                      iconSize: isNarrow ? 20 : 24,
                      padding: EdgeInsets.all(isNarrow ? 4 : 8),
                      constraints: BoxConstraints(
                          minWidth: isNarrow ? 32 : 40,
                          minHeight: isNarrow ? 32 : 40),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Show logout confirmation dialog
  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('LOGOUT'),
          ),
        ],
      ),
    );
  }

  // Build quick actions grid
  Widget _buildQuickActionsGrid(BuildContext context, bool isDarkMode) {
    final quickActionsProvider = Provider.of<QuickActionsProvider>(context);
    final visibleActions = quickActionsProvider.visibleQuickActions;

    return LayoutBuilder(builder: (context, constraints) {
      // Determine the optimal number of columns based on available width
      int crossAxisCount;
      double childAspectRatio;

      final width = constraints.maxWidth;

      if (width > 900) {
        crossAxisCount = 5;
        childAspectRatio = 1.0;
      } else if (width > 700) {
        crossAxisCount = 4;
        childAspectRatio = 1.0;
      } else if (width > 500) {
        crossAxisCount = 3;
        childAspectRatio = 0.95;
      } else if (width > 300) {
        crossAxisCount = 2;
        childAspectRatio = 0.9;
      } else {
        crossAxisCount = 2;
        childAspectRatio = 0.85;
      }

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: childAspectRatio,
          crossAxisSpacing:
              width > 500 ? 10 : 8, // Adjust spacing for smaller screens
          mainAxisSpacing: width > 500 ? 12 : 10,
        ),
        itemCount: visibleActions.length,
        itemBuilder: (context, index) {
          final action = visibleActions[index];
          return _buildQuickActionCard(context, action, isDarkMode);
        },
      );
    });
  }

  // Build a single quick action card with enhanced graphics
  Widget _buildQuickActionCard(
      BuildContext context, QuickAction action, bool isDarkMode) {
    // Create a gradient based on the action color
    final Color gradientStart = isDarkMode
        ? action.color.withAlpha(77) // ~0.3 opacity
        : action.color.withAlpha(13); // ~0.05 opacity
    final Color gradientEnd = isDarkMode
        ? action.color.withAlpha(26) // ~0.1 opacity
        : action.color.withAlpha(51); // ~0.2 opacity

    // Check if this is a primary action that should be highlighted
    final bool isPrimaryAction =
        action.id == 'facial_verification' || action.id == 'personnel_database';

    return LayoutBuilder(builder: (context, constraints) {
      // Adjust sizes based on available width
      final isSmall = constraints.maxWidth < 120;
      final iconSize = isSmall ? 18.0 : 22.0;
      final containerSize = isSmall ? 36.0 : 48.0;
      final padding = isSmall ? 8.0 : 10.0;
      final fontSize = isSmall
          ? DesignSystem.adjustedFontSizeXSmall
          : DesignSystem.adjustedFontSizeSmall;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.all(isSmall ? 1 : 2),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              gradientStart,
              gradientEnd,
            ],
          ),
          color: isDarkMode ? DesignSystem.darkCardColor : Colors.white,
          borderRadius: BorderRadius.circular(DesignSystem.borderRadiusMedium),
          boxShadow: [
            BoxShadow(
              color: action.color.withAlpha(26), // ~0.1 opacity
              blurRadius: isSmall ? 4 : 8,
              offset: Offset(0, isSmall ? 1 : 2),
            ),
          ],
          border: Border.all(
            color: isPrimaryAction
                ? action.color.withAlpha(128) // ~0.5 opacity
                : action.color.withAlpha(51), // ~0.2 opacity
            width: isPrimaryAction ? 1.5 : 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _handleQuickActionTap(context, action),
            borderRadius:
                BorderRadius.circular(DesignSystem.borderRadiusMedium),
            splashColor: action.color.withAlpha(26), // ~0.1 opacity
            highlightColor: action.color.withAlpha(13), // ~0.05 opacity
            child: Padding(
              padding: EdgeInsets.symmetric(
                  vertical: isSmall ? 8 : 12, horizontal: isSmall ? 4 : 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Enhanced icon with animated container
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer glow effect
                      Container(
                        width: containerSize,
                        height: containerSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              action.color.withAlpha(51), // ~0.2 opacity
                              action.color.withAlpha(0), // ~0.0 opacity
                            ],
                            stops: const [0.6, 1.0],
                          ),
                        ),
                      ),
                      // Icon container
                      Container(
                        padding: EdgeInsets.all(padding),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? action.color.withAlpha(77) // ~0.3 opacity
                              : action.color.withAlpha(38), // ~0.15 opacity
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: action.color.withAlpha(51), // ~0.2 opacity
                              blurRadius: isSmall ? 2 : 4,
                              offset: Offset(0, isSmall ? 1 : 2),
                            ),
                          ],
                        ),
                        child: action.isFontAwesome
                            ? FaIcon(
                                action.icon,
                                color: isDarkMode ? Colors.white : action.color,
                                size: iconSize,
                              )
                            : Icon(
                                action.icon,
                                color: isDarkMode ? Colors.white : action.color,
                                size: iconSize,
                              ),
                      ),
                      // Badge for primary actions
                      if (isPrimaryAction)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: isSmall ? 6 : 10,
                            height: isSmall ? 6 : 10,
                            decoration: BoxDecoration(
                              color: DesignSystem.accentColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDarkMode
                                    ? DesignSystem.darkCardColor
                                    : Colors.white,
                                width: isSmall ? 1.0 : 1.5,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: isSmall ? 4 : 8),
                  // Enhanced title with better typography
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: isSmall ? 2 : 4),
                    child: Text(
                      action.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isDarkMode
                            ? Colors.white
                            : DesignSystem.textPrimaryColor,
                        fontSize: fontSize,
                        fontWeight: DesignSystem.fontWeightMedium,
                        letterSpacing: 0.2,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  // Bottom navigation bar removed to avoid duplicate menus

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return PlatformScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: AppBar(
        title: const Text('NAFacial'),
        backgroundColor: isDarkMode
            ? DesignSystem.darkAppBarColor
            : DesignSystem.lightAppBarColor,
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.bars, size: 20),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.bell, size: 20),
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
        ],
      ),
      drawer: _buildDrawer(context, isDarkMode),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadUserMetrics();
          await _loadSystemStatus();
          await _loadRecentPersonnel();
        },
        child: SingleChildScrollView(
          padding: DesignSystem.defaultScreenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Admin profile section
              _buildAdminProfileSection(context, isDarkMode),
              const SizedBox(height: 24),

              // Quick face recognition widget
              if (_isFaceDetectionAvailable)
                QuickFaceRecognitionWidget(
                  onRecognize: () {
                    Navigator.pushNamed(context, '/facial_verification');
                  },
                ),
              if (_isFaceDetectionAvailable) const SizedBox(height: 24),

              // Quick actions section
              Text(
                'Quick Actions',
                style: TextStyle(
                  color:
                      isDarkMode ? Colors.white : DesignSystem.textPrimaryColor,
                  fontSize: DesignSystem.adjustedFontSizeLarge,
                  fontWeight: DesignSystem.fontWeightBold,
                ),
              ),
              const SizedBox(height: 16),
              _buildQuickActionsGrid(context, isDarkMode),
              const SizedBox(height: 24),

              // Security features slider
              const EnhancedSecurityFeaturesSlider(),
              const SizedBox(height: 24),

              // User activity summary
              UserActivitySummary(
                totalScans: _totalVerifications,
                successfulScans:
                    _totalVerifications - 10, // Estimate successful scans
                failedScans: 10, // Estimate failed scans
              ),
              const SizedBox(height: 24),

              // System status widget
              SystemStatusWidget(
                isOnline: true,
                isDatabaseSynced: _isSystemHealthy,
                lastSyncTime: _lastUpdateTime,
                pendingUpdates: _databaseSize > 2000 ? 0 : 5,
              ),
              const SizedBox(height: 24),

              // Version info
              _buildVersionInfo(context, isDarkMode),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      // Removed bottom navigation bar to avoid duplicate menus
    );
  }

  // Build the drawer
  Widget _buildDrawer(BuildContext context, bool isDarkMode) {
    return Drawer(
      child: Container(
        color: isDarkMode ? DesignSystem.darkBackgroundColor : Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: isDarkMode
                    ? DesignSystem.darkNavyBlue
                    : DesignSystem.navyBlue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  kIsWeb
                      ? Image.network(
                          'assets/favicon/android-chrome-192x192.png',
                          height: 60,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.face,
                              size: 60,
                              color: Colors.white,
                            );
                          },
                        )
                      : Image.asset(
                          'assets/favicon/android-chrome-192x192.png',
                          height: 60,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.face,
                              size: 60,
                              color: Colors.white,
                            );
                          },
                        ),
                  const SizedBox(height: 16),
                  const Text(
                    'NAFacial',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Powered by NAS',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(
              context,
              icon: FontAwesomeIcons.house,
              title: 'Home',
              onTap: () {
                Navigator.pop(context);
              },
              isDarkMode: isDarkMode,
              isFontAwesome: true,
            ),
            _buildDrawerItem(
              context,
              icon: FontAwesomeIcons.faceSmile,
              title: 'Facial Verification',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/facial_verification');
              },
              isDarkMode: isDarkMode,
              isFontAwesome: true,
            ),
            // Removed Live Recognition as it's a duplicate of Facial Verification
            _buildDrawerItem(
              context,
              icon: FontAwesomeIcons.userGroup,
              title: 'Personnel Database',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/personnel_database');
              },
              isDarkMode: isDarkMode,
              isFontAwesome: true,
            ),
            _buildDrawerItem(
              context,
              icon: FontAwesomeIcons.userPlus,
              title: 'Register Personnel',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/register_personnel');
              },
              isDarkMode: isDarkMode,
              isFontAwesome: true,
            ),
            _buildDrawerItem(
              context,
              icon: FontAwesomeIcons.clockRotateLeft,
              title: 'Access Logs',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/access_logs');
              },
              isDarkMode: isDarkMode,
              isFontAwesome: true,
            ),
            _buildDrawerItem(
              context,
              icon: FontAwesomeIcons.fingerprint,
              title: 'Biometric Management',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/biometric_management');
              },
              isDarkMode: isDarkMode,
              isFontAwesome: true,
            ),
            _buildDrawerItem(
              context,
              icon: FontAwesomeIcons.images,
              title: 'Gallery',
              onTap: () {
                Navigator.pop(context);
                _openGallery(context);
              },
              isDarkMode: isDarkMode,
              isFontAwesome: true,
            ),
            _buildDrawerItem(
              context,
              icon: FontAwesomeIcons.bell,
              title: 'Notifications',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/notifications');
              },
              isDarkMode: isDarkMode,
              isFontAwesome: true,
            ),
            const Divider(),
            _buildDrawerItem(
              context,
              icon: FontAwesomeIcons.gear,
              title: 'Settings',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              },
              isDarkMode: isDarkMode,
              isFontAwesome: true,
            ),
            _buildDrawerItem(
              context,
              icon: FontAwesomeIcons.circleInfo,
              title: 'About',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/about');
              },
              isDarkMode: isDarkMode,
              isFontAwesome: true,
            ),
            _buildDrawerItem(
              context,
              icon: FontAwesomeIcons.envelope,
              title: 'Contact Us',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/contact');
              },
              isDarkMode: isDarkMode,
              isFontAwesome: true,
            ),
            _buildDrawerItem(
              context,
              icon: FontAwesomeIcons.rightFromBracket,
              title: 'Logout',
              onTap: () {
                Navigator.pop(context);
                _showLogoutConfirmation(context);
              },
              isDarkMode: isDarkMode,
              isFontAwesome: true,
            ),
          ],
        ),
      ),
    );
  }

  // Build a drawer item
  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isDarkMode,
    bool isFontAwesome = false,
  }) {
    return ListTile(
      leading: isFontAwesome
          ? FaIcon(
              icon,
              color: isDarkMode ? Colors.white70 : DesignSystem.navyBlue,
              size: 20,
            )
          : Icon(
              icon,
              color: isDarkMode ? Colors.white70 : DesignSystem.navyBlue,
            ),
      title: Text(
        title,
        style: TextStyle(
          color: isDarkMode ? Colors.white : DesignSystem.textPrimaryColor,
        ),
      ),
      onTap: onTap,
    );
  }

  // Build version info
  Widget _buildVersionInfo(BuildContext context, bool isDarkMode) {
    final versionProvider = Provider.of<VersionProvider>(context);
    final deviceInfo = MediaQuery.of(context).size.width > 600
        ? 'Desktop'
        : MediaQuery.of(context).size.width < 400
            ? 'Mobile'
            : 'Tablet';

    return Center(
      child: Text(
        'NAFacial v${versionProvider.currentVersion} | Powered by NAS | $deviceInfo',
        style: TextStyle(
          color: isDarkMode ? Colors.white54 : Colors.black54,
          fontSize: 12,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
