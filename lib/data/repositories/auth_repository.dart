import '../models/models.dart';

/// Abstract repository interface for authentication
abstract class AuthRepository {
  /// Login with email and password
  Future<User> login({
    required String email,
    required String password,
  });

  /// Register new user
  Future<User> register({
    required String fullName,
    required String email,
    required String password,
    String? placeOfBirth,
    DateTime? dateOfBirth,
  });

  /// Logout current user
  Future<void> logout();

  /// Get current user profile
  Future<User?> getProfile();

  /// Update user profile
  Future<User> updateProfile({
    String? fullName,
    String? phone,
    String? imageUrl,
    String? placeOfBirth,
    DateTime? dateOfBirth,
  });

  /// Check if user is logged in
  Future<bool> isLoggedIn();

  /// Get stored auth token
  Future<String?> getToken();
}
