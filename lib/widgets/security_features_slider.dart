import 'dart:async';
import 'package:flutter/material.dart';
import '../config/design_system.dart';

class SecurityFeaturesSlider extends StatefulWidget {
  const SecurityFeaturesSlider({Key? key}) : super(key: key);

  @override
  State<SecurityFeaturesSlider> createState() => _SecurityFeaturesSliderState();
}

class _SecurityFeaturesSliderState extends State<SecurityFeaturesSlider> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  // List of AI-generated security features
  final List<SecurityFeature> _securityFeatures = [
    SecurityFeature(
      title: 'Nigerian Army Tactical Recognition',
      description:
          'Advanced facial recognition system developed for Nigerian Army personnel identification with 99.9% accuracy in diverse field conditions.',
      icon: Icons.face_retouching_natural,
      color: const Color(0xFF1A8D1A), // Nigerian green
      imagePath: 'assets/images/military_facial_scan.png',
    ),
    SecurityFeature(
      title: 'NAS Neural Defense Network',
      description:
          'Nigerian Army Signals proprietary deep learning algorithms that analyze facial features in real-time to detect unauthorized access attempts.',
      icon: Icons.psychology,
      color: const Color(0xFF008751), // Nigerian flag green
      imagePath: 'assets/images/military_neural_network.png',
    ),
    SecurityFeature(
      title: 'Multi-Spectrum Biometric Shield',
      description:
          'Military-grade biometric verification combining facial geometry, iris patterns, and behavioral analysis for Nigerian defense installations.',
      icon: Icons.fingerprint,
      color: const Color(0xFF00573F), // Dark green
      imagePath: 'assets/images/military_biometric.png',
    ),
    SecurityFeature(
      title: 'Sovereign Data Fortress',
      description:
          'Nigerian Army Signals developed encryption protocol for all biometric data with decentralized storage to ensure national security integrity.',
      icon: Icons.security,
      color: const Color(0xFF0D0D0D), // Nigerian black
      imagePath: 'assets/images/military_encryption.png',
    ),
    SecurityFeature(
      title: 'Eagle Eye Surveillance',
      description:
          'Real-time monitoring system with AI-powered threat detection designed specifically for Nigerian military installations and checkpoints.',
      icon: Icons.shield,
      color: const Color(0xFF2D4B9A), // Nigerian blue
      imagePath: 'assets/images/military_surveillance.png',
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Start auto-scrolling timer
    _startAutoScroll();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_currentPage < _securityFeatures.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignSystem.borderRadiusMedium),
      ),
      color: isDarkMode ? DesignSystem.darkCardColor : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.shield_outlined,
                  color: DesignSystem.accentColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Advanced Security Features',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode
                        ? Colors.white
                        : DesignSystem.lightTextPrimaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Slider
            SizedBox(
              height: isMobile ? 180 : 200,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _securityFeatures.length,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildFeatureCard(
                      _securityFeatures[index], isDarkMode, isMobile);
                },
              ),
            ),

            const SizedBox(height: 16),

            // Dots indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _securityFeatures.length,
                (index) => _buildDotIndicator(index, isDarkMode),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
      SecurityFeature feature, bool isDarkMode, bool isMobile) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DesignSystem.borderRadiusSmall),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            feature.color.withAlpha(isDarkMode ? 50 : 25),
            feature.color.withAlpha(isDarkMode ? 25 : 13),
          ],
        ),
        border: Border.all(
          color: feature.color.withAlpha(75),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Military-themed header with icon and title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: feature.color.withAlpha(isDarkMode ? 75 : 50),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    feature.icon,
                    color: feature.color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    feature.title,
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode
                          ? Colors.white
                          : DesignSystem.lightTextPrimaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Military image placeholder (would be replaced with actual images)
            if (feature.imagePath != null)
              Expanded(
                flex: 2,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: feature.color.withAlpha(15),
                    border: Border.all(
                      color: feature.color.withAlpha(50),
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(7),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Military-themed placeholder with gradient overlay
                        Container(
                          color: Colors.black12,
                          child: Center(
                            child: Icon(
                              _getMilitaryIcon(feature.title),
                              size: 48,
                              color: feature.color.withAlpha(100),
                            ),
                          ),
                        ),
                        // Gradient overlay for military aesthetic
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                feature.color.withAlpha(40),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 12),

            // Description
            Expanded(
              flex: 1,
              child: Text(
                feature.description,
                style: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                  color: isDarkMode
                      ? Colors.white.withAlpha(204) // 0.8 alpha
                      : Colors.black.withAlpha(178), // 0.7 alpha
                ),
              ),
            ),

            const SizedBox(height: 8),

            // NAS badge
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: feature.color.withAlpha(isDarkMode ? 75 : 50),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Powered by NAS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: feature.color,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDotIndicator(int index, bool isDarkMode) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? DesignSystem.accentColor
            : (isDarkMode
                ? Colors.white.withAlpha(77) // 0.3 alpha
                : Colors.grey.withAlpha(77)), // 0.3 alpha
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  // Helper method to get appropriate military-themed icons
  IconData _getMilitaryIcon(String title) {
    if (title.contains('Recognition')) {
      return Icons.face_retouching_natural;
    } else if (title.contains('Neural')) {
      return Icons.psychology;
    } else if (title.contains('Biometric')) {
      return Icons.fingerprint;
    } else if (title.contains('Fortress')) {
      return Icons.security;
    } else if (title.contains('Eagle')) {
      return Icons.shield;
    }
    return Icons.military_tech;
  }
}

class SecurityFeature {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String? imagePath;

  SecurityFeature({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.imagePath,
  });
}
