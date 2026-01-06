/// API Endpoints - centralized for easy maintenance
class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';

  // User
  static const String profile = '/user/profile';
  static const String updateProfile = '/user/update';

  // Destinations
  static const String destinations = '/destination';
  static const String destinationDetail = '/destination/detail'; // + /{id}

  // Guides
  static const String guides = '/guide';
  static const String guideDetail = '/guide/detail'; // + /{id}

  // Orders
  static const String orders = '/order';
  static const String orderDetail = '/order'; // + /{id}
  static const String createOrder = '/order/create';
  static const String cancelOrder = '/order/cancel'; // + /{id}
}
