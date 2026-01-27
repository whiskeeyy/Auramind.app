import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../screens/home_screen.dart';
import '../screens/auth/login_screen.dart';

/// Widget that wraps the app and handles authentication state
/// Routes to Login if no session, Home if authenticated
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
    _listenToAuthChanges();
  }

  /// Check initial authentication status
  void _checkAuthStatus() {
    setState(() {
      _isAuthenticated = _authService.isAuthenticated;
      _isLoading = false;
    });
  }

  /// Listen to authentication state changes
  void _listenToAuthChanges() {
    _authService.authStateChanges.listen((event) {
      setState(() {
        _isAuthenticated = event.session != null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while checking auth status
    if (_isLoading) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    // Route based on authentication status
    return _isAuthenticated ? const HomeScreen() : const LoginScreen();
  }
}
