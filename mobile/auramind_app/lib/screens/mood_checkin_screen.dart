import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class MoodCheckinScreen extends StatefulWidget {
  const MoodCheckinScreen({super.key});

  @override
  State<MoodCheckinScreen> createState() => _MoodCheckinScreenState();
}

class _MoodCheckinScreenState extends State<MoodCheckinScreen> {
  double _moodScore = 5.0;
  double _stressLevel = 5.0;
  double _energyLevel = 5.0;
  final TextEditingController _noteController = TextEditingController();
  final List<String> _selectedActivities = [];
  final AuthService _authService = AuthService();
  bool _isSubmitting = false;

  final List<String> _activityOptions = [
    'Work',
    'Exercise',
    'Social',
    'Rest',
    'Coding',
    'Reading',
    'Gaming',
    'Meditation',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Check-in'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mood Score
            _buildSlider(
              label: 'How are you feeling?',
              value: _moodScore,
              emoji: _getMoodEmoji(_moodScore),
              color: _getMoodColor(_moodScore),
              onChanged: (value) => setState(() => _moodScore = value),
            ),
            const SizedBox(height: 24),

            // Stress Level
            _buildSlider(
              label: 'Stress Level',
              value: _stressLevel,
              emoji: '😰',
              color: Colors.orange,
              onChanged: (value) => setState(() => _stressLevel = value),
            ),
            const SizedBox(height: 24),

            // Energy Level
            _buildSlider(
              label: 'Energy Level',
              value: _energyLevel,
              emoji: '⚡',
              color: Colors.amber,
              onChanged: (value) => setState(() => _energyLevel = value),
            ),
            const SizedBox(height: 32),

            // Activities
            Text(
              'What did you do today?',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _activityOptions.map((activity) {
                final isSelected = _selectedActivities.contains(activity);
                return FilterChip(
                  label: Text(activity),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedActivities.add(activity);
                      } else {
                        _selectedActivities.remove(activity);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // Note
            TextField(
              controller: _noteController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'How was your day?',
                hintText: 'Share your thoughts...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isSubmitting ? null : _submitCheckin,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check),
                label: Text(_isSubmitting ? 'Saving...' : 'Save Check-in'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required String emoji,
    required Color color,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                value.toInt().toString(),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: value,
          min: 1,
          max: 10,
          divisions: 9,
          activeColor: color,
          onChanged: onChanged,
        ),
      ],
    );
  }

  String _getMoodEmoji(double score) {
    if (score <= 3) return '😢';
    if (score <= 5) return '😐';
    if (score <= 7) return '🙂';
    return '😄';
  }

  Color _getMoodColor(double score) {
    if (score <= 3) return Colors.red;
    if (score <= 5) return Colors.orange;
    if (score <= 7) return Colors.blue;
    return Colors.green;
  }

  Future<void> _submitCheckin() async {
    setState(() => _isSubmitting = true);

    try {
      // Get auth token
      final token = await _authService.getAccessToken();

      if (token == null) {
        throw Exception('Not authenticated. Please login again.');
      }

      // Create API service with auth token
      final apiService = ApiService(authToken: token);

      // Submit mood log
      final response = await apiService.createMoodLog(
        moodScore: _moodScore.toInt(),
        stressLevel: _stressLevel.toInt(),
        energyLevel: _energyLevel.toInt(),
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        activities: _selectedActivities,
      );

      if (mounted) {
        // Check for new achievements
        final newAchievements = response['new_achievements'] as List<dynamic>?;

        if (newAchievements != null && newAchievements.isNotEmpty) {
          await _showAchievementDialog(newAchievements);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Check-in saved successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }

        // Reset form
        setState(() {
          _moodScore = 5.0;
          _stressLevel = 5.0;
          _energyLevel = 5.0;
          _noteController.clear();
          _selectedActivities.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '❌ Failed to save: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _showAchievementDialog(List<dynamic> newBadges) async {
    for (var badge in newBadges) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '🎉 Chúc mừng! 🎉',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 20),
                // Badge Icon with Glow
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Text(
                    '🏆', // You could look up the emoji from badge code if available
                    style: TextStyle(fontSize: 50),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  badge['name'] ?? 'Huy hiệu mới',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  badge['description'] ?? 'Bạn vừa mở khóa một thành tựu mới!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Tuyệt vời!'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }
}
