import 'package:flutter/material.dart';
import 'package:flutter_ins/screens/root_navigator.dart';
import 'package:flutter_ins/screens/track_map_screen.dart';
import 'package:flutter_ins/utils/app_colors.dart';
import '../models/order.dart';

class OrderDetailScreen extends StatelessWidget {
  final OrderService order;
  const OrderDetailScreen({super.key, required this.order});

  bool get _canTrack => order.status == OrderStatus.approved;
  bool get _canCancel => order.status == OrderStatus.pending;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.secondaryDark,
        title: const Text('Detail Pesanan Kamu'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Kartu utama ──────────────────────────────────────
          Container(
            decoration: _cardBox,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // hero foto destinasi
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Image.network(
                    order.placeImg,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Guide & ID
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundImage: NetworkImage(order.guideImg),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              order.guideName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          Text(
                            order.id,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.secondaryDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Detail info
                      _infoRow('Tempat', order.place),
                      _infoRow(
                        'Layanan',
                        order.service == ServiceType.chat
                            ? 'Chat'
                            : 'Meet + Chat',
                      ),
                      _infoRow('Durasi', '${order.hours} jam'),
                      _infoRow('Status', switch (order.status) {
                        OrderStatus.pending => 'Pending',
                        OrderStatus.approved => 'On going',
                        OrderStatus.canceled => 'Canceled',
                        OrderStatus.completed => 'Completed',
                      }),

                      const SizedBox(height: 16),

                      // Rincian Harga
                      const Text(
                        'Rincian Harga',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            'Rp ${_formatCurrency(order.price ~/ order.hours)} × ${order.hours} jam',
                          ),
                          const Spacer(),
                          Text(
                            'Rp ${_formatCurrency(order.price)}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Tombol aksi utama ────────────────────────────────
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    RootNavigation.openAt(context, 3);
                  },
                  style: _outlineBlue,
                  child: const Text(
                    'Chat Teman Sejenak',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed:
                      _canTrack
                          ? () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TrackMapScreen(order: order),
                            ),
                          )
                          : null,
                  style: _blueBtn.copyWith(
                    backgroundColor: MaterialStateProperty.all(
                      _canTrack ? AppColors.primary : Colors.grey.shade400,
                    ),
                  ),
                  child: const Text(
                    'Lihat jarak kami',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (_canCancel)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Batal Pesanan')),
                  );
                },
                style: _outlineGrey,
                child: const Text('Batalkan Pesanan'),
              ),
            ),
        ],
      ),
    );
  }

  // ── helpers ────────────────────────────────────────────────
  Widget _infoRow(String label, String val) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.gray700)),
        const Spacer(),
        Flexible(child: Text(val, style: const TextStyle(fontSize: 13))),
      ],
    ),
  );

  String _formatCurrency(int value) {
    final str = value.toString();
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return str.replaceAllMapped(reg, (m) => '${m[1]}.');
  }

  // ── button styles ──────────────────────────────────────────
  ButtonStyle get _blueBtn => ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.background,
    minimumSize: const Size(0, 48),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );

  ButtonStyle get _outlineBlue => OutlinedButton.styleFrom(
    foregroundColor: AppColors.primary,
    side: const BorderSide(color: AppColors.primary, width: 2),
    minimumSize: const Size(0, 48),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );

  ButtonStyle get _outlineGrey => OutlinedButton.styleFrom(
    foregroundColor: AppColors.gray700,
    side: BorderSide(color: AppColors.gray400),
    minimumSize: const Size(0, 48),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );

  // ── kartu dekorasi ─────────────────────────────────────────
  BoxDecoration get _cardBox => BoxDecoration(
    color: AppColors.background,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(.05),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  );
}
