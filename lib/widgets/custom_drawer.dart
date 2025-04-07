import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/design_system.dart';
import '../providers/auth_provider.dart';
import '../screens/about_screen.dart';
import '../screens/contact_screen.dart';
import '../screens/privacy_policy_screen.dart';
import '../screens/terms_conditions_screen.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> with SingleTickerProviderStateMixin {
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
        curve: Interval(0.2, 1.0, curve: Curves.easeInOut),
      ),
    );
    
    _itemsFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.2, 1.0, curve: Curves.easeInOut),
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
                  color: Colors.black.withOpacity(0.2),
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
                                color: Colors.black.withOpacity(0.2),
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
                          _buildDrawerItem(
                            icon: Icons.home,
                            title: 'Home',
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.pushReplacementNamed(context, '/home');
                            },
                          ),
                          _buildDrawerItem(
                            icon: Icons.camera_alt,
                            title: 'Facial Verification',
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.pushNamed(context, '/facial_verification');
                            },
                          ),
                          _buildDrawerItem(
                            icon: Icons.people,
                            title: 'Personnel Database',
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.pushNamed(context, '/facial_verification');
                            },
                          ),
                          const Divider(),
                          _buildDrawerItem(
                            icon: Icons.info,
                            title: 'About',
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const AboutScreen()),
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
                                MaterialPageRoute(builder: (context) => const ContactScreen()),
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
                                MaterialPageRoute(builder: (context) => const TermsConditionsScreen()),
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
                                MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
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
                                Navigator.of(context).pushReplacementNamed('/login');
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
                      child: const Text(
                        '© 2023 Nigerian Army',
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
      dense: true,
      visualDensity: VisualDensity.compact,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      hoverColor: DesignSystem.primaryColor.withOpacity(0.1),
    );
  }
}
