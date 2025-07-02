import 'package:flutter/material.dart';
import 'package:flutter_ins/screens/root_navigator.dart';
import 'package:flutter_ins/utils/app_colors.dart';
import '../models/guide.dart';
import '../models/destination.dart';

class OrderScreen extends StatefulWidget {
  final Destination place;
  final Guide guide;
  const OrderScreen({super.key, required this.place, required this.guide});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  int _service = 0; // 0=Chat, 1=Meet+Chat
  int _hours   = 1;

  static const int _chatRate = 50000;
  static const int _meetRate = 350000;

  int get _pricePerHour => _service == 0 ? _chatRate : _meetRate;
  int get _total        => _pricePerHour * _hours;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.primary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── CARD ─────────────────────────────────────────────
          Container(
            decoration: _cardBox,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _hero(),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _titleRow(),
                      const SizedBox(height: 4),
                      _locationRow(),
                      const SizedBox(height: 24),
                      _serviceChooser(),
                      const SizedBox(height: 24),
                      _durationChooser(),
                      const SizedBox(height: 24),
                      const Text('Details',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15)),
                      const SizedBox(height: 6),
                      Text(widget.place.description,
                          style: const TextStyle(fontSize: 13, height: 1.4)),
                    ],
                  ),
                ),
                Divider(color: AppColors.gray700, height: 1),
                _totalBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── SUB WIDGETS ────────────────────────────────────────────
  Widget _hero() => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: [
            Image.network(widget.place.imageUrl,
                width: double.infinity, height: 220, fit: BoxFit.cover),
            Positioned(
              left: 16,
              bottom: 16,
              child: Row(
                children: [
                  CircleAvatar(
                      radius: 22,
                      backgroundImage: NetworkImage(widget.guide.imageUrl)),
                  const SizedBox(width: 8),
                  Text(widget.guide.name,
                      style: const TextStyle(
                          color: AppColors.secondaryDark, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _titleRow() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(widget.place.title,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 20)),
          ),
          Text(
            'Rp ${_pricePerHour.toString().replaceAllMapped(RegExp(r'(\d{3})(?=\d)'), (m) => '${m[1]}.')} /h',
            style:
                const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ],
      );

  Widget _locationRow() => Row(
        children: [
          const Icon(Icons.location_on_outlined, size: 14, color: AppColors.gray700),
          const SizedBox(width: 4),
          Flexible(
            child: Text(widget.place.location,
                style: const TextStyle(fontSize: 12, color: AppColors.gray700)),
          ),
          if (widget.place.distance != null) ...[
            const SizedBox(width: 6),
            Text('• ${widget.place.distance}',
                style: const TextStyle(fontSize: 12, color: AppColors.gray700)),
          ],
        ],
      );

  Widget _serviceChooser() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Service',
              style:
                  TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 8),
          Row(
            children: [
              _serviceChip(0, 'Chat'),
              const SizedBox(width: 12),
              _serviceChip(1, 'Meet + Chat'),
            ],
          ),
        ],
      );

  Widget _durationChooser() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Duration (hours)',
              style:
                  TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            children: List.generate(6, (i) => _hourChip(i + 1)).toList(),
          ),
        ],
      );

  Widget _totalBar() => Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total',
                    style: TextStyle(fontSize: 12, color: AppColors.gray700)),
                const SizedBox(height: 2),
                Text(
                  'Rp ${_total.toString().replaceAllMapped(RegExp(r'(\d{3})(?=\d)'), (m) => '${m[1]}.')}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 18),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: 160, // lebar tetap → tak pakai Expanded
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.background,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 14),
                ),
                onPressed: _payNow,
                child: const Text('Choose Payment',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      );

  // ── CHIPS ──────────────────────────────────────────────────
  Widget _serviceChip(int v, String label) => ChoiceChip(
        selected: _service == v,
        onSelected: (_) => setState(() => _service = v),
        label: Text(label,
            style: TextStyle(
                color: _service == v ? AppColors.background : AppColors.primary)),
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.gray100,
      );

  Widget _hourChip(int h) => ChoiceChip(
        selected: _hours == h,
        onSelected: (_) => setState(() => _hours = h),
        label: Text('$h',
            style: TextStyle(color: _hours == h ? AppColors.background : AppColors.primary)),
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.gray100,
      );

  // ── PAYMENT SHEET (dummy) ─────────────────────────────────
  void _payNow() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.gray300,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          const Text('Choose payment method',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 20),
          ListTile(
            leading:
                const Icon(Icons.credit_card, color: AppColors.primary, size: 28),
            title: const Text('Credit / Debit Card'),
            onTap: _paid,
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet_rounded,
                color: AppColors.primary, size: 28),
            title: const Text('E-Wallet'),
            onTap: _paid,
          ),
        ]),
      ),
    );
  }

  void _paid() {
    // 1. tutup modal-sheet “Pay”
    Navigator.pop(context);

    // 2. tampilkan snackbar konfirmasi (opsional)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Thank you! Order successfully placed.')),
    );

    // 3. lompat ke tab “History / Orders” (index 2) di RootNavigation
    //    dan bersihkan semua halaman di atas root agar bottom-bar tidak rangkap
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const RootNavigation(initialIndex: 2),
      ),
      (route) => false,
    );
  }
  // ── DECORATION ─────────────────────────────────────────────
  BoxDecoration get _cardBox => BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: AppColors.gray300.withOpacity(.05),
              blurRadius: 8,
              offset: const Offset(0, 4)),
        ],
      );
}
