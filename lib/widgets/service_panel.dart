import 'package:flutter/material.dart';
import 'package:flutter_ins/utils/app_colors.dart';

class ServicePanel extends StatelessWidget {
  final VoidCallback onMeetTap;
  final VoidCallback onChatTap;
  const ServicePanel({super.key, required this.onMeetTap, required this.onChatTap});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: AppColors.background,
          border: const Border(top: BorderSide(color: AppColors.gray200, width: 1)),
        ),
        child: Column(
          children: [
            Row(
              children: const [
                Icon(Icons.info_outline_rounded, size: 18, color: AppColors.primary),
                SizedBox(width: 6),
                Expanded(
                  child: Text('Untuk melanjutkan, silakan pilih opsi di bawah ini.',
                      maxLines: 2,
                      style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: _blueBtn,
                    onPressed: onMeetTap,
                    child: const Text('Ayo Bertemu',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    style: _outlineBtn,
                    onPressed: onChatTap,
                    child: const Text('Lanjutkan Chat',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  ButtonStyle get _blueBtn => ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        minimumSize: const Size(0, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      );

  ButtonStyle get _outlineBtn => OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        minimumSize: const Size(0, 48),
        side: const BorderSide(color: AppColors.primary, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      );
}
