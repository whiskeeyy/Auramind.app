import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'mood_checkin_screen.dart';
import 'chat_screen.dart';
import 'dashboard_screen.dart';
import 'calendar_screen.dart';
import 'achievements_screen.dart';
import '../widgets/streak_widget.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final AuthService _authService = AuthService();
  final _supabase = Supabase.instance.client;

  int _streakDays = 0;
  bool _loadingStreak = true;

  static const List<Widget> _screens = [
    MoodCheckinScreen(),
    ChatScreen(),
    CalendarScreen(),
    DashboardScreen(),
    AchievementsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await _supabase
          .from('profiles')
          .select('current_streak')
          .eq('id', userId)
          .maybeSingle();

      if (mounted && response != null) {
        setState(() {
          _streakDays = response['current_streak'] as int? ?? 0;
          _loadingStreak = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching profile streak: $e');
      if (mounted) setState(() => _loadingStreak = false);
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await _authService.signOut();
        // Navigation handled by AuthWrapper listening to auth state
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Logout failed: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show AppBar for Calendar (2), Dashboard (3), and Achievements (4)
    // Check-in (0) and Chat (1) handle their own headers usually, but we can standardise if needed.
    // For now, let's keep the existing behaviour but add it for Achievements too.
    final showAppBar = _selectedIndex >= 2;

    String title = '';
    switch (_selectedIndex) {
      case 2:
        title = 'Calendar';
        break;
      case 3:
        title = 'Dashboard';
        break;
      case 4:
        title = 'Achievements';
        break;
    }

    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: Text(title),
              centerTitle: true,
              actions: [
                // Show StreakWidget in AppBar
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: StreakWidget(
                    streakDays: _streakDays,
                    isLoading: _loadingStreak,
                  ),
                ),
                if (_selectedIndex == 3) // Only show logout on Dashboard
                  IconButton(
                    icon: const Icon(Icons.logout),
                    tooltip: 'Logout',
                    onPressed: _handleLogout,
                  ),
              ],
            )
          : null,
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
          // Refresh streak when switching tabs just in case
          if (index == 0 || index == 4) _fetchProfileData();
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.mood_outlined),
            selectedIcon: Icon(Icons.mood),
            label: 'Check-in',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dash',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events),
            label: 'Awards',
          ),
        ],
      ),
    );
  }
}
