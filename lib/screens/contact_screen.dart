import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/design_system.dart';
import '../providers/theme_provider.dart';
import '../widgets/platform_aware_widgets.dart';
import '../widgets/custom_drawer.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({Key? key}) : super(key: key);

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isSubmitting = true;
      });

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Message sent successfully!'),
            backgroundColor: DesignSystem.successColor,
          ),
        );

        // Clear form
        _nameController.clear();
        _emailController.clear();
        _messageController.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return PlatformScaffold(
      appBar: AppBar(
        title: const Text('Contact Us'),
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
                const PlatformText(
                  'Get in Touch',
                  isTitle: true,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Have questions or feedback? We\'d love to hear from you. Fill out the form below or use our contact information.',
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: DesignSystem.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 32),

                // Contact Information
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: DesignSystem.primaryColor.withValues(alpha: 15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      _buildContactItem(
                        icon: Icons.email,
                        title: 'Email',
                        detail: 'offrmbabubakar@gmail.com',
                      ),
                      const SizedBox(height: 16),
                      _buildContactItem(
                        icon: Icons.location_on,
                        title: 'Address',
                        detail: 'Nigerian Army Headquarters, Abuja, Nigeria',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Contact Form
                const PlatformText(
                  'Send us a Message',
                  isTitle: true,
                ),
                const SizedBox(height: 16),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name Field
                      PlatformTextField(
                        controller: _nameController,
                        label: 'Full Name',
                        prefixIcon: Icons.person,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Email Field
                      PlatformTextField(
                        controller: _emailController,
                        label: 'Email Address',
                        prefixIcon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Message Field
                      PlatformTextField(
                        controller: _messageController,
                        label: 'Message',
                        prefixIcon: Icons.message,
                        maxLines: 5,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your message';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Submit Button
                      PlatformButton(
                        text: _isSubmitting ? 'SENDING...' : 'SEND MESSAGE',
                        onPressed: _isSubmitting ? null : _submitForm,
                        icon: Icons.send,
                        isFullWidth: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Footer
                const Center(
                  child: Text(
                    'We aim to respond to all inquiries within 48 hours.',
                    style: TextStyle(
                      fontSize: 14,
                      color: DesignSystem.textSecondaryColor,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String detail,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: DesignSystem.primaryColor.withValues(alpha: 25),
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
                detail,
                style: const TextStyle(
                  fontSize: 14,
                  color: DesignSystem.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 40),
              // Footer with copyright
              Center(
                child: Column(
                  children: [
                    Text(
                      '© ${DateTime.now().year} Nigerian Army Signals (NAS)',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Powered by NAS',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: DesignSystem.accentColor,
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
      ],
    );
  }
}
