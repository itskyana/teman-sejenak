enum OrderStatus { pending, approved, canceled, completed }
enum ServiceType { chat, meet }

OrderStatus _statusFrom(String s) =>
    OrderStatus.values.firstWhere((e) => e.name == s);
ServiceType _serviceFrom(String s) =>
    ServiceType.values.firstWhere((e) => e.name == s);

class OrderService {
  final double guideLat;
  final double guideLng;

  OrderService({
    required this.id,
    required this.guideName,
    required this.guideImg,
    required this.place,
    required this.placeImg,
    required this.service,
    required this.hours,
    required this.price,
    required this.etaMinutes,
    required this.status,
    required this.guideLat,
    required this.guideLng,
  });

  final String id;
  final String guideName;
  final String guideImg;
  final String place;
  final String placeImg;
  final ServiceType service;
  final int hours;
  final int price;
  final int etaMinutes;
  OrderStatus status;

  Duration get eta => Duration(minutes: etaMinutes);

  factory OrderService.fromJson(Map<String, dynamic> j) => OrderService(
        id: j['id'],
        guideName: j['guideName'],
        guideImg: j['guideImg'],
        place: j['place'],
        placeImg: j['placeImg'],
        service: _serviceFrom(j['service']),
        hours: j['hours'],
        price: j['price'],
        etaMinutes: j['etaMinutes'],
        status: _statusFrom(j['status']),
        guideLat: (j['guideLat'] as num).toDouble(),
        guideLng: (j['guideLng'] as num).toDouble(),
      );
}
