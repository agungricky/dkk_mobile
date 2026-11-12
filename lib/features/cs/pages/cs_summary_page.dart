import 'package:flutter/material.dart';

import '../../../app/app_theme.dart';
import '../../../mock/mock_orders.dart';
import '../../orders/models/order_model.dart';

class CsSummaryPage extends StatelessWidget {
  const CsSummaryPage({super.key});

  static const List<String> statuses = [
    'proses',
    'packing',
    'kirim',
    'selesai',
    'batal',
  ];

  String rupiah(int value) {
    final formatted = value.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
    return 'Rp$formatted';
  }

  String statusLabel(String status) {
    switch (status) {
      case 'proses':
        return 'Proses';
      case 'packing':
        return 'Packing';
      case 'kirim':
        return 'Dikirim';
      case 'selesai':
        return 'Selesai';
      case 'batal':
        return 'Batal';
      default:
        return status;
    }
  }

  Color statusColor(String status) {
    switch (status) {
      case 'proses':
        return const Color(0xFFA65A04);
      case 'packing':
        return const Color(0xFF6956B5);
      case 'kirim':
        return const Color(0xFF1873B4);
      case 'selesai':
        return const Color(0xFF0B8B65);
      case 'batal':
        return const Color(0xFFB42332);
      default:
        return Colors.grey;
    }
  }

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
          Icon(icon, color: color, size: 23),
          const SizedBox(height: 12),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 21,
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

  Widget panel(String title, Widget content) {
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.navy,
            ),
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orders = List<OrderModel>.from(MockOrders.csOrders)
      ..sort((a, b) => b.orderDate.compareTo(a.orderDate));

    final validOrders = orders
        .where((order) => order.status != 'batal')
        .toList();

    final totalOrders = orders.length;
    final canceledOrders = orders
        .where((order) => order.status == 'batal')
        .length;

    final omzet = validOrders.fold<int>(
      0,
      (sum, order) => sum + order.totalPrice,
    );

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
                  'Ringkasan Saya',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Statistik pribadi Customer Service',
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
                // PENANDA DATA DEMO
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF4FD),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 19,
                        color: AppTheme.primary,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Data simulasi. Ringkasan ini belum '
                          'terhubung dengan Laravel API.',
                          style: TextStyle(fontSize: 12, color: AppTheme.navy),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 17),

                const Text(
                  'Statistik Pesanan',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.navy,
                  ),
                ),

                const SizedBox(height: 12),

                // STATISTIK
                Row(
                  children: [
                    Expanded(
                      child: statCard(
                        'Total Pesanan',
                        '$totalOrders',
                        Icons.receipt_long_outlined,
                        AppTheme.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: statCard(
                        'Pesanan Valid',
                        '${validOrders.length}',
                        Icons.check_circle_outline,
                        const Color(0xFF0B8B65),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: statCard(
                        'Omzet Non-Batal',
                        rupiah(omzet),
                        Icons.payments_outlined,
                        AppTheme.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: statCard(
                        'Dibatalkan',
                        '$canceledOrders',
                        Icons.cancel_outlined,
                        const Color(0xFFB42332),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // DISTRIBUSI STATUS
                panel(
                  'Distribusi Status Pesanan',
                  Column(
                    children: statuses.map((status) {
                      final count = orders
                          .where((order) => order.status == status)
                          .length;

                      final percentage = totalOrders == 0
                          ? 0.0
                          : count / totalOrders;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 17),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    statusLabel(status),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  '$count pesanan',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 7),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: percentage,
                                minHeight: 9,
                                backgroundColor: const Color(0xFFEEF2F6),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  statusColor(status),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // RIWAYAT PESANAN
                panel(
                  'Riwayat Pesanan',
                  orders.isEmpty
                      ? const Text(
                          'Belum ada pesanan.',
                          style: TextStyle(color: Colors.black54),
                        )
                      : Column(
                          children: orders.map((order) {
                            return Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Color(0xFFEEF1F5)),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          order.number,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.navy,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        statusLabel(order.status),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: statusColor(order.status),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    order.buyer,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    rupiah(order.totalPrice),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                ),

                // IKLAN
                panel(
                  'Lead & Biaya Iklan',
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.campaign_outlined,
                        size: 34,
                        color: AppTheme.primary,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Data Advertiser belum tersedia',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 7),
                      Text(
                        'Lead, biaya iklan, CPC, CPO, '
                        'dan rasio konversi akan ditampilkan '
                        'setelah sistem Advertiser terintegrasi.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
