import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/design_system.dart';
import '../providers/auth_provider.dart';
import '../widgets/platform_aware_widgets.dart';
import '../widgets/grid_background.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _rankController = TextEditingController();
  final _departmentController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _rankController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  // Handle registration
  Future<void> _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.register(
        _usernameController.text.trim(),
        _passwordController.text,
        _fullNameController.text.trim(),
        _rankController.text.trim(),
        _departmentController.text.trim(),
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful! You can now login.'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back to login screen
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return PlatformScaffold(
      appBar: AppBar(
        title: const Text('Secure Registration'),
        backgroundColor: isDarkMode
            ? DesignSystem.darkSurfaceColor
            : DesignSystem.primaryColor,
        elevation: 0,
      ),
      body: GridBackground(
        useGradient: true,
        gridColor: Colors.white.withAlpha(20),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isLandscape ? 800 : 400,
                ),
                child: Padding(
                  padding: EdgeInsets.all(DesignSystem.adjustedSpacingLarge),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Title
                      PlatformContainer(
                        padding:
                            EdgeInsets.all(DesignSystem.adjustedSpacingMedium),
                        backgroundColor: Colors.white.withAlpha(25),
                        borderRadius: BorderRadius.circular(
                            DesignSystem.borderRadiusMedium),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.security,
                              color: DesignSystem.accentColor,
                              size: 24,
                            ),
                            SizedBox(width: DesignSystem.adjustedSpacingSmall),
                            PlatformText(
                              'PERSONNEL REGISTRATION',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: DesignSystem.adjustedFontSizeMedium,
                                fontWeight: DesignSystem.fontWeightBold,
                                letterSpacing: DesignSystem.letterSpacingWide,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: DesignSystem.adjustedSpacingMedium),

                      // Registration form
                      PlatformCard(
                        padding:
                            EdgeInsets.all(DesignSystem.adjustedSpacingMedium),
                        backgroundColor: Colors.white.withAlpha(230),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Username field
                              PlatformTextField(
                                controller: _usernameController,
                                label: 'Username',
                                prefixIcon: Icons.person,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a username';
                                  }
                                  if (value.length < 4) {
                                    return 'Username must be at least 4 characters';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(
                                  height: DesignSystem.adjustedSpacingMedium),

                              // Password field
                              PlatformTextField(
                                controller: _passwordController,
                                label: 'Password',
                                obscureText: _obscurePassword,
                                prefixIcon: Icons.lock,
                                suffixIcon: _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                onSuffixIconPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a password';
                                  }
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(
                                  height: DesignSystem.adjustedSpacingMedium),

                              // Confirm password field
                              PlatformTextField(
                                controller: _confirmPasswordController,
                                label: 'Confirm Password',
                                obscureText: _obscureConfirmPassword,
                                prefixIcon: Icons.lock_outline,
                                suffixIcon: _obscureConfirmPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                onSuffixIconPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please confirm your password';
                                  }
                                  if (value != _passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(
                                  height: DesignSystem.adjustedSpacingMedium),

                              // Full name field
                              PlatformTextField(
                                controller: _fullNameController,
                                label: 'Full Name',
                                prefixIcon: Icons.badge,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your full name';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(
                                  height: DesignSystem.adjustedSpacingMedium),

                              // Rank field
                              PlatformTextField(
                                controller: _rankController,
                                label: 'Rank',
                                prefixIcon: Icons.military_tech,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your rank';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(
                                  height: DesignSystem.adjustedSpacingMedium),

                              // Department field
                              PlatformTextField(
                                controller: _departmentController,
                                label: 'Department',
                                prefixIcon: Icons.business,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your department';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(
                                  height: DesignSystem.adjustedSpacingLarge),

                              // Register button
                              PlatformButton(
                                text: 'REGISTER',
                                onPressed: authProvider.isLoading
                                    ? null
                                    : () => _register(),
                                icon: Icons.app_registration,
                                isFullWidth: true,
                              ),

                              if (authProvider.error != null) ...[
                                SizedBox(
                                    height: DesignSystem.adjustedSpacingSmall),
                                Text(
                                  authProvider.error!,
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize:
                                        DesignSystem.adjustedFontSizeSmall,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: DesignSystem.adjustedSpacingMedium),

                      // Security notice
                      PlatformContainer(
                        padding: EdgeInsets.symmetric(
                          vertical: DesignSystem.adjustedSpacingSmall,
                          horizontal: DesignSystem.adjustedSpacingMedium,
                        ),
                        backgroundColor: const Color(
                            0xCC001F3F), // primaryColor with 0.8 opacity
                        borderRadius: BorderRadius.circular(
                            DesignSystem.borderRadiusSmall),
                        child: const PlatformText(
                          'AUTHORIZED PERSONNEL REGISTRATION ONLY',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFFFFD700), // accentColor
                            fontSize: 12,
                            letterSpacing: 1.0, // letterSpacingExtraWide
                            fontWeight: FontWeight.w700, // fontWeightBold
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
