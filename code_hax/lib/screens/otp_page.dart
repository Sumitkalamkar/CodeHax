import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_constants.dart';
import '../services/auth_service.dart';

class OtpPage extends StatefulWidget {
  final String username;
  final String email;
  final String password;

  const OtpPage({
    super.key,
    required this.username,
    required this.email,
    required this.password,
  });

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final int _otpLength = 6;
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  bool loading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(_otpLength, (_) => TextEditingController());
    _focusNodes = List.generate(_otpLength, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  String get _otpCode => _controllers.map((c) => c.text.trim()).join();

  void _onOtpChanged(int index, String value) {
    if (value.length == 1 && index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    if (_otpCode.length == _otpLength) {
      FocusScope.of(context).unfocus();
      verifyOtp();
    }
  }

  void _onKeyEvent(int index, RawKeyEvent event) {
    if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> verifyOtp() async {
    final otp = _otpCode;
    if (otp.length < _otpLength) {
      setState(() => error = 'Please enter the complete 6-digit code');
      return;
    }

    setState(() {
      loading = true;
      error = null;
    });

    try {
      // ✅ STEP 1 — VERIFY OTP
      await authService.verifyOtp(widget.email, otp);

      // ✅ STEP 2 — CREATE ACCOUNT AFTER VERIFY
      final result = await authService.signup(
        username: widget.username,
        email: widget.email,
        password: widget.password,
      );

      if (result['success']) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, "/home");
      } else {
        setState(() => error = result['error'] ?? "Signup failed");
      }
    } catch (e) {
      setState(() => error = e.toString());
      for (final c in _controllers) c.clear();
      _focusNodes[0].requestFocus();
    }

    setState(() => loading = false);
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
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppConstants.secondaryDark,
                  border: Border.all(color: AppConstants.accentGreen, width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    // ── Logo ──
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
                      'Email Verification',
                      style: GoogleFonts.robotoMono(
                        fontSize: 12,
                        color: AppConstants.accentGreen.withOpacity(0.6),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Shield Icon ──
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppConstants.accentGreen.withOpacity(0.08),
                        border: Border.all(
                          color: AppConstants.accentGreen.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.shield_outlined,
                        color: AppConstants.accentGreen,
                        size: 36,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Description ──
                    Text(
                      'Enter the 6-digit code sent to',
                      style: GoogleFonts.robotoMono(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.email,
                      style: GoogleFonts.robotoMono(
                        color: AppConstants.accentGreen,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 28),

                    // ── OTP Boxes ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_otpLength, (i) {
                        return Padding(
                          padding: EdgeInsets.only(right: i < _otpLength - 1 ? 10 : 0),
                          child: SizedBox(
                            width: 46,
                            height: 56,
                            child: RawKeyboardListener(
                              focusNode: FocusNode(),
                              onKey: (event) => _onKeyEvent(i, event),
                              child: TextField(
                                controller: _controllers[i],
                                focusNode: _focusNodes[i],
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                maxLength: 1,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                style: GoogleFonts.robotoMono(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: InputDecoration(
                                  counterText: '',
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.05),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: AppConstants.accentGreen.withOpacity(0.3),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: AppConstants.accentGreen.withOpacity(0.3),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: AppConstants.accentGreen,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                onChanged: (val) => _onOtpChanged(i, val),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),

                    // ── Error Banner ──
                    if (error != null) ...[
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
                          error!,
                          style: GoogleFonts.robotoMono(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // ── Verify Button ──
                    ElevatedButton(
                      onPressed: loading ? null : verifyOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.accentGreen,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 48),
                        disabledBackgroundColor: Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: loading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(Colors.grey[700]),
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Verify & Create Account',
                              style: GoogleFonts.robotoMono(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                    ),

                    const SizedBox(height: 16),

                    // ── Back to Sign Up ──
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.arrow_back_ios,
                            size: 12,
                            color: Colors.white38,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Back to Sign Up',
                            style: GoogleFonts.robotoMono(
                              color: Colors.white38,
                              fontSize: 12,
                            ),
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
      ),
    );
  }
}
