import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/design_system.dart';
import '../providers/auth_provider.dart';
import '../widgets/platform_aware_widgets.dart';
import '../widgets/grid_background.dart';
import '../widgets/version_info.dart';
import 'registration_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  int _tapCount = 0;
  DateTime? _lastTapTime;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _animationController.forward();

    // Initialize auth provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.initialize();
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Handle login
  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      if (success && mounted) {
        // Navigate to home screen or dashboard
        Navigator.of(context).pushReplacementNamed('/home');
      }
    }
  }

  // Handle biometric login
  Future<void> _loginWithBiometric() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (!authProvider.isBiometricAvailable ||
        !authProvider.isBiometricEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Biometric authentication is not available or not enabled'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await authProvider.loginWithBiometric();

    if (success && mounted) {
      // Navigate to home screen or dashboard
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  // Handle logo tap for hidden registration
  void _handleLogoTap() {
    final now = DateTime.now();

    if (_lastTapTime != null && now.difference(_lastTapTime!).inSeconds < 2) {
      setState(() {
        _tapCount++;
      });

      if (_tapCount >= 5) {
        // Reset tap count
        setState(() {
          _tapCount = 0;
        });

        // Navigate to hidden registration screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const RegistrationScreen(),
          ),
        );
      }
    } else {
      setState(() {
        _tapCount = 1;
      });
    }

    _lastTapTime = now;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return PlatformScaffold(
      body: GridBackground(
        isSpecialScreen: true,
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
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo and title
                        GestureDetector(
                          onTap: _handleLogoTap,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: DesignSystem.accentColor,
                                width: 2,
                              ),
                              gradient: const RadialGradient(
                                colors: [
                                  Color(
                                      0xB3001F3F), // primaryColor with 0.7 opacity
                                  Color(0xFF001F3F), // primaryColor
                                ],
                                center: Alignment.center,
                                radius: 0.8,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(
                                      0x4D4A90E2), // secondaryColor with 0.3 opacity
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                Icons.security,
                                size: 60,
                                color: DesignSystem.accentColor,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: DesignSystem.adjustedSpacingMedium),
                        PlatformText(
                          'NAFacial',
                          isHeadline: true,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: DesignSystem.adjustedFontSizeXXLarge,
                            fontWeight: DesignSystem.fontWeightBold,
                          ),
                        ),
                        PlatformText(
                          'Nigerian Army Facial Verification System',
                          style: TextStyle(
                            color: Colors.white.withAlpha(230),
                            fontSize: DesignSystem.adjustedFontSizeSmall,
                            letterSpacing: DesignSystem.letterSpacingWide,
                          ),
                        ),
                        SizedBox(height: DesignSystem.adjustedSpacingLarge),

                        // Login form
                        PlatformCard(
                          padding: EdgeInsets.all(
                              DesignSystem.adjustedSpacingMedium),
                          backgroundColor: Colors.white.withAlpha(230),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                PlatformText(
                                  'SECURE LOGIN',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: DesignSystem.primaryColor,
                                    fontSize:
                                        DesignSystem.adjustedFontSizeMedium,
                                    fontWeight: DesignSystem.fontWeightBold,
                                    letterSpacing:
                                        DesignSystem.letterSpacingWide,
                                  ),
                                ),
                                SizedBox(
                                    height: DesignSystem.adjustedSpacingMedium),

                                // Username field
                                PlatformTextField(
                                  controller: _usernameController,
                                  label: 'Username',
                                  prefixIcon: Icons.person,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your username';
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
                                      return 'Please enter your password';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(
                                    height: DesignSystem.adjustedSpacingLarge),

                                // Login button
                                PlatformButton(
                                  text: 'LOGIN',
                                  onPressed: authProvider.isLoading
                                      ? null
                                      : () => _login(),
                                  icon: Icons.login,
                                  isFullWidth: true,
                                ),

                                if (authProvider.error != null) ...[
                                  SizedBox(
                                      height:
                                          DesignSystem.adjustedSpacingSmall),
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

                                // Biometric login button (if available)
                                if (authProvider.isBiometricAvailable &&
                                    authProvider.isBiometricEnabled) ...[
                                  SizedBox(
                                      height:
                                          DesignSystem.adjustedSpacingMedium),
                                  const Divider(),
                                  SizedBox(
                                      height:
                                          DesignSystem.adjustedSpacingSmall),
                                  PlatformText(
                                    'OR',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: DesignSystem.textSecondaryColor,
                                      fontSize:
                                          DesignSystem.adjustedFontSizeSmall,
                                    ),
                                  ),
                                  SizedBox(
                                      height:
                                          DesignSystem.adjustedSpacingSmall),
                                  PlatformButton(
                                    text: 'LOGIN WITH BIOMETRIC',
                                    onPressed: authProvider.isLoading
                                        ? null
                                        : () => _loginWithBiometric(),
                                    icon: Icons.fingerprint,
                                    isFullWidth: true,
                                    isPrimary: false,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: DesignSystem.adjustedSpacingLarge),

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
                            'RESTRICTED ACCESS - AUTHORIZED PERSONNEL ONLY',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFFFFD700), // accentColor
                              fontSize: 12,
                              letterSpacing: 1.0, // letterSpacingExtraWide
                              fontWeight: FontWeight.w700, // fontWeightBold
                            ),
                          ),
                        ),

                        // Version info
                        const SizedBox(height: 50),
                        const VersionInfo(
                          useBackground: true,
                          showIcon: true,
                          fontSize: 13.0,
                        ),
                        // Add bottom padding to prevent overflow
                        const SizedBox(height: 40),
                      ],
                    ),
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
