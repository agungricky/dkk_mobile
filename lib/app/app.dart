import 'package:flutter/material.dart';

import 'app_theme.dart';
import '../features/auth/pages/login_page.dart';
import '../features/auth/services/auth_service.dart';

// Sesuaikan path import dengan lokasi file dashboard.
import '../features/cs/pages/cs_shell.dart';
import '../features/leader_cs/pages/leader_shell.dart';
import '../features/packing/pages/packing_shell.dart';

class DahaDigitalKreasiApp extends StatelessWidget {
  const DahaDigitalKreasiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DahaDigitalKreasi',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final AuthService _authService = AuthService();

  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await _authService.checkToken();

      if (!mounted) return;

      final userData = result?['user'];

      setState(() {
        _user = userData is Map
            ? Map<String, dynamic>.from(userData)
            : null;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  Widget _buildDashboard(Map<String, dynamic> user) {
    final role = user['role']?.toString().toLowerCase();

    final leaderValue = user['leader'];

    final isLeader = leaderValue == true ||
        leaderValue == 1 ||
        leaderValue == '1';

    switch (role) {
      case 'cs':
        return isLeader
            ? const LeaderShell()
            : const CsShell();

      case 'packing':
        return const PackingShell();

      default:
        return Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Role $role belum memiliki dashboard.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.wifi_off_rounded,
                  size: 56,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Tidak dapat memeriksa sesi login.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _checkSession,
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_user == null) {
      return const LoginPage();
    }

    return _buildDashboard(_user!);
  }
}