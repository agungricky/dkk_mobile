import 'package:flutter/material.dart';

import '../../../app/app_theme.dart';

class CsProfilePage extends StatefulWidget {
  final VoidCallback onLogout;

  const CsProfilePage({super.key, required this.onLogout});

  @override
  State<CsProfilePage> createState() => _CsProfilePageState();
}

class _CsProfilePageState extends State<CsProfilePage> {
  final nameController = TextEditingController(text: 'CS Demo');

  final email = 'cs.demo@ddk.test';

  String displayName = 'CS Demo';

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  void saveName() {
    final name = nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nama tidak boleh kosong.')));
      return;
    }

    setState(() {
      displayName = name;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Nama demo diperbarui sementara.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void confirmLogout() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Keluar dari aplikasi?'),
          content: const Text('Kamu akan kembali ke halaman Login.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                widget.onLogout();
              },
              child: const Text('Keluar'),
            ),
          ],
        );
      },
    );
  }

  Widget infoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF4FD),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 21, color: AppTheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF708095),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.navy,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget panel(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5EBF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.navy,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        children: [
          // HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF103961), Color(0xFF145B91)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profil Saya',
                  style: TextStyle(
                    fontSize: 23,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Informasi akun dan pengaturan pengguna',
                  style: TextStyle(fontSize: 12, color: Color(0xFFD2E5F7)),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                // KARTU IDENTITAS
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(17),
                    border: Border.all(color: const Color(0xFFE5EBF2)),
                  ),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.asset(
                          'assets/images/ddk_logo.png',
                          width: 90,
                          height: 90,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        displayName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.navy,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        email,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF4FD),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Text(
                          'CUSTOMER SERVICE',
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                panel('Informasi Akun', [
                  infoRow(Icons.person_outline, 'Nama Karyawan', displayName),
                  const Divider(height: 1),
                  infoRow(Icons.email_outlined, 'Email', email),
                  const Divider(height: 1),
                  infoRow(Icons.badge_outlined, 'Role', 'Customer Service'),
                  const Divider(height: 1),
                  infoRow(
                    Icons.business_outlined,
                    'Perusahaan',
                    'PT Daha Digital Kreasi',
                  ),
                ]),

                // EDIT PROFIL DEMO
                panel('Pengaturan Profil', [
                  const Text(
                    'Ubah Nama Tampilan (Demo)',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      hintText: 'Nama karyawan',
                      prefixIcon: Icon(Icons.edit_outlined),
                    ),
                  ),
                  const SizedBox(height: 13),
                  FilledButton.icon(
                    onPressed: saveName,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Simpan Nama Demo'),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Perubahan ini hanya berlaku '
                    'selama halaman demo aktif.',
                    style: TextStyle(color: Colors.black45, fontSize: 11),
                  ),
                ]),

                panel('Tentang Aplikasi', [
                  infoRow(
                    Icons.apps_outlined,
                    'Nama Aplikasi',
                    'DahaDigitalKreasi',
                  ),
                  const Divider(height: 1),
                  infoRow(
                    Icons.info_outline,
                    'Versi Tampilan',
                    'Prototype UI 1.0',
                  ),
                  const Divider(height: 1),
                  infoRow(
                    Icons.cloud_off_outlined,
                    'Sumber Data',
                    'Data Simulasi',
                  ),
                ]),

                // LOGOUT
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: confirmLogout,
                    icon: const Icon(Icons.logout, color: Color(0xFFB42332)),
                    label: const Text(
                      'Keluar dari Aplikasi',
                      style: TextStyle(
                        color: Color(0xFFB42332),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      side: const BorderSide(color: Color(0xFFE7BFC3)),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  '© PT Daha Digital Kreasi',
                  style: TextStyle(fontSize: 11, color: Colors.black45),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
