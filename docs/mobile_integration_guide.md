# Mobile Integration Guide - AI Agents & Realtime Updates

This guide covers integrating the enhanced AI agent system with your Flutter mobile app, including Realtime subscriptions and Riverpod state management.

## Table of Contents

1. [Avatar States](#avatar-states)
2. [Realtime Subscriptions](#realtime-subscriptions)
3. [Riverpod State Management](#riverpod-state-management)
4. [Fast Dashboard Loading](#fast-dashboard-loading)
5. [Rate Limiting Handling](#rate-limiting-handling)

---

## Avatar States

### Available States

The system now supports 6 avatar states:

| State | Description | Conditions |
|-------|-------------|------------|
| `STATE_JOYFUL` | Happy, celebratory | Mood ≥ 8, Stress ≤ 7 |
| `STATE_NEUTRAL` | Calm, balanced | Mood 5-7, Stress ≤ 7 |
| `STATE_SAD` | Gentle sadness | Mood 3-4, Stress ≤ 7 |
| `STATE_EXHAUSTED` | Tired, drained | Mood 1-2, Stress ≤ 7 |
| `STATE_ANXIOUS` | Concerned, stressed | Stress > 7, Mood ≥ 5 |
| `STATE_OVERWHELMED` | High stress + low mood | Stress > 8 AND Mood < 5 |

### Dart Enum

```dart
enum AvatarState {
  joyful,
  neutral,
  sad,
  exhausted,
  anxious,
  overwhelmed;
  
  /// Parse from API string
  static AvatarState fromString(String? state) {
    switch (state) {
      case 'STATE_JOYFUL':
        return AvatarState.joyful;
      case 'STATE_SAD':
        return AvatarState.sad;
      case 'STATE_EXHAUSTED':
        return AvatarState.exhausted;
      case 'STATE_ANXIOUS':
        return AvatarState.anxious;
      case 'STATE_OVERWHELMED':
        return AvatarState.overwhelmed;
      case 'STATE_NEUTRAL':
      default:
        return AvatarState.neutral;
    }
  }
  
  /// Convert to API string
  String toApiString() {
    return 'STATE_${name.toUpperCase()}';
  }
}
```

### Animation Mapping

Map each state to appropriate Lottie animations or custom animations:

```dart
String getAvatarAnimation(AvatarState state) {
  switch (state) {
    case AvatarState.joyful:
      return 'assets/animations/avatar_happy.json';
    case AvatarState.sad:
      return 'assets/animations/avatar_sad.json';
    case AvatarState.exhausted:
      return 'assets/animations/avatar_tired.json';
    case AvatarState.anxious:
      return 'assets/animations/avatar_anxious.json';
    case AvatarState.overwhelmed:
      return 'assets/animations/avatar_overwhelmed.json';
    case AvatarState.neutral:
    default:
      return 'assets/animations/avatar_neutral.json';
  }
}
```

---

## Realtime Subscriptions

### Setup Supabase Realtime

Subscribe to mood_logs table changes for live dashboard updates:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

class MoodLogsRealtimeService {
  final SupabaseClient _supabase = Supabase.instance.client;
  RealtimeChannel? _subscription;
  
  /// Subscribe to mood logs for the current user
  void subscribeMoodLogs(
    String userId,
    Function(Map<String, dynamic>) onInsert,
    Function(Map<String, dynamic>) onUpdate,
  ) {
    _subscription = _supabase
      .channel('mood_logs_$userId')
      .onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'mood_logs',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'user_id',
          value: userId,
        ),
        callback: (payload) {
          final newLog = payload.newRecord;
          onInsert(newLog);
        },
      )
      .onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: 'mood_logs',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'user_id',
          value: userId,
        ),
        callback: (payload) {
          final updatedLog = payload.newRecord;
          onUpdate(updatedLog);
        },
      )
      .subscribe();
  }
  
  /// Unsubscribe from realtime updates
  void unsubscribe() {
    _subscription?.unsubscribe();
    _subscription = null;
  }
}
```

### Usage with Riverpod

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider for realtime service
final moodLogsRealtimeProvider = Provider((ref) {
  return MoodLogsRealtimeService();
});

// Subscribe in your widget or provider
class DashboardScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    
    final userId = ref.read(currentUserIdProvider);
    final realtimeService = ref.read(moodLogsRealtimeProvider);
    
    realtimeService.subscribeMoodLogs(
      userId,
      onInsert: (newLog) {
        // Update mood logs list
        ref.read(moodLogsProvider.notifier).addLog(newLog);
        
        // Update avatar state
        final avatarState = AvatarState.fromString(newLog['avatar_state']);
        ref.read(avatarStateProvider.notifier).setState(avatarState);
      },
      onUpdate: (updatedLog) {
        ref.read(moodLogsProvider.notifier).updateLog(updatedLog);
      },
    );
  }
  
  @override
  void dispose() {
    ref.read(moodLogsRealtimeProvider).unsubscribe();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    // Your dashboard UI
    return Scaffold(/* ... */);
  }
}
```

---

## Riverpod State Management

### Avatar State Provider

Create a provider to manage and cache the avatar state:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Avatar state notifier
class AvatarStateNotifier extends StateNotifier<AvatarState> {
  AvatarStateNotifier() : super(AvatarState.neutral);
  
  /// Update state from mood log
  void setState(AvatarState newState) {
    state = newState;
  }
  
  /// Update from API string
  void setStateFromString(String? stateString) {
    state = AvatarState.fromString(stateString);
  }
  
  /// Reset to neutral
  void reset() {
    state = AvatarState.neutral;
  }
}

/// Avatar state provider with caching
final avatarStateProvider = StateNotifierProvider<AvatarStateNotifier, AvatarState>((ref) {
  return AvatarStateNotifier();
});
```

### Mood Logs Provider

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Mood log state
class MoodLogsState {
  final List<Map<String, dynamic>> logs;
  final bool isLoading;
  final String? error;
  
  MoodLogsState({
    this.logs = const [],
    this.isLoading = false,
    this.error,
  });
  
  MoodLogsState copyWith({
    List<Map<String, dynamic>>? logs,
    bool? isLoading,
    String? error,
  }) {
    return MoodLogsState(
      logs: logs ?? this.logs,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Mood logs notifier
class MoodLogsNotifier extends StateNotifier<MoodLogsState> {
  MoodLogsNotifier() : super(MoodLogsState());
  
  /// Add new log from realtime
  void addLog(Map<String, dynamic> log) {
    state = state.copyWith(
      logs: [log, ...state.logs],
    );
  }
  
  /// Update existing log
  void updateLog(Map<String, dynamic> updatedLog) {
    final logs = state.logs.map((log) {
      if (log['id'] == updatedLog['id']) {
        return updatedLog;
      }
      return log;
    }).toList();
    
    state = state.copyWith(logs: logs);
  }
  
  /// Load logs from API
  Future<void> loadLogs() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final response = await Supabase.instance.client
        .from('mood_logs')
        .select()
        .order('created_at', ascending: false);
      
      state = state.copyWith(
        logs: List<Map<String, dynamic>>.from(response),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

/// Mood logs provider
final moodLogsProvider = StateNotifierProvider<MoodLogsNotifier, MoodLogsState>((ref) {
  return MoodLogsNotifier();
});
```

---

## Fast Dashboard Loading

### Load Avatar State from Profile

For instant dashboard rendering, load the avatar state from the profiles table instead of querying mood_logs:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  /// Get current avatar state from profile (fast)
  Future<AvatarState> getCurrentAvatarState() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return AvatarState.neutral;
      
      final response = await _supabase
        .from('profiles')
        .select('avatar_state')
        .eq('user_id', userId)
        .single();
      
      return AvatarState.fromString(response['avatar_state']);
    } catch (e) {
      print('Error loading avatar state: $e');
      return AvatarState.neutral;
    }
  }
}

// Provider
final profileServiceProvider = Provider((ref) => ProfileService());

// Load on app start
final initialAvatarStateProvider = FutureProvider<AvatarState>((ref) async {
  final service = ref.read(profileServiceProvider);
  return await service.getCurrentAvatarState();
});
```

### Dashboard Loading Pattern

```dart
class DashboardScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avatarStateAsync = ref.watch(initialAvatarStateProvider);
    
    return avatarStateAsync.when(
      loading: () => LoadingScreen(),
      error: (err, stack) => ErrorScreen(error: err),
      data: (avatarState) {
        // Set the avatar state in the provider
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(avatarStateProvider.notifier).setState(avatarState);
        });
        
        return DashboardContent();
      },
    );
  }
}
```

---

## Rate Limiting Handling

### Detect Rate Limit Errors

Handle 429 status codes from the API:

```dart
class MoodLogService {
  Future<Map<String, dynamic>> createMoodLog(MoodLogCreate log) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/mood-logs'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(log.toJson()),
      );
      
      if (response.statusCode == 429) {
        // Rate limited
        final error = jsonDecode(response.body);
        throw RateLimitException(error['detail']);
      }
      
      if (response.statusCode != 200) {
        throw Exception('Failed to create mood log');
      }
      
      return jsonDecode(response.body);
    } catch (e) {
      rethrow;
    }
  }
}

/// Custom exception for rate limiting
class RateLimitException implements Exception {
  final String message;
  RateLimitException(this.message);
  
  @override
  String toString() => message;
}
```

### Show User-Friendly Message

```dart
try {
  await moodLogService.createMoodLog(log);
} on RateLimitException catch (e) {
  // Show rate limit dialog
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Đã đạt giới hạn'),
      content: Text(
        'Bạn đã sử dụng hết số lần phân tích AI trong giờ này. '
        'Vui lòng thử lại sau hoặc ghi nhật ký mà không cần phân tích AI.'
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Đóng'),
        ),
      ],
    ),
  );
} catch (e) {
  // Handle other errors
  showErrorSnackbar(context, 'Có lỗi xảy ra: $e');
}
```

---

## Complete Example

### Home Screen with Avatar

```dart
class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avatarState = ref.watch(avatarStateProvider);
    final animationPath = getAvatarAnimation(avatarState);
    
    return Scaffold(
      body: Column(
        children: [
          // Avatar with current state
          Lottie.asset(
            animationPath,
            width: 200,
            height: 200,
          ),
          
          // State indicator
          Text(
            _getStateMessage(avatarState),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          
          // Other content
          Expanded(
            child: MoodLogsList(),
          ),
        ],
      ),
    );
  }
  
  String _getStateMessage(AvatarState state) {
    switch (state) {
      case AvatarState.joyful:
        return 'Bạn đang vui vẻ!';
      case AvatarState.sad:
        return 'Bạn có vẻ buồn...';
      case AvatarState.exhausted:
        return 'Bạn trông mệt mỏi...';
      case AvatarState.anxious:
        return 'Bạn đang căng thẳng...';
      case AvatarState.overwhelmed:
        return 'Bạn đang quá tải...';
      case AvatarState.neutral:
      default:
        return 'Bạn đang bình yên';
    }
  }
}
```

---

## Summary

### Key Integration Points

1. **Avatar States**: Parse 6 states from API, map to animations
2. **Realtime**: Subscribe to `mood_logs` table for live updates
3. **Riverpod**: Cache avatar state and mood logs in providers
4. **Fast Loading**: Load initial avatar state from `profiles` table
5. **Rate Limiting**: Handle 429 errors gracefully with user-friendly messages

### Performance Benefits

- **Fast Dashboard**: Avatar state loads from profiles table (single query)
- **Live Updates**: Realtime subscriptions eliminate polling
- **Cached State**: Riverpod providers prevent unnecessary API calls
- **Optimized**: Rate limiting protects free tier API usage

### Next Steps

1. Implement avatar animations for all 6 states
2. Set up Realtime subscriptions in your app
3. Create Riverpod providers for state management
4. Test rate limiting behavior
5. Monitor user feedback on new states
