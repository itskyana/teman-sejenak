import 'package:flutter/foundation.dart';
import '../../data/models/models.dart';
import '../../data/repositories/repositories.dart';
import 'view_state.dart';

/// Provider for Order data and state management
class OrderProvider extends ChangeNotifier {
  final OrderRepository _repository;

  OrderProvider({OrderRepository? repository})
      : _repository = repository ?? OrderRepositoryImpl();

  // State
  ViewState _state = ViewState.initial;
  String? _errorMessage;

  // Data
  List<Order> _orders = [];
  List<Order> _activeOrders = [];
  List<Order> _orderHistory = [];
  Order? _currentOrder;

  // Getters
  ViewState get state => _state;
  String? get errorMessage => _errorMessage;
  List<Order> get orders => _orders;
  List<Order> get activeOrders => _activeOrders;
  List<Order> get orderHistory => _orderHistory;
  Order? get currentOrder => _currentOrder;

  bool get isLoading => _state == ViewState.loading;
  bool get hasError => _state == ViewState.error;
  bool get hasData => _orders.isNotEmpty;
  bool get hasActiveOrders => _activeOrders.isNotEmpty;

  // ══════════════════════════════════════════════════════════════
  // ACTIONS
  // ══════════════════════════════════════════════════════════════

  /// Load all orders
  Future<void> loadOrders() async {
    _setState(ViewState.loading);

    try {
      _orders = await _repository.getAll();
      await _refreshLists();
      _setState(ViewState.loaded);
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Load active orders
  Future<void> loadActiveOrders() async {
    try {
      _activeOrders = await _repository.getActive();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading active orders: $e');
    }
  }

  /// Load order history
  Future<void> loadHistory() async {
    try {
      _orderHistory = await _repository.getHistory();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading history: $e');
    }
  }

  /// Create a new order
  Future<Order?> createOrder({
    required String guideId,
    required String destinationId,
    required ServiceType serviceType,
    required int hours,
    required DateTime scheduledAt,
  }) async {
    _setState(ViewState.loading);

    try {
      final order = await _repository.create(
        guideId: guideId,
        destinationId: destinationId,
        serviceType: serviceType,
        hours: hours,
        scheduledAt: scheduledAt,
      );
      
      _currentOrder = order;
      await loadOrders(); // Refresh all orders
      return order;
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  /// Cancel an order
  Future<bool> cancelOrder(String orderId) async {
    try {
      final success = await _repository.cancel(orderId);
      if (success) {
        await _refreshLists();
        notifyListeners();
      }
      return success;
    } catch (e) {
      debugPrint('Error canceling order: $e');
      return false;
    }
  }

  /// Update order status
  Future<bool> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      final updated = await _repository.updateStatus(orderId, status);
      if (updated != null) {
        await _refreshLists();
        if (_currentOrder?.id == orderId) {
          _currentOrder = updated;
        }
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating order status: $e');
      return false;
    }
  }

  /// Set current order (for tracking)
  void setCurrentOrder(Order order) {
    _currentOrder = order;
    notifyListeners();
  }

  /// Clear current order
  void clearCurrentOrder() {
    _currentOrder = null;
    notifyListeners();
  }

  /// Get order by ID
  Future<Order?> getById(String id) async {
    return _repository.getById(id);
  }

  // ══════════════════════════════════════════════════════════════
  // PRIVATE HELPERS
  // ══════════════════════════════════════════════════════════════

  Future<void> _refreshLists() async {
    _activeOrders = _orders.where((o) => o.status.isActive).toList();
    _orderHistory = _orders.where((o) => o.status.isFinished).toList();
  }

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
