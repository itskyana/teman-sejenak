import '../models/models.dart';

/// Abstract repository interface for orders
abstract class OrderRepository {
  /// Get all orders for current user
  Future<List<Order>> getAll();

  /// Get order by ID
  Future<Order?> getById(String id);

  /// Get active orders (pending, approved, in progress)
  Future<List<Order>> getActive();

  /// Get order history (completed, canceled)
  Future<List<Order>> getHistory();

  /// Create a new order
  Future<Order> create({
    required String guideId,
    required String destinationId,
    required ServiceType serviceType,
    required int hours,
    required DateTime scheduledAt,
  });

  /// Cancel an order
  Future<bool> cancel(String orderId);

  /// Update order status (for admin/guide)
  Future<Order?> updateStatus(String orderId, OrderStatus status);
}
