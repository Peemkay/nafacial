import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/design_system.dart';
import '../providers/auth_provider.dart';
import '../screens/about_screen.dart';
import '../screens/contact_screen.dart';
import '../screens/privacy_policy_screen.dart';
import '../screens/terms_conditions_screen.dart';
import '../screens/facial_verification_screen.dart';
import '../screens/live_facial_recognition_screen.dart';
import '../screens/personnel_registration_screen.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _drawerSlideAnimation;
  late Animation<double> _itemsSlideAnimation;
  late Animation<double> _itemsFadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Create animations
    _drawerSlideAnimation = Tween<double>(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _itemsSlideAnimation = Tween<double>(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeInOut),
      ),
    );

    _itemsFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeInOut),
      ),
    );

    // Start animation when drawer opens
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_drawerSlideAnimation.value * 100, 0),
          child: Container(
            width: 280,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(50),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children: [
                // Drawer Header with Logo
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        DesignSystem.primaryColor,
                        DesignSystem.primaryColor.withBlue(100),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(50),
                                blurRadius: 5,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Image.asset(
                              'assets/favicon/favicon-96x96.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // App Name
                        const Text(
                          'NAFacial',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // User name if logged in
                        if (user != null)
                          Text(
                            user.username,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Menu Items
                Expanded(
                  child: Transform.translate(
                    offset: Offset(_itemsSlideAnimation.value * 100, 0),
                    child: Opacity(
                      opacity: _itemsFadeAnimation.value,
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          // Home Section
                          _buildDrawerHeader('Main Navigation'),
                          _buildDrawerItem(
                            icon: Icons.home,
                            title: 'Home',
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.pushReplacementNamed(context, '/home');
                            },
                          ),
                          _buildDrawerItem(
                            icon: Icons.dashboard,
                            title: 'Dashboard',
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.pushReplacementNamed(context, '/home');
                            },
                          ),

                          // Verification Section
                          _buildDrawerHeader('Verification'),
                          _buildDrawerItem(
                            icon: Icons.camera_alt,
                            title: 'Verification',
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.pushNamed(
                                  context, '/facial_verification');
                            },
                          ),
                          _buildDrawerItem(
                            icon: Icons.face_retouching_natural,
                            title: 'Live Recognition',
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const LiveFacialRecognitionScreen(),
                                ),
                              );
                            },
                          ),
                          _buildDrawerItem(
                            icon: Icons.camera_enhance,
                            title: 'Quick Scan',
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const LiveFacialRecognitionScreen(),
                                ),
                              );
                            },
                          ),

                          // Personnel Section
                          _buildDrawerHeader('Personnel Management'),
                          _buildDrawerItem(
                            icon: Icons.people,
                            title: 'Database',
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const FacialVerificationScreen(
                                    initialTabIndex: 4,
                                  ),
                                ),
                              );
                            },
                          ),
                          _buildDrawerItem(
                            icon: Icons.person_add,
                            title: 'Register',
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const PersonnelRegistrationScreen(),
                                ),
                              );
                            },
                          ),
                          _buildDrawerItem(
                            icon: Icons.badge,
                            title: 'ID Management',
                            onTap: () {
                              Navigator.pop(context);
                              _showFeatureComingSoon(context);
                            },
                          ),
                          _buildDrawerItem(
                            icon: Icons.military_tech,
                            title: 'Rank Management',
                            onTap: () {
                              Navigator.pop(context);
                              _showFeatureComingSoon(context);
                            },
                          ),

                          // Security Section
                          _buildDrawerHeader('Security'),
                          _buildDrawerItem(
                            icon: Icons.security,
                            title: 'Access Control',
                            onTap: () {
                              Navigator.pop(context);
                              _showFeatureComingSoon(context);
                            },
                          ),
                          _buildDrawerItem(
                            icon: Icons.history,
                            title: 'Access Logs',
                            onTap: () {
                              Navigator.pop(context);
                              _showFeatureComingSoon(context);
                            },
                          ),
                          _buildDrawerItem(
                            icon: Icons.fingerprint,
                            title: 'Biometric Settings',
                            onTap: () {
                              Navigator.pop(context);
                              _showFeatureComingSoon(context);
                            },
                          ),

                          // Media Section
                          _buildDrawerHeader('Media'),
                          _buildDrawerItem(
                            icon: Icons.photo_library,
                            title: 'Gallery',
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.pushNamed(context, '/gallery');
                            },
                          ),
                          _buildDrawerItem(
                            icon: Icons.video_library,
                            title: 'Video Archive',
                            onTap: () {
                              Navigator.pop(context);
                              _showFeatureComingSoon(context);
                            },
                          ),
                          _buildDrawerItem(
                            icon: Icons.upload_file,
                            title: 'Import/Export',
                            onTap: () {
                              Navigator.pop(context);
                              _showFeatureComingSoon(context);
                            },
                          ),

                          // Reports Section
                          _buildDrawerHeader('Reports & Analytics'),
                          _buildDrawerItem(
                            icon: Icons.analytics,
                            title: 'Analytics Dashboard',
                            onTap: () {
                              Navigator.pop(context);
                              _showFeatureComingSoon(context);
                            },
                          ),
                          _buildDrawerItem(
                            icon: Icons.bar_chart,
                            title: 'Statistical Reports',
                            onTap: () {
                              Navigator.pop(context);
                              _showFeatureComingSoon(context);
                            },
                          ),
                          _buildDrawerItem(
                            icon: Icons.summarize,
                            title: 'Activity Summary',
                            onTap: () {
                              Navigator.pop(context);
                              _showFeatureComingSoon(context);
                            },
                          ),

                          // Settings & Info Section
                          _buildDrawerHeader('Settings & Information'),
                          _buildDrawerItem(
                            icon: Icons.settings,
                            title: 'Settings',
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.pushNamed(context, '/settings');
                            },
                          ),
                          _buildDrawerItem(
                            icon: Icons.update,
                            title: 'Check for Updates',
                            onTap: () {
                              Navigator.pop(context);
                              _showFeatureComingSoon(context);
                            },
                          ),

                          // Information Section
                          _buildDrawerHeader('Information'),
                          _buildDrawerItem(
                            icon: Icons.info_outline,
                            title: 'About',
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AboutScreen(),
                                ),
                              );
                            },
                          ),
                          _buildDrawerItem(
                            icon: Icons.contact_support,
                            title: 'Contact Us',
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ContactScreen(),
                                ),
                              );
                            },
                          ),
                          _buildDrawerItem(
                            icon: Icons.description_outlined,
                            title: 'Terms & Conditions',
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const TermsConditionsScreen(),
                                ),
                              );
                            },
                          ),
                          _buildDrawerItem(
                            icon: Icons.privacy_tip_outlined,
                            title: 'Privacy Policy',
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const PrivacyPolicyScreen(),
                                ),
                              );
                            },
                          ),
                          _buildDrawerItem(
                            icon: Icons.map,
                            title: 'App Roadmap',
                            onTap: () {
                              Navigator.pop(context);
                              _showFeatureComingSoon(context);
                            },
                          ),
                          _buildDrawerItem(
                            icon: Icons.logout,
                            title: 'Logout',
                            onTap: () {
                              Navigator.pop(context);
                              _showLogoutConfirmation(context);
                            },
                          ),
                          // Add a spacer at the bottom
                          const SizedBox(height: 16),

                          _buildDrawerItem(
                            icon: Icons.info_outline,
                            title: 'About',
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AboutScreen(),
                                ),
                              );
                            },
                          ),
                          _buildDrawerItem(
                            icon: Icons.contact_mail,
                            title: 'Contact Us',
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const ContactScreen()),
                              );
                            },
                          ),
                          _buildDrawerItem(
                            icon: Icons.description,
                            title: 'Terms & Conditions',
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const TermsConditionsScreen()),
                              );
                            },
                          ),
                          _buildDrawerItem(
                            icon: Icons.privacy_tip,
                            title: 'Privacy Policy',
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const PrivacyPolicyScreen()),
                              );
                            },
                          ),
                          const Divider(),
                          _buildDrawerItem(
                            icon: Icons.logout,
                            title: 'Logout',
                            onTap: () async {
                              await authProvider.logout();
                              if (context.mounted) {
                                Navigator.of(context)
                                    .pushReplacementNamed('/login');
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Footer
                Transform.translate(
                  offset: Offset(_itemsSlideAnimation.value * 100, 0),
                  child: Opacity(
                    opacity: _itemsFadeAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        '© ${DateTime.now().year} Nigerian Army',
                        style: TextStyle(
                          color: DesignSystem.textSecondaryColor,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDrawerHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const SizedBox(height: 8),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: DesignSystem.primaryColor.withAlpha(180),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  void _showFeatureComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('This feature is coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final authProvider =
                  Provider.of<AuthProvider>(context, listen: false);
              // Store the context reference
              final contextRef = context;
              authProvider.logout().then((_) {
                Navigator.pushReplacementNamed(contextRef, '/login');
              });
            },
            child: const Text('LOGOUT'),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: DesignSystem.primaryColor,
        size: 24,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: DesignSystem.textPrimaryColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
      dense: true,
      visualDensity: VisualDensity.compact,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      hoverColor: DesignSystem.primaryColor.withAlpha(20),
      selectedTileColor: DesignSystem.primaryColor.withAlpha(30),
    );
  }
}
