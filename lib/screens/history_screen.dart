import 'package:flutter/material.dart';
import 'package:flutter_ins/utils/app_colors.dart';
import '../models/order.dart';
import '../utils/json_loader.dart';
import 'order_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  List<OrderService> _orders = [];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _load();
  }

  Future<void> _load() async {
    final list = await JsonLoader.loadList<OrderService>(
      'order_data.json',
      OrderService.fromJson,
    );
    setState(() => _orders = list);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: _bar(),
        body: TabBarView(controller: _tab, children: [
          _list((o) =>
              o.status == OrderStatus.pending ||
              o.status == OrderStatus.approved),
          _list((o) =>
              o.status == OrderStatus.canceled ||
              o.status == OrderStatus.completed),
        ]),
      );

  PreferredSizeWidget _bar() => AppBar(
        title: const Text('Pemesanan Kamu'),
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.secondaryDark,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(46),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(30),
            ),
            child: TabBar(
              controller: _tab,
              labelColor: AppColors.background,
              unselectedLabelColor: AppColors.gray700,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: EdgeInsets.zero,
              indicator: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(30)),
              tabs: const [Tab(text: 'Dalam Proses'), Tab(text: 'Riwayat')],
            ),
          ),
        ),
      );

  Widget _list(bool Function(OrderService) filter) {
    final data = _orders.where(filter).toList();
    if (data.isEmpty) {
      return const Center(child: Text('Tidak ada data pesanan'));
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: data.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (_, i) => _OrderCard(
        order: data[i],
        onCancel: () =>
            setState(() => data[i].status = OrderStatus.canceled),
      ),
    );
  }
}

// ──────────────────── Kartu order ───────────────────────────
class _OrderCard extends StatelessWidget {
  final OrderService order;
  final VoidCallback onCancel;
  const _OrderCard({required this.order, required this.onCancel});

  bool get _canCancel => order.status == OrderStatus.pending;

  Color get _statusColor => switch (order.status) {
        OrderStatus.pending   => Colors.amber,
        OrderStatus.approved  => Colors.blue,
        OrderStatus.canceled  => Colors.red,
        OrderStatus.completed => Colors.green
      };

  String get _statusLabel => switch (order.status) {
        OrderStatus.pending   => 'Pending',
        OrderStatus.approved  => 'On going',
        OrderStatus.canceled  => 'Canceled',
        OrderStatus.completed => 'Completed'
      };

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 8,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- header (avatar + title) -----------------------
              Row(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(order.guideImg,
                      width: 54, height: 54, fit: BoxFit.cover),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(
                              child: Text(order.guideName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600))),
                          Text(order.id,
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.gray700)),
                        ]),
                        const SizedBox(height: 2),
                        Text(
                            '${order.service == ServiceType.chat ? 'Chat' : 'Meet'} • ${order.hours}h',
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.gray700)),
                      ]),
                )
              ]),
              const SizedBox(height: 14),

              // --- price + status ---------------------------------
              Row(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Price',
                      style: TextStyle(fontSize: 11, color: AppColors.gray700)),
                  const SizedBox(height: 2),
                  Text(
                      'Rp ${order.price.toString().replaceAllMapped(RegExp(r'(\d{3})(?=\d)'), (m) => '${m[1]}.')}',
                      style: const TextStyle(fontSize: 13)),
                ]),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: _statusColor.withOpacity(.1),
                      borderRadius: BorderRadius.circular(12)),
                  child: Text(_statusLabel,
                      style: TextStyle(fontSize: 12, color: _statusColor)),
                ),
              ]),
              const SizedBox(height: 14),

              // --- action buttons ---------------------------------
              Row(children: [
                Flexible(
                  child: OutlinedButton(
                    onPressed: _canCancel ? onCancel : null,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.gray700,
                      side: BorderSide(
                          color: _canCancel
                              ? AppColors.gray400
                              : AppColors.gray300),
                      minimumSize: const Size(0, 48),   // ← tinggi konsisten
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => OrderDetailScreen(order: order)),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.background,
                      minimumSize: const Size(0, 48),   // ← tinggi konsisten
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Detail Pesanan'),
                  ),
                ),
              ]),
            ],
          ),
        ),
      );
}
