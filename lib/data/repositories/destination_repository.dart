import '../models/models.dart';

/// Abstract repository interface for destinations
/// 
/// This defines the contract that any destination repository must implement.
/// By using an abstract class, we can easily swap implementations
/// (e.g., from local JSON to remote API) without changing the UI code.
abstract class DestinationRepository {
  /// Get all destinations
  Future<List<Destination>> getAll();

  /// Get destination by ID
  Future<Destination?> getById(int id);

  /// Get popular/trending destinations
  Future<List<Destination>> getPopular({int limit = 10});

  /// Get nearby destinations (based on location)
  Future<List<Destination>> getNearby({
    required double latitude,
    required double longitude,
    int limit = 10,
  });

  /// Search destinations by keyword
  Future<List<Destination>> search(String query);
}
