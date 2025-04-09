import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/design_system.dart';
import '../providers/theme_provider.dart';
import '../providers/version_provider.dart';
import '../utils/responsive_utils.dart';
import '../main.dart';

/// A widget that provides a professional web layout with header, content, and footer
class WebLayout extends StatelessWidget {
  final Widget content;
  final Function()? onMenuPressed;

  const WebLayout({
    Key? key,
    required this.content,
    this.onMenuPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        WebHeader(onMenuPressed: onMenuPressed),

        // Content with footer at the bottom (not fixed)
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Main content
                content,

                // Footer at the bottom of the content
                const WebFooter(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// A professional header for web view with dropdown menu
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

  // Controller for the dropdown menu overlay
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
                  color: Colors.black.withAlpha(10),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildMenuDropdownItem(
                    'Home', Icons.home, () => _navigateTo('/home')),
                _buildMenuDropdownItem('Facial Verification', Icons.face,
                    () => _navigateTo('/facial_verification')),
                _buildMenuDropdownItem('Live Recognition', Icons.camera,
                    () => _navigateTo('/live_recognition')),
                _buildMenuDropdownItem('Personnel Database', Icons.people,
                    () => _navigateTo('/personnel_database')),
                _buildMenuDropdownItem('Registration', Icons.person_add,
                    () => _navigateTo('/personnel_registration')),
                _buildMenuDropdownItem(
                    'Settings', Icons.settings, () => _navigateTo('/settings')),
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
    final isDarkMode = themeProvider.isDarkMode;

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: isDarkMode
            ? DesignSystem.darkAppBarColor
            : DesignSystem.lightAppBarColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
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
                decoration: BoxDecoration(
                  color: DesignSystem.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
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
                style: const TextStyle(
                  color: Colors.white, // Always white
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
                        ? Colors.white.withAlpha(10)
                        : Colors.black.withAlpha(5))
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
                          : Colors.white, // Always white
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
                        : Colors.white, // Always white
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

          // Theme Toggle
          const SizedBox(width: 16),
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: Colors.white, // Always white
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
                    : Colors.white, // Always white
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
}

/// A professional footer for web view
class WebFooter extends StatelessWidget {
  const WebFooter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final isDesktop = ResponsiveUtils.isDesktop(context);

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF00264D), // Dark blue background for better visibility
        boxShadow: [
          BoxShadow(
            color: Color(0x33000000), // More visible shadow
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        vertical: 40,
        horizontal: isDesktop ? 80 : 24,
      ),
      child: Column(
        children: [
          // Main footer content
          isDesktop
              ? _buildDesktopFooter(context, isDarkMode)
              : _buildMobileFooter(context, isDarkMode),

          const SizedBox(height: 40),

          // Divider
          Container(
            height: 1,
            width: double.infinity,
            color: Colors.white.withAlpha(30), // Subtle white divider
          ),

          const SizedBox(height: 20),

          // Copyright and version
          _buildCopyrightSection(context, isDarkMode),
        ],
      ),
    );
  }

  Widget _buildDesktopFooter(BuildContext context, bool isDarkMode) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo and description
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: DesignSystem.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
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
              const SizedBox(height: 16),
              Text(
                'NAFacial is a facial recognition system designed for the Nigerian Army to enhance security and personnel management.',
                style: TextStyle(
                  color: Colors.white.withAlpha(240), // More visible text
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 40),

        // Quick Links
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFooterHeading('Quick Links', isDarkMode),
              const SizedBox(height: 16),
              _buildFooterLink('Home', '/home', isDarkMode),
              _buildFooterLink('About', '/about', isDarkMode),
              _buildFooterLink('Contact', '/contact', isDarkMode),
              _buildFooterLink('Terms & Conditions', '/terms', isDarkMode),
              _buildFooterLink('Privacy Policy', '/privacy', isDarkMode),
            ],
          ),
        ),

        const SizedBox(width: 40),

        // Features
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFooterHeading('Features', isDarkMode),
              const SizedBox(height: 16),
              _buildFooterLink(
                  'Facial Verification', '/facial_verification', isDarkMode),
              _buildFooterLink(
                  'Live Recognition', '/live_recognition', isDarkMode),
              _buildFooterLink(
                  'Personnel Database', '/personnel_database', isDarkMode),
              _buildFooterLink(
                  'Registration', '/personnel_registration', isDarkMode),
              _buildFooterLink('Settings', '/settings', isDarkMode),
            ],
          ),
        ),

        const SizedBox(width: 40),

        // Contact
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFooterHeading('Contact', isDarkMode),
              const SizedBox(height: 16),
              _buildContactItem(
                Icons.email,
                'offrmbabubakar@gmail.com',
                isDarkMode,
              ),
              const SizedBox(height: 12),
              _buildContactItem(
                Icons.phone,
                '+234 XXX XXX XXXX',
                isDarkMode,
              ),
              const SizedBox(height: 12),
              _buildContactItem(
                Icons.location_on,
                'Nigerian Army Headquarters, Abuja',
                isDarkMode,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileFooter(BuildContext context, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo and description
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: DesignSystem.primaryColor,
                shape: BoxShape.circle,
              ),
              child: Center(
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
        const SizedBox(height: 16),
        Text(
          'NAFacial is a facial recognition system designed for the Nigerian Army to enhance security and personnel management.',
          style: TextStyle(
            color: isDarkMode
                ? Colors.white.withAlpha(70)
                : Colors.black.withAlpha(70),
          ),
        ),

        const SizedBox(height: 32),

        // Quick Links
        _buildFooterHeading('Quick Links', isDarkMode),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            _buildFooterLinkInline('Home', '/home', isDarkMode),
            _buildFooterLinkInline('About', '/about', isDarkMode),
            _buildFooterLinkInline('Contact', '/contact', isDarkMode),
            _buildFooterLinkInline('Terms', '/terms', isDarkMode),
            _buildFooterLinkInline('Privacy', '/privacy', isDarkMode),
          ],
        ),

        const SizedBox(height: 32),

        // Contact
        _buildFooterHeading('Contact', isDarkMode),
        const SizedBox(height: 16),
        _buildContactItem(
          Icons.email,
          'offrmbabubakar@gmail.com',
          isDarkMode,
        ),
        const SizedBox(height: 12),
        _buildContactItem(
          Icons.phone,
          '+234 XXX XXX XXXX',
          isDarkMode,
        ),
        const SizedBox(height: 12),
        _buildContactItem(
          Icons.location_on,
          'Nigerian Army Headquarters, Abuja',
          isDarkMode,
        ),
      ],
    );
  }

  Widget _buildCopyrightSection(BuildContext context, bool isDarkMode) {
    return Consumer<VersionProvider>(
      builder: (context, versionProvider, child) {
        final deviceInfo = MediaQuery.of(context).size.width > 600
            ? 'Desktop'
            : MediaQuery.of(context).size.width < 400
                ? 'Mobile'
                : 'Tablet';

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '© ${DateTime.now().year} Nigerian Army. All rights reserved.',
              style: const TextStyle(
                color: Colors.white, // Always white
                fontSize: 12,
              ),
            ),
            Text(
              'NAFacial v${versionProvider.currentVersion} | $deviceInfo',
              style: const TextStyle(
                color: Colors.white, // Always white
                fontSize: 12,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFooterHeading(String title, bool isDarkMode) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white, // Always white
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildFooterLink(String title, String route, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () =>
            Navigator.of(navigatorKey.currentContext!).pushNamed(route),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white, // Always white
          ),
        ),
      ),
    );
  }

  Widget _buildFooterLinkInline(String title, String route, bool isDarkMode) {
    return InkWell(
      onTap: () => Navigator.of(navigatorKey.currentContext!).pushNamed(route),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white, // Always white
        ),
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text, bool isDarkMode) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.white, // Always white
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white, // Always white
            ),
          ),
        ),
      ],
    );
  }
}
