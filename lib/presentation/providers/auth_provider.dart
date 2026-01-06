import 'package:flutter/foundation.dart';
import '../../data/models/models.dart';
import '../../data/repositories/repositories.dart';

/// State for authentication
enum AuthState { initial, loading, authenticated, unauthenticated, error, sessionExpired }

/// Provider for Authentication state management
class AuthProvider extends ChangeNotifier {
  final AuthRepositoryImpl _repository;

  AuthProvider({AuthRepositoryImpl? repository})
      : _repository = repository ?? AuthRepositoryImpl();

  // State
  AuthState _state = AuthState.initial;
  String? _errorMessage;

  // Data
  User? _user;

  // Getters
  AuthState get state => _state;
  String? get errorMessage => _errorMessage;
  User? get user => _user;

  bool get isLoading => _state == AuthState.loading;
  bool get isAuthenticated => _state == AuthState.authenticated && _user != null;
  bool get isSessionExpired => _state == AuthState.sessionExpired;
  bool get hasError => _state == AuthState.error;

  String get userName => _user?.fullName ?? 'Guest';
  String get userEmail => _user?.email ?? '';
  String get userInitials => _user?.initials ?? '?';

  // ══════════════════════════════════════════════════════════════
  // ACTIONS
  // ══════════════════════════════════════════════════════════════

  /// Initialize - check if user is logged in and session is valid
  Future<void> initialize() async {
    _setState(AuthState.loading);

    try {
      final isLoggedIn = await _repository.isLoggedIn();
      
      if (isLoggedIn) {
        // Check session expiry
        if (await _repository.isSessionExpired()) {
          await _repository.logout();
          _setState(AuthState.sessionExpired);
          return;
        }

        _user = await _repository.getProfile();
        if (_user != null) {
          _setState(AuthState.authenticated);
        } else {
          _setState(AuthState.unauthenticated);
        }
      } else {
        _setState(AuthState.unauthenticated);
      }
    } catch (e) {
      debugPrint('Auth initialize error: $e');
      _setState(AuthState.unauthenticated);
    }
  }

  /// Check if session is still valid
  Future<bool> checkSession() async {
    if (await _repository.isSessionExpired()) {
      _user = null;
      _setState(AuthState.sessionExpired);
      return false;
    }
    return true;
  }

  /// Get remaining session time
  Future<Duration?> getRemainingSessionTime() async {
    return _repository.getRemainingSessionTime();
  }

  /// Login with email and password
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setState(AuthState.loading);

    try {
      _user = await _repository.login(
        email: email,
        password: password,
      );
      _setState(AuthState.authenticated);
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Terjadi kesalahan. Silakan coba lagi.');
      return false;
    }
  }

  /// Register new user
  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    String? placeOfBirth,
    DateTime? dateOfBirth,
  }) async {
    _setState(AuthState.loading);

    try {
      _user = await _repository.register(
        fullName: fullName,
        email: email,
        password: password,
        placeOfBirth: placeOfBirth,
        dateOfBirth: dateOfBirth,
      );
      _setState(AuthState.authenticated);
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Terjadi kesalahan. Silakan coba lagi.');
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    _setState(AuthState.loading);

    try {
      await _repository.logout();
    } catch (_) {
      // Ignore logout errors
    }

    _user = null;
    _setState(AuthState.unauthenticated);
  }

  /// Update profile
  Future<bool> updateProfile({
    String? fullName,
    String? phone,
    String? imageUrl,
    String? placeOfBirth,
    DateTime? dateOfBirth,
  }) async {
    try {
      _user = await _repository.updateProfile(
        fullName: fullName,
        phone: phone,
        imageUrl: imageUrl,
        placeOfBirth: placeOfBirth,
        dateOfBirth: dateOfBirth,
      );
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error updating profile: $e');
      return false;
    }
  }

  /// Refresh profile from server
  Future<void> refreshProfile() async {
    try {
      _user = await _repository.getProfile();
      notifyListeners();
    } catch (e) {
      debugPrint('Error refreshing profile: $e');
    }
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ══════════════════════════════════════════════════════════════
  // PRIVATE HELPERS
  // ══════════════════════════════════════════════════════════════

  void _setState(AuthState state) {
    _state = state;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _state = AuthState.error;
    _errorMessage = message;
    notifyListeners();
  }
}
