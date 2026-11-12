import 'package:flutter/material.dart';

import '../../../app/app_theme.dart';

class LeaderProfilePage extends StatefulWidget {
  final VoidCallback onLogout;

  const LeaderProfilePage({super.key, required this.onLogout});

  @override
  State<LeaderProfilePage> createState() => _LeaderProfilePageState();
}

class _LeaderProfilePageState extends State<LeaderProfilePage> {
  // DATA SIMULASI LEADER CS
  final TextEditingController nameController = TextEditingController(
    text: 'Leader CS Demo',
  );

  String displayName = 'Leader CS Demo';

  final String email = 'leader.demo@ddk.test';

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  // SIMPAN NAMA DEMO
  void saveName() {
    final name = nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama tidak boleh kosong.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      displayName = name;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Nama Leader CS berhasil diperbarui sementara.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // KONFIRMASI LOGOUT
  void confirmLogout() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),

          title: const Row(
            children: [
              Icon(Icons.logout, color: Color(0xFFB42332)),
              SizedBox(width: 10),
              Text('Konfirmasi Logout'),
            ],
          ),

          content: const Text(
            'Apakah kamu yakin ingin keluar '
            'dari aplikasi DahaDigitalKreasi?',
          ),

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
              child: const Text('Ya, Keluar'),
            ),
          ],
        );
      },
    );
  }

  // KOMPONEN INFORMASI AKUN
  Widget infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF4FD),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 21),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF708095),
                    fontSize: 11,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  value,
                  style: const TextStyle(
                    color: AppTheme.navy,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // KOMPONEN PANEL
  Widget panel(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
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
          // HEADER LEADER CS
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
                  'Profil Leader CS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 6),

                Text(
                  'Informasi akun dan pengaturan pengguna',
                  style: TextStyle(color: Color(0xFFD2E5F7), fontSize: 12),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(15),

            child: Column(
              children: [
                // KARTU IDENTITAS LEADER
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
                      // LOGO DDK
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),

                        child: Image.asset(
                          'assets/images/ddk_logo.png',
                          width: 90,
                          height: 90,
                          fit: BoxFit.contain,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // NAMA LEADER
                      Text(
                        displayName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppTheme.navy,
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        email,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),

                      const SizedBox(height: 13),

                      // BADGE ROLE
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),

                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF4FD),
                          borderRadius: BorderRadius.circular(30),
                        ),

                        child: const Text(
                          'LEADER CUSTOMER SERVICE',
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

                // INFORMASI AKUN
                panel('Informasi Akun', [
                  infoRow(Icons.person_outline, 'Nama Karyawan', displayName),

                  const Divider(height: 1),

                  infoRow(Icons.email_outlined, 'Email', email),

                  const Divider(height: 1),

                  infoRow(Icons.shield_outlined, 'Role', 'Leader CS'),

                  const Divider(height: 1),

                  infoRow(
                    Icons.business_outlined,
                    'Perusahaan',
                    'PT Daha Digital Kreasi',
                  ),
                ]),

                // PENGATURAN PROFIL
                panel('Pengaturan Profil', [
                  const Text(
                    'Nama Tampilan Leader CS',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: nameController,

                    textCapitalization: TextCapitalization.words,

                    decoration: const InputDecoration(
                      labelText: 'Nama Tampilan',
                      prefixIcon: Icon(Icons.edit_outlined),
                    ),
                  ),

                  const SizedBox(height: 14),

                  FilledButton.icon(
                    onPressed: saveName,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Simpan Nama Demo'),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'Perubahan nama hanya disimpan '
                    'sementara selama halaman demo aktif. '
                    'Belum terhubung dengan database.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                  ),
                ]),

                // INFORMASI APLIKASI
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
                    'Simulasi Lokal',
                  ),

                  const Divider(height: 1),

                  infoRow(
                    Icons.groups_outlined,
                    'Akses Pengguna',
                    'Monitoring Seluruh CS',
                  ),
                ]),

                // TOMBOL LOGOUT
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

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  '© PT Daha Digital Kreasi',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black45, fontSize: 11),
                ),

                const SizedBox(height: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
