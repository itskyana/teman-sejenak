import 'package:flutter/foundation.dart';
import '../../data/models/models.dart';
import '../../data/repositories/repositories.dart';
import 'view_state.dart';

/// Provider for Guide data and state management
class GuideProvider extends ChangeNotifier {
  final GuideRepository _repository;

  GuideProvider({GuideRepository? repository})
      : _repository = repository ?? GuideRepositoryImpl();

  // State
  ViewState _state = ViewState.initial;
  String? _errorMessage;

  // Data
  List<Guide> _guides = [];
  List<Guide> _featuredGuides = [];
  List<Guide> _searchResults = [];
  List<Guide> _filteredGuides = [];
  Guide? _selectedGuide;

  // Filter state
  String? _selectedGender;
  List<String> _selectedLanguages = [];
  List<String> _selectedInterests = [];
  bool _verifiedOnly = false;

  // Getters
  ViewState get state => _state;
  String? get errorMessage => _errorMessage;
  List<Guide> get guides => _guides;
  List<Guide> get featuredGuides => _featuredGuides;
  List<Guide> get searchResults => _searchResults;
  List<Guide> get filteredGuides => _filteredGuides;
  Guide? get selectedGuide => _selectedGuide;

  String? get selectedGender => _selectedGender;
  List<String> get selectedLanguages => _selectedLanguages;
  List<String> get selectedInterests => _selectedInterests;
  bool get verifiedOnly => _verifiedOnly;

  bool get isLoading => _state == ViewState.loading;
  bool get hasError => _state == ViewState.error;
  bool get hasData => _guides.isNotEmpty;
  bool get hasActiveFilters =>
      _selectedGender != null ||
      _selectedLanguages.isNotEmpty ||
      _selectedInterests.isNotEmpty ||
      _verifiedOnly;

  // ══════════════════════════════════════════════════════════════
  // ACTIONS
  // ══════════════════════════════════════════════════════════════

  /// Load all guides
  Future<void> loadGuides() async {
    _setState(ViewState.loading);

    try {
      _guides = await _repository.getAll();
      _setState(ViewState.loaded);
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Load featured guides
  Future<void> loadFeatured({int limit = 10}) async {
    try {
      _featuredGuides = await _repository.getFeatured(limit: limit);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading featured: $e');
    }
  }

  /// Search guides
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

  /// Apply filters
  Future<void> applyFilters() async {
    try {
      _filteredGuides = await _repository.filter(
        gender: _selectedGender,
        languages: _selectedLanguages.isEmpty ? null : _selectedLanguages,
        interests: _selectedInterests.isEmpty ? null : _selectedInterests,
        verifiedOnly: _verifiedOnly ? true : null,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error filtering: $e');
    }
  }

  /// Set gender filter
  void setGenderFilter(String? gender) {
    _selectedGender = gender;
    applyFilters();
  }

  /// Toggle language filter
  void toggleLanguageFilter(String language) {
    if (_selectedLanguages.contains(language)) {
      _selectedLanguages.remove(language);
    } else {
      _selectedLanguages.add(language);
    }
    applyFilters();
  }

  /// Toggle interest filter
  void toggleInterestFilter(String interest) {
    if (_selectedInterests.contains(interest)) {
      _selectedInterests.remove(interest);
    } else {
      _selectedInterests.add(interest);
    }
    applyFilters();
  }

  /// Set verified only filter
  void setVerifiedOnlyFilter(bool value) {
    _verifiedOnly = value;
    applyFilters();
  }

  /// Clear all filters
  void clearFilters() {
    _selectedGender = null;
    _selectedLanguages = [];
    _selectedInterests = [];
    _verifiedOnly = false;
    _filteredGuides = [];
    notifyListeners();
  }

  /// Select a guide
  void selectGuide(Guide guide) {
    _selectedGuide = guide;
    notifyListeners();
  }

  /// Clear selection
  void clearSelection() {
    _selectedGuide = null;
    notifyListeners();
  }

  /// Get guide by ID
  Future<Guide?> getById(int id) async {
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
