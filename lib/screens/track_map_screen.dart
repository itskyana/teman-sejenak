import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import '../models/order.dart';
import '../utils/app_colors.dart'; // pastikan ini diimport

class TrackMapScreen extends StatefulWidget {
  final OrderService order;
  const TrackMapScreen({super.key, required this.order});

  @override
  State<TrackMapScreen> createState() => _TrackMapScreenState();
}

class _TrackMapScreenState extends State<TrackMapScreen> {
  final _mapCtl = MapController();
  final _markers = <Marker>[];
  Polyline? _route;
  Position? _me;

  bool _mapReady = false;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    await Geolocator.requestPermission();
    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final user = LatLng(pos.latitude, pos.longitude);
    final guide = LatLng(widget.order.guideLat, widget.order.guideLng);

    setState(() {
      _me = pos;
      _markers
        ..add(
          Marker(
            point: user,
            width: 36,
            height: 36,
            child: const Icon(Icons.my_location, color: AppColors.primary, size: 36),
          ),
        )
        ..add(
          Marker(
            point: guide,
            width: 36,
            height: 36,
            child: const Icon(
              Icons.person_pin_circle,
              color: AppColors.danger,
              size: 36,
            ),
          ),
        );

      _route = Polyline(
        points: [user, guide],
        color: AppColors.primary,
        strokeWidth: 4,
      );
    });

    _fitBounds();
  }

  void _fitBounds() {
    if (_me == null || !_mapReady) return;

    final user = LatLng(_me!.latitude, _me!.longitude);
    final guide = LatLng(widget.order.guideLat, widget.order.guideLng);

    _mapCtl.fitBounds(
      LatLngBounds.fromPoints([user, guide]),
      options: const FitBoundsOptions(
        padding: EdgeInsets.symmetric(horizontal: 80, vertical: 80),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.gray100,
    appBar: AppBar(
      title: const Text('Jarak antara kita'),
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textDark, // buat warna teks di AppBar
      elevation: 0,
    ),
    body: Stack(
      children: [
        SizedBox.expand(
          child: FlutterMap(
            mapController: _mapCtl,
            options: MapOptions(
              initialCenter: const LatLng(-6.4025, 106.7942),
              initialZoom: 13,
              onMapReady: () {
                setState(() => _mapReady = true);
                _fitBounds();
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              if (_route != null) PolylineLayer(polylines: [_route!]),
              if (_markers.isNotEmpty) MarkerLayer(markers: _markers),
            ],
          ),
        ),
        if (_me != null)
          Positioned(
            left: 16,
            right: 16,
            bottom: 24 + MediaQuery.of(context).padding.bottom,
            child: _InfoCard(
              distanceKm: _distanceKm(
                _me!.latitude,
                _me!.longitude,
                widget.order.guideLat,
                widget.order.guideLng,
              ),
            ),
          ),
      ],
    ),
  );

  double _distanceKm(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371;
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRad(lat1)) *
            math.cos(_toRad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  double _toRad(double deg) => deg * (math.pi / 180);
}

class _InfoCard extends StatelessWidget {
  final double distanceKm;
  const _InfoCard({required this.distanceKm});

  @override
  Widget build(BuildContext context) {
    final etaMin = (distanceKm / 5 * 60).round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(.06),
              blurRadius: 8,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(children: [
        const Icon(Icons.pin_drop, color: AppColors.primary),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${distanceKm.toStringAsFixed(2)} km',
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 2),
          Text('≈ $etaMin menit berjalan',
              style: TextStyle(fontSize: 12, color: AppColors.gray600)),
        ]),
        const Spacer(),
        SizedBox(
          width: 140,
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.directions_walk_rounded, size: 18),
            label: const Text('Navigasi',
                style: TextStyle(fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.background,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ]),
    );
  }
}
