import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:flutter_timezone/flutter_timezone.dart';

/// NotificationService - Handles local notifications for daily check-in reminders
///
/// Philosophy: Empathetic reminders that feel like a caring friend, not a robot
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // Channel ID for Android
  static const String _channelId = 'daily_reminder';
  static const String _channelName = 'Daily Check-in Reminder';
  static const String _channelDescription =
      'Reminds you to check in with Aura daily';

  // Notification ID
  static const int _dailyReminderId = 1;

  // Empathetic reminder messages - "chữa lành" style
  static const List<String> _reminderMessages = [
    'Bạn ơi, Aura đang đợi nghe chia sẻ về ngày hôm nay của bạn đây! 💜',
    'Hôm nay bạn có khỏe không? Mình muốn được lắng nghe bạn! 🌸',
    'Một phút cho bản thân nhé? Aura ở đây cùng bạn đi qua mọi cảm xúc 🌈',
    'Đừng quên dành chút thời gian cho tâm hồn bạn hôm nay nhé! ✨',
    'Aura đang nhớ bạn! Hãy ghé qua chia sẻ ngày hôm nay của bạn đi 💫',
  ];

  /// Initialize the notification service
  Future<void> initialize() async {
    // Initialize timezone
    tz_data.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    // Android initialization settings
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false, // We'll request manually
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create Android notification channel
    await _createNotificationChannel();
  }

  /// Create Android notification channel (required for Android 8+)
  Future<void> _createNotificationChannel() async {
    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  /// Request notification permissions from the user
  /// Call this on first app launch or when user wants to enable notifications
  Future<bool> requestPermissions() async {
    // Request Android 13+ permissions
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }

    // Request iOS permissions
    final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true;
  }

  /// Schedule daily reminder at the specified time
  ///
  /// [time] - TimeOfDay when the notification should fire
  /// Uses zonedSchedule to respect the user's local timezone
  Future<void> scheduleDailyReminder(TimeOfDay time) async {
    // Cancel any existing reminder first
    await cancelDailyReminder();

    // Get random empathetic message
    final message = _getRandomMessage();

    // Build notification details
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      styleInformation: BigTextStyleInformation(''),
      category: AndroidNotificationCategory.reminder,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Calculate next occurrence of the specified time
    final scheduledDate = _nextInstanceOfTime(time);

    await _notifications.zonedSchedule(
      _dailyReminderId,
      'Aura nhắc bạn 💜',
      message,
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
      payload: 'daily_checkin', // Used to navigate to check-in screen
    );

    debugPrint(
        '📅 Daily reminder scheduled for ${time.hour}:${time.minute.toString().padLeft(2, '0')}');
  }

  /// Cancel the daily reminder
  Future<void> cancelDailyReminder() async {
    await _notifications.cancel(_dailyReminderId);
    debugPrint('🚫 Daily reminder cancelled');
  }

  /// Get a random empathetic reminder message
  String _getRandomMessage() {
    final random = Random();
    return _reminderMessages[random.nextInt(_reminderMessages.length)];
  }

  /// Calculate the next occurrence of the specified time
  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // If the time has already passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  /// Handle notification tap - navigate to check-in screen
  static void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload == 'daily_checkin') {
      // This will be handled by the main app through a callback
      _notificationTapCallback?.call();
    }
  }

  // Callback for notification tap navigation
  static VoidCallback? _notificationTapCallback;

  /// Set callback to handle notification tap navigation
  static void setOnNotificationTap(VoidCallback callback) {
    _notificationTapCallback = callback;
  }

  /// Parse time string from Supabase (format: "HH:MM:SS" or "HH:MM:SS+TZ")
  /// Returns null if parsing fails
  static TimeOfDay? parseTimeFromSupabase(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return null;

    try {
      // Extract HH:MM from the time string
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        return TimeOfDay(hour: hour, minute: minute);
      }
    } catch (e) {
      debugPrint('Failed to parse time: $timeStr. Error: $e');
    }

    return null;
  }

  /// Default reminder time (21:00) if user hasn't set one
  static TimeOfDay get defaultReminderTime =>
      const TimeOfDay(hour: 21, minute: 0);
}
