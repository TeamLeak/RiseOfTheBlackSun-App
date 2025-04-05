import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/two_factor/services/two_factor_service.dart';
// LoadingIndicator is used directly in the UI

class TwoFactorVerificationScreen extends StatefulWidget {
  static const routeName = '/two-factor-verification';
  final String email;

  const TwoFactorVerificationScreen({Key? key, required this.email})
    : super(key: key);

  @override
  State<TwoFactorVerificationScreen> createState() =>
      _TwoFactorVerificationScreenState();
}

class _TwoFactorVerificationScreenState
    extends State<TwoFactorVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final List<TextEditingController> _digitControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  String? _errorMessage;
  int _remainingSeconds = 30;
  Timer? _timer;
  
  final _twoFactorService = TwoFactorService();
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = 30;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    for (final controller in _digitControllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _verifyCode() async {
    // Combine all digits into a single code
    String code = _digitControllers.map((c) => c.text).join();

    if (code.length != 6) {
      setState(() {
        _errorMessage = 'Please enter all 6 digits';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Call the backend API to verify the 2FA code
      final result = await _twoFactorService.verify2FACode(widget.email, code);

      if (!mounted) return;

      if (result['success']) {
        // Store the token in secure storage
        await _storage.write(key: 'auth_token', value: result['token']);
        
        // Navigate to home
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        setState(() {
          _errorMessage = 'Invalid verification code. Please try again.';
          for (final controller in _digitControllers) {
            controller.clear();
          }
          _focusNodes[0].requestFocus();
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resendCode() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // In a real app, you would request a new 2FA code from your backend
      await Future.delayed(const Duration(seconds: 1));

      _startTimer();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification code has been resent'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to resend code. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Two-Factor Authentication'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Animate(
                    effects: const [
                      FadeEffect(
                        duration: Duration(milliseconds: 800),
                        curve: Curves.easeOut,
                      ),
                    ],
                    child: Column(
                      children: [
                        Icon(
                          Icons.security_rounded,
                          size: 64,
                          color: AppTheme.accentColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Verification Required',
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Enter the 6-digit code from your authentication app',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: AppTheme.secondaryTextColor),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Error Message
                  if (_errorMessage != null) ...[
                    Animate(
                      effects: const [
                        ShakeEffect(duration: Duration(milliseconds: 500)),
                      ],
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.errorColor.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: AppTheme.errorColor,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // 6-digit code input
                  Animate(
                    effects: const [
                      FadeEffect(
                        delay: Duration(milliseconds: 200),
                        duration: Duration(milliseconds: 800),
                      ),
                    ],
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        6,
                        (index) => SizedBox(
                          width: 40,
                          child: TextField(
                            controller: _digitControllers[index],
                            focusNode: _focusNodes[index],
                            decoration: InputDecoration(
                              counterText: '',
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppTheme.secondaryTextColor
                                      .withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppTheme.accentColor,
                                  width: 2,
                                ),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryTextColor,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onChanged: (value) {
                              if (value.isNotEmpty && index < 5) {
                                _focusNodes[index + 1].requestFocus();
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Verify Button
                  Animate(
                    effects: const [
                      FadeEffect(
                        delay: Duration(milliseconds: 400),
                        duration: Duration(milliseconds: 800),
                      ),
                    ],
                    child: CustomButton(
                      text: 'Verify Code',
                      onPressed: _verifyCode,
                      isLoading: _isLoading,
                      type: ButtonType.primary,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Resend Button
                  Animate(
                    effects: const [
                      FadeEffect(
                        delay: Duration(milliseconds: 500),
                        duration: Duration(milliseconds: 800),
                      ),
                    ],
                    child: Center(
                      child: TextButton(
                        onPressed: _remainingSeconds > 0 ? null : _resendCode,
                        child: Text(
                          _remainingSeconds > 0
                              ? 'Resend code in ${_remainingSeconds}s'
                              : 'Resend code',
                          style: TextStyle(
                            color:
                                _remainingSeconds > 0
                                    ? AppTheme.secondaryTextColor
                                    : AppTheme.accentColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Need help button
                  Animate(
                    effects: const [
                      FadeEffect(
                        delay: Duration(milliseconds: 600),
                        duration: Duration(milliseconds: 800),
                      ),
                    ],
                    child: Center(
                      child: TextButton(
                        onPressed: () {
                          // Show help dialog
                          showDialog(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: const Text('Need Help?'),
                                  content: const Text(
                                    'If you lost access to your authenticator app, please contact support for assistance in recovering your account.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                          );
                        },
                        child: Text(
                          'Need help?',
                          style: TextStyle(
                            color: AppTheme.infoColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
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
