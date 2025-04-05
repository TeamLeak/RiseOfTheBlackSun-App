import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../core/theme/app_theme.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  static const routeName = '/register';

  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  final _authService = AuthService();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _authService.register(
        _usernameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (result['success']) {
        // Navigate to home
        // ignore: use_build_context_synchronously
        Navigator.pushReplacementNamed(context, '/home');
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Create Account'),
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
                          size: 48,
                          color: AppTheme.accentColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Join BlackSun',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create a new account',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Error Message
                  if (_errorMessage != null) ...[
                    Animate(
                      effects: const [
                        ShakeEffect(
                          duration: Duration(milliseconds: 500),
                        ),
                      ],
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.errorColor.withOpacity(0.3)),
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

                  // Username Field
                  Animate(
                    effects: const [
                      FadeEffect(
                        delay: Duration(milliseconds: 100),
                        duration: Duration(milliseconds: 800),
                      ),
                      SlideEffect(
                        begin: Offset(0, 20),
                        end: Offset.zero,
                        delay: Duration(milliseconds: 100),
                        duration: Duration(milliseconds: 800),
                      ),
                    ],
                    child: CustomTextField(
                      label: 'Username',
                      hint: 'Choose a username',
                      controller: _usernameController,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a username';
                        }
                        if (value.length < 3) {
                          return 'Username must be at least 3 characters';
                        }
                        return null;
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
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
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
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
                      hint: 'Create a password',
                      controller: _passwordController,
                      obscureText: true,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        if (value.length < 8) {
                          return 'Password must be at least 8 characters';
                        }
                        return null;
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Confirm Password Field
                  Animate(
                    effects: const [
                      FadeEffect(
                        delay: Duration(milliseconds: 400),
                        duration: Duration(milliseconds: 800),
                      ),
                      SlideEffect(
                        begin: Offset(0, 20),
                        end: Offset.zero,
                        delay: Duration(milliseconds: 400),
                        duration: Duration(milliseconds: 800),
                      ),
                    ],
                    child: CustomTextField(
                      label: 'Confirm Password',
                      hint: 'Confirm your password',
                      controller: _confirmPasswordController,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Register Button
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
                      text: 'Create Account',
                      onPressed: _register,
                      isLoading: _isLoading,
                      type: ButtonType.primary,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Login Link
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
                          "Already have an account? ",
                          style: TextStyle(
                            color: AppTheme.secondaryTextColor,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                              context, 
                              LoginScreen.routeName,
                            );
                          },
                          child: Text(
                            'Login',
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
