import '../constants/app_constants.dart';
import 'auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatHistoryService {
  Future<Map<String, dynamic>> getHistory({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final token = await authService.getToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }

      final response = await http.get(
        Uri.parse('${AppConstants.backendUrl}/chat/history?page=$page&limit=$limit'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        print('✓ Loaded history from backend');
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return {'success': false, 'error': 'Failed to fetch history'};
    } catch (e) {
      print('✗ Error fetching history: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> saveChat({
    required String userPrompt,
    required String aiResponse,
    required String language,
    required String responseType,
    required String fixedCode,
    required List<String> tips,
    String? sessionId,
  }) async {
    try {
      final token = await authService.getToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }

      // GENERATE SESSION ID IF NOT PROVIDED
      final finalSessionId = sessionId ?? DateTime.now().millisecondsSinceEpoch.toString();

      print('Saving with session_id: $finalSessionId');

      final response = await http.post(
        Uri.parse('${AppConstants.backendUrl}/chat/save'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'user_prompt': userPrompt,
          'ai_response': aiResponse,
          'fixed_code': fixedCode,
          'tips': tips,
          'language': language,
          'response_type': responseType,
          'session_id': finalSessionId, // CRITICAL: PASS SESSION ID!
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✓ Chat saved successfully with session_id: $finalSessionId');
        return {
          'success': true,
          'id': data['id'],
          'session_id': finalSessionId,
        };
      }
      print('✗ Backend returned ${response.statusCode}');
      return {'success': false, 'error': 'Failed to save chat'};
    } catch (e) {
      print('✗ Error saving chat: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getSessionMessages(String sessionId) async {
    try {
      final token = await authService.getToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }

      final response = await http.get(
        Uri.parse('${AppConstants.backendUrl}/chat/session/$sessionId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return {'success': false, 'error': 'Failed to fetch session'};
    } catch (e) {
      print('Error fetching session: $e');
      return {'success': false, 'error': e.toString()};
    }
  }
}

final chatHistoryService = ChatHistoryService();
