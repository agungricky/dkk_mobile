import 'package:flutter/material.dart';

import '../../../app/app_theme.dart';

// CUSTOMER SERVICE
import '../../cs/pages/cs_shell.dart';

// LEADER CS
import '../../leader_cs/pages/leader_shell.dart';

// PACKING
import '../../packing/pages/packing_shell.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // CONTROLLER LOGIN
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  // VISIBILITAS PASSWORD
  bool obscurePassword = true;

  // ROLE SEMENTARA UNTUK PENGUJIAN UI
  String selectedRole = 'cs';

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // FUNGSI LOGIN
  void login() {
    final email = emailController.text.trim();
    final password = passwordController.text;

    // VALIDASI INPUT
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email dan password wajib diisi'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // MENENTUKAN HALAMAN BERDASARKAN ROLE
    Widget dashboard;

    switch (selectedRole) {
      // CUSTOMER SERVICE
      case 'cs':
        dashboard = const CsShell();
        break;

      // LEADER CS
      case 'leader_cs':
        dashboard = const LeaderShell();
        break;

      // PACKING
      case 'packing':
        dashboard = const PackingShell();
        break;

      default:
        dashboard = const CsShell();
        break;
    }

    // PINDAH KE HALAMAN DASHBOARD
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => dashboard),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FA),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),

            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),

              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ============================
                  // LOGO DAHA DIGITAL KREASI
                  // ============================

                  ClipRRect(
                    borderRadius: BorderRadius.circular(26),
                    child: Image.asset(
                      'assets/images/ddk_logo.png',
                      width: 130,
                      height: 130,
                      fit: BoxFit.contain,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // NAMA APLIKASI
                  const Text(
                    'Daha Digital Kreasi',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.navy,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'Masuk ke sistem operasional',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54, fontSize: 14),
                  ),

                  const SizedBox(height: 32),

                  // ============================
                  // FORM LOGIN
                  // ============================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE5EBF2)),
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // JUDUL FORM
                        const Text(
                          'Login Karyawan',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.navy,
                          ),
                        ),

                        const SizedBox(height: 6),

                        const Text(
                          'Masukkan informasi akun untuk melanjutkan.',
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),

                        const SizedBox(height: 22),

                        // ============================
                        // INPUT EMAIL
                        // ============================
                        TextField(
                          controller: emailController,

                          keyboardType: TextInputType.emailAddress,

                          textInputAction: TextInputAction.next,

                          decoration: const InputDecoration(
                            labelText: 'Email',
                            hintText: 'nama@perusahaan.com',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ============================
                        // INPUT PASSWORD
                        // ============================
                        TextField(
                          controller: passwordController,

                          obscureText: obscurePassword,

                          textInputAction: TextInputAction.done,

                          onSubmitted: (_) => login(),

                          decoration: InputDecoration(
                            labelText: 'Password',

                            prefixIcon: const Icon(Icons.lock_outline),

                            suffixIcon: IconButton(
                              tooltip: obscurePassword
                                  ? 'Tampilkan password'
                                  : 'Sembunyikan password',

                              icon: Icon(
                                obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),

                              onPressed: () {
                                setState(() {
                                  obscurePassword = !obscurePassword;
                                });
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 22),

                        // ============================
                        // PILIH ROLE DEMO
                        // ============================
                        const Text(
                          'Role Pengujian',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.navy,
                          ),
                        ),

                        const SizedBox(height: 9),

                        DropdownButtonFormField<String>(
                          initialValue: selectedRole,

                          isExpanded: true,

                          decoration: const InputDecoration(
                            prefixIcon: Icon(
                              Icons.admin_panel_settings_outlined,
                            ),
                          ),

                          items: const [
                            DropdownMenuItem<String>(
                              value: 'cs',
                              child: Text('Customer Service'),
                            ),

                            DropdownMenuItem<String>(
                              value: 'leader_cs',
                              child: Text('Leader CS'),
                            ),

                            DropdownMenuItem<String>(
                              value: 'packing',
                              child: Text('Packing'),
                            ),
                          ],

                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                selectedRole = value;
                              });
                            }
                          },
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          'Pilihan role hanya untuk pengujian tampilan.',
                          style: TextStyle(fontSize: 11, color: Colors.black45),
                        ),

                        const SizedBox(height: 24),

                        // ============================
                        // TOMBOL MASUK
                        // ============================
                        SizedBox(
                          width: double.infinity,
                          height: 52,

                          child: FilledButton(
                            onPressed: login,

                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,

                              children: [
                                Icon(Icons.login, size: 20),

                                SizedBox(width: 10),

                                Text(
                                  'Masuk',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ============================
                  // FOOTER
                  // ============================
                  const Text(
                    '© PT Daha Digital Kreasi',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.black45),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    'Sistem Operasional Internal',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: Colors.black38),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
