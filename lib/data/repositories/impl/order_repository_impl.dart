import 'package:shared_preferences/shared_preferences.dart';
import '../../models/models.dart';
import '../../datasources/datasources.dart';
import '../../../core/constants/asset_paths.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/app_constants.dart';
import '../order_repository.dart';

/// Implementation of OrderRepository
/// 
/// This implementation supports both local JSON and remote API.
/// Set [useRemote] to true to switch to API mode.
class OrderRepositoryImpl implements OrderRepository {
  final LocalDataSource _localDataSource;
  final RemoteDataSource _remoteDataSource;
  final bool useRemote;

  // Cache for local data (simulates local state)
  List<Order>? _cachedOrders;
  SharedPreferences? _prefs;

  OrderRepositoryImpl({
    LocalDataSource? localDataSource,
    RemoteDataSource? remoteDataSource,
    this.useRemote = false, // Default to local JSON
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
  Future<List<Order>> getAll() async {
    if (useRemote) {
      return _getFromRemote();
    }
    return _getFromLocal();
  }

  @override
  Future<Order?> getById(String id) async {
    final orders = await getAll();
    try {
      return orders.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Order>> getActive() async {
    final orders = await getAll();
    return orders.where((o) => o.status.isActive).toList();
  }

  @override
  Future<List<Order>> getHistory() async {
    final orders = await getAll();
    return orders.where((o) => o.status.isFinished).toList();
  }

  @override
  Future<Order> create({
    required String guideId,
    required String destinationId,
    required ServiceType serviceType,
    required int hours,
    required DateTime scheduledAt,
  }) async {
    if (useRemote) {
      return _createRemote(
        guideId: guideId,
        destinationId: destinationId,
        serviceType: serviceType,
        hours: hours,
        scheduledAt: scheduledAt,
      );
    }

    // Local simulation - create a new order
    final pricePerHour = serviceType == ServiceType.chat ? 50000 : 350000;
    final newOrder = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      guideName: 'Guide $guideId', // Would be fetched from guide data
      guideImageUrl: '',
      placeName: 'Destination $destinationId',
      placeImageUrl: '',
      serviceType: serviceType,
      hours: hours,
      price: pricePerHour * hours,
      etaMinutes: 15,
      status: OrderStatus.pending,
      createdAt: DateTime.now(),
      scheduledAt: scheduledAt,
    );

    // Add to local cache
    _cachedOrders ??= [];
    _cachedOrders!.add(newOrder);

    return newOrder;
  }

  @override
  Future<bool> cancel(String orderId) async {
    if (useRemote) {
      return _cancelRemote(orderId);
    }

    // Local simulation
    final orders = await getAll();
    final index = orders.indexWhere((o) => o.id == orderId);
    
    if (index != -1 && orders[index].canCancel) {
      _cachedOrders![index] = orders[index].copyWith(
        status: OrderStatus.canceled,
      );
      return true;
    }
    return false;
  }

  @override
  Future<Order?> updateStatus(String orderId, OrderStatus status) async {
    if (useRemote) {
      return _updateStatusRemote(orderId, status);
    }

    // Local simulation
    final orders = await getAll();
    final index = orders.indexWhere((o) => o.id == orderId);
    
    if (index != -1) {
      final updated = orders[index].copyWith(status: status);
      _cachedOrders![index] = updated;
      return updated;
    }
    return null;
  }

  // ══════════════════════════════════════════════════════════════
  // PRIVATE METHODS
  // ══════════════════════════════════════════════════════════════

  Future<List<Order>> _getFromLocal() async {
    // Return cached data if available
    if (_cachedOrders != null) {
      return _cachedOrders!;
    }

    _cachedOrders = await _localDataSource.loadList<Order>(
      AssetPaths.orderData,
      Order.fromJson,
    );
    return _cachedOrders!;
  }

  Future<List<Order>> _getFromRemote() async {
    final token = await _getToken();
    final response = await _remoteDataSource.get<List<Order>>(
      ApiEndpoints.orders,
      headers: _authHeaders(token),
      fromJsonList: (list) => list
          .map((item) => Order.fromJson(item as Map<String, dynamic>))
          .toList(),
    );

    return response.when(
      success: (data) => data,
      failure: (error) => throw Exception(error),
    );
  }

  Future<Order> _createRemote({
    required String guideId,
    required String destinationId,
    required ServiceType serviceType,
    required int hours,
    required DateTime scheduledAt,
  }) async {
    final token = await _getToken();
    final response = await _remoteDataSource.post<Order>(
      ApiEndpoints.createOrder,
      headers: _authHeaders(token),
      body: {
        'guide_id': guideId,
        'destination_id': destinationId,
        'service_type': serviceType.name,
        'hours': hours,
        'scheduled_at': scheduledAt.toIso8601String(),
      },
      fromJson: Order.fromJson,
    );

    return response.when(
      success: (data) => data,
      failure: (error) => throw Exception(error),
    );
  }

  Future<bool> _cancelRemote(String orderId) async {
    final token = await _getToken();
    final response = await _remoteDataSource.post<Map<String, dynamic>>(
      '${ApiEndpoints.cancelOrder}/$orderId',
      headers: _authHeaders(token),
    );

    return response.isSuccess;
  }

  Future<Order?> _updateStatusRemote(String orderId, OrderStatus status) async {
    final token = await _getToken();
    final response = await _remoteDataSource.put<Order>(
      '${ApiEndpoints.orderDetail}/$orderId',
      headers: _authHeaders(token),
      body: {'status': status.name},
      fromJson: Order.fromJson,
    );

    return response.when(
      success: (data) => data,
      failure: (error) => null,
    );
  }

  /// Clear cache (useful when data is updated)
  void clearCache() {
    _cachedOrders = null;
  }
}
