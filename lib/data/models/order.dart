import 'base_model.dart';

/// Order status enum
enum OrderStatus {
  pending,
  approved,
  inProgress,
  completed,
  canceled;

  /// Create from string
  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => OrderStatus.pending,
    );
  }

  /// Display text in Indonesian
  String get displayText {
    switch (this) {
      case OrderStatus.pending:
        return 'Menunggu';
      case OrderStatus.approved:
        return 'Disetujui';
      case OrderStatus.inProgress:
        return 'Berlangsung';
      case OrderStatus.completed:
        return 'Selesai';
      case OrderStatus.canceled:
        return 'Dibatalkan';
    }
  }

  /// Check if order is active (can be tracked)
  bool get isActive => this == pending || this == approved || this == inProgress;

  /// Check if order is finished
  bool get isFinished => this == completed || this == canceled;
}

/// Service type enum
enum ServiceType {
  chat,
  meet;

  /// Create from string
  static ServiceType fromString(String value) {
    return ServiceType.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => ServiceType.chat,
    );
  }

  /// Display text
  String get displayText {
    switch (this) {
      case ServiceType.chat:
        return 'Chat Only';
      case ServiceType.meet:
        return 'Meet + Chat';
    }
  }
}

/// Order model - represents a service order
class Order extends BaseModel {
  final String id;
  final String guideName;
  final String guideImageUrl;
  final String placeName;
  final String placeImageUrl;
  final ServiceType serviceType;
  final int hours;
  final int price;
  final int etaMinutes;
  final OrderStatus status;
  final double? guideLat;
  final double? guideLng;
  final DateTime? createdAt;
  final DateTime? scheduledAt;

  Order({
    required this.id,
    required this.guideName,
    required this.guideImageUrl,
    required this.placeName,
    required this.placeImageUrl,
    required this.serviceType,
    required this.hours,
    required this.price,
    required this.etaMinutes,
    required this.status,
    this.guideLat,
    this.guideLng,
    this.createdAt,
    this.scheduledAt,
  });

  /// Create from JSON (supports both API and local JSON format)
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id']?.toString() ?? '',
      guideName: json['guide_name'] ?? json['guideName'] ?? '',
      guideImageUrl: json['guide_image_url'] ?? json['guideImg'] ?? '',
      placeName: json['place_name'] ?? json['place'] ?? '',
      placeImageUrl: json['place_image_url'] ?? json['placeImg'] ?? '',
      serviceType: ServiceType.fromString(json['service_type'] ?? json['service'] ?? 'chat'),
      hours: _parseInt(json['hours']),
      price: _parseInt(json['price']),
      etaMinutes: _parseInt(json['eta_minutes'] ?? json['etaMinutes']),
      status: OrderStatus.fromString(json['status'] ?? 'pending'),
      guideLat: _parseDouble(json['guide_lat'] ?? json['guideLat']),
      guideLng: _parseDouble(json['guide_lng'] ?? json['guideLng']),
      createdAt: _parseDateTime(json['created_at'] ?? json['createdAt']),
      scheduledAt: _parseDateTime(json['scheduled_at'] ?? json['scheduledAt']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'guide_name': guideName,
        'guide_image_url': guideImageUrl,
        'place_name': placeName,
        'place_image_url': placeImageUrl,
        'service_type': serviceType.name,
        'hours': hours,
        'price': price,
        'eta_minutes': etaMinutes,
        'status': status.name,
        'guide_lat': guideLat,
        'guide_lng': guideLng,
        'created_at': createdAt?.toIso8601String(),
        'scheduled_at': scheduledAt?.toIso8601String(),
      };

  /// Create a copy with optional new values
  Order copyWith({
    String? id,
    String? guideName,
    String? guideImageUrl,
    String? placeName,
    String? placeImageUrl,
    ServiceType? serviceType,
    int? hours,
    int? price,
    int? etaMinutes,
    OrderStatus? status,
    double? guideLat,
    double? guideLng,
    DateTime? createdAt,
    DateTime? scheduledAt,
  }) {
    return Order(
      id: id ?? this.id,
      guideName: guideName ?? this.guideName,
      guideImageUrl: guideImageUrl ?? this.guideImageUrl,
      placeName: placeName ?? this.placeName,
      placeImageUrl: placeImageUrl ?? this.placeImageUrl,
      serviceType: serviceType ?? this.serviceType,
      hours: hours ?? this.hours,
      price: price ?? this.price,
      etaMinutes: etaMinutes ?? this.etaMinutes,
      status: status ?? this.status,
      guideLat: guideLat ?? this.guideLat,
      guideLng: guideLng ?? this.guideLng,
      createdAt: createdAt ?? this.createdAt,
      scheduledAt: scheduledAt ?? this.scheduledAt,
    );
  }

  /// Get ETA as Duration
  Duration get eta => Duration(minutes: etaMinutes);

  /// Format price as currency string
  String get formattedPrice {
    return 'Rp ${price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        )}';
  }

  /// Check if can be canceled
  bool get canCancel => status == OrderStatus.pending;

  /// Empty order for fallback
  static Order empty() => Order(
        id: '',
        guideName: '',
        guideImageUrl: '',
        placeName: '',
        placeImageUrl: '',
        serviceType: ServiceType.chat,
        hours: 0,
        price: 0,
        etaMinutes: 0,
        status: OrderStatus.pending,
      );

  bool get isEmpty => id.isEmpty;
  bool get isNotEmpty => !isEmpty;

  // ══════════════════════════════════════════════════════════════
  // PRIVATE HELPERS
  // ══════════════════════════════════════════════════════════════
  
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}
