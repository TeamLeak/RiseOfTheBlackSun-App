import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';

class ApiService {
  late Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: Duration(milliseconds: AppConfig.apiTimeout),
        receiveTimeout: Duration(milliseconds: AppConfig.apiTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors for authentication
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Get the auth token
          final token = await _storage.read(key: AppConfig.tokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // Handle 401 Unauthorized errors
          if (e.response?.statusCode == 401) {
            // Clear token and redirect to login
            _storage.delete(key: AppConfig.tokenKey);
            _storage.delete(key: AppConfig.userKey);
            // NotificationService will handle redirecting to login
          }
          return handler.next(e);
        },
      ),
    );
  }

  // Generic GET request
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // Generic POST request
  Future<Response> post(String path, {Object? data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.post(path, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // Generic PUT request
  Future<Response> put(String path, {Object? data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.put(path, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // Generic PATCH request
  Future<Response> patch(String path, {Object? data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.patch(path, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // Generic DELETE request
  Future<Response> delete(String path, {Object? data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.delete(path, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // Upload file
  Future<Response> uploadFile(String path, FormData formData) async {
    try {
      return await _dio.post(path, data: formData);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // Handle errors
  Response _handleError(DioException e) {
    if (e.response != null) {
      return e.response!;
    } else {
      return Response(
        statusCode: 500,
        data: {
          'message': 'Network error: ${e.message}',
          'code': 500,
        },
        requestOptions: e.requestOptions,
      );
    }
  }

  // Set token after login
  Future<void> setToken(String token) async {
    await _storage.write(key: AppConfig.tokenKey, value: token);
  }

  // Clear token on logout
  Future<void> clearToken() async {
    await _storage.delete(key: AppConfig.tokenKey);
  }

  // Store user data
  Future<void> setUserData(Map<String, dynamic> userData) async {
    await _storage.write(key: AppConfig.userKey, value: jsonEncode(userData));
  }

  // Get user data
  Future<Map<String, dynamic>?> getUserData() async {
    final data = await _storage.read(key: AppConfig.userKey);
    if (data != null) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    return null;
  }

  // Clear all stored data
  Future<void> clearAllData() async {
    await _storage.deleteAll();
  }
}
