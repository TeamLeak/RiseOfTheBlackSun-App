import '../../../core/network/api_service.dart';

class TwoFactorService {
  final ApiService _apiService = ApiService();

  // Get 2FA status (enabled/disabled)
  Future<Map<String, dynamic>> get2FAStatus() async {
    final response = await _apiService.get('/user/2fa/status');

    if (response.statusCode == 200) {
      return {
        'success': true,
        'enabled': response.data['enabled'],
        'secret': response.data['secret'],
      };
    } else {
      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to get 2FA status',
      };
    }
  }
  
  // Get QR Code for 2FA setup
  Future<Map<String, dynamic>> get2FAQrCode() async {
    final response = await _apiService.get('/user/2fa/qrcode');
    
    if (response.statusCode == 200) {
      return {
        'success': true,
        'qrUrl': response.data['qr_url'],
        'secret': response.data['secret'],
      };
    } else {
      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to get QR code',
      };
    }
  }

  // Generate new 2FA secret
  Future<Map<String, dynamic>> generate2FASecret() async {
    final response = await _apiService.post('/user/2fa/enable', data: {});

    if (response.statusCode == 200) {
      return {
        'success': true,
        'secret': response.data['secret'],
        'qrCode': response.data['qr_code'],
        'message': response.data['message'],
      };
    } else {
      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to generate 2FA secret',
      };
    }
  }

  // Enable 2FA with verification code
  Future<Map<String, dynamic>> enable2FA(String code, String secret) async {
    final response = await _apiService.post(
      '/user/2fa/enable',
      data: {'code': code, 'secret': secret},
    );

    if (response.statusCode == 200) {
      return {
        'success': true,
        'message': response.data['message'] ?? '2FA enabled successfully',
      };
    } else {
      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to enable 2FA',
      };
    }
  }

  // Disable 2FA
  Future<Map<String, dynamic>> disable2FA(String code, String password) async {
    final response = await _apiService.post(
      '/user/2fa/disable',
      data: {'code': code, 'password': password},
    );

    if (response.statusCode == 200) {
      return {
        'success': true,
        'message': response.data['message'] ?? '2FA disabled successfully',
      };
    } else {
      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to disable 2FA',
      };
    }
  }

  // Verify 2FA code during login
  Future<Map<String, dynamic>> verify2FACode(String email, String code) async {
    try {
      final response = await _apiService.post(
        '/user/2fa/verify',
        data: {'email': email, 'code': code},
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'token': response.data['token'],
          'message': response.data['message'],
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to verify 2FA code',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred during verification',
      };
    }
  }
  
  // Generate backup codes
  Future<Map<String, dynamic>> generateBackupCodes() async {
    final response = await _apiService.post('/user/2fa/backup-codes', data: {});
    
    if (response.statusCode == 200) {
      return {
        'success': true,
        'codes': response.data['codes'],
        'message': response.data['message'],
      };
    } else {
      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to generate backup codes',
      };
    }
  }

  // Get backup codes
  Future<Map<String, dynamic>> getBackupCodes() async {
    final response = await _apiService.get('/user/2fa/backup-codes');
    
    if (response.statusCode == 200) {
      return {
        'success': true,
        'codes': response.data['codes'],
      };
    } else {
      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to get backup codes',
      };
    }
  }
  
  // Get devices
  Future<Map<String, dynamic>> getDevices() async {
    final response = await _apiService.get('/user/devices');
    
    if (response.statusCode == 200) {
      return {
        'success': true,
        'devices': response.data['devices'],
      };
    } else {
      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to get devices',
      };
    }
  }
  
  // Revoke device
  Future<Map<String, dynamic>> revokeDevice(String deviceId) async {
    final response = await _apiService.post('/user/devices/$deviceId/revoke', data: {});
    
    if (response.statusCode == 200) {
      return {
        'success': true,
        'message': response.data['message'] ?? 'Device revoked successfully',
      };
    } else {
      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to revoke device',
      };
    }
  }
  
  // Get current device info
  Future<Map<String, dynamic>> getCurrentDeviceInfo() async {
    final response = await _apiService.get('/user/devices/current');
    
    if (response.statusCode == 200) {
      return {
        'success': true,
        'device': response.data['device'],
      };
    } else {
      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to get current device info',
      };
    }
  }
  
  // Get activity timeline
  Future<Map<String, dynamic>> getActivityTimeline() async {
    final response = await _apiService.get('/user/activity');
    
    if (response.statusCode == 200) {
      return {
        'success': true,
        'timeline': response.data['timeline'],
      };
    } else {
      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to get activity timeline',
      };
    }
  }
  
  // Get activity stats
  Future<Map<String, dynamic>> getActivityStats() async {
    final response = await _apiService.get('/user/activity/stats');
    
    if (response.statusCode == 200) {
      return {
        'success': true,
        'stats': response.data['stats'],
      };
    } else {
      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to get activity stats',
      };
    }
  }
  
  // Get security dashboard
  Future<Map<String, dynamic>> getSecurityDashboard() async {
    final response = await _apiService.get('/user/security/dashboard');
    
    if (response.statusCode == 200) {
      return {
        'success': true,
        'dashboard': response.data,
      };
    } else {
      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to get security dashboard',
      };
    }
  }
  
  // Get security score
  Future<Map<String, dynamic>> getSecurityScore() async {
    final response = await _apiService.get('/user/security/score');
    
    if (response.statusCode == 200) {
      return {
        'success': true,
        'score': response.data['score'],
      };
    } else {
      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to get security score',
      };
    }
  }
  
  // Get security recommendations
  Future<Map<String, dynamic>> getSecurityRecommendations() async {
    final response = await _apiService.get('/user/security/recommendations');
    
    if (response.statusCode == 200) {
      return {
        'success': true,
        'recommendations': response.data['recommendations'],
      };
    } else {
      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to get security recommendations',
      };
    }
  }
  
  // Get security preferences
  Future<Map<String, dynamic>> getSecurityPreferences() async {
    final response = await _apiService.get('/user/security/preferences');
    
    if (response.statusCode == 200) {
      return {
        'success': true,
        'preferences': response.data['preferences'],
      };
    } else {
      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to get security preferences',
      };
    }
  }
  
  // Update security preferences
  Future<Map<String, dynamic>> updateSecurityPreferences(Map<String, dynamic> preferences) async {
    final response = await _apiService.patch('/user/security/preferences', data: preferences);
    
    if (response.statusCode == 200) {
      return {
        'success': true,
        'message': response.data['message'] ?? 'Security preferences updated successfully',
      };
    } else {
      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to update security preferences',
      };
    }
  }

  // Get login history
  Future<Map<String, dynamic>> getLoginHistory({int limit = 10}) async {
    final response = await _apiService.get(
      '/user/login-history',
      queryParameters: {'limit': limit.toString()},
    );

    if (response.statusCode == 200) {
      return {'success': true, 'history': response.data['history']};
    } else {
      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to get login history',
      };
    }
  }
}
