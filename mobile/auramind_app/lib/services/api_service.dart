import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      'http://localhost:8000'; // Update with your backend URL

  final String? _authToken;

  /// Create an API service instance
  /// If authToken is provided, it will be included in all requests
  ApiService({String? authToken}) : _authToken = authToken;

  /// Get headers with optional authentication
  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  Future<Map<String, dynamic>> createMoodLog({
    required int moodScore,
    required int stressLevel,
    required int energyLevel,
    String? note,
    List<String>? activities,
    String? voiceTranscript,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/mood-logs/'),
        headers: _headers,
        body: jsonEncode({
          'mood_score': moodScore,
          'stress_level': stressLevel,
          'energy_level': energyLevel,
          'note': note,
          'activities': activities ?? [],
          'voice_transcript': voiceTranscript,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else {
        throw Exception('Failed to create mood log: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getMoodLogs() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/mood-logs/'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else {
        throw Exception('Failed to fetch mood logs: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Health check failed');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
