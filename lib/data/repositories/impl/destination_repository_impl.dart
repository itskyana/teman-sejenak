import 'package:shared_preferences/shared_preferences.dart';
import '../../models/models.dart';
import '../../datasources/datasources.dart';
import '../../../core/constants/asset_paths.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/app_constants.dart';
import '../destination_repository.dart';

/// Implementation of DestinationRepository
/// 
/// This implementation supports both local JSON and remote API.
/// Set [useRemote] to false to switch to local JSON mode.
class DestinationRepositoryImpl implements DestinationRepository {
  final LocalDataSource _localDataSource;
  final RemoteDataSource _remoteDataSource;
  final bool useRemote;

  // Cache for data
  List<Destination>? _cachedDestinations;
  SharedPreferences? _prefs;

  DestinationRepositoryImpl({
    LocalDataSource? localDataSource,
    RemoteDataSource? remoteDataSource,
    this.useRemote = true, // Default to API
  })  : _localDataSource = localDataSource ?? LocalDataSource.instance,
        _remoteDataSource = remoteDataSource ?? RemoteDataSource.instance;

  Future<String?> _getToken() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!.getString(AppConstants.tokenKey);
  }

  Map<String, String> _authHeaders(String? token) {
    if (token == null) return {};
    return {'Authorization': 'Bearer $token'};
  }

  @override
  Future<List<Destination>> getAll() async {
    if (useRemote) {
      return _getFromRemote();
    }
    return _getFromLocal();
  }

  @override
  Future<Destination?> getById(int id) async {
    final destinations = await getAll();
    try {
      return destinations.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Destination>> getPopular({int limit = 10}) async {
    final destinations = await getAll();
    // Sort by rating (if available) or return first N items
    final sorted = List<Destination>.from(destinations)
      ..sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
    return sorted.take(limit).toList();
  }

  @override
  Future<List<Destination>> getNearby({
    required double latitude,
    required double longitude,
    int limit = 10,
  }) async {
    final destinations = await getAll();
    
    // Calculate distance and sort (simplified - uses rough distance)
    final withDistance = destinations.map((d) {
      if (d.latitude != null && d.longitude != null) {
        final distance = _calculateDistance(
          latitude,
          longitude,
          d.latitude!,
          d.longitude!,
        );
        return d.copyWith(distance: '${distance.toStringAsFixed(1)} km');
      }
      return d;
    }).toList();

    // Sort by distance string (simplified sorting)
    withDistance.sort((a, b) {
      final distA = double.tryParse(a.distance?.replaceAll(' km', '') ?? '999') ?? 999;
      final distB = double.tryParse(b.distance?.replaceAll(' km', '') ?? '999') ?? 999;
      return distA.compareTo(distB);
    });

    return withDistance.take(limit).toList();
  }

  @override
  Future<List<Destination>> search(String query) async {
    if (query.isEmpty) return [];
    
    final destinations = await getAll();
    final lowerQuery = query.toLowerCase();
    
    return destinations.where((d) {
      return d.title.toLowerCase().contains(lowerQuery) ||
          d.location.toLowerCase().contains(lowerQuery) ||
          d.description.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // ══════════════════════════════════════════════════════════════
  // PRIVATE METHODS
  // ══════════════════════════════════════════════════════════════

  Future<List<Destination>> _getFromLocal() async {
    // Return cached data if available
    if (_cachedDestinations != null) {
      return _cachedDestinations!;
    }

    _cachedDestinations = await _localDataSource.loadList<Destination>(
      AssetPaths.destinationData,
      (json) => Destination.fromJson(_addIdIfMissing(json)),
    );
    return _cachedDestinations!;
  }

  Future<List<Destination>> _getFromRemote() async {
    // Return cached data if available
    if (_cachedDestinations != null) {
      return _cachedDestinations!;
    }

    final token = await _getToken();
    final response = await _remoteDataSource.get<List<dynamic>>(
      ApiEndpoints.destinations,
      headers: _authHeaders(token),
    );

    return response.when(
      success: (data) {
        // Parse the list of destinations
        _cachedDestinations = data
            .map((item) => Destination.fromJson(item as Map<String, dynamic>))
            .toList();
        return _cachedDestinations!;
      },
      failure: (error) => throw Exception(error),
    );
  }

  /// Add ID to JSON if missing (for local JSON data)
  Map<String, dynamic> _addIdIfMissing(Map<String, dynamic> json) {
    if (!json.containsKey('id')) {
      json['id'] = json.hashCode;
    }
    return json;
  }

  /// Calculate rough distance between two coordinates
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    // Simplified distance calculation (Haversine approximation)
    const double earthRadius = 6371; // km
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    
    final a = _sin(dLat / 2) * _sin(dLat / 2) +
        _cos(_toRadians(lat1)) * _cos(_toRadians(lat2)) *
        _sin(dLon / 2) * _sin(dLon / 2);
    
    final c = 2 * _atan2(_sqrt(a), _sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degree) => degree * 3.14159265359 / 180;
  double _sin(double x) => _taylorSin(x);
  double _cos(double x) => _taylorCos(x);
  double _sqrt(double x) => _babylonianSqrt(x);
  double _atan2(double y, double x) => _simpleAtan2(y, x);

  // Simple implementations to avoid dart:math dependency issues
  double _taylorSin(double x) {
    x = x % (2 * 3.14159265359);
    double result = x;
    double term = x;
    for (int i = 1; i <= 10; i++) {
      term *= -x * x / ((2 * i) * (2 * i + 1));
      result += term;
    }
    return result;
  }

  double _taylorCos(double x) {
    x = x % (2 * 3.14159265359);
    double result = 1;
    double term = 1;
    for (int i = 1; i <= 10; i++) {
      term *= -x * x / ((2 * i - 1) * (2 * i));
      result += term;
    }
    return result;
  }

  double _babylonianSqrt(double x) {
    if (x <= 0) return 0;
    double guess = x / 2;
    for (int i = 0; i < 20; i++) {
      guess = (guess + x / guess) / 2;
    }
    return guess;
  }

  double _simpleAtan2(double y, double x) {
    if (x > 0) return _atan(y / x);
    if (x < 0 && y >= 0) return _atan(y / x) + 3.14159265359;
    if (x < 0 && y < 0) return _atan(y / x) - 3.14159265359;
    if (y > 0) return 3.14159265359 / 2;
    if (y < 0) return -3.14159265359 / 2;
    return 0;
  }

  double _atan(double x) {
    // Taylor series for arctan
    if (x.abs() > 1) {
      return (x > 0 ? 1 : -1) * (3.14159265359 / 2 - _atan(1 / x));
    }
    double result = 0;
    double term = x;
    for (int i = 0; i < 50; i++) {
      result += term / (2 * i + 1);
      term *= -x * x;
    }
    return result;
  }

  /// Clear cache (useful when data is updated)
  void clearCache() {
    _cachedDestinations = null;
  }
}
