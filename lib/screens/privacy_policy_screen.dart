import 'package:flutter/material.dart';
import '../config/design_system.dart';
import '../widgets/platform_aware_widgets.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: DesignSystem.primaryColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(DesignSystem.adjustedSpacingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Center(
                  child: Text(
                    'Privacy Policy',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: DesignSystem.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Last Updated: ${_getFormattedDate()}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: DesignSystem.textSecondaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Introduction
                _buildSection(
                  title: '1. Introduction',
                  content:
                      'The Nigerian Army ("we," "our," or "us") is committed to protecting the privacy and security of your personal information. This Privacy Policy describes how we collect, use, and disclose your personal information when you use our NAFacial application ("the Application").',
                ),

                // Information We Collect
                _buildSection(
                  title: '2. Information We Collect',
                  content:
                      'We collect several types of information from and about users of our Application, including:\n\n• Personal Information: Name, rank, army number, unit, and other identifying information.\n\n• Biometric Data: Facial recognition data and related biometric identifiers.\n\n• Usage Data: Information about how you use the Application, including login times, features used, and system performance metrics.\n\n• Device Information: Information about the device you use to access the Application, including device type, operating system, and unique device identifiers.',
                ),

                // How We Collect Information
                _buildSection(
                  title: '3. How We Collect Information',
                  content:
                      'We collect information:\n\n• Directly from you when you provide it to us during registration or use of the Application.\n\n• Automatically as you navigate through and use the Application.\n\n• From third-party sources, such as official Nigerian Army personnel databases.',
                ),

                // How We Use Your Information
                _buildSection(
                  title: '4. How We Use Your Information',
                  content:
                      'We use the information we collect about you or that you provide to us:\n\n• To provide, maintain, and improve the Application.\n\n• To verify your identity and authenticate your access to the Application.\n\n• To fulfill the purposes for which you provided the information.\n\n• To carry out our obligations and enforce our rights.\n\n• For security and safety purposes, including preventing unauthorized access.\n\n• For research and analytics to improve the Application and user experience.',
                ),

                // Disclosure of Your Information
                _buildSection(
                  title: '5. Disclosure of Your Information',
                  content:
                      'We may disclose personal information that we collect or you provide:\n\n• To authorized Nigerian Army personnel who need access to the information for official purposes.\n\n• To contractors, service providers, and other third parties we use to support our operations.\n\n• To comply with any court order, law, or legal process.\n\n• To enforce our Terms and Conditions.\n\n• If we believe disclosure is necessary to protect the rights, property, or safety of the Nigerian Army, our personnel, or others.',
                ),

                // Data Security
                _buildSection(
                  title: '6. Data Security',
                  content:
                      'We have implemented measures designed to secure your personal information from accidental loss and from unauthorized access, use, alteration, and disclosure. All information you provide to us is stored on secure servers behind firewalls. Biometric data is encrypted using industry-standard encryption technologies.',
                ),

                // Data Retention
                _buildSection(
                  title: '7. Data Retention',
                  content:
                      'We will retain your personal information for as long as necessary to fulfill the purposes for which we collected it, including for the purposes of satisfying any legal, accounting, or reporting requirements.',
                ),

                // Your Rights
                _buildSection(
                  title: '8. Your Rights',
                  content:
                      'You have the right to:\n\n• Access the personal information we hold about you.\n\n• Request correction of your personal information.\n\n• Request deletion of your personal information, subject to certain exceptions related to national security and legal obligations.\n\n• Object to processing of your personal information.\n\n• Request restriction of processing of your personal information.',
                ),

                // Changes to Our Privacy Policy
                _buildSection(
                  title: '9. Changes to Our Privacy Policy',
                  content:
                      'We may update our Privacy Policy from time to time. If we make material changes, we will notify you through the Application or by other means. Your continued use of the Application after we make changes is deemed to be acceptance of those changes.',
                ),

                // Contact Information
                _buildSection(
                  title: '10. Contact Information',
                  content:
                      'To ask questions or comment about this Privacy Policy and our privacy practices, contact us at offrmbabubakar@gmail.com.',
                ),

                // Footer
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: DesignSystem.primaryColor.withAlpha(15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'By using the NAFacial application, you consent to our collection, use, and disclosure of your information as described in this Privacy Policy.',
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: DesignSystem.textSecondaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                const SizedBox(height: 40),
                // Copyright footer
                Center(
                  child: Column(
                    children: [
                      Text(
                        '© ${DateTime.now().year} Nigerian Army',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
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

  Widget _buildSection({
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: DesignSystem.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: DesignSystem.textPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }
}
