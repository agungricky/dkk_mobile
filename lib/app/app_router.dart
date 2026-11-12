import 'package:flutter/material.dart';

import 'app_theme.dart';
import '../features/auth/pages/login_page.dart';

class DahaDigitalKreasiApp extends StatelessWidget {
  const DahaDigitalKreasiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DahaDigitalKreasi',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const LoginPage(),
    );
  }
}
