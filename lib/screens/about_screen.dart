import 'package:flutter/material.dart';
import '../config/design_system.dart';
import '../widgets/platform_aware_widgets.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: AppBar(
        title: const Text('About NAFacial'),
        backgroundColor: DesignSystem.primaryColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(DesignSystem.adjustedSpacingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: DesignSystem.primaryColor.withOpacity(0.1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Image.asset(
                      'assets/favicon/favicon-96x96.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // App Name and Version
                const Text(
                  'NAFacial',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: DesignSystem.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    fontSize: 16,
                    color: DesignSystem.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 32),
                
                // About Section
                const PlatformText(
                  'About',
                  isTitle: true,
                ),
                const SizedBox(height: 16),
                const Text(
                  'NAFacial is a facial recognition and personnel management system designed specifically for the Nigerian Army. The application provides secure biometric authentication, personnel verification, and database management capabilities.',
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 24),
                
                // Features Section
                const PlatformText(
                  'Key Features',
                  isTitle: true,
                ),
                const SizedBox(height: 16),
                _buildFeatureItem(
                  icon: Icons.face,
                  title: 'Facial Recognition',
                  description: 'Advanced biometric authentication using facial recognition technology.',
                ),
                _buildFeatureItem(
                  icon: Icons.verified_user,
                  title: 'Personnel Verification',
                  description: 'Quick and accurate verification of military personnel.',
                ),
                _buildFeatureItem(
                  icon: Icons.people,
                  title: 'Personnel Database',
                  description: 'Comprehensive database management for military personnel records.',
                ),
                _buildFeatureItem(
                  icon: Icons.security,
                  title: 'Secure Authentication',
                  description: 'Multi-factor authentication for enhanced security.',
                ),
                const SizedBox(height: 32),
                
                // Copyright and Legal
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: DesignSystem.primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: const [
                      Text(
                        '© 2023 Nigerian Army',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'All rights reserved. Unauthorized use, reproduction, or distribution of this application or its contents is strictly prohibited.',
                        style: TextStyle(
                          fontSize: 12,
                          color: DesignSystem.textSecondaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: DesignSystem.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: DesignSystem.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: DesignSystem.textSecondaryColor,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
