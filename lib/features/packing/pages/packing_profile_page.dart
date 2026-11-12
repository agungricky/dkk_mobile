import 'package:flutter/material.dart';

import '../../../app/app_theme.dart';

class PackingProfilePage extends StatefulWidget {
  final VoidCallback onLogout;

  const PackingProfilePage({super.key, required this.onLogout});

  @override
  State<PackingProfilePage> createState() => _PackingProfilePageState();
}

class _PackingProfilePageState extends State<PackingProfilePage> {
  final nameController = TextEditingController(text: 'Petugas Packing Demo');

  String displayName = 'Petugas Packing Demo';

  final String email = 'packing.demo@ddk.test';

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
        content: Text('Nama tampilan demo berhasil diperbarui.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void confirmLogout() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
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
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext);
                widget.onLogout();
              },
              icon: const Icon(Icons.logout),
              label: const Text('Ya, Keluar'),
            ),
          ],
        );
      },
    );
  }

  Widget infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
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
                const SizedBox(height: 4),
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
              color: AppTheme.navy,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 13),
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
          // HEADER PROFIL
          Container(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF103961), Color(0xFF145B91)],
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profil Packing',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Informasi akun dan pengaturan petugas',
                  style: TextStyle(color: Color(0xFFD2E5F7), fontSize: 12),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                // IDENTITAS PETUGAS
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

                      const SizedBox(height: 16),

                      Text(
                        displayName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppTheme.navy,
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        email,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),

                      const SizedBox(height: 13),

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
                          'PETUGAS PACKING',
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
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
                  infoRow(Icons.inventory_2_outlined, 'Role', 'Packing'),
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
                    'Nama Tampilan',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Petugas',
                      prefixIcon: Icon(Icons.edit_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: saveName,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Simpan Nama Demo'),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Perubahan nama hanya sementara. '
                    'Belum terhubung ke database.',
                    style: TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                ]),

                // TENTANG APLIKASI
                panel('Tentang Aplikasi', [
                  infoRow(Icons.apps_outlined, 'Aplikasi', 'DahaDigitalKreasi'),
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
                  style: TextStyle(fontSize: 11, color: Colors.black45),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
