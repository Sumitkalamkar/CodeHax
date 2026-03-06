import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/app_constants.dart';
import '../models/api_response.dart';
import 'auth_service.dart';
class ApiService {
  // Send code to backend for debugging
  static Future<DebugResponse> debugCode({
    required String code,
    required String language,
    String error = '',
    String context = '',
  }) async {
    try {
      final headers = await authService.getHeaders();

      final response = await http.post(
        Uri.parse('${AppConstants.backendUrl}${AppConstants.debugEndpoint}'),
        headers: headers,
        body: jsonEncode({
          'code': code,
          'error': error,
          'language': language,
          'context': context,
        }),
      ).timeout(const Duration(minutes: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return DebugResponse.fromJson(data);
      } else {
        throw ApiError(
          message: 'Server error: ${response.statusCode}',
          code: response.statusCode.toString(),
        );
      }
    } on http.ClientException catch (e) {
      throw ApiError(
        message: 'Connection error: ${e.message}',
        originalError: e,
      );
    } on FormatException catch (e) {
      throw ApiError(
        message: 'Invalid response format: ${e.message}',
        originalError: e,
      );
    } catch (e) {
      throw ApiError(
        message: 'Error: ${e.toString()}',
        originalError: e,
      );
    }
  }

  // Send chat message to backend
  static Future<DebugResponse> sendChatMessage({
  required String message,
  required String language,
  required String sessionId,   
}) async {
  try {
    final headers = await authService.getHeaders();

    final response = await http.post(
      Uri.parse('${AppConstants.backendUrl}${AppConstants.debugEndpoint}'),
      headers: headers,
      body: jsonEncode({
        'code': message,
        'error': '',
        'language': language,
        'context': 'Generate or explain code',
        'session_id': sessionId,   // 🔥 VERY IMPORTANT
      }),
    ).timeout(const Duration(minutes: 8));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return DebugResponse.fromJson(data);
    } else {
      throw ApiError(
        message: 'Server error: ${response.statusCode}',
        code: response.statusCode.toString(),
      );
    }
  } on http.ClientException catch (e) {
    throw ApiError(
      message: 'Connection error: ${e.message}',
      originalError: e,
    );
  } on FormatException catch (e) {
    throw ApiError(
      message: 'Invalid response format: ${e.message}',
      originalError: e,
    );
  } catch (e) {
    throw ApiError(
      message: 'Error: ${e.toString()}',
      originalError: e,
    );
  }
}

  // Save chat to backend
  static Future<void> saveChat({
    required String userPrompt,
    required String aiResponse,
    required String language,
    required String responseType,
  }) async {
    final headers = await authService.getHeaders();

    final response = await http.post(
      Uri.parse('${AppConstants.backendUrl}/chat/save'),
      headers: headers,
      body: jsonEncode({
        "user_prompt": userPrompt,
        "ai_response": aiResponse,
        "language": language,
        "response_type": responseType,
      }),
    );

    if (response.statusCode != 200) {
      throw ApiError(
        message: "Failed to save chat",
        code: response.statusCode.toString(),
      );
    }
  } 


  // Check if backend is online
  static Future<bool> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.backendUrl}/health'),
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
