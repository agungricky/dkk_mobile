import 'package:flutter/material.dart';

import '../../../app/app_theme.dart';

class LeaderDashboardPage extends StatelessWidget {
  final VoidCallback onOpenOrders;
  final VoidCallback onOpenPerformance;

  const LeaderDashboardPage({
    super.key,
    required this.onOpenOrders,
    required this.onOpenPerformance,
  });

  static const staffData = [
    ('ELSA', 18),
    ('IZA', 15),
    ('EVA', 14),
    ('MAYA', 13),
  ];

  static const statusData = [
    ('Proses', 16, Color(0xFFA65A04)),
    ('Kirim', 23, Color(0xFF1873B4)),
    ('Selesai', 17, Color(0xFF0B8B65)),
    ('Batal', 4, Color(0xFFB42332)),
  ];

  static const recentOrders = [
    ('DEMO-001', 'ELSA', 'Pelanggan A', 'Rp150.000', 'Proses'),
    ('DEMO-002', 'IZA', 'Pelanggan B', 'Rp85.000', 'Kirim'),
    ('DEMO-003', 'EVA', 'Pelanggan C', 'Rp120.000', 'Selesai'),
    ('DEMO-004', 'MAYA', 'Pelanggan D', 'Rp175.000', 'Batal'),
  ];

  Widget statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.navy,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF708095)),
          ),
        ],
      ),
    );
  }

  Widget panel({
    required String title,
    required Widget child,
    VoidCallback? onSeeAll,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5EBF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppTheme.navy,
                  ),
                ),
              ),
              if (onSeeAll != null)
                TextButton(
                  onPressed: onSeeAll,
                  child: const Text('Lihat Semua'),
                ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget progressRow(String name, int count, int maxCount, Color color) {
    final value = maxCount == 0 ? 0.0 : count / maxCount;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '$count pesanan',
                style: const TextStyle(fontSize: 11, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 9,
              backgroundColor: const Color(0xFFEEF2F6),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget recentOrderCard(
    String number,
    String cs,
    String buyer,
    String price,
    String status,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEEF1F5))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  number,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.navy,
                    fontSize: 13,
                  ),
                ),
              ),
              Text(
                status,
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            buyer,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.person_outline, size: 15, color: Colors.grey.shade600),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  'CS: $cs',
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ),
              Text(
                price,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.navy,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        children: [
          // HEADER LEADER
          Container(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF103961), Color(0xFF145B91)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
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
                            'Leader CS Workspace',
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
                      child: Text(
                        'LC',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                const Text(
                  'Dashboard Tim',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Monitoring tim dan pesanan Meta',
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
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF4FD),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: AppTheme.primary),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Data simulasi untuk pengujian UI. '
                          'Belum terhubung dengan Laravel API.',
                          style: TextStyle(fontSize: 12, color: AppTheme.navy),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Ringkasan Tim Meta',
                  style: TextStyle(
                    fontSize: 17,
                    color: AppTheme.navy,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: statCard(
                        'Total Pesanan',
                        '60',
                        Icons.receipt_long_outlined,
                        AppTheme.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: statCard(
                        'Pesanan Proses',
                        '16',
                        Icons.schedule_outlined,
                        const Color(0xFFA65A04),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: statCard(
                        'Omzet Contoh',
                        'Rp8,9 jt',
                        Icons.payments_outlined,
                        const Color(0xFF0B8B65),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: statCard(
                        'Jumlah CS',
                        '${staffData.length}',
                        Icons.groups_outlined,
                        AppTheme.primary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                panel(
                  title: 'Performa CS',
                  onSeeAll: onOpenPerformance,
                  child: Column(
                    children: staffData
                        .map(
                          (staff) => progressRow(
                            staff.$1,
                            staff.$2,
                            18,
                            AppTheme.primary,
                          ),
                        )
                        .toList(),
                  ),
                ),

                panel(
                  title: 'Status Pesanan',
                  child: Column(
                    children: statusData
                        .map(
                          (status) =>
                              progressRow(status.$1, status.$2, 60, status.$3),
                        )
                        .toList(),
                  ),
                ),

                panel(
                  title: 'Pesanan Terbaru',
                  onSeeAll: onOpenOrders,
                  child: Column(
                    children: recentOrders
                        .map(
                          (order) => recentOrderCard(
                            order.$1,
                            order.$2,
                            order.$3,
                            order.$4,
                            order.$5,
                          ),
                        )
                        .toList(),
                  ),
                ),

                const SizedBox(height: 6),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onOpenOrders,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Kelola Semua Pesanan'),
                  ),
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
