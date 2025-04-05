import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../auth/services/auth_service.dart';
import '../services/two_factor_service.dart';

class SecurityDashboardScreen extends StatefulWidget {
  const SecurityDashboardScreen({Key? key}) : super(key: key);

  @override
  State<SecurityDashboardScreen> createState() =>
      _SecurityDashboardScreenState();
}

class _SecurityDashboardScreenState extends State<SecurityDashboardScreen> {
  final AuthService _authService = AuthService();
  final TwoFactorService _twoFactorService = TwoFactorService();

  bool _isLoading = true;
  Map<String, dynamic> _securityStatus = {};

  @override
  void initState() {
    super.initState();
    _loadSecurityStatus();
  }

  Future<void> _loadSecurityStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get 2FA status
      final twoFactorStatus = await _twoFactorService.get2FAStatus();

      // Get last login info
      final lastLoginInfo = await _authService.getLastLogin();

      // Get password strength (mock implementation)
      final passwordStrength = await _authService.getPasswordStrength();

      setState(() {
        _securityStatus = {
          'twoFactorEnabled':
              twoFactorStatus['success'] ? twoFactorStatus['enabled'] : false,
          'passwordStrength': passwordStrength['strength'] ?? 'medium',
          'lastLogin': lastLoginInfo['success'] ? lastLoginInfo['data'] : null,
          'recentLoginAttempts':
              lastLoginInfo['success']
                  ? lastLoginInfo['recentAttempts'] ?? 0
                  : 0,
          'accountAge': 'Active for 3 months', // Mock data
        };
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading security status: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSecurityStatus,
      color: AppTheme.accentColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Animate(
              effects: const [
                FadeEffect(duration: Duration(milliseconds: 600)),
              ],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Security Dashboard',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Monitor and manage your account security',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Overall Security Score
            Animate(
              effects: const [
                FadeEffect(
                  delay: Duration(milliseconds: 200),
                  duration: Duration(milliseconds: 600),
                ),
              ],
              child: CustomCard(
                elevation: 4,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Security Score',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryTextColor,
                          ),
                        ),
                        _buildSecurityRating(),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildSecurityProgress(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Security Items
            Text(
              'Security Checklist',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryTextColor,
              ),
            ),

            const SizedBox(height: 16),

            // 2FA Status
            _buildSecurityItem(
              icon: Icons.security,
              title: 'Two-Factor Authentication',
              status:
                  _securityStatus['twoFactorEnabled'] ? 'Enabled' : 'Disabled',
              isSecure: _securityStatus['twoFactorEnabled'],
              action:
                  _securityStatus['twoFactorEnabled'] ? 'Manage' : 'Enable Now',
              onActionPressed: () {
                Navigator.pushNamed(
                  context,
                  '/two-factor-setup',
                  arguments: {'isEnabled': _securityStatus['twoFactorEnabled']},
                ).then((_) => _loadSecurityStatus());
              },
            ),

            // Password Strength
            _buildSecurityItem(
              icon: Icons.password,
              title: 'Password Strength',
              status: _getPasswordStrengthText(
                _securityStatus['passwordStrength'],
              ),
              isSecure: _securityStatus['passwordStrength'] == 'strong',
              action:
                  _securityStatus['passwordStrength'] == 'strong'
                      ? 'Change'
                      : 'Improve',
              onActionPressed: () {
                Navigator.pushNamed(
                  context,
                  '/change-password',
                ).then((_) => _loadSecurityStatus());
              },
            ),

            // Recent Login Activity
            _buildSecurityItem(
              icon: Icons.access_time,
              title: 'Recent Login Activity',
              status:
                  _securityStatus['recentLoginAttempts'] > 0
                      ? '${_securityStatus['recentLoginAttempts']} recent attempts'
                      : 'No recent activity',
              isSecure: _securityStatus['recentLoginAttempts'] < 3,
              action: 'View History',
              onActionPressed: () {
                Navigator.pushNamed(context, '/login-history');
              },
            ),

            // Device Management
            _buildSecurityItem(
              icon: Icons.devices,
              title: 'Device Management',
              status: 'Not configured',
              isSecure: false,
              action: 'Set Up',
              onActionPressed: () {
                // Navigate to device management
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Device management coming soon'),
                    backgroundColor: AppTheme.infoColor,
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            // Additional Security Tips
            Animate(
              effects: const [
                FadeEffect(
                  delay: Duration(milliseconds: 800),
                  duration: Duration(milliseconds: 600),
                ),
              ],
              child: CustomCard(
                elevation: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Security Tips',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSecurityTip(
                      'Use a unique password for each of your important accounts',
                      Icons.vpn_key_outlined,
                    ),
                    const SizedBox(height: 12),
                    _buildSecurityTip(
                      'Enable two-factor authentication for all your accounts',
                      Icons.verified_user_outlined,
                    ),
                    const SizedBox(height: 12),
                    _buildSecurityTip(
                      'Regularly check your login history for suspicious activity',
                      Icons.history_outlined,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityRating() {
    final int score = _calculateSecurityScore();
    Color color;
    String label;

    if (score >= 80) {
      color = AppTheme.successColor;
      label = 'Strong';
    } else if (score >= 50) {
      color = AppTheme.warningColor;
      label = 'Fair';
    } else {
      color = AppTheme.errorColor;
      label = 'Weak';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            score >= 80
                ? Icons.verified_outlined
                : score >= 50
                ? Icons.security_outlined
                : Icons.security_update_warning_outlined,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityProgress() {
    final int score = _calculateSecurityScore();

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: score / 100,
            minHeight: 10,
            backgroundColor: AppTheme.surfaceColor,
            valueColor: AlwaysStoppedAnimation<Color>(
              score >= 80
                  ? AppTheme.successColor
                  : score >= 50
                  ? AppTheme.warningColor
                  : AppTheme.errorColor,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Your account security is $score% complete',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppTheme.secondaryTextColor),
        ),
      ],
    );
  }

  Widget _buildSecurityItem({
    required IconData icon,
    required String title,
    required String status,
    required bool isSecure,
    required String action,
    required VoidCallback onActionPressed,
  }) {
    return Animate(
      effects: const [
        FadeEffect(
          delay: Duration(milliseconds: 400),
          duration: Duration(milliseconds: 600),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: CustomCard(
          elevation: 2,
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color:
                      isSecure
                          ? AppTheme.successColor.withOpacity(0.1)
                          : AppTheme.warningColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color:
                      isSecure ? AppTheme.successColor : AppTheme.warningColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      status,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: onActionPressed,
                child: Text(
                  action,
                  style: TextStyle(
                    color: AppTheme.accentColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityTip(String tip, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppTheme.accentColor),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            tip,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.secondaryTextColor,
            ),
          ),
        ),
      ],
    );
  }

  String _getPasswordStrengthText(String strength) {
    switch (strength) {
      case 'strong':
        return 'Strong';
      case 'medium':
        return 'Medium';
      case 'weak':
        return 'Weak';
      default:
        return 'Unknown';
    }
  }

  int _calculateSecurityScore() {
    int score = 0;

    // 2FA enabled adds 40 points
    if (_securityStatus['twoFactorEnabled'] == true) {
      score += 40;
    }

    // Password strength adds up to 30 points
    if (_securityStatus['passwordStrength'] == 'strong') {
      score += 30;
    } else if (_securityStatus['passwordStrength'] == 'medium') {
      score += 15;
    }

    // Recent login monitoring adds 15 points
    if (_securityStatus['lastLogin'] != null) {
      score += 15;
    }

    // Device management adds 15 points
    if (_securityStatus['deviceManagement'] == true) {
      score += 15;
    }

    return score;
  }
}
