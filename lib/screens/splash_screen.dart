import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../config/theme.dart';
import '../config/design_system.dart';
import '../utils/responsive_utils.dart';
import '../widgets/platform_aware_widgets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _controller.forward();

    // Navigate to verification screen after animations
    Future.delayed(const Duration(seconds: 5), () {
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => const VerificationScreen()),
      // );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get orientation information
    final isLandscape = ResponsiveUtils.isLandscape(context);
    final isDesktop = ResponsiveUtils.isDesktop(context);

    // Use design system for consistent sizing across platforms
    // Calculate sizes based on screen dimensions for better proportions
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // Logo size should be proportional to the screen size but not too large
    final logoSize = isLandscape
        ? screenHeight * 0.4 // 40% of screen height in landscape
        : screenWidth * 0.35; // 35% of screen width in portrait

    // Cap the logo size to reasonable limits
    final cappedLogoSize = logoSize.clamp(
        DesignSystem.containerSizeMedium, DesignSystem.containerSizeExtraLarge);

    // Font sizes should be proportional but not too large
    final systemNameFontSize = DesignSystem.adjustedFontSizeLarge;
    final statusFontSize = DesignSystem.adjustedFontSizeSmall;

    // Ripple size should be proportional to the logo
    final rippleSize = isLandscape
        ? cappedLogoSize * 0.8 // 80% of logo size in landscape
        : cappedLogoSize * 0.7; // 70% of logo size in portrait

    // Spacing should be proportional to the screen
    final spacingHeight = isLandscape
        ? DesignSystem.adjustedSpacingMedium
        : DesignSystem.adjustedSpacingLarge;

    // Layout for landscape mode
    final landscapeLayout = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Logo section
        Expanded(
          flex: 1,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: cappedLogoSize,
              height: cappedLogoSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: DesignSystem.accentColor,
                  width: 2,
                ),
                gradient: const RadialGradient(
                  colors: [
                    Color(0xB3001F3F), // primaryColor with 0.7 opacity
                    Color(0xFF001F3F), // primaryColor
                  ],
                  center: Alignment.center,
                  radius: 0.8,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x4D4A90E2), // secondaryColor with 0.3 opacity
                    blurRadius: 12,
                    spreadRadius: 2,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.security,
                      color: AppTheme.yellow,
                      size: 50,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "NAFacial",
                      style: TextStyle(
                        color: AppTheme.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Content section
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // System Name
              FadeTransition(
                opacity: _fadeAnimation,
                child: AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText(
                      'Nigerian Army Facial Verification System',
                      textStyle: TextStyle(
                        color: Colors.white,
                        fontSize: systemNameFontSize,
                        fontWeight: DesignSystem.fontWeightBold,
                        letterSpacing: DesignSystem.letterSpacingNormal,
                      ),
                      speed: const Duration(milliseconds: 50),
                    ),
                  ],
                  totalRepeatCount: 1,
                ),
              ),
              SizedBox(height: spacingHeight),
              // Scanning Animation
              SpinKitRipple(
                color: DesignSystem.secondaryColor,
                size: rippleSize,
                borderWidth: 4.0,
              ),
              SizedBox(height: spacingHeight),
              // Security Status
              FadeTransition(
                opacity: _fadeAnimation,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.verified_user,
                      color: Color(0xFF00C853), // verified color
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    AnimatedTextKit(
                      animatedTexts: [
                        TyperAnimatedText(
                          'SECURE SYSTEM INITIALIZING',
                          textStyle: TextStyle(
                            color: DesignSystem.accentColor,
                            fontSize: statusFontSize,
                            letterSpacing: DesignSystem.letterSpacingWide,
                            fontWeight: DesignSystem.fontWeightMedium,
                          ),
                          speed: const Duration(milliseconds: 100),
                        ),
                      ],
                      totalRepeatCount: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );

    // Layout for portrait mode
    final portraitLayout = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Logo and Shield Animation
        ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: cappedLogoSize,
            height: cappedLogoSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: DesignSystem.accentColor,
                width: 2,
              ),
              gradient: const RadialGradient(
                colors: [
                  Color(0xB3001F3F), // primaryColor with 0.7 opacity
                  Color(0xFF001F3F), // primaryColor
                ],
                center: Alignment.center,
                radius: 0.8,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x4D4A90E2), // secondaryColor with 0.3 opacity
                  blurRadius: 12,
                  spreadRadius: 2,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.security,
                    color: AppTheme.yellow,
                    size: 50,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "NAFacial",
                    style: TextStyle(
                      color: AppTheme.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: spacingHeight),
        // System Name
        FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: AnimatedTextKit(
              animatedTexts: [
                TypewriterAnimatedText(
                  'Nigerian Army Facial Verification System',
                  textStyle: TextStyle(
                    color: Colors.white,
                    fontSize: systemNameFontSize,
                    fontWeight: DesignSystem.fontWeightBold,
                    letterSpacing: DesignSystem.letterSpacingNormal,
                  ),
                  speed: const Duration(milliseconds: 50),
                ),
              ],
              totalRepeatCount: 1,
            ),
          ),
        ),
        SizedBox(height: spacingHeight),
        // Scanning Animation
        SpinKitRipple(
          color: DesignSystem.secondaryColor,
          size: rippleSize,
          borderWidth: 4.0,
        ),
        SizedBox(height: spacingHeight),
        // Security Status
        FadeTransition(
          opacity: _fadeAnimation,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.verified_user,
                color: Color(0xFF00C853), // verified color
                size: 20,
              ),
              const SizedBox(width: 10),
              AnimatedTextKit(
                animatedTexts: [
                  TyperAnimatedText(
                    'SECURE SYSTEM INITIALIZING',
                    textStyle: TextStyle(
                      color: DesignSystem.accentColor,
                      fontSize: statusFontSize,
                      letterSpacing: DesignSystem.letterSpacingWide,
                      fontWeight: DesignSystem.fontWeightMedium,
                    ),
                    speed: const Duration(milliseconds: 100),
                  ),
                ],
                totalRepeatCount: 1,
              ),
            ],
          ),
        ),
      ],
    );

    return PlatformScaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              DesignSystem.primaryColor,
              DesignSystem.primaryColor.withAlpha(230),
              AppTheme.green.withAlpha(204),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Security pattern overlay
              Positioned.fill(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: CustomPaint(
                    painter: SecurityPatternPainter(),
                  ),
                ),
              ),
              // Main content - responsive layout
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isDesktop
                        ? DesignSystem.maxWidthDesktop
                        : double.infinity,
                  ),
                  child: isLandscape ? landscapeLayout : portraitLayout,
                ),
              ),
              // Bottom classification bar
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: PlatformContainer(
                    padding: EdgeInsets.symmetric(
                        vertical: DesignSystem.adjustedSpacingSmall),
                    backgroundColor: const Color(
                        0xCC001F3F), // primaryColor with 0.8 opacity
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Security pattern painter for background
class SecurityPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.skyBlue.withAlpha(13)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < size.width; i += 20) {
      canvas.drawLine(
        Offset(i.toDouble(), 0),
        Offset(i.toDouble(), size.height),
        paint,
      );
    }

    for (var i = 0; i < size.height; i += 20) {
      canvas.drawLine(
        Offset(0, i.toDouble()),
        Offset(size.width, i.toDouble()),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
