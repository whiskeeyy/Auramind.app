import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../screens/home_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/mood_checkin_screen.dart';
import '../main.dart';

/// Widget that wraps the app and handles authentication state
/// Routes to Login if no session, Home if authenticated
/// Also syncs notification reminders from Supabase profile
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();
  final NotificationService _notificationService = NotificationService();
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
    _listenToAuthChanges();
    _setupNotificationTapHandler();
  }

  /// Check initial authentication status
  void _checkAuthStatus() {
    final isAuth = _authService.isAuthenticated;
    setState(() {
      _isAuthenticated = isAuth;
      _isLoading = false;
    });

    // Sync notifications if authenticated
    if (isAuth) {
      _syncDailyReminder();
    }
  }

  /// Listen to authentication state changes
  void _listenToAuthChanges() {
    _authService.authStateChanges.listen((event) {
      final isAuth = event.session != null;
      setState(() {
        _isAuthenticated = isAuth;
      });

      // Sync notifications when user logs in
      if (isAuth) {
        _syncDailyReminder();
      } else {
        // Cancel notifications when user logs out
        _notificationService.cancelDailyReminder();
      }
    });
  }

  /// Setup handler for notification taps - navigate to check-in screen
  void _setupNotificationTapHandler() {
    NotificationService.setOnNotificationTap(() {
      // Navigate to check-in screen when notification is tapped
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => const MoodCheckinScreen(),
        ),
      );
    });
  }

  /// Sync daily reminder from Supabase profile and schedule notification
  Future<void> _syncDailyReminder() async {
    try {
      // Request notification permissions on first sync
      await _notificationService.requestPermissions();

      // Fetch profile from Supabase
      final userId = _authService.currentUser?.id;
      if (userId == null) return;

      final response = await Supabase.instance.client
          .from('profiles')
          .select('daily_reminder')
          .eq('id', userId)
          .maybeSingle();

      // Parse daily_reminder time from profile
      final timeStr = response?['daily_reminder'] as String?;
      final reminderTime = NotificationService.parseTimeFromSupabase(timeStr) ??
          NotificationService.defaultReminderTime;

      // Schedule the daily reminder
      await _notificationService.scheduleDailyReminder(reminderTime);

      debugPrint(
          '📱 Daily reminder synced: ${reminderTime.hour}:${reminderTime.minute.toString().padLeft(2, '0')}');
    } catch (e) {
      debugPrint('Failed to sync daily reminder: $e');
      // Fallback: schedule with default time
      await _notificationService.scheduleDailyReminder(
        NotificationService.defaultReminderTime,
      );
    }
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
