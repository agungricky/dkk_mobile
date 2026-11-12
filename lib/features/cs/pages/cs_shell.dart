import 'package:flutter/material.dart';

import '../../../app/app_theme.dart';
import '../../auth/pages/login_page.dart';

import 'cs_dashboard_page.dart';
import 'cs_orders_page.dart';
import 'cs_add_order_page.dart';
import 'cs_summary_page.dart';
import 'cs_profile_page.dart';

class CsShell extends StatefulWidget {
  const CsShell({super.key});

  @override
  State<CsShell> createState() => _CsShellState();
}

class _CsShellState extends State<CsShell> {
  int selectedIndex = 0;

  // Navigasi antarhalaman CS
  void changePage(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  // Logout kembali ke Login
  void logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Seluruh halaman Customer Service
    final pages = <Widget>[
      // 0 - DASHBOARD CS
      CsDashboardPage(
        onOpenOrders: () {
          changePage(1);
        },
      ),

      // 1 - PESANAN SAYA
      CsOrdersPage(
        onAddOrder: () {
          changePage(2);
        },
      ),

      // 2 - TAMBAH PESANAN
      CsAddOrderPage(
        onCancel: () {
          changePage(1);
        },
      ),

      // 3 - RINGKASAN SAYA
      const CsSummaryPage(),

      // 4 - PROFIL SAYA
      CsProfilePage(onLogout: logout),
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,

      // Konten halaman sesuai menu
      body: IndexedStack(index: selectedIndex, children: pages),

      // BOTTOM NAVIGATION CUSTOMER SERVICE
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
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Pesanan',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: 'Tambah',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Ringkasan',
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
