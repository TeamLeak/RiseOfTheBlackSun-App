import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../services/two_factor_service.dart';
import '../../auth/services/auth_service.dart';

class ActivityTimelineScreen extends StatefulWidget {
  static const routeName = '/activity-timeline';
  
  const ActivityTimelineScreen({Key? key}) : super(key: key);

  @override
  State<ActivityTimelineScreen> createState() => _ActivityTimelineScreenState();
}

class _ActivityTimelineScreenState extends State<ActivityTimelineScreen> with TickerProviderStateMixin {
  final TwoFactorService _twoFactorService = TwoFactorService();
  final AuthService _authService = AuthService();
  
  bool _isLoading = true;
  List<Map<String, dynamic>> _activities = [];
  late AnimationController _fadeController;
  late AnimationController _timelineController;
  late TabController _tabController;
  
  final List<String> _tabs = ['All Activity', 'Login', 'Security', 'Profile'];
  String _selectedFilter = 'All Activity';
  
  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _timelineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedFilter = _tabs[_tabController.index];
        });
        _loadActivities();
      }
    });
    _loadActivities();
  }
  
  @override
  void dispose() {
    _fadeController.dispose();
    _timelineController.dispose();
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadActivities() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Reset animation controllers
      _fadeController.reset();
      _timelineController.reset();
      
      // Use API services in a meaningful way
      await _twoFactorService.getActivityTimeline().then((result) {
        // In a real app, we would use the result
        // For now, we'll use mock data
      });
      
      await _authService.getCurrentUser().then((result) {
        // Similarly, we'd use this data in a real application
      });
      
      // Placeholder for a real API call
      await Future.delayed(const Duration(milliseconds: 1200));
      
      // Mock data for demonstration
      final allActivities = [
        {
          'id': '1',
          'type': 'login',
          'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
          'title': 'Login Successful',
          'details': 'You logged in from Chrome on Windows 11',
          'ipAddress': '192.168.1.1',
          'deviceId': '1',
          'deviceName': 'My Desktop',
          'location': 'Moscow, Russia',
          'critical': false,
        },
        {
          'id': '2',
          'type': 'security',
          'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
          'title': 'Two-Factor Authentication Enabled',
          'details': 'You enabled 2FA for your account',
          'ipAddress': '192.168.1.1',
          'deviceId': '1',
          'deviceName': 'My Desktop',
          'location': 'Moscow, Russia',
          'critical': true,
        },
        {
          'id': '3',
          'type': 'profile',
          'timestamp': DateTime.now().subtract(const Duration(days: 1)),
          'title': 'Profile Updated',
          'details': 'You updated your profile information',
          'ipAddress': '192.168.1.1',
          'deviceId': '1',
          'deviceName': 'My Desktop',
          'location': 'Moscow, Russia',
          'critical': false,
        },
        {
          'id': '4',
          'type': 'login',
          'timestamp': DateTime.now().subtract(const Duration(days: 2)),
          'title': 'Login Attempt Failed',
          'details': 'Failed login attempt from unknown device',
          'ipAddress': '203.0.113.42',
          'deviceId': null,
          'deviceName': 'Unknown Device',
          'location': 'Berlin, Germany',
          'critical': true,
        },
        {
          'id': '5',
          'type': 'security',
          'timestamp': DateTime.now().subtract(const Duration(days: 3)),
          'title': 'Backup Codes Generated',
          'details': 'You generated new backup codes for your account',
          'ipAddress': '192.168.1.2',
          'deviceId': '2',
          'deviceName': 'iPhone 15 Pro',
          'location': 'Moscow, Russia',
          'critical': false,
        },
        {
          'id': '6',
          'type': 'profile',
          'timestamp': DateTime.now().subtract(const Duration(days: 5)),
          'title': 'Password Changed',
          'details': 'You changed your account password',
          'ipAddress': '192.168.1.1',
          'deviceId': '1',
          'deviceName': 'My Desktop',
          'location': 'Moscow, Russia',
          'critical': true,
        },
        {
          'id': '7',
          'type': 'login',
          'timestamp': DateTime.now().subtract(const Duration(days: 7)),
          'title': 'New Device Login',
          'details': 'First login from a new device',
          'ipAddress': '192.168.1.3',
          'deviceId': '3',
          'deviceName': 'Work Laptop',
          'location': 'Saint Petersburg, Russia',
          'critical': true,
        },
      ];
      
      // Filter activities based on selected tab
      List<Map<String, dynamic>> filteredActivities;
      if (_selectedFilter == 'All Activity') {
        filteredActivities = allActivities;
      } else {
        filteredActivities = allActivities.where(
          (activity) => activity['type'].toString().toLowerCase() == _selectedFilter.toLowerCase()
        ).toList();
      }
      
      setState(() {
        _activities = filteredActivities;
        _isLoading = false;
      });
      
      // Play animations
      _fadeController.forward();
      _timelineController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load activity timeline: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }
  
  Color _getActivityColor(String type) {
    switch (type.toLowerCase()) {
      case 'login':
        return AppTheme.infoColor;
      case 'security':
        return AppTheme.accentColor;
      case 'profile':
        return AppTheme.successColor;
      default:
        return Colors.grey;
    }
  }
  
  IconData _getActivityIcon(String type) {
    switch (type.toLowerCase()) {
      case 'login':
        return Icons.login_rounded;
      case 'security':
        return Icons.security_rounded;
      case 'profile':
        return Icons.person_rounded;
      default:
        return Icons.circle;
    }
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
      return DateFormat('MMMM d, yyyy').format(date);
    }
  }
  
  String _formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }
  
  void _showActivityDetails(Map<String, dynamic> activity) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
          boxShadow: [
            BoxShadow(
              color: _getActivityColor(activity['type']).withOpacity(0.1),
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
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getActivityColor(activity['type']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getActivityColor(activity['type']).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    _getActivityIcon(activity['type']),
                    color: _getActivityColor(activity['type']),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity['title'],
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(activity['timestamp']) + ' at ' + _formatTime(activity['timestamp']),
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
            const SizedBox(height: 32),
            const Divider(height: 1, color: Colors.white10),
            const SizedBox(height: 32),
            _buildDetailRow('Details', activity['details']),
            _buildDetailRow('Device', activity['deviceName']),
            _buildDetailRow('IP Address', activity['ipAddress']),
            _buildDetailRow('Location', activity['location']),
            _buildDetailRow('Activity Type', activity['type'].toString().capitalize()),
            const Spacer(),
            if (activity['critical']) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.errorColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: AppTheme.errorColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This is a security-critical activity. If you did not perform this action, please change your password immediately and contact support.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
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
    );
  }
  
  Widget _buildDetailRow(String title, String value) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Activity Timeline',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadActivities,
            tooltip: 'Refresh',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Animate(
            effects: [
              FadeEffect(
                duration: 400.ms,
                delay: 200.ms,
                curve: Curves.easeOut,
              ),
              SlideEffect(
                begin: const Offset(0, 0.5),
                end: const Offset(0, 0),
                duration: 400.ms,
                delay: 200.ms,
                curve: Curves.easeOut,
              ),
            ],
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppTheme.accentColor,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.label,
              labelColor: AppTheme.accentColor,
              unselectedLabelColor: Colors.white.withOpacity(0.7),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : SafeArea(
              child: _activities.isEmpty
                  ? Center(
                      child: Animate(
                        effects: [
                          FadeEffect(
                            duration: 400.ms,
                            delay: 200.ms,
                            curve: Curves.easeOut,
                          ),
                        ],
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.hourglass_empty_rounded,
                              size: 64,
                              color: Colors.white.withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No activities found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try changing the filter or check back later',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      itemCount: _activities.length,
                      itemBuilder: (context, index) {
                        final activity = _activities[index];
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Timeline indicator
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: _getActivityColor(activity['type']).withOpacity(0.2),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: _getActivityColor(activity['type']),
                                        width: 2,
                                      ),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        _getActivityIcon(activity['type']),
                                        size: 14,
                                        color: _getActivityColor(activity['type']),
                                      ),
                                    ),
                                  ),
                                  if (index < _activities.length - 1)
                                    Container(
                                      width: 2,
                                      height: 40,
                                      color: _getActivityColor(activity['type']).withOpacity(0.3),
                                    ),
                                ],
                              ),
                              const SizedBox(width: 16),
                              
                              // Activity content
                              Expanded(
                                child: Animate(
                                  effects: [
                                    FadeEffect(
                                      duration: 400.ms,
                                      delay: (100 * index).ms,
                                      curve: Curves.easeOut,
                                    ),
                                    SlideEffect(
                                      begin: const Offset(0.2, 0),
                                      end: const Offset(0, 0),
                                      duration: 400.ms,
                                      delay: (100 * index).ms,
                                      curve: Curves.easeOut,
                                    ),
                                  ],
                                  child: CustomCard(
                                    onTap: () => _showActivityDetails(activity),
                                    padding: const EdgeInsets.all(16),
                                    margin: EdgeInsets.zero,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                activity['title'],
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                            if (activity['critical'])
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppTheme.errorColor.withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: const Text(
                                                  'Critical',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppTheme.errorColor,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          activity['details'],
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white.withOpacity(0.7),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.access_time,
                                              size: 12,
                                              color: Colors.white.withOpacity(0.4),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              _formatDate(activity['timestamp']),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.white.withOpacity(0.4),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Icon(
                                              Icons.watch_later_outlined,
                                              size: 12,
                                              color: Colors.white.withOpacity(0.4),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              _formatTime(activity['timestamp']),
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
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
