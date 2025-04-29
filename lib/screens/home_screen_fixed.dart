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
      final versionProvider =
          Provider.of<VersionProvider>(context, listen: false);
      versionProvider.initialize();
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load personnel data
      final personnelProvider =
          Provider.of<PersonnelProvider>(context, listen: false);
      await personnelProvider.loadPersonnel();

      // Load access logs
      final accessLogProvider =
          Provider.of<AccessLogProvider>(context, listen: false);
      await accessLogProvider.loadLogs();
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
    final versionProvider = Provider.of<VersionProvider>(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('NAFacial Dashboard'),
        backgroundColor: isDarkMode
            ? DesignSystem.darkAppBarColor
            : DesignSystem.lightAppBarColor,
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
                            SizedBox(
                                height: DesignSystem.adjustedSpacingMedium),
                            _buildBiometricCard(context),
                          ],
                        ),

                  SizedBox(height: DesignSystem.adjustedSpacingLarge),

                  // Personnel statistics card
                  _buildPersonnelStatisticsCard(context),

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

                  // Recent activity section
                  _buildRecentActivitySection(context),

                  // App version
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      PlatformText(
                        'App Version: ${versionProvider.currentVersion}',
                        style: TextStyle(
                          color: isDarkMode
                              ? DesignSystem.darkTextSecondaryColor
                              : DesignSystem.lightTextSecondaryColor,
                          fontSize: 12,
                        ),
                      ),
                      if (versionProvider.isDownloading)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Column(
                            children: [
                              PlatformText(
                                'Downloading update...',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDarkMode
                                      ? DesignSystem.darkTextSecondaryColor
                                      : DesignSystem.lightTextSecondaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              SizedBox(
                                width: 100,
                                child: LinearProgressIndicator(
                                  value: versionProvider.downloadProgress,
                                  backgroundColor: Colors.grey[300],
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                          DesignSystem.primaryColor),
                                ),
                              ),
                              const SizedBox(height: 2),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pushNamed('/settings');
                                },
                                child: PlatformText(
                                  'Cancel',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: DesignSystem.dangerColor,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (versionProvider.updateAvailable)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushNamed('/settings');
                            },
                            child: const PlatformText(
                              ' • Update Available',
                              style: TextStyle(
                                fontSize: 12,
                                color: DesignSystem.accentColor,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        )
                      else if (!versionProvider.hasInternetConnection)
                        const Padding(
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
                                  fontSize: 12,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  // Bottom padding
                  const SizedBox(height: 16),

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

  Widget _buildPersonnelStatisticsCard(BuildContext context) {
    final personnelProvider = Provider.of<PersonnelProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final personnel = personnelProvider.personnel;

    // Count personnel by category
    int officerMaleCount = 0;
    int officerFemaleCount = 0;
    int soldierMaleCount = 0;
    int soldierFemaleCount = 0;
    int verifiedCount = 0;
    int pendingCount = 0;

    for (var person in personnel) {
      if (person.isOfficer) {
        if (person.isFemale) {
          officerFemaleCount++;
        } else {
          officerMaleCount++;
        }
      } else {
        if (person.isFemale) {
          soldierFemaleCount++;
        } else {
          soldierMaleCount++;
        }
      }

      if (person.verificationStatus == VerificationStatus.verified) {
        verifiedCount++;
      } else {
        pendingCount++;
      }
    }

    return PlatformCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.people,
                color: DesignSystem.primaryColor,
                size: 24,
              ),
              const SizedBox(width: DesignSystem.adjustedSpacingSmall),
              const Expanded(
                child: PlatformText(
                  'Personnel Database',
                  isTitle: true,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              PlatformButton(
                text: 'VIEW ALL',
                onPressed: () {
                  Navigator.of(context).pushNamed('/personnel');
                },
                isSmall: true,
              ),
            ],
          ),
          const SizedBox(height: DesignSystem.adjustedSpacingMedium),
          Row(
            children: [
              Expanded(
                child: _buildStatisticItem(
                  context,
                  'Total Personnel',
                  personnel.length.toString(),
                  Icons.people,
                  DesignSystem.primaryColor,
                ),
              ),
              const SizedBox(width: DesignSystem.adjustedSpacingSmall),
              Expanded(
                child: _buildStatisticItem(
                  context,
                  'Officers',
                  (officerMaleCount + officerFemaleCount).toString(),
                  Icons.military_tech,
                  DesignSystem.accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignSystem.adjustedSpacingSmall),
          Row(
            children: [
              Expanded(
                child: _buildStatisticItem(
                  context,
                  'Verified',
                  verifiedCount.toString(),
                  Icons.verified_user,
                  Colors.green,
                ),
              ),
              const SizedBox(width: DesignSystem.adjustedSpacingSmall),
              Expanded(
                child: _buildStatisticItem(
                  context,
                  'Pending',
                  pendingCount.toString(),
                  Icons.pending,
                  Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticItem(BuildContext context, String title, String value,
      IconData icon, Color color) {
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
              size: 16,
            ),
          ),
          const SizedBox(width: DesignSystem.adjustedSpacingSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PlatformText(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                PlatformText(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
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
              const SizedBox(width: DesignSystem.adjustedSpacingMedium),
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
                      user?.role ?? 'Administrator',
                      style: const TextStyle(
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
          const SizedBox(height: DesignSystem.adjustedSpacingSmall),
          const PlatformText(
            'System Status: ACTIVE',
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: DesignSystem.adjustedSpacingSmall),
          PlatformText(
            'Last Login: ${DateFormat('MMM dd, yyyy HH:mm').format(DateTime.now())}',
            style: const TextStyle(
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
              const SizedBox(width: DesignSystem.adjustedSpacingSmall),
              const Expanded(
                child: PlatformText(
                  'Biometric Authentication',
                  isTitle: true,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignSystem.adjustedSpacingMedium),
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
                    authProvider.toggleBiometric();
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
              const SizedBox(height: DesignSystem.adjustedSpacingSmall),
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

  Widget _buildRecentActivitySection(BuildContext context) {
    final accessLogProvider = Provider.of<AccessLogProvider>(context);
    final logs = accessLogProvider.recentLogs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const PlatformText(
              'Recent Activity',
              isTitle: true,
            ),
            PlatformButton(
              text: 'VIEW ALL',
              onPressed: () {
                _showRecentActivityModal(context);
              },
              isSmall: true,
            ),
          ],
        ),
        const SizedBox(height: DesignSystem.adjustedSpacingMedium),
        if (logs.isEmpty)
          const PlatformText(
            'No recent activity',
            style: TextStyle(
              fontStyle: FontStyle.italic,
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: logs.length > 3 ? 3 : logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              return Card(
                margin:
                    EdgeInsets.only(bottom: DesignSystem.adjustedSpacingSmall),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        DesignSystem.primaryColor.withValues(alpha: 26),
                    child: Icon(
                      log.status == AccessLogStatus.verified
                          ? Icons.check_circle
                          : Icons.error,
                      color: log.status == AccessLogStatus.verified
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                  title: PlatformText(log.personnelName),
                  subtitle: PlatformText(
                    '${log.status == AccessLogStatus.verified ? 'Verified' : 'Failed'} • ${DateFormat('MMM dd, HH:mm').format(log.timestamp)}',
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: DesignSystem.textSecondaryColor,
                  ),
                  onTap: () {
                    // Show details
                  },
                ),
              );
            },
          ),
        const SizedBox(height: DesignSystem.adjustedSpacingLarge),
      ],
    );
  }

  void _showRecentActivityModal(BuildContext context) {
    final accessLogProvider =
        Provider.of<AccessLogProvider>(context, listen: false);
    final logs = accessLogProvider.logs;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(DesignSystem.borderRadiusMedium),
        ),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const PlatformText(
                  'Recent Activity',
                  isTitle: true,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: logs.isEmpty
                  ? const Center(
                      child: PlatformText(
                        'No activity logs found',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: logs.length,
                      itemBuilder: (context, index) {
                        final log = logs[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                log.status == AccessLogStatus.verified
                                    ? Colors.green.withValues(alpha: 26)
                                    : Colors.red.withValues(alpha: 26),
                            child: Icon(
                              log.status == AccessLogStatus.verified
                                  ? Icons.check_circle
                                  : Icons.error,
                              color: log.status == AccessLogStatus.verified
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                          title: PlatformText(log.personnelName),
                          subtitle: PlatformText(
                            '${log.status == AccessLogStatus.verified ? 'Verified' : 'Failed'} • ${DateFormat('MMM dd, HH:mm').format(log.timestamp)}',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            // Show details
                          },
                        );
                      },
                    ),
            ),
            ElevatedButton(
              onPressed: () {
                // View all logs
                Navigator.pop(context);
                // TODO: Navigate to full logs screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignSystem.primaryColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('CLOSE'),
            ),
          ],
        ),
      ),
    );
  }
}
