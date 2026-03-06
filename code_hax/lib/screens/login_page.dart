import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_constants.dart';
import '../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  bool isLoading = false;
  bool passwordVisible = false;
  String? errorMessage;

  // ── Typing animation ──
  final String _fullText = 'Welcome to CodeHax';
  String _displayedText = '';
  int _charIndex = 0;
  Timer? _typingTimer;
  bool _showCursor = true;
  Timer? _cursorTimer;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    _startTyping();
    _startCursorBlink();
  }

  void _startTyping() {
    _typingTimer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
      if (_charIndex < _fullText.length) {
        setState(() {
          _displayedText = _fullText.substring(0, _charIndex + 1);
          _charIndex++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _startCursorBlink() {
    _cursorTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      setState(() => _showCursor = !_showCursor);
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _typingTimer?.cancel();
    _cursorTimer?.cancel();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await authService.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (result['success']) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } else {
        setState(() {
          errorMessage = result['error'] ?? 'Login failed';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.primaryDark,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  // ── Logo + Typing ──
                  Column(
                    children: [
                      // Logo icon
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppConstants.accentGreen.withOpacity(0.1),
                          border: Border.all(
                            color: AppConstants.accentGreen.withOpacity(0.4),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppConstants.accentGreen.withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.terminal_rounded,
                          color: AppConstants.accentGreen,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Typing animation
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: _displayedText,
                              style: GoogleFonts.robotoMono(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                            ),
                            TextSpan(
                              text: _showCursor ? '|' : ' ',
                              style: GoogleFonts.robotoMono(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppConstants.accentGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '// your elite code assistant',
                        style: GoogleFonts.robotoMono(
                          fontSize: 11,
                          color: AppConstants.accentGreen.withOpacity(0.5),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ── Card ──
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppConstants.secondaryDark,
                      border: Border.all(color: AppConstants.accentGreen, width: 2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'CodeHax',
                          style: GoogleFonts.robotoMono(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.accentGreen,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Elite Code Assistant',
                          style: GoogleFonts.robotoMono(
                            fontSize: 12,
                            color: AppConstants.accentGreen.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 32),
                        TextField(
                          controller: emailController,
                          textInputAction: TextInputAction.next,
                          style: GoogleFonts.robotoMono(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: GoogleFonts.robotoMono(color: Colors.white60),
                            hintText: 'you@example.com',
                            hintStyle: GoogleFonts.robotoMono(color: Colors.white24),
                            prefixIcon: Icon(Icons.email, color: AppConstants.accentGreen.withOpacity(0.6)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppConstants.accentGreen.withOpacity(0.3)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: AppConstants.accentGreen, width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.05),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: passwordController,
                          style: GoogleFonts.robotoMono(color: Colors.white),
                          obscureText: !passwordVisible,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _login(),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: GoogleFonts.robotoMono(color: Colors.white60),
                            hintText: 'Enter password',
                            hintStyle: GoogleFonts.robotoMono(color: Colors.white24),
                            prefixIcon: Icon(Icons.lock, color: AppConstants.accentGreen.withOpacity(0.6)),
                            suffixIcon: IconButton(
                              icon: Icon(
                                passwordVisible ? Icons.visibility : Icons.visibility_off,
                                color: AppConstants.accentGreen.withOpacity(0.6),
                              ),
                              onPressed: () => setState(() => passwordVisible = !passwordVisible),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppConstants.accentGreen.withOpacity(0.3)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: AppConstants.accentGreen, width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.05),
                          ),
                        ),
                        if (errorMessage != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.2),
                              border: Border.all(color: Colors.red),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              errorMessage!,
                              style: GoogleFonts.robotoMono(color: Colors.red, fontSize: 12),
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.accentGreen,
                            foregroundColor: Colors.black,
                            minimumSize: const Size(double.infinity, 48),
                            disabledBackgroundColor: Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: isLoading
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation(Colors.grey[700]),
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Login',
                                  style: GoogleFonts.robotoMono(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: GoogleFonts.robotoMono(color: Colors.white70, fontSize: 12),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.of(context).pushReplacementNamed('/signup'),
                              child: Text(
                                'Sign up',
                                style: GoogleFonts.robotoMono(
                                  color: AppConstants.accentGreen,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
