import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_constants.dart';
import '../models/api_response.dart';
import '../services/api_service.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class DebuggerPage extends StatefulWidget {
  const DebuggerPage({Key? key}) : super(key: key);

  @override
  State<DebuggerPage> createState() => _DebuggerPageState();
}

class _DebuggerPageState extends State<DebuggerPage>
    with SingleTickerProviderStateMixin {
  late TextEditingController codeController;
  late TextEditingController errorController;
  late TextEditingController contextController;
  String selectedLanguage = 'python';
  bool isLoading = false;
  DebugResponse? debugResult;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    codeController = TextEditingController();
    errorController = TextEditingController();
    contextController = TextEditingController();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
  }

  @override
  void dispose() {
    codeController.dispose();
    errorController.dispose();
    contextController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _debugCode() async {
    if (codeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter code to debug')),
      );
      return;
    }

    setState(() => isLoading = true);
    _animController.forward(from: 0.0);

    try {
      final response = await ApiService.debugCode(
        code: codeController.text,
        error: errorController.text,
        language: selectedLanguage,
        context: contextController.text,
      );

      setState(() {
        debugResult = response;
      });

      _showResultModal();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showResultModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppConstants.secondaryDark,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.green.shade400, width: 2),
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'DEBUG RESULT',
                      style: GoogleFonts.robotoMono(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close, color: Colors.green),
                    )
                  ],
                ),
                const SizedBox(height: 20),
                _buildResultSection(
                  'SOLUTION',
                  debugResult?.solution ?? '',
                  AppConstants.accentCyan,
                ),
                const SizedBox(height: 20),
                _buildResultSection(
                  'EXPLANATION',
                  debugResult?.explanation ?? '',
                  AppConstants.accentAmber,
                ),
                const SizedBox(height: 20),
                _buildCodeSection(
                  'FIXED CODE',
                  debugResult?.fixedCode ?? '',
                ),
                const SizedBox(height: 20),
                _buildTipsSection(
                  'QUICK TIPS',
                  debugResult?.tips ?? [],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultSection(String title, String content, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '> $title',
          style: GoogleFonts.robotoMono(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(4),
            color: AppConstants.secondaryDark,
          ),
          child: MarkdownBody(
            data: content,
            styleSheet: MarkdownStyleSheet(
              p: GoogleFonts.robotoMono(
                fontSize: 11,
                color: Colors.white,
                height: 1.5,
              ),

              strong: GoogleFonts.robotoMono(
                fontSize: 11,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),

              listBullet: GoogleFonts.robotoMono(
                color: Colors.white,
              ),

              code: GoogleFonts.robotoMono(
                fontSize: 11,
                color: AppConstants.accentLime,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCodeSection(String title, String code) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '> $title',
              style: GoogleFonts.robotoMono(
                fontSize: 12,
                color: AppConstants.accentLime,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text:debugResult?.fixedCode ?? ''));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Copied to clipboard')),
                );
              },
              child: const Icon(Icons.copy, size: 16, color: Color(0xFF00ff00)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: AppConstants.accentLime.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(4),
            color: const Color(0xFF0d1117),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(
              code,
              style: GoogleFonts.robotoMono(
                fontSize: 10,
                color: AppConstants.accentLime,
                height: 1.6,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTipsSection(String title, List<String> tips) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '> $title',
          style: GoogleFonts.robotoMono(
            fontSize: 12,
            color: AppConstants.accentOrange,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...tips.map(
          (tip) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '-> ',
                  style: GoogleFonts.robotoMono(
                    fontSize: 11,
                    color: AppConstants.accentOrange,
                  ),
                ),
                Expanded(
                  child: Text(
                    tip,
                    style: GoogleFonts.robotoMono(
                      fontSize: 11,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

 Widget _buildInputField(
  String label,
  TextEditingController controller, {
  int minLines = 4,
  }) {
  final isCodeField = label.contains('CODE'); // 🔥 detect main field

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '> $label',
        style: GoogleFonts.robotoMono(
          fontSize: 11,
          color: AppConstants.accentCyan,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 8),

      // 🔥 KEYBOARD CONTROL HERE
      Focus(
        onKeyEvent: (node, event) {
          if (isCodeField && event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.enter) {

              // SHIFT + ENTER → new line
              if (HardwareKeyboard.instance.isShiftPressed) {
                return KeyEventResult.ignored;
              }

              // ENTER → debug
              if (!isLoading && codeController.text.trim().isNotEmpty) {
                _debugCode();
                return KeyEventResult.handled;
              }
            }
          }
          return KeyEventResult.ignored;
        },

        child: TextField(
          controller: controller,
          minLines: minLines,
          maxLines: null,

          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,

          style: GoogleFonts.robotoMono(
            fontSize: 11,
            color: Colors.white,
          ),

          decoration: InputDecoration(
            hintText: isCodeField
                ? 'Enter = debug | Shift+Enter = new line'
                : '...',
            hintStyle: GoogleFonts.robotoMono(
              fontSize: 11,
              color: Colors.white24,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Colors.white24),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(
                color: AppConstants.accentGreen,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: AppConstants.secondaryDark,
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      ),
    ],
  );
}

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppConstants.appName,
                  style: GoogleFonts.robotoMono(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.accentGreen,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '> Elite Code Debugger',
                  style: GoogleFonts.robotoMono(
                    fontSize: 12,
                    color: AppConstants.accentGreen.withOpacity(0.6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Text(
              '> SELECT LANGUAGE',
              style: GoogleFonts.robotoMono(
                fontSize: 11,
                color: AppConstants.accentCyan,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              children: AppConstants.supportedLanguages.take(5).map((lang) {
                return GestureDetector(
                  onTap: () => setState(() => selectedLanguage = lang),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: selectedLanguage == lang
                            ? AppConstants.accentGreen
                            : Colors.white24,
                      ),
                      borderRadius: BorderRadius.circular(4),
                      color: selectedLanguage == lang
                          ? AppConstants.accentGreen.withOpacity(0.1)
                          : AppConstants.secondaryDark,
                    ),
                    child: Text(
                      lang,
                      style: GoogleFonts.robotoMono(
                        fontSize: 11,
                        color: selectedLanguage == lang
                            ? AppConstants.accentGreen
                            : Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),
            _buildInputField('CODE TO DEBUG', codeController, minLines: 8),
            const SizedBox(height: 20),
            _buildInputField(
              'ERROR MESSAGE (optional)',
              errorController,
              minLines: 3,
            ),
            const SizedBox(height: 20),
            _buildInputField('CONTEXT (optional)', contextController, minLines: 2),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : _debugCode,
                icon: Icon(isLoading ? Icons.hourglass_bottom : Icons.bug_report),
                label: Text(
                  isLoading ? 'ANALYZING...' : 'SCAN',
                  style: GoogleFonts.robotoMono(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isLoading
                      ? Colors.grey
                      : AppConstants.accentGreen,
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
