import 'package:flutter/material.dart';
import '../config/design_system.dart';
import '../widgets/platform_aware_widgets.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
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
                    'Terms and Conditions',
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
                  content: 'These Terms and Conditions govern your use of the NAFacial application ("the Application") provided by the Nigerian Army. By accessing or using the Application, you agree to be bound by these Terms and Conditions. If you disagree with any part of these terms, you may not access or use the Application.',
                ),
                
                // Definitions
                _buildSection(
                  title: '2. Definitions',
                  content: '"Application" refers to the NAFacial software.\n\n"User" refers to the person or entity that has been authorized to access and use the Application.\n\n"Nigerian Army" refers to the owner and provider of the Application.',
                ),
                
                // License
                _buildSection(
                  title: '3. License',
                  content: 'The Nigerian Army grants you a limited, non-transferable, non-exclusive license to use the Application solely for official Nigerian Army purposes. This license does not allow you to:\n\n• Modify, adapt, or hack the Application\n• Copy, duplicate, or reproduce the Application\n• Sell, resell, or exploit the Application\n• Use the Application for any unauthorized or illegal purpose',
                ),
                
                // User Obligations
                _buildSection(
                  title: '4. User Obligations',
                  content: 'As a user of the Application, you agree to:\n\n• Maintain the confidentiality of your account credentials\n• Use the Application only for its intended purpose\n• Comply with all applicable laws and regulations\n• Report any security vulnerabilities or breaches immediately\n• Not attempt to gain unauthorized access to any part of the Application',
                ),
                
                // Data Privacy
                _buildSection(
                  title: '5. Data Privacy',
                  content: 'The Application collects and processes personal data, including biometric data, in accordance with our Privacy Policy. By using the Application, you consent to such processing and warrant that all data provided by you is accurate and complete.',
                ),
                
                // Intellectual Property
                _buildSection(
                  title: '6. Intellectual Property',
                  content: 'The Application and its original content, features, and functionality are owned by the Nigerian Army and are protected by international copyright, trademark, patent, trade secret, and other intellectual property laws.',
                ),
                
                // Disclaimer
                _buildSection(
                  title: '7. Disclaimer',
                  content: 'The Application is provided "as is" and "as available" without any warranties of any kind, either express or implied. The Nigerian Army does not warrant that the Application will be uninterrupted, timely, secure, or error-free.',
                ),
                
                // Limitation of Liability
                _buildSection(
                  title: '8. Limitation of Liability',
                  content: 'In no event shall the Nigerian Army be liable for any indirect, incidental, special, consequential, or punitive damages, including without limitation, loss of profits, data, use, goodwill, or other intangible losses, resulting from your access to or use of or inability to access or use the Application.',
                ),
                
                // Termination
                _buildSection(
                  title: '9. Termination',
                  content: 'The Nigerian Army may terminate or suspend your access to the Application immediately, without prior notice or liability, for any reason whatsoever, including without limitation if you breach these Terms and Conditions.',
                ),
                
                // Changes to Terms
                _buildSection(
                  title: '10. Changes to Terms',
                  content: 'The Nigerian Army reserves the right to modify or replace these Terms and Conditions at any time. It is your responsibility to check these Terms and Conditions periodically for changes.',
                ),
                
                // Governing Law
                _buildSection(
                  title: '11. Governing Law',
                  content: 'These Terms and Conditions shall be governed and construed in accordance with the laws of the Federal Republic of Nigeria, without regard to its conflict of law provisions.',
                ),
                
                // Contact Information
                _buildSection(
                  title: '12. Contact Information',
                  content: 'For any questions about these Terms and Conditions, please contact us at offrmbabubakar@gmail.com.',
                ),
                
                // Footer
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: DesignSystem.primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'By using the NAFacial application, you acknowledge that you have read, understood, and agree to be bound by these Terms and Conditions.',
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: DesignSystem.textSecondaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
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
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }
}
