import 'package:flutter/foundation.dart';
import '../../data/models/models.dart';
import '../../data/repositories/repositories.dart';
import 'view_state.dart';

/// Provider for Destination data and state management
class DestinationProvider extends ChangeNotifier {
  final DestinationRepository _repository;

  DestinationProvider({DestinationRepository? repository})
      : _repository = repository ?? DestinationRepositoryImpl();

  // State
  ViewState _state = ViewState.initial;
  String? _errorMessage;
  
  // Data
  List<Destination> _destinations = [];
  List<Destination> _popularDestinations = [];
  List<Destination> _nearbyDestinations = [];
  List<Destination> _searchResults = [];
  Destination? _selectedDestination;

  // Getters
  ViewState get state => _state;
  String? get errorMessage => _errorMessage;
  List<Destination> get destinations => _destinations;
  List<Destination> get popularDestinations => _popularDestinations;
  List<Destination> get nearbyDestinations => _nearbyDestinations;
  List<Destination> get searchResults => _searchResults;
  Destination? get selectedDestination => _selectedDestination;

  bool get isLoading => _state == ViewState.loading;
  bool get hasError => _state == ViewState.error;
  bool get hasData => _destinations.isNotEmpty;

  // ══════════════════════════════════════════════════════════════
  // ACTIONS
  // ══════════════════════════════════════════════════════════════

  /// Load all destinations
  Future<void> loadDestinations() async {
    _setState(ViewState.loading);

    try {
      _destinations = await _repository.getAll();
      _setState(ViewState.loaded);
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Load popular destinations
  Future<void> loadPopular({int limit = 10}) async {
    try {
      _popularDestinations = await _repository.getPopular(limit: limit);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading popular: $e');
    }
  }

  /// Load nearby destinations
  Future<void> loadNearby({
    required double latitude,
    required double longitude,
    int limit = 10,
  }) async {
    try {
      _nearbyDestinations = await _repository.getNearby(
        latitude: latitude,
        longitude: longitude,
        limit: limit,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading nearby: $e');
    }
  }

  /// Search destinations
  Future<void> search(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    try {
      _searchResults = await _repository.search(query);
      notifyListeners();
    } catch (e) {
      debugPrint('Error searching: $e');
    }
  }

  /// Select a destination
  void selectDestination(Destination destination) {
    _selectedDestination = destination;
    notifyListeners();
  }

  /// Clear selection
  void clearSelection() {
    _selectedDestination = null;
    notifyListeners();
  }

  /// Get destination by ID
  Future<Destination?> getById(int id) async {
    return _repository.getById(id);
  }

  // ══════════════════════════════════════════════════════════════
  // PRIVATE HELPERS
  // ══════════════════════════════════════════════════════════════

  void _setState(ViewState state) {
    _state = state;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _state = ViewState.error;
    _errorMessage = message;
    notifyListeners();
  }
}
