import 'package:flutter/material.dart';

import '../../../app/app_theme.dart';

class CsDashboardPage extends StatelessWidget {
  final VoidCallback onOpenOrders;

  const CsDashboardPage({super.key, required this.onOpenOrders});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // HEADER
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
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'CS Workspace',
                              style: TextStyle(
                                color: Color(0xFFD2E5F7),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Notifikasi akan tersedia nanti.'),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.notifications_none,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Halo, Customer Service!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Pantau pekerjaan dan pesananmu hari ini.',
                    style: TextStyle(color: Color(0xFFD2E5F7), fontSize: 12),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.20),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.person_outline,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 7),
                        Text(
                          'Role: Customer Service',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ISI DASHBOARD
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ringkasan Pesanan',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.navy,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // KARTU STATISTIK
                  const Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Total Pesanan',
                          value: '128',
                          icon: Icons.receipt_long_outlined,
                          iconColor: Color(0xFF1873B4),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: _StatCard(
                          title: 'Dalam Proses',
                          value: '24',
                          icon: Icons.schedule_outlined,
                          iconColor: Color(0xFFA65A04),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Dikirim',
                          value: '89',
                          icon: Icons.local_shipping_outlined,
                          iconColor: Color(0xFF1873B4),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: _StatCard(
                          title: 'Selesai',
                          value: '15',
                          icon: Icons.check_circle_outline,
                          iconColor: Color(0xFF0B8B65),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  // TOTAL PENJUALAN
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(17),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5EBF2)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Penjualan Bulan Ini',
                          style: TextStyle(
                            color: Color(0xFF708095),
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Rp18.750.000',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.navy,
                          ),
                        ),
                        SizedBox(height: 7),
                        Text(
                          'Data simulasi untuk pengujian tampilan',
                          style: TextStyle(fontSize: 11, color: Colors.black45),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // JUDUL PESANAN TERBARU
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Pesanan Terbaru',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.navy,
                        ),
                      ),
                      TextButton(
                        onPressed: onOpenOrders,
                        child: const Text('Lihat Semua'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),

                  const _OrderPreviewCard(
                    orderNumber: '261112001A',
                    product: 'Emblem Akrilik Timbul Custom',
                    price: 'Rp150.000',
                    status: 'Proses',
                    statusColor: Color(0xFFA65A04),
                  ),
                  const SizedBox(height: 9),
                  const _OrderPreviewCard(
                    orderNumber: '261112002A',
                    product: 'Gantungan Kunci Akrilik Custom',
                    price: 'Rp85.000',
                    status: 'Dikirim',
                    statusColor: Color(0xFF1873B4),
                  ),
                  const SizedBox(height: 9),
                  const _OrderPreviewCard(
                    orderNumber: '261112003A',
                    product: 'Stiker Kaca Mobil Custom',
                    price: 'Rp120.000',
                    status: 'Selesai',
                    statusColor: Color(0xFF0B8B65),
                  ),

                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'Data dashboard ini masih simulasi',
                      style: TextStyle(fontSize: 11, color: Colors.black38),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// WIDGET KARTU STATISTIK
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
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
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF708095),
                  ),
                ),
              ),
              Icon(icon, color: iconColor, size: 21),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: AppTheme.navy,
            ),
          ),
        ],
      ),
    );
  }
}

// WIDGET KARTU PESANAN
class _OrderPreviewCard extends StatelessWidget {
  final String orderNumber;
  final String product;
  final String price;
  final String status;
  final Color statusColor;

  const _OrderPreviewCard({
    required this.orderNumber,
    required this.product,
    required this.price,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE5EBF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  orderNumber,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.navy,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            product,
            style: const TextStyle(fontSize: 12, color: Color(0xFF61758A)),
          ),
          const SizedBox(height: 11),
          const Divider(height: 1),
          const SizedBox(height: 11),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Harga',
                style: TextStyle(fontSize: 11, color: Color(0xFF708095)),
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
}
