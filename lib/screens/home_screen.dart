import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/design_system.dart';
import '../models/personnel_model.dart';
import '../providers/auth_provider.dart';
import '../providers/personnel_provider.dart';
import '../widgets/platform_aware_widgets.dart';
import '../widgets/custom_drawer.dart';
import 'facial_verification_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    // Initialize personnel provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final personnelProvider =
          Provider.of<PersonnelProvider>(context, listen: false);
      personnelProvider.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return PlatformScaffold(
      appBar: AppBar(
        title: const Text('NAFacial Dashboard'),
        backgroundColor: DesignSystem.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Show notifications
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No new notifications'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            tooltip: 'Notifications',
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(DesignSystem.adjustedSpacingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome card
                PlatformCard(
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
                          SizedBox(width: DesignSystem.adjustedSpacingMedium),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                PlatformText(
                                  'Welcome, ${user?.fullName ?? 'User'}',
                                  isTitle: true,
                                ),
                                PlatformText(
                                  '${user?.rank ?? 'Rank'} - ${user?.department ?? 'Department'}',
                                  style: TextStyle(
                                    color: DesignSystem.textSecondaryColor,
                                    fontSize:
                                        DesignSystem.adjustedFontSizeSmall,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: DesignSystem.adjustedSpacingMedium),
                      const Divider(),
                      SizedBox(height: DesignSystem.adjustedSpacingSmall),
                      PlatformText(
                        'System Status: ACTIVE',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: DesignSystem.fontWeightBold,
                        ),
                      ),
                      SizedBox(height: DesignSystem.adjustedSpacingSmall),
                      PlatformText(
                        'Last Login: ${DateTime.now().toString().substring(0, 16)}',
                        style: TextStyle(
                          fontSize: DesignSystem.adjustedFontSizeSmall,
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
                          SizedBox(width: DesignSystem.adjustedSpacingSmall),
                          PlatformText(
                            'Biometric Authentication',
                            isTitle: true,
                          ),
                        ],
                      ),
                      SizedBox(height: DesignSystem.adjustedSpacingMedium),
                      if (!authProvider.isBiometricAvailable) ...[
                        PlatformText(
                          'Biometric authentication is not available on this device.',
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ] else ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            PlatformText(
                              'Enable Biometric Login',
                              style: TextStyle(
                                fontSize: DesignSystem.adjustedFontSizeMedium,
                              ),
                            ),
                            Switch(
                              value: user?.isBiometricEnabled ?? false,
                              onChanged: (value) async {
                                if (value) {
                                  await authProvider.enableBiometric();
                                } else {
                                  await authProvider.disableBiometric();
                                }
                              },
                              activeColor: DesignSystem.primaryColor,
                            ),
                          ],
                        ),
                        SizedBox(height: DesignSystem.adjustedSpacingSmall),
                        PlatformText(
                          'Use your fingerprint or face recognition for faster login.',
                          style: TextStyle(
                            fontSize: DesignSystem.adjustedFontSizeSmall,
                            color: DesignSystem.textSecondaryColor,
                          ),
                        ),
                      ],
                    ],
                  ),
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

                GridView.count(
                  crossAxisCount:
                      MediaQuery.of(context).size.width > 600 ? 3 : 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: DesignSystem.adjustedSpacingMedium,
                  crossAxisSpacing: DesignSystem.adjustedSpacingMedium,
                  children: [
                    _buildActionCard(
                      context,
                      icon: Icons.face,
                      title: 'Facial Verification',
                      color: DesignSystem.primaryColor,
                      onTap: () {
                        Navigator.of(context).pushNamed('/facial_verification');
                      },
                    ),
                    _buildActionCard(
                      context,
                      icon: Icons.people,
                      title: 'Personnel Database',
                      color: DesignSystem.secondaryColor,
                      onTap: () {
                        // Navigate to facial verification screen with personnel database tab
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                const FacialVerificationScreen(
                                    initialTabIndex: 4),
                          ),
                        );
                      },
                    ),
                    _buildActionCard(
                      context,
                      icon: Icons.history,
                      title: 'Access Logs',
                      color: Colors.orange,
                      onTap: () {
                        // Navigate to access logs screen
                      },
                    ),
                    _buildActionCard(
                      context,
                      icon: Icons.settings,
                      title: 'System Settings',
                      color: Colors.grey.shade700,
                      onTap: () {
                        // Navigate to settings screen
                      },
                    ),
                  ],
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
              PlatformText(
                'Personnel Database',
                isTitle: true,
              ),
              const Spacer(),
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
    return PlatformCard(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(DesignSystem.adjustedSpacingMedium),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 32,
            ),
          ),
          SizedBox(height: DesignSystem.adjustedSpacingSmall),
          PlatformText(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: DesignSystem.fontWeightMedium,
            ),
          ),
        ],
      ),
    );
  }
}
