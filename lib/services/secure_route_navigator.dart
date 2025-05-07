import 'package:flutter/material.dart';
import 'admin_auth_service.dart';

/// A service that handles secure navigation with admin verification
class SecureRouteNavigator {
  static final SecureRouteNavigator _instance = SecureRouteNavigator._internal();
  factory SecureRouteNavigator() => _instance;
  SecureRouteNavigator._internal();

  // Services
  final AdminAuthService _adminAuthService = AdminAuthService();
  
  // List of routes that require admin verification
  static const List<String> _adminRoutes = [
    '/personnel_database',
    '/register_personnel',
    '/edit_personnel',
    '/id_management',
    '/rank_management',
    '/access_logs',
    '/access_control',
    '/device_management',
    '/android_server_manager',
    '/analytics',
    '/statistics',
    '/activity_summary',
  ];
  
  // List of routes that require admin verification for specific actions
  static const List<String> _partialAdminRoutes = [
    '/settings',
    '/biometric_management',
  ];
  
  /// Check if a route requires admin verification
  bool requiresAdminVerification(String route) {
    // Remove leading slash if present
    final normalizedRoute = route.startsWith('/') ? route.substring(1) : route;
    
    // Check if route is in admin routes
    return _adminRoutes.contains('/$normalizedRoute');
  }
  
  /// Check if a route may require admin verification for certain actions
  bool mayRequireAdminVerification(String route) {
    // Remove leading slash if present
    final normalizedRoute = route.startsWith('/') ? route.substring(1) : route;
    
    // Check if route is in partial admin routes
    return _partialAdminRoutes.contains('/$normalizedRoute');
  }
  
  /// Navigate to a route with admin verification if needed
  Future<bool> navigateTo(BuildContext context, String route, {Object? arguments}) async {
    // Check if route requires admin verification
    if (requiresAdminVerification(route)) {
      // Check if admin is already verified
      if (_adminAuthService.isVerificationRequired()) {
        // Show admin verification dialog
        final verified = await _showAdminVerificationDialog(context);
        
        if (!verified) {
          // Admin verification failed
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Admin verification required to access this feature'),
              backgroundColor: Colors.red,
            ),
          );
          return false;
        }
      }
    }
    
    // Navigate to route
    if (arguments != null) {
      Navigator.of(context).pushNamed(route, arguments: arguments);
    } else {
      Navigator.of(context).pushNamed(route);
    }
    
    return true;
  }
  
  /// Show admin verification dialog
  Future<bool> _showAdminVerificationDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Admin Verification Required'),
        content: const Text(
          'This feature requires administrator verification. '
          'Please authenticate with your fingerprint to continue.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );
              
              // Verify admin
              final verified = await _adminAuthService.verifyAdmin(
                reason: 'Verify administrator access',
                requireHighAccuracy: true,
              );
              
              // Close loading indicator
              Navigator.of(context).pop();
              
              // Close verification dialog with result
              Navigator.of(context).pop(verified);
            },
            child: const Text('VERIFY'),
          ),
        ],
      ),
    ) ?? false;
  }
  
  /// Check if admin verification is required for a specific action
  Future<bool> verifyAdminForAction(BuildContext context, String actionName) async {
    // Check if admin is already verified
    if (_adminAuthService.isVerificationRequired()) {
      // Show admin verification dialog for action
      return await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Admin Verification Required'),
          content: Text(
            'The action "$actionName" requires administrator verification. '
            'Please authenticate with your fingerprint to continue.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Show loading indicator
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
                
                // Verify admin
                final verified = await _adminAuthService.verifyAdmin(
                  reason: 'Verify administrator access for: $actionName',
                  requireHighAccuracy: true,
                );
                
                // Close loading indicator
                Navigator.of(context).pop();
                
                // Close verification dialog with result
                Navigator.of(context).pop(verified);
              },
              child: const Text('VERIFY'),
            ),
          ],
        ),
      ) ?? false;
    }
    
    // Admin is already verified
    return true;
  }
}
