import 'package:flutter/material.dart';
import 'package:flutter_ins/utils/app_colors.dart';
import '../models/guide.dart';
import '../widgets/message_bubble.dart';
import '../widgets/service_panel.dart';
import '../widgets/payment_sheet.dart';

class ChatScreen extends StatefulWidget {
  final Guide guide;
  const ChatScreen({super.key, required this.guide});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _showServicePanel = true;

  final List<Map<String, dynamic>> _msgs = [
    {'me': true, 'text': 'Hallo, Kamu mau tidak temani saya ke kafe?'},
    {'me': false, 'text': 'Hai! Tentu saja, saya akan menemanimu.'},
    {'me': false, 'text': 'Tentu, jam berapa yang paling cocok untukmu?'},
    {'me': true, 'text': 'Pagi sekitar jam 10 pagi akan sangat cocok.'},
    {
      'me': false,
      'text':
          'Bagus! Silakan pesan layanan terlebih dahulu, lalu kita bisa membahas detailnya.',
    },
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: _appBar(),
    body: Stack(
      children: [
        // 1. Background gambar
        Positioned.fill(
          child: Image.asset(
            'assets/images/bg_pattern.webp',
            fit: BoxFit.cover,
          ),
        ),

        // 2. Overlay gelap/transparan
        Positioned.fill(
          child: Container(
            color: Colors.white.withOpacity(
              0.9,
            ), // Ganti sesuai efek yang diinginkan
          ),
        ),

        // 3. Isi utama
        Column(
          children: [
            Expanded(child: _chatList()),
            if (_showServicePanel)
              ServicePanel(
                onMeetTap: () => _pay('Ayo Bertemu', 'IDR 100k'),
                onChatTap: () => _pay('Lanjutkan Chat', 'IDR 50k'),
              ),
            _inputDummy(),
          ],
        ),
      ],
    ),
  );

  // ── AppBar ────────────────────────────────────────────────
  PreferredSizeWidget _appBar() => AppBar(
    backgroundColor: AppColors.background,
    elevation: 0,
    foregroundColor: Colors.black87,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back_ios_new_rounded),
      onPressed: () => Navigator.pop(context),
    ),
    titleSpacing: 0,
    title: Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundImage: NetworkImage(widget.guide.imageUrl),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.guide.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Row(
              children: [
                Text(
                  widget.guide.location,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.gray600,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'Online',
                  style: TextStyle(fontSize: 11, color: AppColors.success),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    actions: [
      IconButton(
        icon: const Icon(Icons.call_rounded, color: AppColors.primary),
        onPressed: () {},
      ),
      IconButton(
        icon: const Icon(Icons.videocam_rounded, color: AppColors.primary),
        onPressed: () {},
      ),
      const SizedBox(width: 4),
    ],
  );

  // ── List Chat ─────────────────────────────────────────────
  Widget _chatList() => ListView.builder(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    itemCount: _msgs.length + 1,
    itemBuilder: (_, i) {
      if (i == _msgs.length) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Center(
            child: Text(
              '⚠️ Chat ini sudah limit. Silakan pesan layanan di bawah untuk melanjutkan.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.danger,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        );
      }
      final m = _msgs[i];
      return MessageBubble(text: m['text'], isMe: m['me']);
    },
  );

  // ── Input Dummy ───────────────────────────────────────────
  Widget _inputDummy() => Container(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
    color: AppColors.background.withOpacity(0.95),
    child: Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Type a message…',
              style: TextStyle(fontSize: 13, color: AppColors.gray600),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(12),
          child: const Icon(
            Icons.send_rounded,
            size: 18,
            color: AppColors.background,
          ),
        ),
      ],
    ),
  );

  // ── Pembayaran Dummy ──────────────────────────────────────
  void _pay(String svc, String price) {
    showPaymentSheet(
      context,
      photo: widget.guide.imageUrl,
      name: widget.guide.name,
      service: svc,
      price: price,
      onPaid: () {
        Navigator.pop(context);
        setState(() => _showServicePanel = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pembayaran berhasil! 🎉')),
        );
      },
    );
  }
}
