import 'package:flutter/material.dart';

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
                onPressed: _submitCheckin,
                icon: const Icon(Icons.check),
                label: const Text('Save Check-in'),
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

  void _submitCheckin() {
    // TODO: Implement API call to backend
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Check-in saved! (API integration pending)')),
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }
}
