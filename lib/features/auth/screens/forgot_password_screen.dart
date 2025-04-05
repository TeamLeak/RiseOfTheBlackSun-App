import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../core/theme/app_theme.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  static const routeName = '/forgot-password';

  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _resetLinkSent = false;

  final _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _authService.forgotPassword(
        _emailController.text.trim(),
      );

      if (!mounted) return;

      if (result['success']) {
        setState(() {
          _resetLinkSent = true;
        });
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
                children: _resetLinkSent ? _buildSuccessContent() : _buildRequestContent(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildRequestContent() {
    return [
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
              Icons.lock_reset_rounded,
              size: 64,
              color: AppTheme.accentColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Forgot Password',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryTextColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter your email to receive a password reset link',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
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
          textInputAction: TextInputAction.done,
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
      
      const SizedBox(height: 32),
      
      // Send Reset Link Button
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
        child: CustomButton(
          text: 'Send Reset Link',
          onPressed: _sendResetLink,
          isLoading: _isLoading,
          type: ButtonType.primary,
        ),
      ),
      
      const SizedBox(height: 24),
      
      // Back to Login
      Animate(
        effects: const [
          FadeEffect(
            delay: Duration(milliseconds: 500),
            duration: Duration(milliseconds: 800),
          ),
        ],
        child: Center(
          child: TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Back to Login',
              style: TextStyle(
                color: AppTheme.accentColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildSuccessContent() {
    return [
      Animate(
        effects: const [
          FadeEffect(
            duration: Duration(milliseconds: 800),
          ),
        ],
        child: Column(
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              size: 80,
              color: AppTheme.successColor,
            ),
            const SizedBox(height: 24),
            Text(
              'Reset Link Sent!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryTextColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'We\'ve sent a password reset link to ${_emailController.text}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Please check your email and follow the instructions to reset your password.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            CustomButton(
              text: 'Back to Login',
              onPressed: () {
                Navigator.pushReplacementNamed(context, LoginScreen.routeName);
              },
              type: ButtonType.primary,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                setState(() {
                  _resetLinkSent = false;
                  _emailController.clear();
                });
              },
              child: Text(
                'Try another email',
                style: TextStyle(
                  color: AppTheme.accentColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    ];
  }
}
