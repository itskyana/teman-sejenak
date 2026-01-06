/// Application-wide constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Teman Sejenak';
  static const String appVersion = '1.0.0';

  // API Configuration
  static const String baseUrl = 'http://127.0.0.1/teman-sejenak/api';
  
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Pagination
  static const int defaultPageSize = 20;

  // Pricing
  static const int chatRatePerHour = 50000;
  static const int meetRatePerHour = 350000;

  // Animation Durations
  static const Duration splashDuration = Duration(seconds: 3);
  static const Duration carouselInterval = Duration(seconds: 4);
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String tokenExpiryKey = 'token_expiry';
  static const String userKey = 'user_data';
  static const String onboardingKey = 'onboarding_completed';

  // Session Configuration
  static const Duration sessionDuration = Duration(hours: 24); // Token valid for 24 hours
}
