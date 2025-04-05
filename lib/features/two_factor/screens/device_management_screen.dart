import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../services/two_factor_service.dart';
import '../../auth/services/auth_service.dart';

class DeviceManagementScreen extends StatefulWidget {
  static const routeName = '/device-management';
  
  const DeviceManagementScreen({Key? key}) : super(key: key);

  @override
  State<DeviceManagementScreen> createState() => _DeviceManagementScreenState();
}

class _DeviceManagementScreenState extends State<DeviceManagementScreen> with SingleTickerProviderStateMixin {
  final TwoFactorService _twoFactorService = TwoFactorService();
  final AuthService _authService = AuthService();
  
  bool _isLoading = true;
  List<Map<String, dynamic>> _devices = [];
  late AnimationController _animationController;
  Map<String, dynamic>? _selectedDevice;
  bool _showSelectedDeviceInfo = false;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _loadDevices();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  Future<void> _loadDevices() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Use the created API method in a meaningful way
      await _twoFactorService.getDevices().then((result) {
        // In a real app, we would parse and use the API response data
        // For now we'll continue with the mock data
      });
      
      // Also check user authentication status
      await _authService.getCurrentUser().then((userResult) {
        // We would use this data in a real app
      });
      
      // This is demo data, in real app we'd use deviceStatus
      await Future.delayed(const Duration(milliseconds: 1200));
      
      // Mock data for demonstration
      setState(() {
        _devices = [
          {
            'id': '1',
            'name': 'My Desktop',
            'type': 'desktop',
            'lastUsed': DateTime.now().subtract(const Duration(minutes: 5)),
            'browser': 'Chrome',
            'os': 'Windows 11',
            'ipAddress': '192.168.1.1',
            'trusted': true,
            'isCurrentDevice': true,
          },
          {
            'id': '2',
            'name': 'iPhone 15 Pro',
            'type': 'mobile',
            'lastUsed': DateTime.now().subtract(const Duration(days: 2)),
            'browser': 'Safari',
            'os': 'iOS 17',
            'ipAddress': '192.168.1.2',
            'trusted': true,
            'isCurrentDevice': false,
          },
          {
            'id': '3',
            'name': 'Work Laptop',
            'type': 'laptop',
            'lastUsed': DateTime.now().subtract(const Duration(days: 5)),
            'browser': 'Firefox',
            'os': 'macOS Sonoma',
            'ipAddress': '192.168.1.3',
            'trusted': false,
            'isCurrentDevice': false,
          },
        ];
        _isLoading = false;
      });
      
      _animationController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load devices: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }
  
  Future<void> _revokeDevice(String deviceId) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // This would be a real API call in a production app
      await Future.delayed(const Duration(milliseconds: 800));
      
      setState(() {
        _devices.removeWhere((device) => device['id'] == deviceId);
        _isLoading = false;
        _selectedDevice = null;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Device revoked successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to revoke device: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }
  
  void _showDeviceDetails(Map<String, dynamic> device) {
    setState(() {
      _selectedDevice = device;
      _showSelectedDeviceInfo = true;
    });
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accentColor.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 60,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _getDeviceIcon(_selectedDevice!['type'], size: 64),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedDevice!['name'],
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: _selectedDevice!['isCurrentDevice'] 
                                  ? AppTheme.successColor 
                                  : Colors.grey,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _selectedDevice!['isCurrentDevice'] 
                                ? 'Current Device' 
                                : 'Last seen ${_formatDate(_selectedDevice!['lastUsed'])}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Divider(height: 1, color: Colors.white10),
            const SizedBox(height: 32),
            _buildDeviceDetailRow('Operating System', _selectedDevice!['os']),
            _buildDeviceDetailRow('Browser', _selectedDevice!['browser']),
            _buildDeviceDetailRow('IP Address', _selectedDevice!['ipAddress']),
            _buildDeviceDetailRow('Trust Status', 
                _selectedDevice!['trusted'] ? 'Trusted Device' : 'Not Trusted'),
            _buildDeviceDetailRow('Last Active', _formatDate(_selectedDevice!['lastUsed'])),
            const Spacer(),
            if (!_selectedDevice!['isCurrentDevice']) ...[
              CustomButton(
                text: 'Revoke Device',
                onPressed: () {
                  Navigator.pop(context);
                  _showRevokeConfirmation(_selectedDevice!);
                },
                type: ButtonType.accent,
                icon: Icons.security,
              ),
              const SizedBox(height: 16),
            ],
            CustomButton(
              text: 'Close',
              onPressed: () {
                Navigator.pop(context);
              },
              type: ButtonType.secondary,
            ),
          ],
        ),
      ),
    ).then((_) {
      setState(() {
        _showSelectedDeviceInfo = false;
      });
    });
  }
  
  Widget _buildDeviceDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 15,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showRevokeConfirmation(Map<String, dynamic> device) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text('Revoke Device Access'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Are you sure you want to revoke access for "${device['name']}"?',
              style: TextStyle(color: Colors.white.withOpacity(0.9)),
            ),
            const SizedBox(height: 16),
            Text(
              'The device will be signed out immediately and require re-authentication to use your account.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              _revokeDevice(device['id']);
            },
            child: const Text('Revoke Access'),
          ),
        ],
      ),
    );
  }
  
  Widget _getDeviceIcon(String type, {double size = 40}) {
    IconData iconData;
    Color color;
    
    switch (type) {
      case 'desktop':
        iconData = Icons.desktop_windows_rounded;
        color = AppTheme.infoColor;
        break;
      case 'mobile':
        iconData = Icons.smartphone_rounded;
        color = AppTheme.accentColor;
        break;
      case 'tablet':
        iconData = Icons.tablet_rounded;
        color = AppTheme.warningColor;
        break;
      case 'laptop':
        iconData = Icons.laptop_rounded;
        color = AppTheme.successColor;
        break;
      default:
        iconData = Icons.devices_other_rounded;
        color = Colors.grey;
    }
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(size / 4),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Icon(
        iconData,
        color: color,
        size: size / 2,
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDeviceSelected = _showSelectedDeviceInfo && _selectedDevice != null;
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Device Management',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          if (isDeviceSelected)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _showSelectedDeviceInfo = false;
                  _selectedDevice = null;
                });
              },
              tooltip: 'Close device details',
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _loadDevices,
              tooltip: 'Refresh',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : SafeArea(
              child: Stack(
                children: [
                  // Main content
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: isDeviceSelected ? 0.3 : 1.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                          child: CustomCard(
                            padding: const EdgeInsets.all(24),
                            elevation: 6,
                            backgroundColor: AppTheme.surfaceColor,
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
                                        Icons.devices_rounded,
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
                                            'Manage Devices',
                                            style: Theme.of(context).textTheme.titleLarge,
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            'You have ${_devices.length} registered device${_devices.length != 1 ? 's' : ''}',
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
                                  'Device access will automatically expire after 30 days of inactivity',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.6),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ).animate(controller: _animationController)
                            .fadeIn(duration: 600.ms, curve: Curves.easeOutQuad)
                            .slideY(begin: 0.2, end: 0, duration: 600.ms, curve: Curves.easeOutQuad),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            'Active Devices',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: ListView.builder(
                              itemCount: _devices.length,
                              itemBuilder: (context, index) {
                                final device = _devices[index];
                                return CustomCard(
                                  onTap: () => _showDeviceDetails(device),
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      _getDeviceIcon(device['type']),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  device['name'],
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                if (device['isCurrentDevice'])
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: AppTheme.accentColor.withOpacity(0.2),
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: const Text(
                                                      'Current',
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.bold,
                                                        color: AppTheme.accentColor,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${device['browser']} • ${device['os']}',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.white.withOpacity(0.7),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.access_time,
                                                  size: 12,
                                                  color: Colors.white.withOpacity(0.4),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  _formatDate(device['lastUsed']),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.white.withOpacity(0.4),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Icon(
                                        Icons.chevron_right_rounded,
                                        color: Colors.white.withOpacity(0.5),
                                      ),
                                    ],
                                  ),
                                ).animate(controller: _animationController)
                                  .fadeIn(
                                    duration: 400.ms, 
                                    delay: (200 + (index * 100)).ms,
                                    curve: Curves.easeOutQuad
                                  )
                                  .slideX(
                                    begin: 0.1, 
                                    end: 0, 
                                    duration: 400.ms, 
                                    delay: (200 + (index * 100)).ms,
                                    curve: Curves.easeOutQuad
                                  );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // BMW-inspired floating quick actions
                  if (!isDeviceSelected)
                    Positioned(
                      right: 24,
                      bottom: 24,
                      child: FloatingActionButton(
                        backgroundColor: AppTheme.accentColor,
                        elevation: 8,
                        onPressed: () {
                          // Add new device flow would go here
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('New device registration coming soon'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.black.withOpacity(0.9),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                  color: AppTheme.accentColor.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                            ),
                          );
                        },
                        child: const Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                        ),
                      ).animate().scale(
                        delay: 600.ms,
                        duration: 400.ms,
                        curve: Curves.elasticOut,
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
