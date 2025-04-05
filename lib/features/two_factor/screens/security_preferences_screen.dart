import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../services/two_factor_service.dart';
import '../../auth/services/auth_service.dart';

class SecurityPreferencesScreen extends StatefulWidget {
  static const routeName = '/security-preferences';
  
  const SecurityPreferencesScreen({Key? key}) : super(key: key);

  @override
  State<SecurityPreferencesScreen> createState() => _SecurityPreferencesScreenState();
}

class _SecurityPreferencesScreenState extends State<SecurityPreferencesScreen> with SingleTickerProviderStateMixin {
  final TwoFactorService _twoFactorService = TwoFactorService();
  final AuthService _authService = AuthService();
  
  bool _isLoading = true;
  bool _isSaving = false;
  late AnimationController _animationController;
  
  // Security Preferences
  bool _emailNotifications = true;
  bool _inAppNotifications = true;
  bool _loginAlerts = true;
  bool _trustedDevicesOnly = false;
  int _passwordExpireDays = 90;
  int _autoLogoutMinutes = 30;
  
  final List<int> _passwordExpireOptions = [0, 30, 60, 90, 180, 365];
  final List<int> _autoLogoutOptions = [0, 5, 15, 30, 60, 120];
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _loadPreferences();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  Future<void> _loadPreferences() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // This would be a real API call in a production app
      await Future.delayed(const Duration(milliseconds: 1200));
      
      // Mock data for demonstration
      setState(() {
        _emailNotifications = true;
        _inAppNotifications = true;
        _loginAlerts = true;
        _trustedDevicesOnly = false;
        _passwordExpireDays = 90;
        _autoLogoutMinutes = 30;
        _isLoading = false;
      });
      
      _animationController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load security preferences: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }
  
  Future<void> _savePreferences() async {
    setState(() {
      _isSaving = true;
    });
    
    try {
      // This would be a real API call in a production app
      await Future.delayed(const Duration(milliseconds: 1200));
      
      setState(() {
        _isSaving = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Security preferences saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save security preferences: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }
  
  String _formatPasswordExpiration(int days) {
    if (days == 0) {
      return 'Never';
    } else if (days == 30) {
      return '30 days';
    } else if (days == 60) {
      return '60 days';
    } else if (days == 90) {
      return '90 days';
    } else if (days == 180) {
      return '6 months';
    } else if (days == 365) {
      return '1 year';
    }
    return '$days days';
  }
  
  String _formatAutoLogout(int minutes) {
    if (minutes == 0) {
      return 'Never';
    } else if (minutes == 60) {
      return '1 hour';
    } else if (minutes == 120) {
      return '2 hours';
    }
    return '$minutes minutes';
  }
  
  Widget _buildSwitchCard({
    required String title, 
    required String description, 
    required bool value, 
    required Function(bool) onChanged,
    required IconData icon,
    Color? iconColor,
  }) {
    return CustomCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (iconColor ?? AppTheme.accentColor).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (iconColor ?? AppTheme.accentColor).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? AppTheme.accentColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: AppTheme.accentColor,
                inactiveThumbColor: Colors.grey.shade400,
                inactiveTrackColor: Colors.grey.shade800,
              ),
            ],
          ),
        ],
      ),
    ).animate(controller: _animationController)
      .fadeIn(duration: 600.ms, curve: Curves.easeOutQuad)
      .slideY(begin: 0.2, end: 0, duration: 600.ms, curve: Curves.easeOutQuad);
  }
  
  Widget _buildPasswordExpirationCard() {
    return CustomCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.warningColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.lock_clock,
                  color: AppTheme.warningColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Password Expiration',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Set how often you want to be required to change your password',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Current setting: ${_formatPasswordExpiration(_passwordExpireDays)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ),
              DropdownButton<int>(
                value: _passwordExpireDays,
                dropdownColor: AppTheme.cardColor,
                iconEnabledColor: AppTheme.accentColor,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
                underline: Container(
                  height: 2,
                  color: AppTheme.accentColor.withOpacity(0.5),
                ),
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _passwordExpireDays = newValue;
                    });
                  }
                },
                items: _passwordExpireOptions.map<DropdownMenuItem<int>>((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(_formatPasswordExpiration(value)),
                  );
                }).toList(),
              ),
            ],
          ),
          if (_passwordExpireDays == 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.warningColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.warningColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppTheme.warningColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'For maximum security, we recommend setting a password expiration period.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ).animate(controller: _animationController)
      .fadeIn(duration: 600.ms, delay: 200.ms, curve: Curves.easeOutQuad)
      .slideY(begin: 0.2, end: 0, duration: 600.ms, delay: 200.ms, curve: Curves.easeOutQuad);
  }
  
  Widget _buildAutoLogoutCard() {
    return CustomCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.infoColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.infoColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.timer_outlined,
                  color: AppTheme.infoColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Auto Logout',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Set how long your session remains active without activity',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Current setting: ${_formatAutoLogout(_autoLogoutMinutes)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ),
              DropdownButton<int>(
                value: _autoLogoutMinutes,
                dropdownColor: AppTheme.cardColor,
                iconEnabledColor: AppTheme.accentColor,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
                underline: Container(
                  height: 2,
                  color: AppTheme.accentColor.withOpacity(0.5),
                ),
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _autoLogoutMinutes = newValue;
                    });
                  }
                },
                items: _autoLogoutOptions.map<DropdownMenuItem<int>>((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(_formatAutoLogout(value)),
                  );
                }).toList(),
              ),
            ],
          ),
          if (_autoLogoutMinutes == 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.warningColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.warningColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppTheme.warningColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'For maximum security, we recommend setting an auto-logout timer.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ).animate(controller: _animationController)
      .fadeIn(duration: 600.ms, delay: 300.ms, curve: Curves.easeOutQuad)
      .slideY(begin: 0.2, end: 0, duration: 600.ms, delay: 300.ms, curve: Curves.easeOutQuad);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Security Preferences',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadPreferences,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : SafeArea(
              child: Stack(
                children: [
                  ListView(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 100), // Add bottom padding for the save button
                    children: [
                      CustomCard(
                        padding: const EdgeInsets.all(24),
                        backgroundColor: AppTheme.surfaceColor,
                        elevation: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppTheme.accentColor.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.shield,
                                    color: AppTheme.accentColor,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Security Settings',
                                        style: Theme.of(context).textTheme.titleLarge,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Configure your security preferences',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            const Divider(height: 1, color: Colors.white10),
                            const SizedBox(height: 20),
                            Text(
                              'Customize your security preferences to enhance your account protection. We recommend enabling all security features for maximum safety.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ).animate(controller: _animationController)
                        .fadeIn(duration: 600.ms, curve: Curves.easeOutQuad)
                        .slideY(begin: 0.2, end: 0, duration: 600.ms, curve: Curves.easeOutQuad),
                      
                      const SizedBox(height: 24),
                      Text(
                        'Notifications',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w600,
                        ),
                      ).animate(controller: _animationController)
                        .fadeIn(duration: 400.ms, curve: Curves.easeOutQuad),
                      const SizedBox(height: 16),
                      
                      _buildSwitchCard(
                        title: 'Email Notifications',
                        description: 'Receive security alerts via email',
                        value: _emailNotifications,
                        onChanged: (value) {
                          setState(() {
                            _emailNotifications = value;
                          });
                        },
                        icon: Icons.email_outlined,
                        iconColor: AppTheme.infoColor,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      _buildSwitchCard(
                        title: 'In-App Notifications',
                        description: 'Show security alerts within the app',
                        value: _inAppNotifications,
                        onChanged: (value) {
                          setState(() {
                            _inAppNotifications = value;
                          });
                        },
                        icon: Icons.notifications_outlined,
                        iconColor: AppTheme.warningColor,
                      ),
                      
                      const SizedBox(height: 24),
                      Text(
                        'Login Security',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w600,
                        ),
                      ).animate(controller: _animationController)
                        .fadeIn(duration: 400.ms, delay: 100.ms, curve: Curves.easeOutQuad),
                      const SizedBox(height: 16),
                      
                      _buildSwitchCard(
                        title: 'Login Alerts',
                        description: 'Receive alerts for new login attempts',
                        value: _loginAlerts,
                        onChanged: (value) {
                          setState(() {
                            _loginAlerts = value;
                          });
                        },
                        icon: Icons.login,
                        iconColor: AppTheme.accentColor,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      _buildSwitchCard(
                        title: 'Trusted Devices Only',
                        description: 'Only allow logins from devices you\'ve marked as trusted',
                        value: _trustedDevicesOnly,
                        onChanged: (value) {
                          setState(() {
                            _trustedDevicesOnly = value;
                          });
                        },
                        icon: Icons.devices,
                        iconColor: AppTheme.successColor,
                      ),
                      
                      const SizedBox(height: 24),
                      Text(
                        'Session Security',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w600,
                        ),
                      ).animate(controller: _animationController)
                        .fadeIn(duration: 400.ms, delay: 200.ms, curve: Curves.easeOutQuad),
                      const SizedBox(height: 16),
                      
                      _buildPasswordExpirationCard(),
                      
                      const SizedBox(height: 16),
                      
                      _buildAutoLogoutCard(),
                    ],
                  ),
                  
                  // Save button at the bottom
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0),
                            Colors.black.withOpacity(0.8),
                            Colors.black,
                          ],
                          stops: const [0, 0.5, 1.0],
                        ),
                      ),
                      child: CustomButton(
                        text: 'Save Preferences',
                        onPressed: _savePreferences,
                        isLoading: _isSaving,
                        type: ButtonType.accent,
                        icon: Icons.save_outlined,
                      ).animate(controller: _animationController)
                        .fadeIn(duration: 400.ms, delay: 400.ms, curve: Curves.easeOut)
                        .slideY(begin: 0.5, end: 0, duration: 500.ms, delay: 400.ms, curve: Curves.easeOutQuint),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
