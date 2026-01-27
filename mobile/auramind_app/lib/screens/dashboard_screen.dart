import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Weekly Overview Card
            _buildOverviewCard(context),
            const SizedBox(height: 24),

            // Mood Trend Chart
            _buildSectionTitle(context, 'Mood Trend (7 Days)'),
            const SizedBox(height: 12),
            _buildMoodChart(context),
            const SizedBox(height: 24),

            // Emotion Distribution
            _buildSectionTitle(context, 'Emotion Distribution'),
            const SizedBox(height: 12),
            _buildEmotionPieChart(context),
            const SizedBox(height: 24),

            // Recent Activities
            _buildSectionTitle(context, 'Recent Activities'),
            const SizedBox(height: 12),
            _buildActivityList(context),
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
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                    context, '7.2', 'Avg Mood', Icons.mood, Colors.green),
                _buildStatItem(context, '4.5', 'Avg Stress',
                    Icons.warning_amber, Colors.orange),
                _buildStatItem(
                    context, '6.8', 'Avg Energy', Icons.bolt, Colors.amber),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label,
      IconData icon, Color color) {
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
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
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
                    getTitlesWidget: (value, meta) {
                      return Text(value.toInt().toString());
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      const days = [
                        'Mon',
                        'Tue',
                        'Wed',
                        'Thu',
                        'Fri',
                        'Sat',
                        'Sun'
                      ];
                      if (value.toInt() >= 0 && value.toInt() < days.length) {
                        return Text(days[value.toInt()]);
                      }
                      return const Text('');
                    },
                  ),
                ),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              minY: 0,
              maxY: 10,
              lineBarsData: [
                LineChartBarData(
                  spots: [
                    const FlSpot(0, 6),
                    const FlSpot(1, 7),
                    const FlSpot(2, 5),
                    const FlSpot(3, 8),
                    const FlSpot(4, 7),
                    const FlSpot(5, 6),
                    const FlSpot(6, 8),
                  ],
                  isCurved: true,
                  color: Theme.of(context).colorScheme.primary,
                  barWidth: 3,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                  value: 40,
                  title: '😄 40%',
                  color: Colors.green,
                  radius: 80,
                ),
                PieChartSectionData(
                  value: 30,
                  title: '😐 30%',
                  color: Colors.blue,
                  radius: 80,
                ),
                PieChartSectionData(
                  value: 20,
                  title: '😢 20%',
                  color: Colors.orange,
                  radius: 80,
                ),
                PieChartSectionData(
                  value: 10,
                  title: '😰 10%',
                  color: Colors.red,
                  radius: 80,
                ),
              ],
              sectionsSpace: 2,
              centerSpaceRadius: 0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityList(BuildContext context) {
    final activities = [
      {'name': 'Coding', 'count': 5, 'icon': Icons.code},
      {'name': 'Exercise', 'count': 3, 'icon': Icons.fitness_center},
      {'name': 'Social', 'count': 4, 'icon': Icons.people},
      {'name': 'Rest', 'count': 7, 'icon': Icons.bed},
    ];

    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: activities.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final activity = activities[index];
          return ListTile(
            leading: Icon(activity['icon'] as IconData),
            title: Text(activity['name'] as String),
            trailing: Chip(
              label: Text('${activity['count']} times'),
            ),
          );
        },
      ),
    );
  }
}
