import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/design_system.dart';
import '../providers/theme_provider.dart';
import '../widgets/platform_aware_widgets.dart';
import '../widgets/custom_drawer.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    return PlatformScaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: isDarkMode
            ? DesignSystem.darkAppBarColor
            : DesignSystem.lightAppBarColor,
      ),
      drawer: const CustomDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(DesignSystem.adjustedSpacingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Privacy Policy',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : DesignSystem.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Last Updated: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? Colors.white70 : DesignSystem.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Introduction
                _buildSectionTitle('1. Introduction', isDarkMode),
                _buildParagraph(
                  'The Nigerian Army is committed to protecting the privacy and security of personal information collected through the NAFacial application. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our facial recognition and personnel management system.',
                  isDarkMode,
                ),
                _buildParagraph(
                  'Please read this Privacy Policy carefully. By accessing or using the NAFacial application, you acknowledge that you have read, understood, and agree to be bound by all the terms of this Privacy Policy.',
                  isDarkMode,
                ),
                
                // Information We Collect
                _buildSectionTitle('2. Information We Collect', isDarkMode),
                _buildParagraph(
                  'We collect the following types of information:',
                  isDarkMode,
                ),
                _buildListItem(
                  'Personal Information: Name, rank, army number, date of birth, contact details, and other identifying information.',
                  isDarkMode,
                ),
                _buildListItem(
                  'Biometric Data: Facial recognition data, fingerprints, and other biometric identifiers.',
                  isDarkMode,
                ),
                _buildListItem(
                  'Service Information: Enlistment date, years of service, unit, corps, and service status.',
                  isDarkMode,
                ),
                _buildListItem(
                  'Usage Data: Information about how you use the Application, including access logs, verification attempts, and system interactions.',
                  isDarkMode,
                ),
                
                // How We Collect Information
                _buildSectionTitle('3. How We Collect Information', isDarkMode),
                _buildParagraph(
                  'We collect information through:',
                  isDarkMode,
                ),
                _buildListItem(
                  'Direct Collection: Information provided during registration and profile updates.',
                  isDarkMode,
                ),
                _buildListItem(
                  'Automated Collection: Biometric data captured through the Application\'s facial recognition and fingerprint scanning features.',
                  isDarkMode,
                ),
                _buildListItem(
                  'System Logs: Automatically generated logs of system access and usage.',
                  isDarkMode,
                ),
                
                // How We Use Information
                _buildSectionTitle('4. How We Use Information', isDarkMode),
                _buildParagraph(
                  'We use the collected information for:',
                  isDarkMode,
                ),
                _buildListItem(
                  'Personnel Verification: To verify the identity of Nigerian Army personnel.',
                  isDarkMode,
                ),
                _buildListItem(
                  'Access Control: To manage and control access to Nigerian Army facilities and systems.',
                  isDarkMode,
                ),
                _buildListItem(
                  'Personnel Management: To maintain accurate and up-to-date personnel records.',
                  isDarkMode,
                ),
                _buildListItem(
                  'Security: To enhance the security of Nigerian Army operations and facilities.',
                  isDarkMode,
                ),
                _buildListItem(
                  'System Improvement: To analyze usage patterns and improve the functionality of the Application.',
                  isDarkMode,
                ),
                
                // Data Security
                _buildSectionTitle('5. Data Security', isDarkMode),
                _buildParagraph(
                  '5.1 We implement appropriate technical and organizational measures to protect the security, confidentiality, and integrity of personal information and biometric data.',
                  isDarkMode,
                ),
                _buildParagraph(
                  '5.2 Access to personal information and biometric data is restricted to authorized personnel only, on a need-to-know basis.',
                  isDarkMode,
                ),
                _buildParagraph(
                  '5.3 All data is encrypted during transmission and storage using industry-standard encryption protocols.',
                  isDarkMode,
                ),
                
                // Data Retention
                _buildSectionTitle('6. Data Retention', isDarkMode),
                _buildParagraph(
                  '6.1 We retain personal information and biometric data for as long as necessary to fulfill the purposes for which it was collected, or as required by applicable laws and regulations.',
                  isDarkMode,
                ),
                _buildParagraph(
                  '6.2 When a personnel member is discharged, retires, or otherwise leaves the Nigerian Army, their data will be archived according to Nigerian Army data retention policies.',
                  isDarkMode,
                ),
                
                // Data Sharing
                _buildSectionTitle('7. Data Sharing', isDarkMode),
                _buildParagraph(
                  '7.1 We do not share personal information or biometric data with third parties except as necessary to fulfill the purposes for which it was collected, or as required by law.',
                  isDarkMode,
                ),
                _buildParagraph(
                  '7.2 We may share information with other Nigerian military and security agencies when necessary for national security purposes.',
                  isDarkMode,
                ),
                
                // Your Rights
                _buildSectionTitle('8. Your Rights', isDarkMode),
                _buildParagraph(
                  'As a user of the NAFacial application, you have the right to:',
                  isDarkMode,
                ),
                _buildListItem(
                  'Access your personal information and biometric data stored in the Application.',
                  isDarkMode,
                ),
                _buildListItem(
                  'Request correction of inaccurate or incomplete information.',
                  isDarkMode,
                ),
                _buildListItem(
                  'Be informed about how your data is being used.',
                  isDarkMode,
                ),
                _buildListItem(
                  'Lodge a complaint with the appropriate authority if you believe your data has been mishandled.',
                  isDarkMode,
                ),
                
                // Changes to Privacy Policy
                _buildSectionTitle('9. Changes to Privacy Policy', isDarkMode),
                _buildParagraph(
                  '9.1 We reserve the right to modify this Privacy Policy at any time without notice.',
                  isDarkMode,
                ),
                _buildParagraph(
                  '9.2 Continued use of the Application after any such changes shall constitute your consent to such changes.',
                  isDarkMode,
                ),
                
                // Contact Information
                _buildSectionTitle('10. Contact Information', isDarkMode),
                _buildParagraph(
                  'If you have any questions about this Privacy Policy, please contact:',
                  isDarkMode,
                ),
                _buildContactInfo('Data Protection Officer', isDarkMode),
                _buildContactInfo('Nigerian Army Headquarters', isDarkMode),
                _buildContactInfo('Abuja, Nigeria', isDarkMode),
                _buildContactInfo('Email: privacy@nafacial.mil.ng', isDarkMode),
                
                const SizedBox(height: 32),
                
                // Footer
                Center(
                  child: Text(
                    '© ${DateTime.now().year} Nigerian Army. All rights reserved.',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.white70 : DesignSystem.textSecondaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildSectionTitle(String title, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 16.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: isDarkMode ? DesignSystem.accentColor : DesignSystem.primaryColor,
        ),
      ),
    );
  }
  
  Widget _buildParagraph(String text, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          height: 1.5,
          color: isDarkMode ? Colors.white : DesignSystem.textPrimaryColor,
        ),
      ),
    );
  }
  
  Widget _buildListItem(String text, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? DesignSystem.accentColor : DesignSystem.primaryColor,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: isDarkMode ? Colors.white : DesignSystem.textPrimaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildContactInfo(String text, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0, left: 16.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          color: isDarkMode ? Colors.white : DesignSystem.textPrimaryColor,
        ),
      ),
    );
  }
}
