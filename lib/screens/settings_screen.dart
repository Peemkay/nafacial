import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/design_system.dart';
import '../providers/theme_provider.dart';
import '../providers/quick_actions_provider.dart';
import '../providers/version_provider.dart';
import '../services/button_service.dart';
import '../widgets/platform_aware_widgets.dart';
import 'profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isHardwareButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadHardwareButtonPreference();
  }

  Future<void> _loadHardwareButtonPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isHardwareButtonEnabled =
          prefs.getBool('hardware_button_enabled') ?? false;
    });
  }

  Future<void> _setHardwareButtonPreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hardware_button_enabled', value);

    if (value) {
      await ButtonService.startButtonService();
    } else {
      await ButtonService.stopButtonService();
    }

    setState(() {
      _isHardwareButtonEnabled = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    final isDarkMode = themeProvider.isDarkMode;

    return PlatformScaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: isDarkMode
            ? DesignSystem.darkAppBarColor
            : DesignSystem.lightAppBarColor,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Appearance section
            _buildSectionHeader(context, 'Appearance'),
            Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                children: [
                  // Theme mode
                  ListTile(
                    leading: Icon(
                      themeProvider.isDarkMode
                          ? Icons.dark_mode
                          : Icons.light_mode,
                      color: themeProvider.isDarkMode
                          ? DesignSystem.darkIconColor
                          : DesignSystem.lightIconColor,
                    ),
                    title: const Text('Theme Mode'),
                    subtitle: Text(
                        themeProvider.isDarkMode ? 'Dark Mode' : 'Light Mode'),
                    trailing: Switch(
                      value: themeProvider.isDarkMode,
                      onChanged: (value) {
                        themeProvider.toggleTheme();
                      },
                      activeColor: themeProvider.isDarkMode
                          ? DesignSystem.darkSecondaryColor
                          : DesignSystem.lightPrimaryColor,
                    ),
                  ),
                  const Divider(),
                  // Theme selection
                  ListTile(
                    leading: Icon(
                      Icons.palette,
                      color: themeProvider.isDarkMode
                          ? DesignSystem.darkIconColor
                          : DesignSystem.lightIconColor,
                    ),
                    title: const Text('Select Theme'),
                    onTap: () => _showThemeSelectionDialog(context),
                  ),
                ],
              ),
            ),

            // Account section
            _buildSectionHeader(context, 'Account'),
            Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.person,
                      color: isDarkMode
                          ? DesignSystem.darkIconColor
                          : DesignSystem.lightIconColor,
                    ),
                    title: const Text('Profile'),
                    subtitle: const Text('Manage your profile information'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(
                      Icons.security,
                      color: isDarkMode
                          ? DesignSystem.darkIconColor
                          : DesignSystem.lightIconColor,
                    ),
                    title: const Text('Security'),
                    subtitle:
                        const Text('Change password and security settings'),
                    onTap: () {
                      // Show not implemented yet message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Security settings coming soon'),
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(
                      Icons.fingerprint,
                      color: isDarkMode
                          ? DesignSystem.darkIconColor
                          : DesignSystem.lightIconColor,
                    ),
                    title: const Text('Biometric Management'),
                    subtitle: const Text(
                        'Manage biometric devices and authentication'),
                    onTap: () {
                      Navigator.pushNamed(context, '/biometric_management');
                    },
                  ),
                ],
              ),
            ),

            // Quick Actions section
            _buildSectionHeader(context, 'Quick Actions'),
            Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                children: [
                  // Hardware button quick launch
                  ListTile(
                    leading: Icon(
                      Icons.touch_app,
                      color: isDarkMode
                          ? DesignSystem.darkIconColor
                          : DesignSystem.lightIconColor,
                    ),
                    title: const Text('Hardware Button Camera Launch'),
                    subtitle: const Text(
                        'Double-press volume down button to launch camera'),
                    trailing: Switch(
                      value: _isHardwareButtonEnabled,
                      onChanged: (value) {
                        _setHardwareButtonPreference(value);
                      },
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(
                      Icons.dashboard_customize,
                      color: isDarkMode
                          ? DesignSystem.darkIconColor
                          : DesignSystem.lightIconColor,
                    ),
                    title: const Text('Customize Quick Actions'),
                    subtitle: const Text(
                        'Choose which actions appear on the home screen'),
                    onTap: () {
                      _showQuickActionsSettingsDialog(context);
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(
                      Icons.restore,
                      color: isDarkMode
                          ? DesignSystem.darkIconColor
                          : DesignSystem.lightIconColor,
                    ),
                    title: const Text('Reset to Defaults'),
                    subtitle: const Text('Restore default quick actions'),
                    onTap: () {
                      _showResetQuickActionsDialog(context);
                    },
                  ),
                ],
              ),
            ),

            // App section
            _buildSectionHeader(context, 'App'),
            Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                children: [
                  Consumer<VersionProvider>(
                    builder: (context, versionProvider, _) => ListTile(
                      leading: Icon(
                        Icons.system_update,
                        color: isDarkMode
                            ? DesignSystem.darkIconColor
                            : DesignSystem.lightIconColor,
                      ),
                      title: const Text('Check for Updates'),
                      subtitle: Text(
                        versionProvider.updateAvailable
                            ? 'New version ${versionProvider.latestVersion} available'
                            : 'Current version: ${versionProvider.currentVersion}',
                      ),
                      trailing: versionProvider.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    DesignSystem.primaryColor),
                              ),
                            )
                          : versionProvider.updateAvailable
                              ? const Icon(
                                  Icons.download,
                                  color: Colors.green,
                                )
                              : const Icon(Icons.check_circle_outline),
                      onTap: () async {
                        if (versionProvider.isLoading) return;

                        if (versionProvider.updateAvailable) {
                          // Show update dialog
                          _showUpdateDialog(context, versionProvider);
                        } else {
                          // Check for updates
                          final hasUpdate =
                              await versionProvider.checkForUpdates();
                          if (!hasUpdate && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('You have the latest version'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(
                      Icons.info_outline,
                      color: isDarkMode
                          ? DesignSystem.darkIconColor
                          : DesignSystem.lightIconColor,
                    ),
                    title: const Text('About'),
                    subtitle: const Text('App information and version'),
                    onTap: () {
                      // Show about dialog
                      _showAboutDialog(context);
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(
                      Icons.privacy_tip_outlined,
                      color: isDarkMode
                          ? DesignSystem.darkIconColor
                          : DesignSystem.lightIconColor,
                    ),
                    title: const Text('Privacy Policy'),
                    onTap: () {
                      // Navigate to privacy policy screen
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(
                      Icons.description_outlined,
                      color: isDarkMode
                          ? DesignSystem.darkIconColor
                          : DesignSystem.lightIconColor,
                    ),
                    title: const Text('Terms & Conditions'),
                    onTap: () {
                      // Navigate to terms and conditions screen
                    },
                  ),
                ],
              ),
            ),

            // Logout button
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: PlatformButton(
                text: 'LOGOUT',
                onPressed: () {
                  // Show logout confirmation dialog
                  _showLogoutConfirmationDialog(context);
                },
                icon: Icons.logout,
                buttonType: PlatformButtonType.danger,
                isFullWidth: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) => Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: themeProvider.isDarkMode
                ? DesignSystem.darkSecondaryColor
                : DesignSystem.lightPrimaryColor,
          ),
        ),
      ),
    );
  }

  void _showThemeSelectionDialog(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.light_mode),
              title: const Text('Light Mode'),
              selected: !themeProvider.isDarkMode,
              onTap: () {
                themeProvider.setTheme(ThemeMode.light);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Dark Mode'),
              selected: themeProvider.isDarkMode,
              onTap: () {
                themeProvider.setTheme(ThemeMode.dark);
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    final versionProvider =
        Provider.of<VersionProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AboutDialog(
        applicationName: 'NAFacial',
        applicationVersion: versionProvider.currentVersion,
        applicationIcon: Image.asset(
          'assets/images/logo.png',
          width: 48,
          height: 48,
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.face,
            size: 48,
            color: DesignSystem.primaryColor,
          ),
        ),
        applicationLegalese: '© 2025 Nigerian Army. All rights reserved.',
        children: const [
          SizedBox(height: 16),
          Text(
            'NAFacial is a facial recognition application for the Nigerian Army personnel identification and verification.',
            style: TextStyle(fontSize: 12),
          ),
          SizedBox(height: 8),
          Text(
            'Contact: offrmbabubakar@gmail.com',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  // Show update dialog
  void _showUpdateDialog(
      BuildContext context, VersionProvider versionProvider) {
    showDialog(
      context: context,
      builder: (context) => PopScope(
        canPop: !versionProvider.isDownloading,
        child: AlertDialog(
          title: const Text('Update Available'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!versionProvider.hasInternetConnection) ...[
                      const Row(
                        children: [
                          Icon(Icons.signal_wifi_off, color: Colors.red),
                          SizedBox(width: 8),
                          Text(
                            'No internet connection',
                            style: TextStyle(
                                color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                    Text(
                      'A new version (${versionProvider.latestVersion}) is available.',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text('Current version: ${versionProvider.currentVersion}'),
                    if (versionProvider.updateDate != null) ...[
                      const SizedBox(height: 4),
                      Text('Release date: ${versionProvider.updateDate}'),
                    ],
                    if (versionProvider.updateSize != null) ...[
                      const SizedBox(height: 4),
                      Text('Size: ${versionProvider.updateSize}'),
                    ],
                    const SizedBox(height: 16),
                    if (versionProvider.updateNotes != null) ...[
                      const Text(
                        'What\'s new:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(versionProvider.updateNotes!),
                      ),
                    ],
                    if (versionProvider.isDownloading) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Downloading update...',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: versionProvider.downloadProgress,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            DesignSystem.primaryColor),
                      ),
                      const SizedBox(height: 4),
                      Text(
                          '${(versionProvider.downloadProgress * 100).toStringAsFixed(0)}%'),
                    ],
                  ],
                ),
              );
            },
          ),
          actions: [
            if (!versionProvider.isDownloading) ...[
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('LATER'),
              ),
              ElevatedButton(
                onPressed: versionProvider.hasInternetConnection
                    ? () async {
                        // Start download
                        final success =
                            await versionProvider.downloadAndInstallUpdate();

                        if (success && context.mounted) {
                          Navigator.pop(context);

                          // Show success dialog
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Update Downloaded'),
                              content: const Text(
                                  'The update has been downloaded successfully. Install now?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('LATER'),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    Navigator.pop(context);

                                    // Launch URL if available
                                    if (versionProvider.updateUrl != null) {
                                      try {
                                        final Uri url = Uri.parse(
                                            versionProvider.updateUrl!);
                                        await launchUrl(url,
                                            mode:
                                                LaunchMode.externalApplication);
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Error launching update URL: $e'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: DesignSystem.primaryColor,
                                  ),
                                  child: const Text('INSTALL NOW'),
                                ),
                              ],
                            ),
                          );
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignSystem.primaryColor,
                  disabledBackgroundColor: Colors.grey,
                ),
                child: const Text('UPDATE NOW'),
              ),
            ] else ...[
              TextButton(
                onPressed: () {
                  versionProvider.cancelDownload();
                },
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('MINIMIZE'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              // Perform logout
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('LOGOUT'),
          ),
        ],
      ),
    );
  }

  void _showQuickActionsSettingsDialog(BuildContext context) {
    final quickActionsProvider =
        Provider.of<QuickActionsProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Customize Quick Actions'),
        content: SizedBox(
          width: double.maxFinite,
          child: Consumer<QuickActionsProvider>(
            builder: (context, provider, _) => ListView.builder(
              shrinkWrap: true,
              itemCount: provider.quickActions.length,
              itemBuilder: (context, index) {
                final action = provider.quickActions[index];
                return CheckboxListTile(
                  title: Text(action.title),
                  secondary: Icon(action.icon, color: action.color),
                  value: action.isVisible,
                  onChanged: (value) {
                    if (value != null) {
                      provider.setActionVisibility(action.id, value);
                    }
                  },
                );
              },
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }

  void _showResetQuickActionsDialog(BuildContext context) {
    final quickActionsProvider =
        Provider.of<QuickActionsProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Quick Actions'),
        content: const Text(
            'This will restore all quick actions to their default visibility. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              quickActionsProvider.resetToDefaults();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Quick actions reset to defaults'),
                  backgroundColor: DesignSystem.primaryColor,
                ),
              );
            },
            child: const Text('RESET'),
          ),
        ],
      ),
    );
  }
}
