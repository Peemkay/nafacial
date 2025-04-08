import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../config/design_system.dart';
import '../models/personnel_model.dart';
import '../providers/auth_provider.dart';
import '../providers/personnel_provider.dart';
import '../providers/quick_actions_provider.dart';
import '../providers/access_log_provider.dart';
import '../models/access_log_model.dart';
import '../providers/version_provider.dart';
import '../services/notification_service.dart';
import '../utils/responsive_utils.dart';
import '../widgets/platform_aware_widgets.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/notification_icon.dart';
import '../widgets/grid_background.dart';
import '../widgets/version_info.dart';
import '../providers/theme_provider.dart';
import 'facial_verification_screen.dart';
import 'live_facial_recognition_screen.dart';
import 'personnel_registration_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();

    // Initialize version provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final versionProvider = Provider.of<VersionProvider>(context, listen: false);
      versionProvider.initialize();
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load personnel data if needed
      // Load access logs if needed
    } catch (e) {
      // Handle errors
      debugPrint('Error loading data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final user = authProvider.currentUser;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('NAFacial Dashboard'),
        backgroundColor: isDarkMode ? DesignSystem.darkAppBarColor : DesignSystem.lightAppBarColor,
        actions: const [
          NotificationIcon(),
        ],
      ),
      drawer: const CustomDrawer(),
      body: GridBackground(
        useGradient: true,
        gridColor: Colors.white.withAlpha(20),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(DesignSystem.adjustedSpacingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Admin cards section - responsive layout
                  ResponsiveUtils.isDesktop(context)
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

                  // Quick actions
                  const PlatformText(
                    'Quick Actions',
                    isTitle: true,
                  ),
                  SizedBox(height: DesignSystem.adjustedSpacingMedium),

                  Consumer<QuickActionsProvider>(
                    builder: (context, quickActionsProvider, child) {
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                              ResponsiveUtils.isDesktop(context) ? 4 : 2,
                          crossAxisSpacing: DesignSystem.adjustedSpacingSmall,
                          mainAxisSpacing: DesignSystem.adjustedSpacingSmall,
                          childAspectRatio: 1.2,
                        ),
                        itemCount: quickActionsProvider.quickActions.length,
                        itemBuilder: (context, index) {
                          final action =
                              quickActionsProvider.quickActions[index];
                          return _buildQuickActionCard(context, action);
                        },
                      );
                    },
                  ),

                  SizedBox(height: DesignSystem.adjustedSpacingLarge),
                  
                  // Version info at the bottom
                  const SizedBox(height: 24),
                  const VersionInfo(),
                ],
              ),
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
              CircleAvatar(
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
                    PlatformText(
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
          const Divider(),
          const SizedBox(height: 8),
          const PlatformText(
            'System Status: ACTIVE',
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          PlatformText(
            'Last Login: ${DateFormat('MMM dd, yyyy HH:mm').format(DateTime.now())}',
            style: TextStyle(
              fontSize: 12,
              color: DesignSystem.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBiometricCard(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return PlatformCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.fingerprint,
                color: DesignSystem.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: PlatformText(
                  'Biometric Authentication',
                  isTitle: true,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
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
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(BuildContext context, QuickAction action) {
    return PlatformCard(
      child: InkWell(
        onTap: () => _handleQuickActionTap(context, action),
        borderRadius: BorderRadius.circular(DesignSystem.borderRadiusSmall),
        child: Padding(
          padding: EdgeInsets.all(DesignSystem.adjustedSpacingSmall),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                action.icon,
                color: DesignSystem.primaryColor,
                size: 32,
              ),
              const SizedBox(height: 8),
              PlatformText(
                action.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleQuickActionTap(BuildContext context, QuickAction action) {
    switch (action.id) {
      case 'facial_verification':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const FacialVerificationScreen(),
          ),
        );
        break;
      case 'live_recognition':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LiveFacialRecognitionScreen(),
          ),
        );
        break;
      case 'personnel_registration':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PersonnelRegistrationScreen(),
          ),
        );
        break;
      case 'settings':
        Navigator.pushNamed(context, '/settings');
        break;
      case 'gallery':
        _openGallery(context);
        break;
      default:
        // Handle other actions
        break;
    }
  }

  Future<void> _openGallery(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FacialVerificationScreen(
              initialImage: File(image.path),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }
}
