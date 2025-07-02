import 'package:flutter/material.dart';
import 'package:flutter_ins/utils/app_colors.dart';

Future<void> showPaymentSheet(
  BuildContext ctx, {
  required String photo,
  required String name,
  required String service,
  required String price,
  required VoidCallback onPaid,
}) {
  return showModalBottomSheet(
    context: ctx,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
              color: AppColors.gray200,
              borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(height: 20),
        Row(children: [
          CircleAvatar(radius: 24, backgroundImage: NetworkImage(photo)),
          const SizedBox(width: 12),
          Expanded(
              child: Text(name,
                  style:
                      const TextStyle(fontWeight: FontWeight.w600, fontSize: 15))),
        ]),
        const SizedBox(height: 20),
        _row('Layanan', service),
        _row('Tanggal', 'Besok, 08.00'),
        _row('Harga', price),
        const SizedBox(height: 24),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.background,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: onPaid,
          child: const Text('Bayar', style: TextStyle(fontWeight: FontWeight.w600)),
        ),
      ]),
    ),
  );
}

Widget _row(String l, String v) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Text(l, style: const TextStyle(fontSize: 13, color: AppColors.gray600)),
        const Spacer(),
        Text(v,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      ]),
    );
