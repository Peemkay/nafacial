import 'package:flutter/material.dart';
import '../config/design_system.dart';

class EnhancedSecurityFeaturesSlider extends StatefulWidget {
  const EnhancedSecurityFeaturesSlider({Key? key}) : super(key: key);

  @override
  State<EnhancedSecurityFeaturesSlider> createState() => _EnhancedSecurityFeaturesSliderState();
}

class _EnhancedSecurityFeaturesSliderState extends State<EnhancedSecurityFeaturesSlider> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _features = [
    {
      'title': 'Facial Recognition',
      'description': 'Advanced facial recognition for secure personnel identification',
      'icon': Icons.face,
    },
    {
      'title': 'Multi-factor Authentication',
      'description': 'Enhanced security with multiple verification methods',
      'icon': Icons.security,
    },
    {
      'title': 'Real-time Monitoring',
      'description': 'Monitor access and security events in real-time',
      'icon': Icons.monitor,
    },
    {
      'title': 'Secure Database',
      'description': 'Encrypted database for personnel information',
      'icon': Icons.storage,
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _features.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return _buildFeatureCard(_features[index], isDarkMode);
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _features.length,
            (index) => _buildDotIndicator(index, isDarkMode),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard(Map<String, dynamic> feature, bool isDarkMode) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              feature['icon'],
              size: 48,
              color: DesignSystem.primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              feature['title'],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              feature['description'],
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDarkMode 
                    ? Colors.white.withValues(alpha: 178) 
                    : Colors.black.withValues(alpha: 178),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDotIndicator(int index, bool isDarkMode) {
    return Container(
      width: 8,
      height: 8,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _currentPage == index
            ? DesignSystem.primaryColor
            : (isDarkMode 
                ? Colors.white.withValues(alpha: 102) 
                : Colors.black.withValues(alpha: 102)),
      ),
    );
  }
}
