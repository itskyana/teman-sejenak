import 'package:flutter/material.dart';
import 'package:flutter_ins/utils/app_colors.dart';

class MessageBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  const MessageBubble({super.key, required this.text, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final bg  = isMe ? AppColors.primary : AppColors.gray200;
    final fg  = isMe ? Colors.white : AppColors.gray600;
    final ali = isMe ? Alignment.centerRight : Alignment.centerLeft;

    return Align(
      alignment: ali,
      child: Container(
        // ⇩  jarak vertikal diperlebar
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .7),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
        child: Text(text, style: TextStyle(color: fg, fontSize: 13, height: 1.3)),
      ),
    );
  }
}
