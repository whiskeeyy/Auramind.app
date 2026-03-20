import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:supabase_flutter/supabase_flutter.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  Set<String> _earnedBadges = {};
  Map<String, String> _earnedAt = {};

  // Badge Definitions (Synced with Backend)
  final List<Map<String, dynamic>> _badges = [
    {
      'code': 'FIRST_STEP',
      'name': 'Khởi đầu mới',
      'desc': 'Ghi nhật ký cảm xúc lần đầu tiên',
      'icon': Icons.eco,
      'color': Colors.green,
    },
    {
      'code': 'STREAK_3',
      'name': 'Đà cảm xúc',
      'desc': 'Chuỗi 3 ngày liên tiếp',
      'icon': Icons.local_fire_department,
      'color': Colors.orange,
    },
    {
      'code': 'STREAK_7',
      'name': 'Thói quen tốt',
      'desc': 'Chuỗi 7 ngày liên tiếp',
      'icon': Icons.auto_awesome,
      'color': Colors.purple,
    },
    {
      'code': 'STREAK_30',
      'name': 'Bậc thầy cảm xúc',
      'desc': 'Chuỗi 30 ngày liên tiếp',
      'icon': Icons.workspace_premium,
      'color': Colors.amber,
    },
    {
      'code': 'EARLY_BIRD',
      'name': 'Chào ngày mới',
      'desc': 'Ghi nhật ký từ 5:00 - 8:00 sáng',
      'icon': Icons.wb_sunny,
      'color': Colors.blue,
    },
    {
      'code': 'NIGHT_OWL',
      'name': 'Cú đêm tâm sự',
      'desc': 'Ghi nhật ký từ 23:00 - 4:00 sáng',
      'icon': Icons.nightlight_round,
      'color': Colors.indigo,
    },
    {
      'code': 'BALANCE_MASTER',
      'name': 'Cân bằng hoàn hảo',
      'desc': 'Tâm trạng tốt + Ngủ đủ giấc',
      'icon': Icons.balance,
      'color': Colors.teal,
    },
    {
      'code': 'ACTIVE_SOUL',
      'name': 'Tâm hồn năng động',
      'desc': 'Đi bộ hơn 5000 bước',
      'icon': Icons.directions_run,
      'color': Colors.redAccent,
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchAchievements();
  }

  Future<void> _fetchAchievements() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await _supabase
          .from('user_achievements')
          .select('badge_code, earned_at')
          .eq('user_id', userId);

      final earned = <String>{};
      final earnedDates = <String, String>{};

      for (var record in response) {
        final code = record['badge_code'] as String;
        earned.add(code);

        final date = DateTime.parse(record['earned_at']).toLocal();
        earnedDates[code] = '${date.day}/${date.month}/${date.year}';
      }

      if (mounted) {
        setState(() {
          _earnedBadges = earned;
          _earnedAt = earnedDates;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching achievements: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: _badges.length,
            itemBuilder: (context, index) {
              final badge = _badges[index];
              final isEarned = _earnedBadges.contains(badge['code']);
              return _buildBadgeCard(theme, badge, isEarned);
            },
          );
  }

  Widget _buildBadgeCard(ThemeData theme, Map<String, dynamic> badge, bool isEarned) {
    final badgeColor = badge['color'] as Color;
    final isDark = theme.brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? theme.colorScheme.surfaceContainerHighest.withOpacity(0.7)
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isEarned
                  ? badgeColor.withOpacity(0.4)
                  : theme.colorScheme.outline.withOpacity(0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: isEarned
                    ? badgeColor.withOpacity(0.15)
                    : Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
              // Inner glow for Claymorphism effect
              if (isEarned)
                BoxShadow(
                  color: badgeColor.withOpacity(0.08),
                  blurRadius: 20,
                  spreadRadius: -2,
                ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Badge icon with circular background
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isEarned
                      ? badgeColor.withOpacity(0.15)
                      : theme.colorScheme.onSurface.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  badge['icon'] as IconData,
                  size: 32,
                  color: isEarned
                      ? badgeColor
                      : theme.colorScheme.onSurface.withOpacity(0.3),
                ),
              ),
              const SizedBox(height: 12),
              // Badge name
              Text(
                badge['name'],
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isEarned
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurface.withOpacity(0.4),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              // Badge description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  badge['desc'],
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),
              // Earned date or lock icon
              if (isEarned)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _earnedAt[badge['code']] ?? '',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: badgeColor,
                    ),
                  ),
                )
              else
                Icon(
                  Icons.lock_outline,
                  size: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
