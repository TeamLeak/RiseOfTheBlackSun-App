import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_service.dart';
import '../../../core/models/user_model.dart';
import '../../../core/config/app_config.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  // Login with email and password
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _apiService.post(
      '/login',
      data: {'email': email, 'password': password},
    );

    if (response.statusCode == 200) {
      // Save token and user data
      final token = response.data['token'];
      final userData = response.data['user'];

      await _apiService.setToken(token);
      await _apiService.setUserData(userData);

      // Save to shared preferences if needed
      final prefs = await SharedPreferences.getInstance();
      prefs.setBool('isLoggedIn', true);

      return {'success': true, 'token': token, 'user': User.fromJson(userData)};
    } else {
      return {
        'success': false,
        'message': response.data['message'] ?? 'Login failed',
      };
    }
  }

  // Register new user
  Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
  ) async {
    final response = await _apiService.post(
      '/register',
      data: {'username': username, 'email': email, 'password': password},
    );

    if (response.statusCode == 201) {
      // Save token and user data
      final token = response.data['token'];
      final userData = response.data['user'];

      await _apiService.setToken(token);
      await _apiService.setUserData(userData);

      // Save to shared preferences if needed
      final prefs = await SharedPreferences.getInstance();
      prefs.setBool('isLoggedIn', true);

      return {'success': true, 'token': token, 'user': User.fromJson(userData)};
    } else {
      return {
        'success': false,
        'message': response.data['message'] ?? 'Registration failed',
      };
    }
  }

  // Logout user
  Future<bool> logout() async {
    try {
      final response = await _apiService.post('/auth/logout');

      // Clear token and user data regardless of response
      await _apiService.clearToken();

      // Clear shared preferences
      final prefs = await SharedPreferences.getInstance();
      prefs.setBool('isLoggedIn', false);

      return response.statusCode == 200;
    } catch (e) {
      // Still clear local token on error
      await _apiService.clearToken();
      return false;
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

      if (!isLoggedIn) return false;

      final userData = await _apiService.getUserData();
      if (userData == null) return false;

      // Verify token validity if available
      final token = await _apiService.get(AppConfig.tokenKey);
      if (token is String) {
        try {
          final decodedToken = JwtDecoder.decode(token as String);
          final expirationDate = DateTime.fromMillisecondsSinceEpoch(
            decodedToken['exp'] * 1000,
          );
          if (expirationDate.isBefore(DateTime.now())) {
            // Token expired
            await _apiService.clearToken();
            return false;
          }
        } catch (e) {
          return false;
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // Get current user
  Future<User?> getCurrentUser() async {
    try {
      final userData = await _apiService.getUserData();
      if (userData != null) {
        return User.fromJson(userData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Forgot password
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final response = await _apiService.post(
      '/forgot-password',
      data: {'email': email},
    );

    if (response.statusCode == 200) {
      return {
        'success': true,
        'message':
            response.data['message'] ?? 'Password reset instructions sent',
      };
    } else {
      return {
        'success': false,
        'message':
            response.data['message'] ?? 'Failed to request password reset',
      };
    }
  }

  // Reset password
  Future<Map<String, dynamic>> resetPassword(
    String token,
    String password,
  ) async {
    final response = await _apiService.post(
      '/reset-password/$token',
      data: {'password': password},
    );

    if (response.statusCode == 200) {
      return {
        'success': true,
        'message': response.data['message'] ?? 'Password reset successful',
      };
    } else {
      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to reset password',
      };
    }
  }

  // Change password
  Future<Map<String, dynamic>> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    final response = await _apiService.post(
      '/user/change-password',
      data: {'current_password': currentPassword, 'new_password': newPassword},
    );

    if (response.statusCode == 200) {
      return {
        'success': true,
        'message': response.data['message'] ?? 'Password changed successfully',
      };
    } else {
      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to change password',
      };
    }
  }

  // Get last login information
  Future<Map<String, dynamic>> getLastLogin() async {
    try {
      final response = await _apiService.get('/user/login-history');

      if (response.statusCode == 200) {
        final lastLogin = response.data['lastLogin'];
        final recentAttempts = response.data['recentAttempts'] ?? 0;

        return {
          'success': true,
          'data': lastLogin,
          'recentAttempts': recentAttempts,
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to get login history',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error retrieving login history'};
    }
  }

  // Get password strength assessment
  Future<Map<String, dynamic>> getPasswordStrength() async {
    try {
      final response = await _apiService.get('/user/password-strength');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'strength': response.data['strength'] ?? 'medium',
          'suggestions': response.data['suggestions'] ?? [],
        };
      } else {
        return {
          'success': false,
          'strength': 'medium', // Default value if API fails
          'message':
              response.data['message'] ?? 'Failed to analyze password strength',
        };
      }
    } catch (e) {
      // Provide default value in case of error
      return {
        'success': false,
        'strength': 'medium',
        'message': 'Error analyzing password strength',
      };
    }
  }
}
