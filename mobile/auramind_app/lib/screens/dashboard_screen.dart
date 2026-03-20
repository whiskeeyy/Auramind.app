import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  String? _error;

  // Computed stats
  double _avgMood = 0;
  double _avgStress = 0;
  double _avgEnergy = 0;
  List<FlSpot> _moodTrend = [];
  List<String> _trendLabels = [];
  Map<String, int> _emotionCounts = {};
  Map<String, int> _activityCounts = {};
  int _totalLogs = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = await _authService.getAccessToken();
      if (token == null) {
        throw Exception('Chưa đăng nhập');
      }

      final apiService = ApiService(authToken: token);
      final logs = await apiService.getMoodLogs();

      if (logs.isEmpty) {
        if (mounted) {
          setState(() {
            _totalLogs = 0;
            _isLoading = false;
          });
        }
        return;
      }

      _totalLogs = logs.length;

      // Sort by created_at desc
      logs.sort((a, b) {
        final aDate = DateTime.tryParse(a['created_at'] ?? '') ?? DateTime(2000);
        final bDate = DateTime.tryParse(b['created_at'] ?? '') ?? DateTime(2000);
        return bDate.compareTo(aDate);
      });

      // Compute averages (all logs)
      double totalMood = 0, totalStress = 0, totalEnergy = 0;
      for (var log in logs) {
        totalMood += (log['mood_score'] as num?)?.toDouble() ?? 5.0;
        totalStress += (log['stress_level'] as num?)?.toDouble() ?? 5.0;
        totalEnergy += (log['energy_level'] as num?)?.toDouble() ?? 5.0;
      }
      _avgMood = totalMood / logs.length;
      _avgStress = totalStress / logs.length;
      _avgEnergy = totalEnergy / logs.length;

      // Last 7 logs for trend
      final recentLogs = logs.take(7).toList().reversed.toList();
      _moodTrend = [];
      _trendLabels = [];
      for (int i = 0; i < recentLogs.length; i++) {
        final mood = (recentLogs[i]['mood_score'] as num?)?.toDouble() ?? 5.0;
        _moodTrend.add(FlSpot(i.toDouble(), mood));
        final dateStr = recentLogs[i]['created_at'] as String? ?? '';
        if (dateStr.length >= 10) {
          final date = DateTime.tryParse(dateStr);
          if (date != null) {
            _trendLabels.add('${date.day}/${date.month}');
          } else {
            _trendLabels.add('');
          }
        } else {
          _trendLabels.add('');
        }
      }

      // Emotion distribution
      _emotionCounts = {};
      for (var log in logs) {
        final emotion = log['primary_emotion'] as String? ?? 'neutral';
        _emotionCounts[emotion] = (_emotionCounts[emotion] ?? 0) + 1;
      }

      // Activity frequency
      _activityCounts = {};
      for (var log in logs) {
        final activities = log['activities'] as List<dynamic>?;
        if (activities != null) {
          for (var activity in activities) {
            final name = activity.toString();
            _activityCounts[name] = (_activityCounts[name] ?? 0) + 1;
          }
        }
      }

      if (mounted) {
        setState(() => _isLoading = false);
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDashboardData,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_totalLogs == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.insert_chart_outlined, size: 64, color: Theme.of(context).colorScheme.primary.withOpacity(0.4)),
            const SizedBox(height: 16),
            Text(
              'Chưa có dữ liệu',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Hãy thực hiện Check-in đầu tiên\nđể xem thống kê tại đây!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverviewCard(context),
            const SizedBox(height: 24),
            if (_moodTrend.isNotEmpty) ...[
              _buildSectionTitle(context, 'Xu hướng tâm trạng'),
              const SizedBox(height: 12),
              _buildMoodChart(context),
              const SizedBox(height: 24),
            ],
            if (_emotionCounts.isNotEmpty) ...[
              _buildSectionTitle(context, 'Phân bố cảm xúc'),
              const SizedBox(height: 12),
              _buildEmotionPieChart(context),
              const SizedBox(height: 24),
            ],
            if (_activityCounts.isNotEmpty) ...[
              _buildSectionTitle(context, 'Hoạt động gần đây'),
              const SizedBox(height: 12),
              _buildActivityList(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildOverviewCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(context, _avgMood.toStringAsFixed(1), 'Avg Mood', Icons.mood, Colors.green),
            _buildStatItem(context, _avgStress.toStringAsFixed(1), 'Avg Stress', Icons.warning_amber, Colors.orange),
            _buildStatItem(context, _avgEnergy.toStringAsFixed(1), 'Avg Energy', Icons.bolt, Colors.amber),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildMoodChart(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: true),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) => Text(value.toInt().toString()),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx >= 0 && idx < _trendLabels.length) {
                        return Text(_trendLabels[idx], style: const TextStyle(fontSize: 10));
                      }
                      return const Text('');
                    },
                  ),
                ),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              minY: 0,
              maxY: 10,
              lineBarsData: [
                LineChartBarData(
                  spots: _moodTrend,
                  isCurved: true,
                  color: Theme.of(context).colorScheme.primary,
                  barWidth: 3,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmotionPieChart(BuildContext context) {
    final colors = [Colors.green, Colors.blue, Colors.orange, Colors.red, Colors.purple, Colors.teal];
    final total = _emotionCounts.values.fold(0, (a, b) => a + b);
    final entries = _emotionCounts.entries.toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 200,
          child: Row(
            children: [
              Expanded(
                child: PieChart(
                  PieChartData(
                    sections: entries.asMap().entries.map((e) {
                      final idx = e.key;
                      final entry = e.value;
                      final pct = (entry.value / total * 100).round();
                      return PieChartSectionData(
                        value: entry.value.toDouble(),
                        title: '$pct%',
                        color: colors[idx % colors.length],
                        radius: 70,
                        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                      );
                    }).toList(),
                    sectionsSpace: 2,
                    centerSpaceRadius: 0,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: entries.asMap().entries.map((e) {
                  final idx = e.key;
                  final entry = e.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 12, height: 12, color: colors[idx % colors.length]),
                        const SizedBox(width: 6),
                        Text(entry.key, style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityList(BuildContext context) {
    final sortedActivities = _activityCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final topActivities = sortedActivities.take(6).toList();

    final iconMap = <String, IconData>{
      'Work': Icons.work,
      'Exercise': Icons.fitness_center,
      'Social': Icons.people,
      'Rest': Icons.bed,
      'Coding': Icons.code,
      'Reading': Icons.menu_book,
      'Gaming': Icons.sports_esports,
      'Meditation': Icons.self_improvement,
    };

    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: topActivities.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final activity = topActivities[index];
          return ListTile(
            leading: Icon(iconMap[activity.key] ?? Icons.circle),
            title: Text(activity.key),
            trailing: Chip(label: Text('${activity.value} lần')),
          );
        },
      ),
    );
  }
}
