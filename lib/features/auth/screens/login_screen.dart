import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../core/theme/app_theme.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import 'two_factor_verification_screen.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';

  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _rememberMe = false;
  String? _errorMessage;

  final _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _authService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (result['success']) {
        final user = result['user'];

        // Check if 2FA is enabled for the user
        if (user.twoFactorEnabled) {
          // Redirect to 2FA verification using named route
          // ignore: use_build_context_synchronously
          Navigator.pushReplacementNamed(
            context, 
            TwoFactorVerificationScreen.routeName,
            arguments: {'email': _emailController.text.trim()},
          );
        } else {
          // Navigate to home
          // ignore: use_build_context_synchronously
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        setState(() {
          _errorMessage = result['message'];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  // Logo and Header
                  Animate(
                    effects: const [
                      FadeEffect(
                        duration: Duration(milliseconds: 800),
                        curve: Curves.easeOut,
                      ),
                      SlideEffect(
                        begin: Offset(0, -20),
                        end: Offset.zero,
                        duration: Duration(milliseconds: 800),
                        curve: Curves.easeOut,
                      ),
                    ],
                    child: Column(
                      children: [
                        Icon(
                          Icons.shield_rounded,
                          size: 64,
                          color: AppTheme.accentColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'BlackSun 2FA',
                          style: Theme.of(
                            context,
                          ).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Secure Account Management',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: AppTheme.secondaryTextColor),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

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

                  // Email Field
                  Animate(
                    effects: const [
                      FadeEffect(
                        delay: Duration(milliseconds: 200),
                        duration: Duration(milliseconds: 800),
                      ),
                      SlideEffect(
                        begin: Offset(0, 20),
                        end: Offset.zero,
                        delay: Duration(milliseconds: 200),
                        duration: Duration(milliseconds: 800),
                      ),
                    ],
                    child: CustomTextField(
                      label: 'Email',
                      hint: 'Enter your email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Password Field
                  Animate(
                    effects: const [
                      FadeEffect(
                        delay: Duration(milliseconds: 300),
                        duration: Duration(milliseconds: 800),
                      ),
                      SlideEffect(
                        begin: Offset(0, 20),
                        end: Offset.zero,
                        delay: Duration(milliseconds: 300),
                        duration: Duration(milliseconds: 800),
                      ),
                    ],
                    child: CustomTextField(
                      label: 'Password',
                      hint: 'Enter your password',
                      controller: _passwordController,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Remember Me & Forgot Password
                  Animate(
                    effects: const [
                      FadeEffect(
                        delay: Duration(milliseconds: 400),
                        duration: Duration(milliseconds: 800),
                      ),
                    ],
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  _rememberMe = value ?? false;
                                });
                              },
                              activeColor: AppTheme.accentColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            Text(
                              'Remember Me',
                              style: TextStyle(
                                color: AppTheme.secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              ForgotPasswordScreen.routeName,
                            );
                          },
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: AppTheme.accentColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Login Button
                  Animate(
                    effects: const [
                      FadeEffect(
                        delay: Duration(milliseconds: 500),
                        duration: Duration(milliseconds: 800),
                      ),
                      SlideEffect(
                        begin: Offset(0, 20),
                        end: Offset.zero,
                        delay: Duration(milliseconds: 500),
                        duration: Duration(milliseconds: 800),
                      ),
                    ],
                    child: CustomButton(
                      text: 'Login',
                      onPressed: _login,
                      isLoading: _isLoading,
                      type: ButtonType.primary,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Register Link
                  Animate(
                    effects: const [
                      FadeEffect(
                        delay: Duration(milliseconds: 600),
                        duration: Duration(milliseconds: 800),
                      ),
                    ],
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: TextStyle(color: AppTheme.secondaryTextColor),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              RegisterScreen.routeName,
                            );
                          },
                          child: Text(
                            'Register',
                            style: TextStyle(
                              color: AppTheme.accentColor,
                              fontWeight: FontWeight.w500,
                            ),
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
    );
  }
}
