// Data models for type-safe API responses

class DebugResponse {
  final String solution;
  final String explanation;
  final String fixedCode;
  final List<String> tips;

  DebugResponse({
    required this.solution,
    required this.explanation,
    required this.fixedCode,
    required this.tips,
  });

  // Create from JSON
  factory DebugResponse.fromJson(Map<String, dynamic> json) {
    return DebugResponse(
      solution: json['solution'] ?? 'No solution available',
      explanation: json['explanation'] ?? 'No explanation available',
      fixedCode: json['fixed_code'] ?? 'No code available',
      tips: List<String>.from(json['tips'] ?? []),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() => {
        'solution': solution,
        'explanation': explanation,
        'fixed_code': fixedCode,
        'tips': tips,
      };
}

class ChatMessage {
  final String text;
  final bool isUser;
  final String? code;
  final List<String>? tips;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.code,
    this.tips,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  // Create from API response
  factory ChatMessage.fromResponse(DebugResponse response) {
    return ChatMessage(
      text: '${response.solution}\n\n${response.explanation}',
      isUser: false,
      code: response.fixedCode,
      tips: response.tips,
    );
  }

  // Create user message
  factory ChatMessage.user(String text) {
    return ChatMessage(
      text: text,
      isUser: true,
    );
  }
}

class ApiError {
  final String message;
  final String? code;
  final dynamic originalError;

  ApiError({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => 'ApiError: $message ${code != null ? '(Code: $code)' : ''}';
}
