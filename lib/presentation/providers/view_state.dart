/// State for async operations used across providers
enum ViewState {
  /// Initial state, no action taken yet
  initial,
  
  /// Loading/fetching data
  loading,
  
  /// Data loaded successfully
  loaded,
  
  /// Error occurred
  error,
}

/// Extension methods for ViewState
extension ViewStateExtension on ViewState {
  bool get isInitial => this == ViewState.initial;
  bool get isLoading => this == ViewState.loading;
  bool get isLoaded => this == ViewState.loaded;
  bool get isError => this == ViewState.error;
}
