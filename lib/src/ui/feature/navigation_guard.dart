import 'package:flutter/material.dart';

import 'package:spotsell/src/core/dependency_injection/service_locator.dart';
import 'package:spotsell/src/data/entities/entities.dart';
import 'package:spotsell/src/data/services/auth_service.dart';
import 'package:spotsell/src/ui/feature/admin/admin_screen.dart';
import 'package:spotsell/src/ui/feature/buyer/buyer_screen.dart';
import 'package:spotsell/src/ui/feature/guests/welcome/welcome_screen.dart';

/// Widget that guards routes based on authentication state
/// Automatically redirects users based on their authentication and role status
class NavigationGuard extends StatefulWidget {
  const NavigationGuard({super.key});

  @override
  State<NavigationGuard> createState() => _NavigationGuardState();
}

class _NavigationGuardState extends State<NavigationGuard> {
  late AuthService _authService;
  bool _isInitializing = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      // Get AuthService from service locator
      _authService = getService<AuthService>();

      // Initialize authentication state if not already done
      if (!_authService.isInitialized) {
        final result = await _authService.initialize();
        if (result is Error) {
          setState(() {
            _error = result.toString();
            _isInitializing = false;
          });
          return;
        }
      }

      // Listen to authentication state changes
      _authService.addListener(_onAuthStateChanged);

      setState(() {
        _isInitializing = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Authentication service unavailable: $e';
        _isInitializing = false;
      });
    }
  }

  void _onAuthStateChanged() {
    if (mounted) {
      setState(() {
        // Trigger rebuild when auth state changes
      });
    }
  }

  @override
  void dispose() {
    _authService.removeListener(_onAuthStateChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show loading screen during initialization
    if (_isInitializing || _authService.isLoading) {
      return _buildLoadingScreen();
    }

    // Show error screen if initialization failed
    if (_error != null) {
      return _buildErrorScreen();
    }

    // Redirect based on authentication state
    return _buildAuthenticatedScreen();
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Loading SpotSell...',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Please wait while we prepare your experience',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 24),
            Text(
              'Authentication Error',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _error ?? 'An unknown error occurred',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _error = null;
                  _isInitializing = true;
                });
                _initializeAuth();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthenticatedScreen() {
    // If user is not authenticated, show welcome screen
    if (!_authService.isAuthenticated) {
      return const WelcomeScreen();
    }

    // User is authenticated, determine which screen to show based on role
    final primaryRole = _authService.primaryRole;

    switch (primaryRole) {
      case UserRole.admin:
        return const AdminScreen();
      default:
        return const BuyerScreen();
    }
  }
}
