import 'package:flutter/material.dart';

import '../../../app/app_theme.dart';
import '../../auth/pages/login_page.dart';

// FORM TAMBAH PESANAN BERSAMA
import '../../cs/pages/cs_add_order_page.dart';

// HALAMAN LEADER CS
import 'leader_dashboard_page.dart';
import 'leader_orders_page.dart';
import 'leader_performance_page.dart';
import 'leader_profile_page.dart';

class LeaderShell extends StatefulWidget {
  const LeaderShell({super.key});

  @override
  State<LeaderShell> createState() => _LeaderShellState();
}

class _LeaderShellState extends State<LeaderShell> {
  int selectedIndex = 0;

  // PINDAH HALAMAN
  void changePage(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  // TAMBAH PESANAN LEADER CS
  void openAddOrder() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (pageContext) {
          return Scaffold(
            backgroundColor: AppTheme.background,
            body: CsAddOrderPage(
              isLeader: true,
              onCancel: () {
                Navigator.pop(pageContext);
              },
            ),
          );
        },
      ),
    );
  }

  // LOGOUT
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
      // 0. DASHBOARD TIM
      LeaderDashboardPage(
        onOpenOrders: () => changePage(1),
        onOpenPerformance: () => changePage(2),
      ),

      // 1. KELOLA PESANAN
      const LeaderOrdersPage(),

      // 2. PERFORMA CS
      const LeaderPerformancePage(),

      // 3. PROFIL LEADER
      LeaderProfilePage(onLogout: logout),
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,

      body: IndexedStack(index: selectedIndex, children: pages),

      // TOMBOL TAMBAH PESANAN
      // HANYA TAMPIL DI DASHBOARD DAN KELOLA PESANAN
      floatingActionButton: selectedIndex == 0 || selectedIndex == 1
          ? FloatingActionButton.extended(
              onPressed: openAddOrder,
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text(
                'Tambah Pesanan',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            )
          : null,

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      // BOTTOM NAVIGATION
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
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Pesanan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Performa',
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
