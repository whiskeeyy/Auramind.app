import 'package:flutter/material.dart';
import 'dart:ui';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final AuthService _authService = AuthService();
  ApiService? _apiService;

  DateTime _focusedMonth = DateTime.now();
  Map<String, dynamic>? _calendarData;
  bool _isLoading = true;
  bool _isAnalyzing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initAndLoad();
  }

  Future<void> _initAndLoad() async {
    final token = await _authService.getAccessToken();
    _apiService = ApiService(authToken: token);
    await _loadCalendarData();
  }

  Future<void> _loadCalendarData() async {
    if (_apiService == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _apiService!.getCalendarData(
        month: _focusedMonth.month,
        year: _focusedMonth.year,
        includeInsight: false, // Don't auto-load insight
      );

      if (mounted) {
        setState(() {
          _calendarData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    });
    _loadCalendarData();
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
    _loadCalendarData();
  }

  /// Trigger AI insight analysis on-demand
  Future<void> _analyzeMonth() async {
    if (_apiService == null) return;

    setState(() => _isAnalyzing = true);

    try {
      final data = await _apiService!.getCalendarData(
        month: _focusedMonth.month,
        year: _focusedMonth.year,
        includeInsight: true,
      );

      if (mounted) {
        setState(() {
          _calendarData = data;
          _isAnalyzing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAnalyzing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Lỗi phân tích: ${e.toString().replaceAll("Exception: ", "")}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
              Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.3),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildInsightSection(),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? _buildErrorView()
                        : _buildCalendarGrid(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final monthNames = [
      'Tháng 1',
      'Tháng 2',
      'Tháng 3',
      'Tháng 4',
      'Tháng 5',
      'Tháng 6',
      'Tháng 7',
      'Tháng 8',
      'Tháng 9',
      'Tháng 10',
      'Tháng 11',
      'Tháng 12'
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _previousMonth,
          ),
          Text(
            '${monthNames[_focusedMonth.month - 1]} ${_focusedMonth.year}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _nextMonth,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightSection() {
    final insight = _calendarData?['monthly_insight'] as String?;
    final totalLogs = _calendarData?['total_logs'] as int? ?? 0;

    // Don't show anything if no data
    if (totalLogs < 3 && insight == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .primaryContainer
                  .withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            child: insight != null
                ? Row(
                    children: [
                      const Icon(Icons.lightbulb,
                          color: Colors.amber, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          insight,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      const Icon(Icons.auto_awesome, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Nhấn để xem xu hướng cảm xúc tháng này',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      _isAnalyzing
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : FilledButton.tonal(
                              onPressed: _analyzeMonth,
                              child: const Text('Phân tích'),
                            ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(_error ?? 'Đã có lỗi xảy ra'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadCalendarData,
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final firstDayOfMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final firstWeekday = firstDayOfMonth.weekday; // 1 = Monday

    // Build day data map
    final dayDataMap = <String, Map<String, dynamic>>{};
    final days = _calendarData?['days'] as List? ?? [];
    for (var day in days) {
      dayDataMap[day['date']] = day;
    }

    final weekDays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Weekday headers
          Row(
            children: weekDays
                .map((day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: day == 'CN' ? Colors.red[300] : null,
                                  ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          // Calendar grid
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: 42, // 6 weeks max
              itemBuilder: (context, index) {
                final dayOffset = index - (firstWeekday - 1);

                if (dayOffset < 0 || dayOffset >= daysInMonth) {
                  return const SizedBox(); // Empty cell
                }

                final dayNumber = dayOffset + 1;
                final dateStr =
                    '${_focusedMonth.year}-${_focusedMonth.month.toString().padLeft(2, '0')}-${dayNumber.toString().padLeft(2, '0')}';
                final dayData = dayDataMap[dateStr];

                return _buildDayCell(dayNumber, dayData);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCell(int day, Map<String, dynamic>? data) {
    final hasData = data != null;
    final moodScore = data?['average_mood_score'] as double? ?? 5.0;
    final avatarState =
        data?['primary_avatar_state'] as String? ?? 'STATE_NEUTRAL';

    // Mood-based color palette (pastel)
    Color cellColor;
    if (!hasData) {
      cellColor = Colors.grey.withOpacity(0.1);
    } else if (moodScore >= 7) {
      cellColor = Colors.green[100]!;
    } else if (moodScore >= 5) {
      cellColor = Colors.blue[50]!;
    } else if (moodScore >= 3) {
      cellColor = Colors.orange[100]!;
    } else {
      cellColor = Colors.purple[100]!;
    }

    // Avatar state emoji
    String emoji = _getAvatarEmoji(avatarState);

    return GestureDetector(
      onTap: hasData ? () => _showDayDetail(day, data) : null,
      child: Container(
        decoration: BoxDecoration(
          color: cellColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: hasData
                ? Theme.of(context).colorScheme.outline.withOpacity(0.3)
                : Colors.transparent,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Day number
            Positioned(
              top: 4,
              left: 6,
              child: Text(
                '$day',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: hasData ? FontWeight.bold : FontWeight.normal,
                  color: hasData ? Colors.black87 : Colors.grey[400],
                ),
              ),
            ),
            // Avatar emoji (if has data)
            if (hasData)
              Positioned(
                bottom: 4,
                child: Text(emoji, style: const TextStyle(fontSize: 16)),
              ),
          ],
        ),
      ),
    );
  }

  String _getAvatarEmoji(String state) {
    switch (state) {
      case 'STATE_JOYFUL':
        return '😊';
      case 'STATE_SAD':
        return '😔';
      case 'STATE_ANXIOUS':
        return '😟';
      case 'STATE_EXHAUSTED':
        return '😫';
      case 'STATE_OVERWHELMED':
        return '😵';
      default:
        return '😐';
    }
  }

  void _showDayDetail(int day, Map<String, dynamic> data) {
    final activities = (data['top_activities'] as List?)?.cast<String>() ?? [];
    final moodScore = data['average_mood_score'] as double? ?? 5.0;
    final logCount = data['log_count'] as int? ?? 0;
    final avatarState =
        data['primary_avatar_state'] as String? ?? 'STATE_NEUTRAL';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Text(
                      _getAvatarEmoji(avatarState),
                      style: const TextStyle(fontSize: 40),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ngày $day',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          '$logCount lần check-in',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Mood Score
                Row(
                  children: [
                    const Icon(Icons.favorite, color: Colors.pink),
                    const SizedBox(width: 8),
                    Text('Mood trung bình: '),
                    Text(
                      '${moodScore.toStringAsFixed(1)}/10',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Activities
                if (activities.isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(Icons.local_activity, color: Colors.orange),
                      const SizedBox(width: 8),
                      const Text('Hoạt động:'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: activities
                        .map((activity) => Chip(
                              label: Text(activity),
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer,
                            ))
                        .toList(),
                  ),
                ],

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
