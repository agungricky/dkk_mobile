import 'package:flutter/material.dart';

import '../../../app/app_theme.dart';

// MODEL DATA DEMO PERFORMA CS
class _CsPerformance {
  final String name;
  final int process;
  final int shipping;
  final int completed;
  final int canceled;
  final int revenue;

  const _CsPerformance({
    required this.name,
    required this.process,
    required this.shipping,
    required this.completed,
    required this.canceled,
    required this.revenue,
  });

  int get totalOrders => process + shipping + completed + canceled;

  int get validOrders => totalOrders - canceled;
}

class LeaderPerformancePage extends StatefulWidget {
  const LeaderPerformancePage({super.key});

  @override
  State<LeaderPerformancePage> createState() => _LeaderPerformancePageState();
}

class _LeaderPerformancePageState extends State<LeaderPerformancePage> {
  final searchController = TextEditingController();

  String selectedPeriod = 'november';

  // DATA SIMULASI NOVEMBER 2026
  // Total 60 pesanan, omzet contoh Rp8.900.000.
  static const novemberData = <_CsPerformance>[
    _CsPerformance(
      name: 'ELSA',
      process: 5,
      shipping: 7,
      completed: 5,
      canceled: 1,
      revenue: 2800000,
    ),
    _CsPerformance(
      name: 'IZA',
      process: 4,
      shipping: 6,
      completed: 4,
      canceled: 1,
      revenue: 2300000,
    ),
    _CsPerformance(
      name: 'EVA',
      process: 4,
      shipping: 5,
      completed: 4,
      canceled: 1,
      revenue: 2000000,
    ),
    _CsPerformance(
      name: 'MAYA',
      process: 3,
      shipping: 5,
      completed: 4,
      canceled: 1,
      revenue: 1800000,
    ),
  ];

  // DATA SIMULASI OKTOBER 2026
  static const octoberData = <_CsPerformance>[
    _CsPerformance(
      name: 'ELSA',
      process: 3,
      shipping: 4,
      completed: 4,
      canceled: 1,
      revenue: 1800000,
    ),
    _CsPerformance(
      name: 'IZA',
      process: 3,
      shipping: 4,
      completed: 3,
      canceled: 1,
      revenue: 1600000,
    ),
    _CsPerformance(
      name: 'EVA',
      process: 2,
      shipping: 4,
      completed: 3,
      canceled: 1,
      revenue: 1500000,
    ),
    _CsPerformance(
      name: 'MAYA',
      process: 2,
      shipping: 3,
      completed: 3,
      canceled: 1,
      revenue: 1300000,
    ),
  ];

  List<_CsPerformance> get periodData {
    return selectedPeriod == 'november' ? novemberData : octoberData;
  }

  List<_CsPerformance> get filteredData {
    final query = searchController.text.trim().toLowerCase();

    return periodData
        .where((item) => item.name.toLowerCase().contains(query))
        .toList();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  String rupiah(int value) {
    final result = value.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
    return 'Rp$result';
  }

  String monthLabel() {
    return selectedPeriod == 'november' ? 'November 2026' : 'Oktober 2026';
  }

  Widget statCard(String label, String value, IconData icon, Color color) {
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
          Icon(icon, color: color, size: 23),
          const SizedBox(height: 12),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppTheme.navy,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(color: Color(0xFF708095), fontSize: 11),
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
              color: AppTheme.navy,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  Widget progressRow(
    String label,
    int value,
    int maximum, {
    Color color = AppTheme.primary,
  }) {
    final percentage = maximum == 0 ? 0.0 : value / maximum;

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              Text(
                '$value pesanan',
                style: const TextStyle(color: Colors.black54, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 9,
              backgroundColor: const Color(0xFFEEF2F6),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget statusItem(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          '$label $count',
          style: const TextStyle(fontSize: 11, color: Color(0xFF61758A)),
        ),
      ],
    );
  }

  Widget performanceCard(_CsPerformance item) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
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
              CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFFE8F3FB),
                child: Text(
                  item.name.substring(0, 1),
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        color: AppTheme.navy,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Customer Service',
                      style: TextStyle(fontSize: 11, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF4FD),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${item.totalOrders} Order',
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Text(
            'Omzet Non-Batal',
            style: TextStyle(fontSize: 11, color: Color(0xFF708095)),
          ),
          const SizedBox(height: 6),
          Text(
            rupiah(item.revenue),
            style: const TextStyle(
              color: AppTheme.navy,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 13),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Pesanan Valid: ${item.validOrders}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                'Batal: ${item.canceled}',
                style: const TextStyle(
                  color: Color(0xFFB42332),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Wrap(
            spacing: 13,
            runSpacing: 9,
            children: [
              statusItem('Proses', item.process, const Color(0xFFA65A04)),
              statusItem('Kirim', item.shipping, const Color(0xFF1873B4)),
              statusItem('Selesai', item.completed, const Color(0xFF0B8B65)),
              statusItem('Batal', item.canceled, const Color(0xFFB42332)),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F6FA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'Lead dan closing rate belum tersedia. '
              'Menunggu integrasi data Advertiser.',
              style: TextStyle(fontSize: 11, color: Color(0xFF61758A)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = periodData;
    final results = filteredData;

    final totalOrders = data.fold<int>(
      0,
      (sum, item) => sum + item.totalOrders,
    );

    final totalRevenue = data.fold<int>(0, (sum, item) => sum + item.revenue);

    final totalCanceled = data.fold<int>(0, (sum, item) => sum + item.canceled);

    final totalProcess = data.fold<int>(0, (sum, item) => sum + item.process);

    final totalShipping = data.fold<int>(0, (sum, item) => sum + item.shipping);

    final totalCompleted = data.fold<int>(
      0,
      (sum, item) => sum + item.completed,
    );

    final maxOrders = data.fold<int>(
      0,
      (maxValue, item) =>
          item.totalOrders > maxValue ? item.totalOrders : maxValue,
    );

    return SafeArea(
      child: Column(
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
                  'Performa CS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Monitoring kinerja seluruh tim Meta',
                  style: TextStyle(color: Color(0xFFD2E5F7), fontSize: 12),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(15),
              children: [
                // FILTER PERIODE
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5EBF2)),
                  ),
                  child: DropdownButtonFormField<String>(
                    key: ValueKey(selectedPeriod),
                    initialValue: selectedPeriod,
                    decoration: const InputDecoration(
                      labelText: 'Periode Laporan',
                      prefixIcon: Icon(Icons.calendar_month_outlined),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'november',
                        child: Text('November 2026'),
                      ),
                      DropdownMenuItem(
                        value: 'oktober',
                        child: Text('Oktober 2026'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedPeriod = value;
                        });
                      }
                    },
                  ),
                ),

                const SizedBox(height: 14),

                Container(
                  padding: const EdgeInsets.all(12),
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
                          'Data performa masih simulasi. '
                          'Belum terhubung Laravel API.',
                          style: TextStyle(fontSize: 12, color: AppTheme.navy),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  'Ringkasan ${monthLabel()}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.navy,
                  ),
                ),

                const SizedBox(height: 12),

                // STATISTIK TIM
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
                        'Omzet Non-Batal',
                        rupiah(totalRevenue),
                        Icons.payments_outlined,
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
                        'Jumlah CS',
                        '${data.length}',
                        Icons.groups_outlined,
                        AppTheme.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: statCard(
                        'Dibatalkan',
                        '$totalCanceled',
                        Icons.cancel_outlined,
                        const Color(0xFFB42332),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // GRAFIK PERFORMA
                panel(
                  'Perbandingan Pesanan CS',
                  Column(
                    children: data.map((item) {
                      return progressRow(
                        item.name,
                        item.totalOrders,
                        maxOrders,
                      );
                    }).toList(),
                  ),
                ),

                // DISTRIBUSI STATUS
                panel(
                  'Status Pesanan Tim',
                  Column(
                    children: [
                      progressRow(
                        'Proses',
                        totalProcess,
                        totalOrders,
                        color: const Color(0xFFA65A04),
                      ),
                      progressRow(
                        'Kirim',
                        totalShipping,
                        totalOrders,
                        color: const Color(0xFF1873B4),
                      ),
                      progressRow(
                        'Selesai',
                        totalCompleted,
                        totalOrders,
                        color: const Color(0xFF0B8B65),
                      ),
                      progressRow(
                        'Batal',
                        totalCanceled,
                        totalOrders,
                        color: const Color(0xFFB42332),
                      ),
                    ],
                  ),
                ),

                // DAFTAR PERFORMA
                const Text(
                  'Performa Per CS',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.navy,
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Cari nama Customer Service...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchController.text.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              searchController.clear();
                              setState(() {});
                            },
                            icon: const Icon(Icons.close),
                          ),
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  '${results.length} CS ditemukan',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),

                const SizedBox(height: 12),

                if (results.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.search_off_outlined,
                          size: 42,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Customer Service tidak ditemukan',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else
                  ...results.map(performanceCard),

                // LEAD DAN BIAYA IKLAN
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
                      SizedBox(height: 12),
                      Text(
                        'Belum terhubung ke Advertiser',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Jumlah lead, biaya iklan, CPC, '
                        'CPO, dan closing rate belum tersedia. '
                        'Data akan diperoleh dari sistem '
                        'Advertiser setelah integrasi API.',
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.5,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
