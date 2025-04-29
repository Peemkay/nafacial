import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/design_system.dart';
import '../providers/theme_provider.dart';
import '../widgets/platform_aware_widgets.dart';
import '../widgets/custom_drawer.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    return PlatformScaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
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
                  'Terms of Service',
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
                  'Welcome to NAFacial, a facial recognition and personnel management system designed for the Nigerian Army. By accessing or using the NAFacial application, you agree to be bound by these Terms of Service.',
                  isDarkMode,
                ),
                _buildParagraph(
                  'Please read these Terms carefully. If you do not agree with any part of these Terms, you must not use the NAFacial application.',
                  isDarkMode,
                ),
                
                // Definitions
                _buildSectionTitle('2. Definitions', isDarkMode),
                _buildDefinitionItem(
                  '"Application"',
                  'refers to the NAFacial software application.',
                  isDarkMode,
                ),
                _buildDefinitionItem(
                  '"User"',
                  'refers to any individual who has been granted access to use the Application.',
                  isDarkMode,
                ),
                _buildDefinitionItem(
                  '"Nigerian Army"',
                  'refers to the land branch of the Nigerian Armed Forces.',
                  isDarkMode,
                ),
                _buildDefinitionItem(
                  '"Biometric Data"',
                  'refers to facial recognition data and other biometric identifiers collected by the Application.',
                  isDarkMode,
                ),
                
                // Access and Use
                _buildSectionTitle('3. Access and Use', isDarkMode),
                _buildParagraph(
                  '3.1 The Application is intended for use by authorized personnel of the Nigerian Army only.',
                  isDarkMode,
                ),
                _buildParagraph(
                  '3.2 Users must maintain the confidentiality of their login credentials and are responsible for all activities that occur under their account.',
                  isDarkMode,
                ),
                _buildParagraph(
                  '3.3 Users must not attempt to gain unauthorized access to any part of the Application or any system or network connected to the Application.',
                  isDarkMode,
                ),
                _buildParagraph(
                  '3.4 The Nigerian Army reserves the right to revoke access to the Application at any time without notice.',
                  isDarkMode,
                ),
                
                // Data Collection and Privacy
                _buildSectionTitle('4. Data Collection and Privacy', isDarkMode),
                _buildParagraph(
                  '4.1 The Application collects and processes Biometric Data and personal information of Nigerian Army personnel.',
                  isDarkMode,
                ),
                _buildParagraph(
                  '4.2 All data collected by the Application is subject to the Nigerian Army\'s data protection policies and relevant Nigerian laws governing data protection.',
                  isDarkMode,
                ),
                _buildParagraph(
                  '4.3 The Nigerian Army will take reasonable measures to protect the data collected by the Application from unauthorized access or disclosure.',
                  isDarkMode,
                ),
                
                // Intellectual Property
                _buildSectionTitle('5. Intellectual Property', isDarkMode),
                _buildParagraph(
                  '5.1 The Application and all of its content, features, and functionality are owned by the Nigerian Army and are protected by Nigerian and international copyright, trademark, patent, trade secret, and other intellectual property or proprietary rights laws.',
                  isDarkMode,
                ),
                _buildParagraph(
                  '5.2 Users are not granted any right or license to use any intellectual property of the Nigerian Army except as expressly provided in these Terms.',
                  isDarkMode,
                ),
                
                // Limitation of Liability
                _buildSectionTitle('6. Limitation of Liability', isDarkMode),
                _buildParagraph(
                  '6.1 The Nigerian Army shall not be liable for any indirect, incidental, special, consequential, or punitive damages, including but not limited to, damages for loss of profits, goodwill, use, data, or other intangible losses, resulting from the use of or inability to use the Application.',
                  isDarkMode,
                ),
                _buildParagraph(
                  '6.2 The Nigerian Army shall not be liable for any damage, loss, or injury resulting from hacking, tampering, or other unauthorized access or use of the Application or the information contained therein.',
                  isDarkMode,
                ),
                
                // Changes to Terms
                _buildSectionTitle('7. Changes to Terms', isDarkMode),
                _buildParagraph(
                  '7.1 The Nigerian Army reserves the right to modify or replace these Terms at any time without notice.',
                  isDarkMode,
                ),
                _buildParagraph(
                  '7.2 Continued use of the Application after any such changes shall constitute your consent to such changes.',
                  isDarkMode,
                ),
                
                // Governing Law
                _buildSectionTitle('8. Governing Law', isDarkMode),
                _buildParagraph(
                  '8.1 These Terms shall be governed by and construed in accordance with the laws of the Federal Republic of Nigeria.',
                  isDarkMode,
                ),
                _buildParagraph(
                  '8.2 Any dispute arising out of or in connection with these Terms shall be subject to the exclusive jurisdiction of the courts of Nigeria.',
                  isDarkMode,
                ),
                
                // Contact Information
                _buildSectionTitle('9. Contact Information', isDarkMode),
                _buildParagraph(
                  'If you have any questions about these Terms, please contact:',
                  isDarkMode,
                ),
                _buildContactInfo('Nigerian Army Headquarters', isDarkMode),
                _buildContactInfo('Abuja, Nigeria', isDarkMode),
                _buildContactInfo('Email: legal@nafacial.mil.ng', isDarkMode),
                
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
  
  Widget _buildDefinitionItem(String term, String definition, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: 16,
            height: 1.5,
            color: isDarkMode ? Colors.white : DesignSystem.textPrimaryColor,
          ),
          children: [
            TextSpan(
              text: '$term: ',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(text: definition),
          ],
        ),
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
