import 'package:flutter/material.dart';
import '../config/design_system.dart';
import '../providers/theme_provider.dart';
import 'package:provider/provider.dart';
import '../widgets/app_bar_with_back_button.dart';

class AppRoadmapScreen extends StatelessWidget {
  const AppRoadmapScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBarWithBackButton(
        title: 'App Roadmap',
        backgroundColor: isDarkMode ? DesignSystem.darkCardColor : Colors.white,
        foregroundColor:
            isDarkMode ? Colors.white : DesignSystem.lightTextPrimaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('NAFacial App Structure', isDarkMode),
            const SizedBox(height: 16),
            _buildAppTree(context, isDarkMode),
            const SizedBox(height: 32),
            _buildSectionTitle('Upcoming Features', isDarkMode),
            const SizedBox(height: 16),
            _buildUpcomingFeatures(isDarkMode),
            const SizedBox(height: 32),
            _buildSectionTitle('Recent Updates', isDarkMode),
            const SizedBox(height: 16),
            _buildRecentUpdates(isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDarkMode) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: isDarkMode ? Colors.white : DesignSystem.lightTextPrimaryColor,
      ),
    );
  }

  Widget _buildAppTree(BuildContext context, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? DesignSystem.darkCardColor : Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTreeNode(
              'Authentication',
              [
                'Login',
                'Registration',
                'Biometric Authentication',
              ],
              isDarkMode),
          const SizedBox(height: 16),
          _buildTreeNode(
              'Personnel Management',
              [
                'Personnel Database',
                'Personnel Registration',
                'ID Management',
                'Rank Management',
              ],
              isDarkMode),
          const SizedBox(height: 16),
          _buildTreeNode(
              'Facial Recognition',
              [
                'Facial Verification',
                'Live Recognition',
                'Gallery',
              ],
              isDarkMode),
          const SizedBox(height: 16),
          _buildTreeNode(
              'Access Control',
              [
                'Access Logs',
                'Access Control Settings',
                'Permissions Management',
              ],
              isDarkMode),
          const SizedBox(height: 16),
          _buildTreeNode(
              'Analytics',
              [
                'Statistics',
                'Activity Summary',
                'Reports',
              ],
              isDarkMode),
          const SizedBox(height: 16),
          _buildTreeNode(
              'System',
              [
                'Settings',
                'Notifications',
                'Updates',
              ],
              isDarkMode),
          const SizedBox(height: 16),
          _buildTreeNode(
              'Information',
              [
                'About',
                'Contact',
                'Terms & Conditions',
                'Privacy Policy',
              ],
              isDarkMode),
        ],
      ),
    );
  }

  Widget _buildTreeNode(String title, List<String> children, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.folder,
              color: DesignSystem.primaryColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDarkMode
                    ? Colors.white
                    : DesignSystem.lightTextPrimaryColor,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children
                .map((child) => Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.insert_drive_file,
                            color: DesignSystem.accentColor,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            child,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDarkMode
                                  ? Colors.white70
                                  : DesignSystem.lightTextSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingFeatures(bool isDarkMode) {
    final features = [
      {
        'title': 'Enhanced Biometric Integration',
        'description':
            'Support for more biometric devices and improved accuracy',
        'eta': 'Q3 2023',
      },
      {
        'title': 'Advanced Analytics Dashboard',
        'description':
            'Comprehensive analytics with visual reports and insights',
        'eta': 'Q4 2023',
      },
      {
        'title': 'Mobile App Enhancements',
        'description': 'Improved UI/UX and performance optimizations',
        'eta': 'Ongoing',
      },
      {
        'title': 'AI-Powered Threat Detection',
        'description':
            'Advanced security features using artificial intelligence',
        'eta': 'Q1 2024',
      },
    ];

    return Column(
      children: features
          .map((feature) => _buildFeatureCard(
                feature['title']!,
                feature['description']!,
                feature['eta']!,
                isDarkMode,
              ))
          .toList(),
    );
  }

  Widget _buildFeatureCard(
      String title, String description, String eta, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? DesignSystem.darkCardColor : Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: DesignSystem.primaryColor.withAlpha(50),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.upcoming,
              color: DesignSystem.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode
                        ? Colors.white
                        : DesignSystem.lightTextPrimaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode
                        ? Colors.white70
                        : DesignSystem.lightTextSecondaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: isDarkMode ? Colors.white54 : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'ETA: $eta',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode ? Colors.white54 : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentUpdates(bool isDarkMode) {
    final updates = [
      {
        'version': '1.2.0',
        'date': 'June 15, 2023',
        'changes': [
          'Added biometric login support',
          'Fixed personnel database issues',
          'Improved facial recognition accuracy',
          'Added notification system',
        ],
      },
      {
        'version': '1.1.0',
        'date': 'May 1, 2023',
        'changes': [
          'Added dark mode support',
          'Improved UI responsiveness',
          'Fixed camera issues on multiple platforms',
          'Added gallery feature',
        ],
      },
    ];

    return Column(
      children: updates
          .map((update) => _buildUpdateCard(
                update['version']! as String,
                update['date']! as String,
                update['changes'] as List<dynamic>,
                isDarkMode,
              ))
          .toList(),
    );
  }

  Widget _buildUpdateCard(
      String version, String date, List<dynamic> changes, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? DesignSystem.darkCardColor : Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: DesignSystem.accentColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  version,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                date,
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? Colors.white54 : Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...changes
              .map((change) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '• ',
                          style: TextStyle(
                            color: DesignSystem.accentColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            change,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDarkMode
                                  ? Colors.white70
                                  : DesignSystem.lightTextSecondaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }
}
