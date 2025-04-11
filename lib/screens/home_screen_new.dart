import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../config/design_system.dart';
import '../providers/auth_provider.dart';
import '../providers/quick_actions_provider.dart';
import '../providers/version_provider.dart';
import '../utils/responsive_utils.dart';
import '../widgets/platform_aware_widgets.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/grid_background.dart';
import '../widgets/notification_icon.dart';
import '../widgets/web_layout.dart';
import '../providers/theme_provider.dart';
import '../widgets/security_features_slider.dart';
import 'facial_verification_screen.dart';
import 'live_facial_recognition_screen.dart';
import 'personnel_registration_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ImagePicker picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    // Get providers
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final isWebPlatform = ResponsiveUtils.isWebPlatform();

    return Scaffold(
      key: _scaffoldKey,
      // Use custom web layout for web platform, regular layout for others
      appBar: isWebPlatform
          ? null // No AppBar for web, we'll use our custom header
          : AppBar(
              title: const Text('NAFacial Dashboard'),
              backgroundColor: isDarkMode
                  ? DesignSystem.darkAppBarColor
                  : DesignSystem.lightAppBarColor,
              actions: const [
                NotificationIcon(),
              ],
            ),
      drawer: isWebPlatform ? null : const CustomDrawer(), // No drawer for web
      body: isWebPlatform
          // Web layout with header and footer
          ? WebLayout(
              onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
              content: _buildMainContent(context, isDarkMode, isWebPlatform),
            )
          // Mobile/desktop layout
          : _buildMainContent(context, isDarkMode, isWebPlatform),
    );
  }

  Widget _buildMainContent(
      BuildContext context, bool isDarkMode, bool isWebPlatform) {
    return GridBackground(
      useGradient: isDarkMode, // Only use gradient in dark mode
      gridColor:
          isDarkMode ? Colors.white.withAlpha(20) : Colors.grey.withAlpha(10),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(DesignSystem.adjustedSpacingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Admin cards section - responsive layout
                ResponsiveUtils.isDesktop(context) ||
                        ResponsiveUtils.isTablet(context)
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 1,
                            child: _buildAdminCard(context),
                          ),
                          SizedBox(width: DesignSystem.adjustedSpacingMedium),
                          Expanded(
                            flex: 1,
                            child: _buildBiometricCard(context),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          _buildAdminCard(context),
                          SizedBox(height: DesignSystem.adjustedSpacingMedium),
                          _buildBiometricCard(context),
                        ],
                      ),

                SizedBox(height: DesignSystem.adjustedSpacingLarge),

                // Quick actions section
                PlatformCard(
                  child: Padding(
                    padding: EdgeInsets.all(DesignSystem.adjustedSpacingMedium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Quick actions header
                        Row(
                          children: [
                            const Icon(
                              Icons.flash_on,
                              color: DesignSystem.primaryColor,
                              size: 24,
                            ),
                            SizedBox(width: DesignSystem.adjustedSpacingSmall),
                            const Expanded(
                              child: PlatformText(
                                'Quick Actions',
                                isTitle: true,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            PlatformButton(
                              text: 'CUSTOMIZE',
                              onPressed: () {
                                Navigator.of(context).pushNamed('/settings');
                              },
                              isSmall: true,
                              isPrimary: false,
                            ),
                          ],
                        ),
                        SizedBox(height: DesignSystem.adjustedSpacingMedium),
                        const Divider(),
                        SizedBox(height: DesignSystem.adjustedSpacingMedium),

                        // Quick actions grid
                        Consumer<QuickActionsProvider>(
                          builder: (context, quickActionsProvider, child) {
                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: ResponsiveUtils.isDesktop(
                                        context)
                                    ? 4
                                    : ResponsiveUtils.isTablet(context)
                                        ? 3
                                        : 2, // Changed from 3 to 2 for mobile to fix overflow
                                crossAxisSpacing:
                                    DesignSystem.adjustedSpacingSmall,
                                mainAxisSpacing:
                                    DesignSystem.adjustedSpacingSmall,
                                childAspectRatio: ResponsiveUtils.isDesktop(
                                        context)
                                    ? 1.2
                                    : ResponsiveUtils.isTablet(context)
                                        ? 1.0
                                        : 0.9, // Decreased aspect ratio to make cards larger
                              ),
                              itemCount:
                                  quickActionsProvider.quickActions.length,
                              itemBuilder: (context, index) {
                                final action =
                                    quickActionsProvider.quickActions[index];
                                return _buildQuickActionCard(context, action);
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Security Features Slider
                const SizedBox(height: 24),
                const SecurityFeaturesSlider(),

                // App version at the bottom
                SizedBox(height: DesignSystem.adjustedSpacingLarge),
                // Only show version info on non-web platforms (web has it in the footer)
                if (!isWebPlatform)
                  Consumer<VersionProvider>(
                    builder: (context, versionProvider, child) {
                      final deviceInfo = MediaQuery.of(context).size.width > 600
                          ? 'Desktop'
                          : MediaQuery.of(context).size.width < 400
                              ? 'Mobile'
                              : 'Tablet';
                      return Center(
                        child: Text(
                          'NAFacial v${versionProvider.currentVersion} | Powered by NAS | $deviceInfo',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkMode
                                ? Colors.white.withAlpha(150)
                                : Colors.black.withAlpha(100),
                          ),
                        ),
                      );
                    },
                  ),

                SizedBox(height: DesignSystem.adjustedSpacingLarge),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdminCard(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return PlatformCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: DesignSystem.primaryColor,
                radius: 30,
                child: Icon(
                  Icons.person,
                  color: DesignSystem.accentColor,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PlatformText(
                      user?.fullName ?? 'Admin User',
                      isTitle: true,
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    const PlatformText(
                      'Administrator',
                      style: TextStyle(
                        color: DesignSystem.accentColor,
                        fontWeight: DesignSystem.fontWeightMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          // Admin actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildAdminAction(
                context,
                'Profile',
                Icons.person,
                () => Navigator.pushNamed(context, '/profile'),
              ),
              _buildAdminAction(
                context,
                'Settings',
                Icons.settings,
                () => Navigator.pushNamed(context, '/settings'),
              ),
              _buildAdminAction(
                context,
                'Logout',
                Icons.logout,
                () async {
                  await authProvider.logout();
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdminAction(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Icon(
              icon,
              color: DesignSystem.primaryColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: DesignSystem.fontWeightMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBiometricCard(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return PlatformCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.fingerprint,
                color: DesignSystem.primaryColor,
                size: 30,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PlatformText(
                      'Biometric Authentication',
                      isTitle: true,
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    PlatformText(
                      'Secure your account',
                      style: TextStyle(
                        color: DesignSystem.accentColor,
                        fontWeight: DesignSystem.fontWeightMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          if (!authProvider.isBiometricAvailable) ...[
            const PlatformText(
              'Biometric authentication is not available on this device.',
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: PlatformText(
                    'Status: ${authProvider.isBiometricEnabled ? 'Enabled' : 'Disabled'}',
                    style: TextStyle(
                      color: authProvider.isBiometricEnabled
                          ? Colors.green
                          : Colors.orange,
                      fontWeight: DesignSystem.fontWeightMedium,
                    ),
                  ),
                ),
                PlatformButton(
                  text: authProvider.isBiometricEnabled ? 'DISABLE' : 'ENABLE',
                  onPressed: () {
                    // Toggle biometric
                  },
                  isSmall: true,
                  buttonType: authProvider.isBiometricEnabled
                      ? PlatformButtonType.warning
                      : PlatformButtonType.success,
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          // Biometric actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildAdminAction(
                context,
                'Verify',
                Icons.face,
                () => Navigator.pushNamed(context, '/facial_verification'),
              ),
              _buildAdminAction(
                context,
                'Live Scan',
                Icons.camera_alt,
                () => Navigator.pushNamed(context, '/live_recognition'),
              ),
              _buildAdminAction(
                context,
                'Gallery',
                Icons.photo_library,
                () => _openGallery(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(BuildContext context, dynamic action) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignSystem.borderRadiusSmall),
      ),
      color:
          isDarkMode ? DesignSystem.darkCardColor.withAlpha(200) : Colors.white,
      child: InkWell(
        onTap: () => _handleQuickActionTap(context, action),
        borderRadius: BorderRadius.circular(DesignSystem.borderRadiusSmall),
        child: Padding(
          padding: EdgeInsets.all(
              isMobile ? 8.0 : 12.0), // Increased padding for better visibility
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with colored background
              Container(
                padding: EdgeInsets.all(isMobile
                    ? 10.0
                    : 14.0), // Increased padding for larger icons
                decoration: BoxDecoration(
                  color: action.color.withAlpha(isDarkMode ? 60 : 30),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  action.icon,
                  color: isDarkMode ? Colors.white : action.color,
                  size: isMobile ? 32 : 40, // Increased icon size
                ),
              ),
              SizedBox(height: isMobile ? 8 : 10), // Increased spacing
              // Title with responsive font size
              Flexible(
                child: Text(
                  action.title,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1, // Limit to one line to prevent overflow
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: isMobile ? 14 : 16, // Increased font size
                    color: isDarkMode
                        ? Colors.white.withAlpha(220)
                        : DesignSystem.lightTextPrimaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleQuickActionTap(BuildContext context, dynamic action) {
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
      default:
        // For any other actions, use the route property from the action
        if (action.route != null && action.route.isNotEmpty) {
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

  Future<void> _openGallery(BuildContext context) async {
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null && mounted) {
        // Use a post-frame callback to ensure we're not using context across async gaps
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FacialVerificationScreen(
                initialTabIndex: 1, // Photo tab
              ),
            ),
          );
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }
}
