import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/models.dart';
import '../../datasources/datasources.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/api_endpoints.dart';
import '../auth_repository.dart';

/// Implementation of AuthRepository
/// 
/// Handles authentication with remote API and local token storage.
/// Includes session management with token expiry.
class AuthRepositoryImpl implements AuthRepository {
  final RemoteDataSource _remoteDataSource;
  SharedPreferences? _prefs;

  // Cached user
  User? _currentUser;

  AuthRepositoryImpl({
    RemoteDataSource? remoteDataSource,
  }) : _remoteDataSource = remoteDataSource ?? RemoteDataSource.instance;

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    final response = await _remoteDataSource.post<Map<String, dynamic>>(
      ApiEndpoints.login,
      body: {
        'email': email,
        'password': password,
      },
    );

    debugPrint('Status code: ${response.statusCode}');
    debugPrint('Data: ${jsonEncode(response.data)}');

    return response.when(
      success: (data) async {
        // API returns { token, user, expires_in }
        final token = data['token'] as String?;
        final userData = data['user'] as Map<String, dynamic>?;
        final expiresIn = data['expires_in'] as int? ?? 86400; // default 24 hours
        
        if (token == null) {
          throw AuthException('Token tidak ditemukan dalam response');
        }

        // Create user from response
        User user;
        if (userData != null) {
          user = User.fromJson(userData).copyWith(token: token);
        } else {
          // Minimal user dari data yang ada
          user = User(
            id: data['id'] ?? 0,
            fullName: data['full_name'] ?? data['name'] ?? email.split('@').first,
            email: data['email'] ?? email,
            token: token,
          );
        }

        // Save user and token with expiry
        await _saveUserWithExpiry(user, expiresIn);
        _currentUser = user;
        return user;
      },
      failure: (error) => throw AuthException(error),
    );
  }

  @override
  Future<User> register({
    required String fullName,
    required String email,
    required String password,
    String? placeOfBirth,
    DateTime? dateOfBirth,
  }) async {
    final response = await _remoteDataSource.post<Map<String, dynamic>>(
      ApiEndpoints.register,
      body: {
        'full_name': fullName,
        'email': email,
        'password': password,
        if (placeOfBirth != null) 'place_of_birth': placeOfBirth,
        if (dateOfBirth != null) 'date_of_birth': dateOfBirth.toIso8601String().split('T').first,
      },
    );

    return response.when(
      success: (data) async {
        // After registration, do auto login or return minimal user
        // Depending on API response
        final token = data['token'] as String?;
        final userData = data['user'] as Map<String, dynamic>?;
        
        User user;
        if (userData != null) {
          user = User.fromJson(userData).copyWith(token: token);
        } else {
          user = User(
            id: _parseInt(data['id']),
            fullName: fullName,
            email: email,
            placeOfBirth: placeOfBirth,
            dateOfBirth: dateOfBirth,
            token: token,
          );
        }

        if (token != null) {
          final expiresIn = data['expires_in'] as int? ?? 86400;
          await _saveUserWithExpiry(user, expiresIn);
        }
        
        _currentUser = user;
        return user;
      },
      failure: (error) => throw AuthException(error),
    );
  }

  @override
  Future<void> logout() async {
    try {
      final token = await getToken();
      if (token != null) {
        await _remoteDataSource.post(
          ApiEndpoints.logout,
          headers: {'Authorization': 'Bearer $token'},
        );
      }
    } catch (e) {
      // Ignore logout errors from server
      debugPrint('Logout API error (ignored): $e');
    }

    await _clearUser();
    _currentUser = null;
  }

  @override
  Future<User?> getProfile() async {
    // Check if session is expired
    if (await isSessionExpired()) {
      await _clearUser();
      _currentUser = null;
      return null;
    }

    // Return cached user if available
    if (_currentUser != null) {
      return _currentUser;
    }

    // Try to load from local storage
    final prefs = await _preferences;
    final userJson = prefs.getString(AppConstants.userKey);
    
    if (userJson != null) {
      _currentUser = User.fromJson(jsonDecode(userJson));
      return _currentUser;
    }

    // Try to fetch from server if we have a token
    final token = await getToken();
    if (token != null) {
      final response = await _remoteDataSource.get<Map<String, dynamic>>(
        ApiEndpoints.profile,
        headers: {'Authorization': 'Bearer $token'},
      );

      return response.when(
        success: (data) async {
          final userData = data['user'] ?? data;
          final user = User.fromJson(userData as Map<String, dynamic>).copyWith(token: token);
          await _saveUser(user);
          _currentUser = user;
          return user;
        },
        failure: (_) => null,
      );
    }

    return null;
  }

  @override
  Future<User> updateProfile({
    String? fullName,
    String? phone,
    String? imageUrl,
    String? placeOfBirth,
    DateTime? dateOfBirth,
  }) async {
    final token = await getToken();
    if (token == null || await isSessionExpired()) {
      throw AuthException('Sesi telah berakhir. Silakan login kembali.');
    }

    final response = await _remoteDataSource.put<Map<String, dynamic>>(
      ApiEndpoints.updateProfile,
      headers: {'Authorization': 'Bearer $token'},
      body: {
        if (fullName != null) 'full_name': fullName,
        if (phone != null) 'phone': phone,
        if (imageUrl != null) 'image_url': imageUrl,
        if (placeOfBirth != null) 'place_of_birth': placeOfBirth,
        if (dateOfBirth != null) 'date_of_birth': dateOfBirth.toIso8601String().split('T').first,
      },
    );

    return response.when(
      success: (data) async {
        debugPrint('Profile update response data: ${jsonEncode(data)}');
        final userData = data['user'] ?? data;
        final user = User.fromJson(userData as Map<String, dynamic>).copyWith(token: token);
        await _saveUser(user);
        _currentUser = user;
        return user;
      },
      failure: (error) => throw AuthException(error),
    );
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    if (token == null || token.isEmpty) return false;
    
    // Check if session is expired
    if (await isSessionExpired()) {
      await _clearUser();
      return false;
    }
    
    return true;
  }

  @override
  Future<String?> getToken() async {
    final prefs = await _preferences;
    return prefs.getString(AppConstants.tokenKey);
  }

  /// Check if the session has expired
  Future<bool> isSessionExpired() async {
    final prefs = await _preferences;
    final expiryMillis = prefs.getInt(AppConstants.tokenExpiryKey);
    
    if (expiryMillis == null) return true;
    
    final expiryTime = DateTime.fromMillisecondsSinceEpoch(expiryMillis);
    return DateTime.now().isAfter(expiryTime);
  }

  /// Get remaining session time
  Future<Duration?> getRemainingSessionTime() async {
    final prefs = await _preferences;
    final expiryMillis = prefs.getInt(AppConstants.tokenExpiryKey);
    
    if (expiryMillis == null) return null;
    
    final expiryTime = DateTime.fromMillisecondsSinceEpoch(expiryMillis);
    final remaining = expiryTime.difference(DateTime.now());
    
    return remaining.isNegative ? Duration.zero : remaining;
  }

  // ══════════════════════════════════════════════════════════════
  // PRIVATE METHODS
  // ══════════════════════════════════════════════════════════════

  /// Save user with token expiry time
  Future<void> _saveUserWithExpiry(User user, int expiresInSeconds) async {
    final prefs = await _preferences;
    
    // Calculate expiry time
    final expiryTime = DateTime.now().add(Duration(seconds: expiresInSeconds));
    
    if (user.token != null) {
      await prefs.setString(AppConstants.tokenKey, user.token!);
      await prefs.setInt(AppConstants.tokenExpiryKey, expiryTime.millisecondsSinceEpoch);
    }
    
    await prefs.setString(AppConstants.userKey, jsonEncode(user.toJson()));
    
    debugPrint('Session saved. Expires at: $expiryTime');
  }

  Future<void> _saveUser(User user) async {
    final prefs = await _preferences;
    
    if (user.token != null) {
      await prefs.setString(AppConstants.tokenKey, user.token!);
    }
    
    await prefs.setString(AppConstants.userKey, jsonEncode(user.toJson()));
  }

  Future<void> _clearUser() async {
    final prefs = await _preferences;
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.tokenExpiryKey);
    await prefs.remove(AppConstants.userKey);
    debugPrint('Session cleared');
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }
}

/// Exception for authentication errors
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}
