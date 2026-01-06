import '../models/models.dart';

/// Abstract repository interface for guides
abstract class GuideRepository {
  /// Get all guides
  Future<List<Guide>> getAll();

  /// Get guide by ID
  Future<Guide?> getById(int id);

  /// Get featured/verified guides
  Future<List<Guide>> getFeatured({int limit = 10});

  /// Get guides by location
  Future<List<Guide>> getByLocation(String location);

  /// Search guides by keyword
  Future<List<Guide>> search(String query);

  /// Filter guides by criteria
  Future<List<Guide>> filter({
    String? gender,
    List<String>? languages,
    List<String>? interests,
    bool? verifiedOnly,
  });
}
