import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/design_system.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/responsive_utils.dart';
import 'notification_icon.dart';

class WebHeader extends StatefulWidget {
  final Function()? onMenuPressed;

  const WebHeader({
    Key? key,
    this.onMenuPressed,
  }) : super(key: key);

  @override
  State<WebHeader> createState() => _WebHeaderState();
}

class _WebHeaderState extends State<WebHeader> {
  bool _isHoveringHome = false;
  bool _isHoveringAbout = false;
  bool _isHoveringContact = false;
  bool _isHoveringTerms = false;
  bool _isHoveringPrivacy = false;
  bool _isHoveringMenu = false;
  bool _isMenuOpen = false;

  // Overlay entry for dropdown menu
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
      if (_isMenuOpen) {
        _showMenuOverlay();
      } else {
        _removeOverlay();
      }
    });
  }

  void _showMenuOverlay() {
    _removeOverlay(); // Remove any existing overlay

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: offset.dy + size.height,
        left: offset.dx + size.width * 0.7, // Position near the menu button
        width: 200,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Main Navigation
                _buildMenuDropdownItem(
                    'Home', Icons.home, () => _navigateTo('/home')),

                // Verification
                const Divider(),
                _buildMenuDropdownItem('Facial Verification', Icons.face,
                    () => _navigateTo('/facial_verification')),
                _buildMenuDropdownItem('Live Recognition', Icons.camera,
                    () => _navigateTo('/live_recognition')),

                // Personnel Management
                const Divider(),
                _buildMenuDropdownItem('Personnel Database', Icons.people,
                    () => _navigateTo('/personnel_database')),
                _buildMenuDropdownItem('Register Personnel', Icons.person_add,
                    () => _navigateTo('/register_personnel')),
                _buildMenuDropdownItem('ID Management', Icons.badge,
                    () => _navigateTo('/id_management')),
                _buildMenuDropdownItem('Rank Management', Icons.military_tech,
                    () => _navigateTo('/rank_management')),

                // Security
                const Divider(),
                _buildMenuDropdownItem('Access Logs', Icons.history,
                    () => _navigateTo('/access_logs')),
                _buildMenuDropdownItem('Access Control', Icons.security,
                    () => _navigateTo('/access_control')),
                _buildMenuDropdownItem(
                    'Biometric Management',
                    Icons.fingerprint,
                    () => _navigateTo('/biometric_management')),

                // Reports & Analytics
                const Divider(),
                _buildMenuDropdownItem('Analytics', Icons.analytics,
                    () => _navigateTo('/analytics')),
                _buildMenuDropdownItem('Statistics', Icons.bar_chart,
                    () => _navigateTo('/statistics')),
                _buildMenuDropdownItem('Activity Summary', Icons.summarize,
                    () => _navigateTo('/activity_summary')),

                // Settings & Information
                const Divider(),
                _buildMenuDropdownItem(
                    'Settings', Icons.settings, () => _navigateTo('/settings')),
                _buildMenuDropdownItem('App Roadmap', Icons.map,
                    () => _navigateTo('/app_roadmap')),

                // Information
                const Divider(),
                _buildMenuDropdownItem(
                    'About', Icons.info, () => _navigateTo('/about')),
                _buildMenuDropdownItem(
                    'Contact', Icons.mail, () => _navigateTo('/contact')),
                _buildMenuDropdownItem(
                    'Terms', Icons.description, () => _navigateTo('/terms')),
                _buildMenuDropdownItem('Privacy', Icons.privacy_tip,
                    () => _navigateTo('/privacy')),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _navigateTo(String route) {
    _removeOverlay();
    setState(() {
      _isMenuOpen = false;
    });
    Navigator.pushNamed(context, route);
  }

  Widget _buildMenuDropdownItem(
      String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 12),
            Text(title),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final user = authProvider.currentUser;

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: isDarkMode
            ? DesignSystem.darkAppBarColor
            : DesignSystem.lightAppBarColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 26),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // Logo and App Name
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: DesignSystem.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.security,
                    color: DesignSystem.accentColor,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'NAFacial',
                style: TextStyle(
                  color: isDarkMode
                      ? Colors.white
                      : DesignSystem.lightTextPrimaryColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          // Spacer
          const Spacer(),

          // Menu Button (visible on all web views)
          InkWell(
            onTap: _toggleMenu,
            onHover: (hovering) {
              setState(() {
                _isHoveringMenu = hovering;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _isMenuOpen
                    ? (isDarkMode
                        ? Colors.white.withValues(alpha: 26)
                        : Colors.black.withValues(alpha: 13))
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: _isMenuOpen
                    ? Border.all(color: DesignSystem.accentColor, width: 1)
                    : null,
              ),
              child: Row(
                children: [
                  Text(
                    'Menu',
                    style: TextStyle(
                      color: _isHoveringMenu || _isMenuOpen
                          ? DesignSystem.accentColor
                          : isDarkMode
                              ? Colors.white
                              : DesignSystem.lightTextPrimaryColor,
                      fontWeight: _isHoveringMenu || _isMenuOpen
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _isMenuOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    color: _isHoveringMenu || _isMenuOpen
                        ? DesignSystem.accentColor
                        : isDarkMode
                            ? Colors.white
                            : DesignSystem.lightTextPrimaryColor,
                  ),
                ],
              ),
            ),
          ),

          // Navigation Links (only visible on desktop)
          if (ResponsiveUtils.isDesktop(context)) ...[
            _buildNavLink(
              title: 'Home',
              isHovering: _isHoveringHome,
              onHover: (value) => setState(() => _isHoveringHome = value),
              onTap: () => Navigator.pushReplacementNamed(context, '/home'),
              isDarkMode: isDarkMode,
            ),
            _buildNavLink(
              title: 'About',
              isHovering: _isHoveringAbout,
              onHover: (value) => setState(() => _isHoveringAbout = value),
              onTap: () => Navigator.pushNamed(context, '/about'),
              isDarkMode: isDarkMode,
            ),
            _buildNavLink(
              title: 'Contact',
              isHovering: _isHoveringContact,
              onHover: (value) => setState(() => _isHoveringContact = value),
              onTap: () => Navigator.pushNamed(context, '/contact'),
              isDarkMode: isDarkMode,
            ),
            _buildNavLink(
              title: 'Terms',
              isHovering: _isHoveringTerms,
              onHover: (value) => setState(() => _isHoveringTerms = value),
              onTap: () => Navigator.pushNamed(context, '/terms'),
              isDarkMode: isDarkMode,
            ),
            _buildNavLink(
              title: 'Privacy',
              isHovering: _isHoveringPrivacy,
              onHover: (value) => setState(() => _isHoveringPrivacy = value),
              onTap: () => Navigator.pushNamed(context, '/privacy'),
              isDarkMode: isDarkMode,
            ),
          ],

          // Notification Icon
          const SizedBox(width: 16),
          const NotificationIcon(),

          // User Profile
          if (user != null && ResponsiveUtils.isDesktop(context)) ...[
            const SizedBox(width: 16),
            _buildUserProfile(user, isDarkMode),
          ],

          // Mobile menu button removed

          // Theme Toggle
          const SizedBox(width: 16),
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: isDarkMode
                  ? Colors.white
                  : DesignSystem.lightTextPrimaryColor,
            ),
            onPressed: () => themeProvider.toggleTheme(),
          ),
        ],
      ),
    );
  }

  Widget _buildNavLink({
    required String title,
    required bool isHovering,
    required Function(bool) onHover,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: onTap,
        onHover: onHover,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                color: isHovering
                    ? DesignSystem.accentColor
                    : isDarkMode
                        ? Colors.white
                        : DesignSystem.lightTextPrimaryColor,
                fontWeight: isHovering ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 4),
            // Animated underline
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 2,
              width: isHovering ? 20 : 0,
              decoration: BoxDecoration(
                color: DesignSystem.accentColor,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfile(dynamic user, bool isDarkMode) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, '/profile'),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundColor: DesignSystem.primaryColor,
            child: Icon(
              Icons.person,
              color: DesignSystem.accentColor,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            user.fullName ?? 'User',
            style: TextStyle(
              color: isDarkMode
                  ? Colors.white
                  : DesignSystem.lightTextPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
