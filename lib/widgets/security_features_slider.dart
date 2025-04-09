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
      title: 'Advanced Facial Recognition',
      description:
          'AI-powered facial recognition with 99.8% accuracy and liveness detection to prevent spoofing attacks.',
      icon: Icons.face_retouching_natural,
      color: Colors.blue,
    ),
    SecurityFeature(
      title: 'Neural Network Analysis',
      description:
          'Deep learning algorithms analyze facial features in real-time to detect anomalies and unauthorized access attempts.',
      icon: Icons.psychology,
      color: Colors.purple,
    ),
    SecurityFeature(
      title: 'Biometric Authentication',
      description:
          'Multi-factor biometric verification using facial geometry, iris patterns, and behavioral analysis.',
      icon: Icons.fingerprint,
      color: Colors.green,
    ),
    SecurityFeature(
      title: 'Encrypted Data Storage',
      description:
          'Military-grade encryption for all biometric data with decentralized storage to prevent unauthorized access.',
      icon: Icons.security,
      color: Colors.red,
    ),
    SecurityFeature(
      title: 'Threat Intelligence',
      description:
          'Real-time monitoring and alerts for suspicious activities with AI-powered threat detection.',
      icon: Icons.shield,
      color: Colors.orange,
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
            feature.color.withOpacity(isDarkMode ? 0.2 : 0.1),
            feature.color.withOpacity(isDarkMode ? 0.1 : 0.05),
          ],
        ),
        border: Border.all(
          color: feature.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: feature.color.withOpacity(isDarkMode ? 0.3 : 0.2),
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
            const SizedBox(height: 16),
            Expanded(
              child: Text(
                feature.description,
                style: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                  color: isDarkMode
                      ? Colors.white.withOpacity(0.8)
                      : Colors.black.withOpacity(0.7),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: feature.color.withOpacity(isDarkMode ? 0.3 : 0.2),
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
                ? Colors.white.withOpacity(0.3)
                : Colors.grey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class SecurityFeature {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  SecurityFeature({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
