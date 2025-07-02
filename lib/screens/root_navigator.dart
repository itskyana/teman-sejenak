import 'package:flutter/material.dart';
import 'package:flutter_ins/utils/app_colors.dart';

import 'home_screen.dart';
import 'guide_list_screen.dart';
import 'history_screen.dart';
import 'message_screen.dart';
import 'profile_screen.dart';

class RootNavigation extends StatefulWidget {
  /// index tab pertama kali ditampilkan
  final int initialIndex;
  const RootNavigation({super.key, this.initialIndex = 0});

  /// Helper: buka RootNavigation & pilih tab tertentu,
  /// sambil mengosongkan stack di atas root.
  static void openAt(BuildContext ctx, int tabIndex) {
    Navigator.of(ctx).pushAndRemoveUntil(
      MaterialPageRoute(
          builder: (_) => RootNavigation(initialIndex: tabIndex)),
      (route) => false,
    );
  }

  @override
  State<RootNavigation> createState() => _RootNavigationState();
}

class _RootNavigationState extends State<RootNavigation> {
  late int _index;

  final _pages = const [
    HomeScreen(),
    GuideListScreen(),   // Guides
    HistoryScreen(),     // Orders / History
    MessageListScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;      // ← gunakan parameter
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        body: IndexedStack(index: _index, children: _pages),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                  color: AppColors.gray500,
                  blurRadius: 5,
                  offset: const Offset(0, -2)),
            ],
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: AppColors.background,
            elevation: 0,
            currentIndex: _index,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.secondary,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            onTap: (i) => setState(() => _index = i),
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home_rounded), label: 'Home'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.people_rounded), label: 'Teman'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.history_rounded), label: 'Riwayat'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.message_rounded), label: 'Pesan'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline_rounded), label: 'Profil'),
            ],
          ),
        ),
      );
}
