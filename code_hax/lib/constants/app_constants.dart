import 'package:flutter/material.dart';

class AppConstants {
  // Backend URL - UPDATE WITH YOUR IP
  static const String backendUrl = 'http://localhost:8000';

  // Colors
  static const Color primaryDark = Color(0xFF0a0e27);
  static const Color secondaryDark = Color(0xFF1a1f3a);
  static const Color accentGreen = Color(0xFF00ff00);
  static const Color accentCyan = Color(0xFF00ffff);
  static const Color accentOrange = Color(0xFFffa500);
  static const Color accentLime = Color(0xFF00ff00);
  static const Color accentAmber = Color(0xFFffc107);

  // Strings
  static const String appName = 'CodeHax';
  static const String appSubtitle = 'Elite Code Debugger & AI Chat';
  static const String debuggerTab = 'Debugger';
  static const String chatTab = 'Chat';
  static const String scanForBugs = 'SCAN FOR BUGS';
  static const String analyzing = 'ANALYZING...';
  static const String enterCode = 'Enter code to debug';
  static const String errorMessage = 'ERROR MESSAGE (optional)';
  static const String context = 'CONTEXT (optional)';
  static const String selectLanguage = 'SELECT LANGUAGE';
  static const String solution = 'SOLUTION';
  static const String explanation = 'EXPLANATION';
  static const String fixedCode = 'FIXED CODE';
  static const String quickTips = 'QUICK TIPS';
  static const String copiedToClipboard = 'Copied to clipboard';

  // Languages
  static const List<String> supportedLanguages = [
    'python',
    'javascript',
    'java',
    'cpp',
    'rust',
    'go',
    'csharp',
    'typescript',
  ];

  // API Endpoints
  static const String debugEndpoint = '/debug';
}
