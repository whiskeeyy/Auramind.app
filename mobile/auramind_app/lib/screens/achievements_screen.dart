import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

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
      'icon': '🌱',
      'color': Colors.green,
    },
    {
      'code': 'STREAK_3',
      'name': 'Đà cảm xúc',
      'desc': 'Chuỗi 3 ngày liên tiếp',
      'icon': '🔥',
      'color': Colors.orange,
    },
    {
      'code': 'STREAK_7',
      'name': 'Thói quen tốt',
      'desc': 'Chuỗi 7 ngày liên tiếp',
      'icon': '✨',
      'color': Colors.purple,
    },
    {
      'code': 'STREAK_30',
      'name': 'Bậc thầy cảm xúc',
      'desc': 'Chuỗi 30 ngày liên tiếp',
      'icon': '👑',
      'color': Colors.amber,
    },
    {
      'code': 'EARLY_BIRD',
      'name': 'Chào ngày mới',
      'desc': 'Ghi nhật ký từ 5:00 - 8:00 sáng',
      'icon': '🌅',
      'color': Colors.blue,
    },
    {
      'code': 'NIGHT_OWL',
      'name': 'Cú đêm tâm sự',
      'desc': 'Ghi nhật ký từ 23:00 - 4:00 sáng',
      'icon': '🦉',
      'color': Colors.indigo,
    },
    {
      'code': 'BALANCE_MASTER',
      'name': 'Cân bằng hoàn hảo',
      'desc': 'Tâm trạng tốt + Ngủ đủ giấc',
      'icon': '⚖️',
      'color': Colors.teal,
    },
    {
      'code': 'ACTIVE_SOUL',
      'name': 'Tâm hồn năng động',
      'desc': 'Đi bộ hơn 5000 bước',
      'icon': '👟',
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

        // Format date simply
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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'Thành tựu',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
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

                return _buildBadgeCard(badge, isEarned);
              },
            ),
    );
  }

  Widget _buildBadgeCard(Map<String, dynamic> badge, bool isEarned) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isEarned
                  ? (badge['color'] as Color).withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Text(
              badge['icon'],
              style: TextStyle(
                fontSize: 40,
                color: isEarned
                    ? null
                    : Colors
                        .grey, // Grayscale effect via color filter logic ideally, but text color works for emojis mostly
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            badge['name'],
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isEarned ? Colors.black87 : Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              badge['desc'],
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          if (isEarned)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: (badge['color'] as Color).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _earnedAt[badge['code']] ?? '',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: badge['color'],
                ),
              ),
            )
          else
            Icon(Icons.lock_outline, size: 16, color: Colors.grey[400]),
        ],
      ),
    );
  }
}
