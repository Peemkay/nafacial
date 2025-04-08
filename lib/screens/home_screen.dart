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
  @override
  void initState() {
    super.initState();

    // Initialize providers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final personnelProvider =
          Provider.of<PersonnelProvider>(context, listen: false);
      personnelProvider.initialize();

      // Initialize access log provider
      final accessLogProvider =
          Provider.of<AccessLogProvider>(context, listen: false);
      accessLogProvider.initialize();

      // Add a test notification after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          final notificationService =
              Provider.of<NotificationService>(context, listen: false);
          notificationService.showNotification(
            title: 'Welcome to NAFacial',
            body: 'You have successfully logged in to the system.',
            type: NotificationType.info,
          );
        }
      });

      // Initialize version provider
      final versionProvider =
          Provider.of<VersionProvider>(context, listen: false);
      versionProvider.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final user = authProvider.currentUser;

    return PlatformScaffold(
      appBar: AppBar(
        title: const Text('NAFacial Dashboard'),
        backgroundColor: isDarkMode ? DesignSystem.darkAppBarColor : DesignSystem.lightAppBarColor,
        actions: [
          const NotificationIcon(),
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
                          // Welcome card
                          Expanded(
                            flex: 3,
                            child: PlatformCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor:
                                            DesignSystem.primaryColor,
                                        radius: 30,
                                        child: Icon(
                                          Icons.person,
                                          color: DesignSystem.accentColor,
                                          size: 30,
                                        ),
                                      ),
                                      SizedBox(
                                          width: DesignSystem
                                              .adjustedSpacingMedium),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            PlatformText(
                                              'Welcome, ${user?.fullName ?? 'User'}',
                                              isTitle: true,
                                            ),
                                            PlatformText(
                                              '${user?.rank ?? 'Rank'} - ${user?.department ?? 'Department'}',
                                              style: TextStyle(
                                                color: DesignSystem
                                                    .textSecondaryColor,
                                                fontSize: DesignSystem
                                                    .adjustedFontSizeSmall,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                      height:
                                          DesignSystem.adjustedSpacingMedium),
                                  const Divider(),
                                  SizedBox(
                                      height:
                                          DesignSystem.adjustedSpacingSmall),
                                  PlatformText(
                                    'System Status: ACTIVE',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: DesignSystem.fontWeightBold,
                                    ),
                                  ),
                                  SizedBox(
                                      height:
                                          DesignSystem.adjustedSpacingSmall),
                                  PlatformText(
                                    'Last Login: ${DateTime.now().toString().substring(0, 16)}',
                                    style: TextStyle(
                                      fontSize:
                                          DesignSystem.adjustedFontSizeSmall,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: DesignSystem.adjustedSpacingMedium),
                          // Biometric settings
                          Expanded(
                            flex: 2,
                            child: PlatformCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.fingerprint,
                                        color: DesignSystem.primaryColor,
                                        size: 24,
                                      ),
                                      SizedBox(
                                          width: DesignSystem
                                              .adjustedSpacingSmall),
                                      Expanded(
                                        child: PlatformText(
                                          'Biometric Authentication',
                                          isTitle: true,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                      height:
                                          DesignSystem.adjustedSpacingMedium),
                                  if (!authProvider.isBiometricAvailable) ...[
                                    PlatformText(
                                      'Biometric authentication is not available on this device.',
                                      style: TextStyle(
                                        color: Colors.red,
                                      ),
                                    ),
                                  ] else ...[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: PlatformText(
                                            'Enable Biometric Login',
                                            style: TextStyle(
                                              fontSize: DesignSystem
                                                  .adjustedFontSizeMedium,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Switch(
                                          value:
                                              user?.isBiometricEnabled ?? false,
                                          onChanged: (value) async {
                                            if (value) {
                                              await authProvider
                                                  .enableBiometric();
                                            } else {
                                              await authProvider
                                                  .disableBiometric();
                                            }
                                          },
                                          activeColor:
                                              DesignSystem.primaryColor,
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                        height:
                                            DesignSystem.adjustedSpacingSmall),
                                    PlatformText(
                                      'Use your fingerprint or face recognition for faster login.',
                                      style: TextStyle(
                                        fontSize:
                                            DesignSystem.adjustedFontSizeSmall,
                                        color: DesignSystem.textSecondaryColor,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          // Welcome card
                          PlatformCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor:
                                          DesignSystem.primaryColor,
                                      radius: 30,
                                      child: Icon(
                                        Icons.person,
                                        color: DesignSystem.accentColor,
                                        size: 30,
                                      ),
                                    ),
                                    SizedBox(
                                        width:
                                            DesignSystem.adjustedSpacingMedium),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          PlatformText(
                                            'Welcome, ${user?.fullName ?? 'User'}',
                                            isTitle: true,
                                          ),
                                          PlatformText(
                                            '${user?.rank ?? 'Rank'} - ${user?.department ?? 'Department'}',
                                            style: TextStyle(
                                              color: DesignSystem
                                                  .textSecondaryColor,
                                              fontSize: DesignSystem
                                                  .adjustedFontSizeSmall,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                    height: DesignSystem.adjustedSpacingMedium),
                                const Divider(),
                                SizedBox(
                                    height: DesignSystem.adjustedSpacingSmall),
                                PlatformText(
                                  'System Status: ACTIVE',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: DesignSystem.fontWeightBold,
                                  ),
                                ),
                                SizedBox(
                                    height: DesignSystem.adjustedSpacingSmall),
                                PlatformText(
                                  'Last Login: ${DateTime.now().toString().substring(0, 16)}',
                                  style: TextStyle(
                                    fontSize:
                                        DesignSystem.adjustedFontSizeSmall,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: DesignSystem.adjustedSpacingLarge),
                          // Biometric settings
                          PlatformCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.fingerprint,
                                      color: DesignSystem.primaryColor,
                                      size: 24,
                                    ),
                                    SizedBox(
                                        width:
                                            DesignSystem.adjustedSpacingSmall),
                                    Expanded(
                                      child: PlatformText(
                                        'Biometric Authentication',
                                        isTitle: true,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                    height: DesignSystem.adjustedSpacingMedium),
                                if (!authProvider.isBiometricAvailable) ...[
                                  PlatformText(
                                    'Biometric authentication is not available on this device.',
                                    style: TextStyle(
                                      color: Colors.red,
                                    ),
                                  ),
                                ] else ...[
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: PlatformText(
                                          'Enable Biometric Login',
                                          style: TextStyle(
                                            fontSize: DesignSystem
                                                .adjustedFontSizeMedium,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Switch(
                                        value:
                                            user?.isBiometricEnabled ?? false,
                                        onChanged: (value) async {
                                          if (value) {
                                            await authProvider
                                                .enableBiometric();
                                          } else {
                                            await authProvider
                                                .disableBiometric();
                                          }
                                        },
                                        activeColor: DesignSystem.primaryColor,
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                      height:
                                          DesignSystem.adjustedSpacingSmall),
                                  PlatformText(
                                    'Use your fingerprint or face recognition for faster login.',
                                    style: TextStyle(
                                      fontSize:
                                          DesignSystem.adjustedFontSizeSmall,
                                      color: DesignSystem.textSecondaryColor,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),

                SizedBox(height: DesignSystem.adjustedSpacingLarge),

                // Personnel Database Statistics
                _buildPersonnelStatisticsCard(context),

                SizedBox(height: DesignSystem.adjustedSpacingLarge),

                // Quick actions
                PlatformText(
                  'Quick Actions',
                  isTitle: true,
                ),
                SizedBox(height: DesignSystem.adjustedSpacingMedium),

                Consumer<QuickActionsProvider>(
                  builder: (context, quickActionsProvider, _) {
                    final visibleActions =
                        quickActionsProvider.visibleQuickActions;

                    // Responsive grid layout
                    final bool isDesktop = ResponsiveUtils.isDesktop(context);
                    final bool isTablet = ResponsiveUtils.isTablet(context);
                    final int crossAxisCount = isDesktop
                        ? 4
                        : isTablet
                            ? 3
                            : 2;

                    return GridView.count(
                      crossAxisCount: crossAxisCount,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: isDesktop || isTablet
                          ? DesignSystem.adjustedSpacingLarge
                          : DesignSystem.adjustedSpacingMedium,
                      crossAxisSpacing: isDesktop || isTablet
                          ? DesignSystem.adjustedSpacingLarge
                          : DesignSystem.adjustedSpacingMedium,
                      childAspectRatio: isDesktop || isTablet ? 1.2 : 1.0,
                      children: visibleActions.map((action) {
                        // Map the action to the appropriate function
                        VoidCallback onTap;
                        switch (action.id) {
                          case 'facial_verification':
                            onTap = () => Navigator.of(context)
                                .pushNamed('/facial_verification');
                            break;
                          case 'personnel_database':
                            onTap = () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const FacialVerificationScreen(
                                            initialTabIndex: 4),
                                  ),
                                );
                            break;
                          case 'access_logs':
                            onTap = () => _showAccessLogsDialog(context);
                            break;
                          case 'settings':
                            onTap = () =>
                                Navigator.of(context).pushNamed('/settings');
                            break;
                          case 'live_recognition':
                            onTap = () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const LiveFacialRecognitionScreen(),
                                  ),
                                );
                            break;
                          case 'register_personnel':
                            onTap = () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const PersonnelRegistrationScreen(),
                                  ),
                                );
                            break;
                          case 'gallery':
                            onTap = () => _openGallery(context);
                            break;
                          default:
                            onTap = () {};
                        }

                        return _buildActionCard(
                          context,
                          icon: action.icon,
                          title: action.title,
                          color: action.color,
                          onTap: onTap,
                        );
                      }).toList(),
                    );
                  },
                ),

                SizedBox(height: DesignSystem.adjustedSpacingLarge),

                // Security notice
                PlatformContainer(
                  padding: EdgeInsets.symmetric(
                    vertical: DesignSystem.adjustedSpacingSmall,
                    horizontal: DesignSystem.adjustedSpacingMedium,
                  ),
                  backgroundColor:
                      const Color(0xCC001F3F), // primaryColor with 0.8 opacity
                  borderRadius:
                      BorderRadius.circular(DesignSystem.borderRadiusSmall),
                  child: const PlatformText(
                    'RESTRICTED ACCESS - AUTHORIZED PERSONNEL ONLY',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFFFD700), // accentColor
                      fontSize: 12,
                      letterSpacing: 1.0, // letterSpacingExtraWide
                      fontWeight: FontWeight.w700, // fontWeightBold
                    ),
                  ),
                ),

                // Version display
                SizedBox(height: DesignSystem.adjustedSpacingMedium),
                Consumer<VersionProvider>(
                  builder: (context, versionProvider, _) {
                    return Center(
                      child: Column(
                        children: [
                          PlatformText(
                            'Version ${versionProvider.currentVersion}',
                            style: TextStyle(
                              color: DesignSystem.textSecondaryColor,
                              fontSize: DesignSystem.adjustedFontSizeSmall,
                            ),
                          ),
                          if (versionProvider.isDownloading)
                            Padding(
                              padding: EdgeInsets.only(top: 4.0),
                              child: Column(
                                children: [
                                  PlatformText(
                                    'Downloading update: ${(versionProvider.downloadProgress * 100).toStringAsFixed(0)}%',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize:
                                          DesignSystem.adjustedFontSizeSmall,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  SizedBox(
                                    width: 100,
                                    child: LinearProgressIndicator(
                                      value: versionProvider.downloadProgress,
                                      backgroundColor: Colors.grey[300],
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          DesignSystem.primaryColor),
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context)
                                          .pushNamed('/settings');
                                    },
                                    child: PlatformText(
                                      'Tap for details',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontSize:
                                            DesignSystem.adjustedFontSizeSmall,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else if (versionProvider.updateAvailable)
                            Padding(
                              padding: EdgeInsets.only(top: 4.0),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pushNamed('/settings');
                                },
                                child: PlatformText(
                                  'Update available! Tap to update.',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize:
                                        DesignSystem.adjustedFontSizeSmall,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                          else if (!versionProvider.hasInternetConnection)
                            Padding(
                              padding: EdgeInsets.only(top: 4.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.signal_wifi_off,
                                      color: Colors.orange, size: 12),
                                  SizedBox(width: 4),
                                  PlatformText(
                                    'No internet connection',
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontSize:
                                          DesignSystem.adjustedFontSizeSmall,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),

                // Bottom padding
                SizedBox(height: DesignSystem.adjustedSpacingSmall),

                // Version info at the bottom
                const SizedBox(height: 24),
                const VersionInfo(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPersonnelStatisticsCard(BuildContext context) {
    final personnelProvider = Provider.of<PersonnelProvider>(context);
    final allPersonnel = personnelProvider.allPersonnel;

    // Count personnel by category
    int officerMaleCount = 0;
    int officerFemaleCount = 0;
    int soldierMaleCount = 0;
    int soldierFemaleCount = 0;
    int verifiedCount = 0;
    int pendingCount = 0;

    for (final personnel in allPersonnel) {
      // Count by category
      if (personnel.category == PersonnelCategory.officerMale) {
        officerMaleCount++;
      } else if (personnel.category == PersonnelCategory.officerFemale) {
        officerFemaleCount++;
      } else if (personnel.category == PersonnelCategory.soldierMale) {
        soldierMaleCount++;
      } else if (personnel.category == PersonnelCategory.soldierFemale) {
        soldierFemaleCount++;
      }

      // Count by verification status
      if (personnel.status == VerificationStatus.verified) {
        verifiedCount++;
      } else if (personnel.status == VerificationStatus.pending) {
        pendingCount++;
      }
    }

    return PlatformCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.people,
                color: DesignSystem.primaryColor,
                size: 24,
              ),
              SizedBox(width: DesignSystem.adjustedSpacingSmall),
              Expanded(
                child: PlatformText(
                  'Personnel Database',
                  isTitle: true,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              PlatformButton(
                text: 'VIEW ALL',
                onPressed: () {
                  Navigator.of(context).pushNamed('/facial_verification');
                },
                isSmall: true,
                isPrimary: false,
              ),
            ],
          ),
          SizedBox(height: DesignSystem.adjustedSpacingMedium),
          const Divider(),
          SizedBox(height: DesignSystem.adjustedSpacingMedium),

          // Statistics grid
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: DesignSystem.adjustedSpacingMedium,
            crossAxisSpacing: DesignSystem.adjustedSpacingMedium,
            childAspectRatio: 2.0,
            children: [
              _buildStatCard(
                title: 'Total Personnel',
                value: allPersonnel.length.toString(),
                icon: Icons.people,
                color: DesignSystem.primaryColor,
              ),
              _buildStatCard(
                title: 'Verified',
                value: verifiedCount.toString(),
                icon: Icons.verified_user,
                color: Colors.green,
              ),
              _buildStatCard(
                title: 'Pending',
                value: pendingCount.toString(),
                icon: Icons.pending,
                color: Colors.orange,
              ),
              _buildStatCard(
                title: 'Officers',
                value: (officerMaleCount + officerFemaleCount).toString(),
                icon: Icons.military_tech,
                color: DesignSystem.secondaryColor,
              ),
            ],
          ),

          SizedBox(height: DesignSystem.adjustedSpacingMedium),
          PlatformText(
            'Tap on "VIEW ALL" to access the personnel database and verification tools.',
            style: TextStyle(
              color: DesignSystem.textSecondaryColor,
              fontSize: DesignSystem.adjustedFontSizeSmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(DesignSystem.adjustedSpacingSmall),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(DesignSystem.borderRadiusSmall),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(DesignSystem.adjustedSpacingSmall),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          SizedBox(width: DesignSystem.adjustedSpacingSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: DesignSystem.fontWeightBold,
                    fontSize: DesignSystem.adjustedFontSizeLarge,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: DesignSystem.adjustedFontSizeSmall,
                    color: DesignSystem.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    final bool isDesktop = ResponsiveUtils.isDesktop(context);
    final bool isTablet = ResponsiveUtils.isTablet(context);
    final double iconSize = isDesktop
        ? 40
        : isTablet
            ? 36
            : 32;
    final double elevation = isDesktop || isTablet ? 4.0 : 2.0;

    return PlatformCard(
      onTap: onTap,
      elevation: elevation,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              color.withAlpha(15),
            ],
          ),
          borderRadius: BorderRadius.circular(DesignSystem.borderRadiusMedium),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(isDesktop || isTablet
                  ? DesignSystem.adjustedSpacingMedium
                  : DesignSystem.adjustedSpacingSmall),
              decoration: BoxDecoration(
                color: color.withAlpha(30),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withAlpha(40),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: color,
                size: iconSize,
              ),
            ),
            SizedBox(height: DesignSystem.adjustedSpacingSmall),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: PlatformText(
                title,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: DesignSystem.fontWeightMedium,
                  fontSize: isDesktop || isTablet
                      ? DesignSystem.adjustedFontSizeMedium
                      : DesignSystem.adjustedFontSizeSmall,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Open gallery for image selection
  void _openGallery(BuildContext context) {
    final imagePicker = ImagePicker();

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(DesignSystem.borderRadiusMedium),
        ),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.photo_library,
                  color: DesignSystem.primaryColor,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Select Image Source',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: DesignSystem.primaryColor,
                child: Icon(Icons.camera_alt, color: Colors.white),
              ),
              title: const Text('Camera'),
              subtitle: const Text('Take a new photo'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? photo = await imagePicker.pickImage(
                  source: ImageSource.camera,
                  preferredCameraDevice: CameraDevice.front,
                );

                if (photo != null && context.mounted) {
                  // Navigate to facial verification with the selected image
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FacialVerificationScreen(
                        initialImage: File(photo.path),
                      ),
                    ),
                  );
                }
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: DesignSystem.secondaryColor,
                child: Icon(Icons.photo_library, color: Colors.white),
              ),
              title: const Text('Gallery'),
              subtitle: const Text('Choose from your photos'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await imagePicker.pickImage(
                  source: ImageSource.gallery,
                );

                if (image != null && context.mounted) {
                  // Navigate to facial verification with the selected image
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FacialVerificationScreen(
                        initialImage: File(image.path),
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // Show access logs dialog
  void _showAccessLogsDialog(BuildContext context) {
    // Get access logs from provider
    final accessLogProvider =
        Provider.of<AccessLogProvider>(context, listen: false);

    try {
      final accessLogs = accessLogProvider.getRecentAccessLogs(limit: 10);

      // If no logs exist, create some sample logs for demonstration
      if (accessLogs.isEmpty) {
        // Create sample access logs
        final sampleLogs = [
          AccessLog(
            id: '1',
            personnelName: 'Maj. John Smith',
            personnelArmyNumber: 'N/123456',
            timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
            status: AccessLogStatus.verified,
            confidence: 0.92,
            adminName: 'Admin User',
            adminArmyNumber: 'ADMIN-1',
          ),
          AccessLog(
            id: '2',
            personnelName: 'Capt. Sarah Johnson',
            personnelArmyNumber: 'N/789012',
            timestamp: DateTime.now().subtract(const Duration(hours: 1)),
            status: AccessLogStatus.verified,
            confidence: 0.85,
            adminName: 'Admin User',
            adminArmyNumber: 'ADMIN-1',
          ),
          AccessLog(
            id: '3',
            personnelName: 'Lt. Michael Brown',
            personnelArmyNumber: 'N/345678',
            timestamp: DateTime.now().subtract(const Duration(hours: 2)),
            status: AccessLogStatus.unverified,
            confidence: 0.62,
            adminName: 'Admin User',
            adminArmyNumber: 'ADMIN-1',
          ),
          AccessLog(
            id: '4',
            personnelName: 'Unknown Person',
            personnelArmyNumber: null,
            timestamp: DateTime.now().subtract(const Duration(hours: 3)),
            status: AccessLogStatus.notFound,
            confidence: 0.0,
            adminName: 'Admin User',
            adminArmyNumber: 'ADMIN-1',
          ),
        ];

        // Add sample logs to provider
        for (final log in sampleLogs) {
          accessLogProvider.addAccessLog(
            personnelId: log.id,
            personnelName: log.personnelName,
            personnelArmyNumber: log.personnelArmyNumber,
            status: log.status,
            confidence: log.confidence,
          );
        }

        // Get updated logs
        accessLogs.addAll(sampleLogs);
      }

      _displayAccessLogsDialog(context, accessLogs);
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading access logs: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Display access logs dialog
  void _displayAccessLogsDialog(
      BuildContext context, List<AccessLog> accessLogs) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignSystem.borderRadiusMedium),
        ),
        child: Container(
          width: double.maxFinite,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.history,
                    color: DesignSystem.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Recent Access Logs',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 400),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: accessLogs.length,
                  itemBuilder: (context, index) {
                    final log = accessLogs[index];
                    final dateFormat = DateFormat('MMM d, yyyy HH:mm');
                    final formattedDate = dateFormat.format(log.timestamp);

                    // Determine status color
                    Color statusColor;
                    if (log.status == AccessLogStatus.verified) {
                      statusColor = Colors.green;
                    } else if (log.status == AccessLogStatus.unverified) {
                      statusColor = Colors.orange;
                    } else {
                      statusColor = Colors.red;
                    }

                    // Get status text
                    String statusText;
                    switch (log.status) {
                      case AccessLogStatus.verified:
                        statusText = 'Verified';
                        break;
                      case AccessLogStatus.unverified:
                        statusText = 'Unverified';
                        break;
                      case AccessLogStatus.notFound:
                        statusText = 'Not Found';
                        break;
                      default:
                        statusText = 'Unknown';
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              DesignSystem.primaryColor.withOpacity(0.1),
                          child: Icon(
                            log.status == AccessLogStatus.verified
                                ? Icons.check_circle
                                : log.status == AccessLogStatus.unverified
                                    ? Icons.warning
                                    : Icons.error,
                            color: statusColor,
                          ),
                        ),
                        title: Text(log.personnelName ?? 'Unknown Person'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(log.personnelArmyNumber ?? 'N/A'),
                            Text(
                              formattedDate,
                              style: const TextStyle(fontSize: 12),
                            ),
                            if (log.adminName != null)
                              Text(
                                'By: ${log.adminName} (${log.adminArmyNumber ?? 'N/A'})',
                                style: const TextStyle(
                                    fontSize: 10, fontStyle: FontStyle.italic),
                              ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              statusText,
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (log.confidence > 0)
                              Text(
                                '${(log.confidence * 100).toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: log.confidence > 0.8
                                      ? Colors.green
                                      : log.confidence > 0.7
                                          ? Colors.orange
                                          : Colors.red,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('CLOSE'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      // View all logs
                      Navigator.pop(context);
                      // TODO: Navigate to full logs screen
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DesignSystem.primaryColor,
                    ),
                    child: const Text('VIEW ALL'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
