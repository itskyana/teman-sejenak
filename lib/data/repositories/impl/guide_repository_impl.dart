import 'package:shared_preferences/shared_preferences.dart';
import '../../models/models.dart';
import '../../datasources/datasources.dart';
import '../../../core/constants/asset_paths.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/app_constants.dart';
import '../guide_repository.dart';

/// Implementation of GuideRepository
/// 
/// This implementation supports both local JSON and remote API.
/// Set [useRemote] to false to switch to local JSON mode.
class GuideRepositoryImpl implements GuideRepository {
  final LocalDataSource _localDataSource;
  final RemoteDataSource _remoteDataSource;
  final bool useRemote;

  // Cache for local data
  List<Guide>? _cachedGuides;
  SharedPreferences? _prefs;

  GuideRepositoryImpl({
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
  Future<List<Guide>> getAll() async {
    if (useRemote) {
      return _getFromRemote();
    }
    return _getFromLocal();
  }

  @override
  Future<Guide?> getById(int id) async {
    final guides = await getAll();
    try {
      return guides.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Guide>> getFeatured({int limit = 10}) async {
    final guides = await getAll();
    
    // Get verified guides sorted by rating
    final featured = guides.where((g) => g.verified).toList()
      ..sort((a, b) => b.rating.compareTo(a.rating));
    
    return featured.take(limit).toList();
  }

  @override
  Future<List<Guide>> getByLocation(String location) async {
    if (location.isEmpty) return [];
    
    final guides = await getAll();
    final lowerLocation = location.toLowerCase();
    
    return guides.where((g) {
      return g.location.toLowerCase().contains(lowerLocation);
    }).toList();
  }

  @override
  Future<List<Guide>> search(String query) async {
    if (query.isEmpty) return [];
    
    final guides = await getAll();
    final lowerQuery = query.toLowerCase();
    
    return guides.where((g) {
      return g.name.toLowerCase().contains(lowerQuery) ||
          g.location.toLowerCase().contains(lowerQuery) ||
          g.interests.any((i) => i.toLowerCase().contains(lowerQuery)) ||
          g.languages.any((l) => l.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  @override
  Future<List<Guide>> filter({
    String? gender,
    List<String>? languages,
    List<String>? interests,
    bool? verifiedOnly,
  }) async {
    var guides = await getAll();

    if (gender != null && gender.isNotEmpty) {
      guides = guides.where((g) => 
        g.gender.toLowerCase() == gender.toLowerCase()
      ).toList();
    }

    if (languages != null && languages.isNotEmpty) {
      guides = guides.where((g) =>
        g.languages.any((l) => languages.contains(l))
      ).toList();
    }

    if (interests != null && interests.isNotEmpty) {
      guides = guides.where((g) =>
        g.interests.any((i) => interests.contains(i))
      ).toList();
    }

    if (verifiedOnly == true) {
      guides = guides.where((g) => g.verified).toList();
    }

    return guides;
  }

  // ══════════════════════════════════════════════════════════════
  // PRIVATE METHODS
  // ══════════════════════════════════════════════════════════════

  Future<List<Guide>> _getFromLocal() async {
    // Return cached data if available
    if (_cachedGuides != null) {
      return _cachedGuides!;
    }

    _cachedGuides = await _localDataSource.loadList<Guide>(
      AssetPaths.guideData,
      (json) => Guide.fromJson(_addIdIfMissing(json)),
    );
    return _cachedGuides!;
  }

  Future<List<Guide>> _getFromRemote() async {
    final token = await _getToken();
    final response = await _remoteDataSource.get<List<Guide>>(
      ApiEndpoints.guides,
      headers: _authHeaders(token),
      fromJsonList: (list) => list
          .map((item) => Guide.fromJson(item as Map<String, dynamic>))
          .toList(),
    );

    return response.when(
      success: (data) => data,
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

  /// Clear cache (useful when data is updated)
  void clearCache() {
    _cachedGuides = null;
  }
}
