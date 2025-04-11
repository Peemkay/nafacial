import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/design_system.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../widgets/platform_aware_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _fullNameController;
  late TextEditingController _usernameController;
  late TextEditingController _rankController;
  late TextEditingController _departmentController;
  late TextEditingController _armyNumberController;

  bool _isEditing = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _usernameController = TextEditingController();
    _rankController = TextEditingController();
    _departmentController = TextEditingController();
    _armyNumberController = TextEditingController();

    // Load user data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _rankController.dispose();
    _departmentController.dispose();
    _armyNumberController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = await authProvider.getCurrentUser();

    if (user != null) {
      setState(() {
        _fullNameController.text = user.fullName;
        _usernameController.text = user.username;
        _rankController.text = user.rank;
        _departmentController.text = user.department;
        _armyNumberController.text = user.armyNumber ?? '';
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = await authProvider.getCurrentUser();

      if (currentUser != null) {
        // Create updated user
        final updatedUser = currentUser.copyWith(
          fullName: _fullNameController.text.trim(),
          rank: _rankController.text.trim(),
          department: _departmentController.text.trim(),
        );

        // Update user
        final success = await authProvider.updateUserProfile(updatedUser);

        if (success && mounted) {
          setState(() {
            _isEditing = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          setState(() {
            _errorMessage = 'Failed to update profile';
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return PlatformScaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: isDarkMode
            ? DesignSystem.darkAppBarColor
            : DesignSystem.lightAppBarColor,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
              tooltip: 'Edit Profile',
            )
          else
            IconButton(
              icon: const Icon(Icons.cancel),
              onPressed: () {
                setState(() {
                  _isEditing = false;
                  _loadUserData(); // Reload original data
                });
              },
              tooltip: 'Cancel',
            ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final user = authProvider.currentUser;

          if (user == null) {
            return const Center(
              child: Text('User not found'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile header
                  Center(
                    child: Column(
                      children: [
                        // Profile avatar
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: isDarkMode
                              ? DesignSystem.darkPrimaryColor
                              : DesignSystem.lightPrimaryColor,
                          child: Text(
                            user.fullName.isNotEmpty
                                ? user.fullName[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              fontSize: 40,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // User name with rank and initials
                        Text(
                          '${user.rank} ${user.initials}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Full name and role
                        Text(
                          '${user.fullName} - ${user.isAdmin ? 'Administrator' : 'User'}',
                          style: TextStyle(
                            fontSize: 16,
                            color: isDarkMode
                                ? DesignSystem.darkTextSecondaryColor
                                : DesignSystem.lightTextSecondaryColor,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),

                  // Error message
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Profile form
                  Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Personal Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Full Name
                          TextFormField(
                            controller: _fullNameController,
                            decoration: const InputDecoration(
                              labelText: 'Full Name',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person),
                            ),
                            enabled: _isEditing,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your full name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Username
                          TextFormField(
                            controller: _usernameController,
                            decoration: const InputDecoration(
                              labelText: 'Username',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.account_circle),
                            ),
                            enabled: false, // Username cannot be changed
                          ),
                          const SizedBox(height: 16),

                          // Rank
                          TextFormField(
                            controller: _rankController,
                            decoration: const InputDecoration(
                              labelText: 'Rank',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.military_tech),
                            ),
                            enabled: _isEditing,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your rank';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Department
                          TextFormField(
                            controller: _departmentController,
                            decoration: const InputDecoration(
                              labelText: 'Department',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.business),
                            ),
                            enabled: _isEditing,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your department';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Army Number
                          TextFormField(
                            controller: _armyNumberController,
                            decoration: const InputDecoration(
                              labelText: 'Army Number',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.numbers),
                            ),
                            enabled: false, // Army number cannot be changed
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Biometric settings
                  Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Biometric Authentication',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SwitchListTile(
                            title: const Text('Enable Biometric Login'),
                            subtitle: Text(
                              user.isBiometricEnabled
                                  ? 'Biometric login is enabled'
                                  : 'Biometric login is disabled',
                            ),
                            value: user.isBiometricEnabled,
                            onChanged: (value) async {
                              if (value) {
                                // Enable biometric
                                final success =
                                    await authProvider.enableBiometric();
                                if (!success && mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Failed to enable biometric login'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              } else {
                                // Disable biometric
                                final success =
                                    await authProvider.disableBiometric();
                                if (!success && mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Failed to disable biometric login'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Save button
                  if (_isEditing)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: PlatformButton(
                        text: _isLoading ? 'SAVING...' : 'SAVE CHANGES',
                        onPressed: _isLoading ? null : _saveProfile,
                        icon: Icons.save,
                        buttonType: PlatformButtonType.primary,
                        isFullWidth: true,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
