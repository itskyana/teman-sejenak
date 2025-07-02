import 'package:flutter/material.dart';
import 'package:flutter_ins/utils/app_colors.dart';
import '../models/guide.dart';

class GuideCard extends StatelessWidget {
  final Guide g;
  const GuideCard({super.key, required this.g});

  @override
  Widget build(BuildContext context) => Container(
        width: 230,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(.05),
                blurRadius: 10,
                offset: const Offset(0, 5)),
          ],
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          CircleAvatar(radius: 26, backgroundImage: NetworkImage(g.imageUrl)),
          const SizedBox(width: 10),

          // ── detail teks ────────────────────────────
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Text(g.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15),
                          overflow: TextOverflow.ellipsis),
                    ),
                    if (g.verified)
                      _pillBadge('Verified', AppColors.info), // gaya baru
                  ]),
                  const SizedBox(height: 2),

                  // rating, gender, age
                  Row(children: [
                    Icon(Icons.star,
                        size: 14, color: AppColors.warning),
                    const SizedBox(width: 2),
                    Text('${g.rating}',
                        style:
                            const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(width: 6),
                    Text('(${g.gender} · ${g.age})',
                        style:
                            const TextStyle(fontSize: 11, color: AppColors.gray600)),
                  ]),
                  const SizedBox(height: 2),

                  // lokasi
                  Row(children: [
                    const Icon(Icons.location_on_outlined,
                        size: 14, color: AppColors.gray600),
                    const SizedBox(width: 2),
                    Flexible(
                      child: Text(g.location,
                          style:
                              const TextStyle(fontSize: 11, color: AppColors.gray600),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ]),
                  const SizedBox(height: 6),

                  // bahasa
                  Text('Language: ${g.languages.join(', ')}',
                      style: const TextStyle(fontSize: 12)),
                  const SizedBox(height: 8),

                  // badges available + interests
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      ...g.available
                          .map((a) => _pillBadge(a, AppColors.warning)),
                      ...g.interests
                          .map((i) => _pillBadge(i, AppColors.success)),
                    ],
                  )
                ]),
          ),
        ]),
      );

  /// Badge bergaya sama dengan lencana status Order
  Widget _pillBadge(String text, Color base) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: base.withOpacity(.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(text,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: base)),
      );
}
