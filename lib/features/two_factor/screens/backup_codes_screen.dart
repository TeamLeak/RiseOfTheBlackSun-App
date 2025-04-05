import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_card.dart';
import '../services/two_factor_service.dart';

class BackupCodesScreen extends StatefulWidget {
  static const routeName = '/backup-codes';

  const BackupCodesScreen({Key? key}) : super(key: key);

  @override
  State<BackupCodesScreen> createState() => _BackupCodesScreenState();
}

class _BackupCodesScreenState extends State<BackupCodesScreen> {
  final _twoFactorService = TwoFactorService();
  
  bool _isLoading = true;
  String? _errorMessage;
  List<String> _backupCodes = [];
  
  @override
  void initState() {
    super.initState();
    _loadBackupCodes();
  }
  
  Future<void> _loadBackupCodes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final result = await _twoFactorService.getBackupCodes();
      
      setState(() {
        if (result['success']) {
          _backupCodes = List<String>.from(result['codes']);
        } else {
          _errorMessage = result['message'];
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load backup codes: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _generateNewCodes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final result = await _twoFactorService.generateBackupCodes();
      
      setState(() {
        if (result['success']) {
          _backupCodes = List<String>.from(result['codes']);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('New backup codes generated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          _errorMessage = result['message'];
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to generate new backup codes: ${e.toString()}';
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
        title: const Text('Backup Codes'),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }
  
  Widget _buildContent() {
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppTheme.errorColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Error',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.errorColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.secondaryTextColor),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Try Again',
                onPressed: _loadBackupCodes,
                type: ButtonType.primary,
              ),
            ],
          ),
        ),
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Animate(
            effects: const [FadeEffect(duration: Duration(milliseconds: 600))],
            child: Column(
              children: [
                Icon(
                  Icons.key_rounded,
                  size: 64,
                  color: AppTheme.accentColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'Recovery Backup Codes',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'These codes can be used to recover your account if you lose access to your authenticator app.',
                  style: TextStyle(color: AppTheme.secondaryTextColor),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Info card
          Animate(
            effects: const [
              FadeEffect(
                delay: Duration(milliseconds: 200),
                duration: Duration(milliseconds: 600),
              ),
            ],
            child: CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 20,
                        color: AppTheme.warningColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Important Information',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '• Each code can only be used once\n'
                    '• Store them securely\n'
                    '• Generating new codes will invalidate old ones\n'
                    '• If you lose both your authenticator app and your backup codes, you may be locked out of your account',
                    style: TextStyle(height: 1.5),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Backup codes list
          if (_backupCodes.isNotEmpty) ...[
            Animate(
              effects: const [
                FadeEffect(
                  delay: Duration(milliseconds: 400),
                  duration: Duration(milliseconds: 600),
                ),
              ],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Your Backup Codes',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  CustomCard(
                    child: Column(
                      children: [
                        for (final code in _backupCodes)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.surfaceVariant,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      code,
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.copy, size: 20),
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: code));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Code copied to clipboard'),
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                  tooltip: 'Copy code',
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton.icon(
                              icon: const Icon(Icons.copy_all),
                              label: const Text('Copy All Codes'),
                              onPressed: () {
                                Clipboard.setData(
                                  ClipboardData(text: _backupCodes.join('\n')),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('All codes copied to clipboard'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Animate(
              effects: const [
                FadeEffect(
                  delay: Duration(milliseconds: 400),
                  duration: Duration(milliseconds: 600),
                ),
              ],
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.more_horiz,
                        size: 48,
                        color: AppTheme.secondaryTextColor.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No backup codes found',
                        style: TextStyle(color: AppTheme.secondaryTextColor),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 32),
          
          // Generate new codes button
          Animate(
            effects: const [
              FadeEffect(
                delay: Duration(milliseconds: 600),
                duration: Duration(milliseconds: 600),
              ),
            ],
            child: CustomButton(
              text: _backupCodes.isEmpty 
                  ? 'Generate Backup Codes' 
                  : 'Generate New Backup Codes',
              onPressed: _generateNewCodes,
              type: ButtonType.primary,
              icon: Icons.refresh,
            ),
          ),
          
          if (_backupCodes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Animate(
              effects: const [
                FadeEffect(
                  delay: Duration(milliseconds: 700),
                  duration: Duration(milliseconds: 600),
                ),
              ],
              child: Text(
                'Warning: Generating new codes will invalidate all existing ones',
                style: TextStyle(
                  color: AppTheme.warningColor,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
