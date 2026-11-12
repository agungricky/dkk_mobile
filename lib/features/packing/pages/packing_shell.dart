import 'package:flutter/material.dart';

import '../../../app/app_theme.dart';
import '../../auth/pages/login_page.dart';
import 'packing_dashboard_page.dart';
import 'packing_profile_page.dart';
import 'packing_photo_page.dart';
import 'packing_scan_page.dart';
import 'packing_history_page.dart';

class PackingShell extends StatefulWidget {
  const PackingShell({super.key});

  @override
  State<PackingShell> createState() => _PackingShellState();
}

class _PackingShellState extends State<PackingShell> {
  int selectedIndex = 0;

  void changePage(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  void logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      // 0 - BERANDA PACKING
      PackingDashboardPage(
        onOpenPhoto: () => changePage(1),
        onOpenScan: () => changePage(2),
      ),

      // 1 - FOTO PACKING META
      const PackingPhotoPage(),

      // 2 - SCAN PENGIRIMAN
      const PackingScanPage(),

      // 3 - RIWAYAT
      const PackingHistoryPage(),

      // 4 - PROFIL PACKING
      PackingProfilePage(onLogout: logout),
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,

      body: IndexedStack(index: selectedIndex, children: pages),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: changePage,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: const Color(0xFF8393A4),
        selectedFontSize: 11,
        unselectedFontSize: 10,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_a_photo_outlined),
            activeIcon: Icon(Icons.add_a_photo),
            label: 'Foto Meta',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scan Kirim',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

// HALAMAN SEMENTARA UNTUK MENU
// YANG BELUM DIBUAT
class PackingPlaceholderPage extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const PackingPlaceholderPage({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F3FB),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(icon, color: AppTheme.primary, size: 42),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppTheme.navy,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Halaman sedang disiapkan',
                style: TextStyle(color: Colors.black38, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
