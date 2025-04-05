import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/custom_card.dart';
import '../services/two_factor_service.dart';

class TwoFactorSetupScreen extends StatefulWidget {
  final bool isEnabled;
  
  const TwoFactorSetupScreen({
    Key? key,
    required this.isEnabled,
  }) : super(key: key);

  @override
  State<TwoFactorSetupScreen> createState() => _TwoFactorSetupScreenState();
}

class _TwoFactorSetupScreenState extends State<TwoFactorSetupScreen> {
  final TwoFactorService _twoFactorService = TwoFactorService();
  
  bool _isLoading = false;
  String? _errorMessage;
  String? _secret;
  String? _qrCodeUrl;
  bool _showDisableConfirmation = false;
  
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    if (!widget.isEnabled) {
      _generateSecret();
    }
  }
  
  @override
  void dispose() {
    _codeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  // All backup code functionality has been moved to the dedicated BackupCodesScreen
  
  Future<void> _generateSecret() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // Use the dedicated QR code endpoint
      final result = await _twoFactorService.get2FAQrCode();
      
      if (result['success']) {
        setState(() {
          _secret = result['secret'];
          _qrCodeUrl = result['qrUrl'];
        });
      } else {
        setState(() {
          _errorMessage = result['message'];
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to generate 2FA secret: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _enableTwoFactor() async {
    if (_codeController.text.isEmpty || _secret == null) {
      setState(() {
        _errorMessage = 'Please enter the verification code from your authenticator app';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final result = await _twoFactorService.enable2FA(
        _codeController.text.trim(),
        _secret!,
      );
      
      if (result['success']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Two-factor authentication enabled successfully'),
              backgroundColor: AppTheme.successColor,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        setState(() {
          _errorMessage = result['message'];
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to enable 2FA: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _disableTwoFactor() async {
    if (_codeController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter both your current password and verification code';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final result = await _twoFactorService.disable2FA(
        _codeController.text.trim(),
        _passwordController.text,
      );
      
      if (result['success']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Two-factor authentication disabled successfully'),
              backgroundColor: AppTheme.successColor,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        setState(() {
          _errorMessage = result['message'];
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to disable 2FA: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _copySecretToClipboard() async {
    if (_secret != null) {
      await Clipboard.setData(ClipboardData(text: _secret!));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Secret code copied to clipboard'),
            backgroundColor: AppTheme.infoColor,
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEnabled ? 'Manage 2FA' : 'Enable 2FA'),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
      ),
      body: _isLoading 
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
              ),
            )
          : widget.isEnabled 
              ? _buildDisableContent()
              : _buildEnableContent(),
    );
  }
  
  Widget _buildEnableContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Animate(
            effects: const [
              FadeEffect(duration: Duration(milliseconds: 600)),
            ],
            child: Column(
              children: [
                Icon(
                  Icons.security,
                  size: 64,
                  color: AppTheme.accentColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'Set Up Two-Factor Authentication',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryTextColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Add an extra layer of security to your account',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.secondaryTextColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Error Message
          if (_errorMessage != null) ...[
            Container(
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
            const SizedBox(height: 24),
          ],
          
          // Step 1: Get an Authenticator App
          Animate(
            effects: const [
              FadeEffect(
                delay: Duration(milliseconds: 200),
                duration: Duration(milliseconds: 600),
              ),
            ],
            child: CustomCard(
              elevation: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Text(
                          '1',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Install an Authenticator App',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryTextColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Download and install an authenticator app on your device:',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildAuthAppChip('Google Authenticator'),
                      _buildAuthAppChip('Microsoft Authenticator'),
                      _buildAuthAppChip('Authy'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Step 2: Scan QR Code
          if (_secret != null && _qrCodeUrl != null) ...[
            Animate(
              effects: const [
                FadeEffect(
                  delay: Duration(milliseconds: 400),
                  duration: Duration(milliseconds: 600),
                ),
              ],
              child: CustomCard(
                elevation: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.accentColor,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Text(
                            '2',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Scan QR Code',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryTextColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Scan this QR code with your authenticator app:',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: QrImageView(
                          data: _qrCodeUrl!,
                          version: QrVersions.auto,
                          size: 200.0,
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Or enter this secret key manually:',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _secret!,
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w500,
                                color: AppTheme.primaryTextColor,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          color: AppTheme.accentColor,
                          onPressed: _copySecretToClipboard,
                          tooltip: 'Copy to clipboard',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Step 3: Enter Verification Code
            Animate(
              effects: const [
                FadeEffect(
                  delay: Duration(milliseconds: 600),
                  duration: Duration(milliseconds: 600),
                ),
              ],
              child: CustomCard(
                elevation: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.accentColor,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Text(
                            '3',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Verify',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryTextColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Enter the 6-digit code from your authenticator app:',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Verification Code',
                      hint: 'Enter 6-digit code',
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 32),
          
          // Enable Button
          Animate(
            effects: const [
              FadeEffect(
                delay: Duration(milliseconds: 800),
                duration: Duration(milliseconds: 600),
              ),
            ],
            child: CustomButton(
              text: 'Enable Two-Factor Authentication',
              onPressed: _enableTwoFactor,
              isLoading: _isLoading,
              type: ButtonType.primary,
              icon: Icons.check_circle_outline,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDisableContent() {
    return _showDisableConfirmation
        ? _buildDisableConfirmationContent()
        : _buildManageContent();
  }
  
  Widget _buildManageContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Animate(
            effects: const [
              FadeEffect(duration: Duration(milliseconds: 600)),
            ],
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.verified_user,
                    size: 64,
                    color: AppTheme.successColor,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Two-Factor Authentication Enabled',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryTextColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Your account is protected with an additional layer of security',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.secondaryTextColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Information Card
          Animate(
            effects: const [
              FadeEffect(
                delay: Duration(milliseconds: 200),
                duration: Duration(milliseconds: 600),
              ),
            ],
            child: CustomCard(
              elevation: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What is Two-Factor Authentication?',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Two-factor authentication adds an extra layer of security to your account. In addition to your password, you'll need to enter a code from your authenticator app when you sign in.",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Recovery Options Information
          Animate(
            effects: const [
              FadeEffect(
                delay: Duration(milliseconds: 400),
                duration: Duration(milliseconds: 600),
              ),
            ],
            child: CustomCard(
              elevation: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recovery Options',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'If you lose access to your authenticator app, you will need to contact support to recover your account. Make sure to keep your backup codes in a safe place.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 18,
                        color: AppTheme.warningColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Disabling 2FA will make your account less secure',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.warningColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Backup Codes Button
          Animate(
            effects: const [
              FadeEffect(
                delay: Duration(milliseconds: 600),
                duration: Duration(milliseconds: 600),
              ),
            ],
            child: CustomButton(
              text: 'Manage Backup Codes',
              onPressed: () => Navigator.pushNamed(context, '/backup-codes'),
              type: ButtonType.accent,
              icon: Icons.key,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Disable Button
          Animate(
            effects: const [
              FadeEffect(
                delay: Duration(milliseconds: 800),
                duration: Duration(milliseconds: 600),
              ),
            ],
            child: CustomButton(
              text: 'Disable Two-Factor Authentication',
              onPressed: () {
                setState(() {
                  _showDisableConfirmation = true;
                });
              },
              type: ButtonType.secondary,
              icon: Icons.security_update_warning,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDisableConfirmationContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Animate(
            effects: const [
              FadeEffect(duration: Duration(milliseconds: 600)),
            ],
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.warningColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    size: 64,
                    color: AppTheme.warningColor,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Disable Two-Factor Authentication?',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryTextColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'This will remove the additional layer of security from your account',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.secondaryTextColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Error Message
          if (_errorMessage != null) ...[
            Container(
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
            const SizedBox(height: 24),
          ],
          
          // Verification Fields
          Animate(
            effects: const [
              FadeEffect(
                delay: Duration(milliseconds: 200),
                duration: Duration(milliseconds: 600),
              ),
            ],
            child: CustomCard(
              elevation: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Verification Required',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Current Password',
                    hint: 'Enter your current password',
                    controller: _passwordController,
                    obscureText: true,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Verification Code',
                    hint: 'Enter 6-digit code from your authenticator app',
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Action Buttons
          Animate(
            effects: const [
              FadeEffect(
                delay: Duration(milliseconds: 400),
                duration: Duration(milliseconds: 600),
              ),
            ],
            child: Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Cancel',
                    onPressed: () {
                      setState(() {
                        _showDisableConfirmation = false;
                        _errorMessage = null;
                        _codeController.clear();
                        _passwordController.clear();
                      });
                    },
                    type: ButtonType.secondary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    text: 'Disable 2FA',
                    onPressed: _disableTwoFactor,
                    isLoading: _isLoading,
                    type: ButtonType.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAuthAppChip(String name) {
    return Chip(
      label: Text(
        name,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: AppTheme.surfaceColor,
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}
