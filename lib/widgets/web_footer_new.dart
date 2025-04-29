import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/design_system.dart';
import '../providers/theme_provider.dart';
import '../providers/version_provider.dart';
import '../utils/responsive_utils.dart';
import '../main.dart';

class WebFooter extends StatelessWidget {
  const WebFooter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final isDesktop = ResponsiveUtils.isDesktop(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDarkMode
              ? [
                  DesignSystem.darkAppBarColor,
                  const Color(0xFF001428), // Darker shade for gradient effect
                ]
              : [
                  DesignSystem.lightNavBarColor,
                  const Color(0xFFE0E8F0), // Lighter shade for gradient effect
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, -2),
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
            color: isDarkMode
                ? Colors.white.withAlpha(10)
                : Colors.black.withAlpha(10),
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
              const SizedBox(height: 16),
              Text(
                'NAFacial is a facial recognition system designed for the Nigerian Army to enhance security and personnel management.',
                style: TextStyle(
                  color: isDarkMode
                      ? Colors.white.withAlpha(70)
                      : Colors.black.withAlpha(70),
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
              style: TextStyle(
                color: isDarkMode
                    ? Colors.white.withAlpha(70)
                    : Colors.black.withAlpha(70),
                fontSize: 12,
              ),
            ),
            Text(
              'NAFacial v${versionProvider.currentVersion} | $deviceInfo',
              style: TextStyle(
                color: isDarkMode
                    ? Colors.white.withAlpha(70)
                    : Colors.black.withAlpha(70),
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
      style: TextStyle(
        color: isDarkMode ? Colors.white : DesignSystem.lightTextPrimaryColor,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildFooterLink(String title, String route, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => Navigator.pushNamed(navigatorKey.currentContext!, route),
        child: Text(
          title,
          style: TextStyle(
            color: isDarkMode
                ? Colors.white.withAlpha(70)
                : Colors.black.withAlpha(70),
          ),
        ),
      ),
    );
  }

  Widget _buildFooterLinkInline(String title, String route, bool isDarkMode) {
    return InkWell(
      onTap: () => Navigator.pushNamed(navigatorKey.currentContext!, route),
      child: Text(
        title,
        style: TextStyle(
          color: isDarkMode
              ? Colors.white.withAlpha(70)
              : Colors.black.withAlpha(70),
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
          color: isDarkMode
              ? Colors.white.withAlpha(70)
              : Colors.black.withAlpha(70),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: isDarkMode
                  ? Colors.white.withAlpha(70)
                  : Colors.black.withAlpha(70),
            ),
          ),
        ),
      ],
    );
  }
}

class WebFooterContainer extends StatelessWidget {
  final Widget child;

  const WebFooterContainer({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main content
        SingleChildScrollView(
          child: Column(
            children: [
              // Main content
              child,

              // Space for footer
              const SizedBox(height: 300), // Adjust based on footer height
            ],
          ),
        ),

        // Footer positioned at the bottom
        const Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: WebFooter(),
        ),
      ],
    );
  }
}
