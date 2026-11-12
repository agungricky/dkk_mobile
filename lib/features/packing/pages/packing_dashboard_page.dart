import 'package:flutter/material.dart';

import '../../../app/app_theme.dart';
import '../../../mock/mock_packing.dart';

class PackingDashboardPage extends StatelessWidget {
  final VoidCallback onOpenPhoto;
  final VoidCallback onOpenScan;

  const PackingDashboardPage({
    super.key,
    required this.onOpenPhoto,
    required this.onOpenScan,
  });

  Widget statCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5EBF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 25),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: AppTheme.navy,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF708095),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget actionCard({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5EBF2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF4FD),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: AppTheme.primary, size: 26),
              ),
              const SizedBox(height: 13),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppTheme.navy,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF61758A),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              const Row(
                children: [
                  Text(
                    'Buka Menu',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward, size: 16, color: AppTheme.primary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget ruleItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 21, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.navy,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF61758A),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // SUMBER DATA BERSAMA:
    // Foto Meta, Scan Kirim, dan Riwayat menggunakan
    // instance yang sama.
    final store = PackingDemoStore.instance;

    return SafeArea(
      child: AnimatedBuilder(
        animation: store,
        builder: (context, _) {
          // STATISTIK DINAMIS
          final metaMenunggu = store.pendingMetaCount;
          final siapDikirim = store.readyOrders.length;
          final dikirimInternal = store.dispatchedOrders.length;
          final fotoTersimpan = store.totalMetaPhotos;

          return ListView(
            children: [
              // HEADER PACKING
              Container(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF103961), Color(0xFF145B91)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            'assets/images/ddk_logo.png',
                            width: 46,
                            height: 46,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(width: 11),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'DAHA DIGITAL KREASI',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Packing Workspace',
                                style: TextStyle(
                                  color: Color(0xFFD2E5F7),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const CircleAvatar(
                          backgroundColor: Color(0xFF276696),
                          child: Icon(
                            Icons.inventory_2_outlined,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Dashboard Packing',
                      style: TextStyle(
                        fontSize: 23,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Kelola foto barang dan proses pengiriman',
                      style: TextStyle(fontSize: 12, color: Color(0xFFD2E5F7)),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // INFORMASI MODE DEMO
                    Container(
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF4FD),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppTheme.primary,
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Statistik otomatis mengikuti '
                              'aktivitas Foto Meta dan Scan Kirim. '
                              'Data masih simulasi lokal.',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.navy,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Ringkasan Operasional',
                      style: TextStyle(
                        color: AppTheme.navy,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // BARIS STATISTIK 1
                    Row(
                      children: [
                        Expanded(
                          child: statCard(
                            title: 'Meta Menunggu',
                            value: '$metaMenunggu',
                            subtitle: 'Perlu foto / packing',
                            icon: Icons.pending_actions_outlined,
                            color: const Color(0xFFA65A04),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: statCard(
                            title: 'Siap Dikirim',
                            value: '$siapDikirim',
                            subtitle: 'Semua channel',
                            icon: Icons.inventory_2_outlined,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // BARIS STATISTIK 2
                    Row(
                      children: [
                        Expanded(
                          child: statCard(
                            title: 'Dikirim Internal',
                            value: '$dikirimInternal',
                            subtitle: 'Sudah scan resi',
                            icon: Icons.local_shipping_outlined,
                            color: const Color(0xFF0B8B65),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: statCard(
                            title: 'Foto Tersimpan',
                            value: '$fotoTersimpan',
                            subtitle: 'Jumlah foto Meta (demo)',
                            icon: Icons.photo_library_outlined,
                            color: const Color(0xFF6956B5),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 23),

                    const Text(
                      'Menu Operasional',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.navy,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // TOMBOL MENU FOTO META
                    actionCard(
                      title: 'Foto Packing Meta',
                      description:
                          'Cari pesanan Meta, periksa produk, '
                          'ambil foto barang, dan konfirmasi '
                          'selesai packing.',
                      icon: Icons.add_a_photo_outlined,
                      onTap: onOpenPhoto,
                    ),

                    const SizedBox(height: 12),

                    // TOMBOL MENU SCAN
                    actionCard(
                      title: 'Scan Pengiriman',
                      description:
                          'Proses nomor resi Meta, Shopee, '
                          'dan TikTok setelah packing selesai.',
                      icon: Icons.qr_code_scanner,
                      onTap: onOpenScan,
                    ),

                    const SizedBox(height: 23),

                    const Text(
                      'Aturan Alur Packing',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.navy,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5EBF2)),
                      ),
                      child: Column(
                        children: [
                          ruleItem(
                            icon: Icons.camera_alt_outlined,
                            title: 'Foto Produk Meta',
                            description:
                                'Barang pesanan Meta wajib difoto '
                                'sebelum selesai dipacking.',
                            color: AppTheme.primary,
                          ),

                          ruleItem(
                            icon: Icons.inventory_2_outlined,
                            title: 'Packing Marketplace',
                            description:
                                'Shopee dan TikTok menggunakan '
                                'status packing dari sistem '
                                'PembukuanLaser.',
                            color: const Color(0xFF6956B5),
                          ),

                          ruleItem(
                            icon: Icons.qr_code_scanner,
                            title: 'Scan Resi Pengiriman',
                            description:
                                'Scan berlaku untuk Meta, Shopee, '
                                'dan TikTok. Paket belum selesai '
                                'packing tidak boleh dikirim.',
                            color: const Color(0xFF0B8B65),
                          ),

                          ruleItem(
                            icon: Icons.local_shipping_outlined,
                            title: 'Dikirim Internal',
                            description:
                                'Menandakan paket telah diproses '
                                'petugas untuk pengiriman, '
                                'bukan sudah diterima pembeli.',
                            color: const Color(0xFFA65A04),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Center(
                      child: Text(
                        'Data simulasi — belum terhubung API Laravel',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, color: Colors.black45),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
