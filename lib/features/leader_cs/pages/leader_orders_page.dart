import 'package:flutter/material.dart';

import '../../../app/app_theme.dart';

// MODEL KHUSUS DATA DEMO LEADER CS
class _LeaderOrder {
  final String number;
  final String cs;
  final String buyer;
  final String phone;
  final String product;
  final int quantity;
  final int totalPrice;
  final String status;
  final String payment;
  final String address;
  final String date;
  final String note;

  const _LeaderOrder({
    required this.number,
    required this.cs,
    required this.buyer,
    required this.phone,
    required this.product,
    required this.quantity,
    required this.totalPrice,
    required this.status,
    required this.payment,
    required this.address,
    required this.date,
    this.note = '',
  });
}

class LeaderOrdersPage extends StatefulWidget {
  const LeaderOrdersPage({super.key});

  @override
  State<LeaderOrdersPage> createState() => _LeaderOrdersPageState();
}

class _LeaderOrdersPageState extends State<LeaderOrdersPage> {
  final searchController = TextEditingController();

  String selectedCs = 'semua';
  String selectedStatus = 'semua';

  // Semua data masih simulasi.
  static const List<_LeaderOrder> demoOrders = [
    _LeaderOrder(
      number: '261112001A',
      cs: 'ELSA',
      buyer: 'Pelanggan A',
      phone: '6281234500001',
      product: 'Emblem Akrilik Timbul Custom',
      quantity: 1,
      totalPrice: 150000,
      status: 'proses',
      payment: 'DP',
      address: 'Kediri, Jawa Timur',
      date: '12/11/2026',
      note: 'Warna gold, logo custom',
    ),
    _LeaderOrder(
      number: '261112002A',
      cs: 'IZA',
      buyer: 'Pelanggan B',
      phone: '6281234500002',
      product: 'Gantungan Kunci Akrilik Custom',
      quantity: 3,
      totalPrice: 85000,
      status: 'kirim',
      payment: 'COD',
      address: 'Nganjuk, Jawa Timur',
      date: '12/11/2026',
    ),
    _LeaderOrder(
      number: '261112003A',
      cs: 'EVA',
      buyer: 'Pelanggan C',
      phone: '6281234500003',
      product: 'Stiker Kaca Mobil Custom',
      quantity: 2,
      totalPrice: 120000,
      status: 'selesai',
      payment: 'NON COD',
      address: 'Blitar, Jawa Timur',
      date: '12/11/2026',
    ),
    _LeaderOrder(
      number: '261111004A',
      cs: 'MAYA',
      buyer: 'Pelanggan D',
      phone: '6281234500004',
      product: 'Kaligrafi Allah Muhammad',
      quantity: 1,
      totalPrice: 175000,
      status: 'batal',
      payment: 'COD',
      address: 'Tulungagung, Jawa Timur',
      date: '11/11/2026',
    ),
    _LeaderOrder(
      number: '261111005A',
      cs: 'ELSA',
      buyer: 'Pelanggan E',
      phone: '6281234500005',
      product: 'Mihrab Minimalis',
      quantity: 1,
      totalPrice: 450000,
      status: 'pengembalian',
      payment: 'DP',
      address: 'Malang, Jawa Timur',
      date: '11/11/2026',
    ),
    _LeaderOrder(
      number: '261110006A',
      cs: 'IZA',
      buyer: 'Pelanggan F',
      phone: '6281234500006',
      product: 'Emblem UV Universal',
      quantity: 2,
      totalPrice: 195000,
      status: 'pengiriman_gagal',
      payment: 'COD',
      address: 'Surabaya, Jawa Timur',
      date: '10/11/2026',
    ),
  ];

  static const statuses = [
    'semua',
    'proses',
    'kirim',
    'selesai',
    'batal',
    'pengembalian',
    'pengiriman_gagal',
  ];

  static const csNames = ['semua', 'ELSA', 'IZA', 'EVA', 'MAYA'];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  String rupiah(int value) {
    final formatted = value.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
    return 'Rp$formatted';
  }

  String statusLabel(String value) {
    switch (value) {
      case 'proses':
        return 'Proses';
      case 'kirim':
        return 'Dikirim';
      case 'selesai':
        return 'Selesai';
      case 'batal':
        return 'Batal';
      case 'pengembalian':
        return 'Pengembalian';
      case 'pengiriman_gagal':
        return 'Pengiriman Gagal';
      default:
        return 'Semua Status';
    }
  }

  Color statusColor(String value) {
    switch (value) {
      case 'proses':
        return const Color(0xFFA65A04);
      case 'kirim':
        return const Color(0xFF1873B4);
      case 'selesai':
        return const Color(0xFF0B8B65);
      case 'batal':
        return const Color(0xFFB42332);
      case 'pengembalian':
        return const Color(0xFF8055B4);
      case 'pengiriman_gagal':
        return const Color(0xFFC04F37);
      default:
        return Colors.grey;
    }
  }

  List<_LeaderOrder> get filteredOrders {
    final query = searchController.text.trim().toLowerCase();

    return demoOrders.where((order) {
      final searchMatches =
          query.isEmpty ||
          order.number.toLowerCase().contains(query) ||
          order.buyer.toLowerCase().contains(query) ||
          order.phone.contains(query);

      final csMatches = selectedCs == 'semua' || order.cs == selectedCs;

      final statusMatches =
          selectedStatus == 'semua' || order.status == selectedStatus;

      return searchMatches && csMatches && statusMatches;
    }).toList();
  }

  void resetFilters() {
    searchController.clear();

    setState(() {
      selectedCs = 'semua';
      selectedStatus = 'semua';
    });
  }

  Widget statusBadge(String status) {
    final color = statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        statusLabel(status),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void showDetail(_LeaderOrder order) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      showDragHandle: true,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.80,
          minChildSize: 0.40,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Column(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Detail Pesanan',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.navy,
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              order.number,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.navy,
                              ),
                            ),
                          ),
                          statusBadge(order.status),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Identitas Pesanan',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      detailRow('Tanggal', order.date),
                      detailRow('CS', order.cs),
                      const Divider(height: 30),
                      const Text(
                        'Informasi Pembeli',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      detailRow('Nama', order.buyer),
                      detailRow('No. HP', order.phone),
                      detailRow('Alamat', order.address),
                      const Divider(height: 30),
                      const Text(
                        'Informasi Produk',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      detailRow('Produk', order.product),
                      detailRow('Jumlah', '${order.quantity} pcs'),
                      const Divider(height: 30),
                      const Text(
                        'Pembayaran',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      detailRow('Metode', order.payment),
                      detailRow('Total Harga', rupiah(order.totalPrice)),
                      if (order.note.isNotEmpty) ...[
                        const Divider(height: 30),
                        const Text(
                          'Catatan Pesanan',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(order.note),
                      ],
                      const SizedBox(height: 20),
                      const Text(
                        'Data ini hanya simulasi.',
                        style: TextStyle(fontSize: 11, color: Colors.black45),
                      ),
                    ],
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          Navigator.pop(sheetContext);
                        },
                        child: const Text('Tutup Detail'),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget orderCard(_LeaderOrder order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5EBF2)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => showDetail(order),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        order.number,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.navy,
                        ),
                      ),
                    ),
                    statusBadge(order.status),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  order.buyer,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  order.product,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF61758A),
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: 16,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        'CS: ${order.cs}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                    Text(
                      rupiah(order.totalPrice),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.navy,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 13,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      order.date,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'Lihat Detail',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary,
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: AppTheme.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orders = filteredOrders;

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
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kelola Pesanan',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Monitoring pesanan seluruh tim CS',
                  style: TextStyle(fontSize: 12, color: Color(0xFFD2E5F7)),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(15),
              children: [
                // PANEL FILTER
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5EBF2)),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: searchController,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Cari nomor / nama / telepon...',
                          hintStyle: const TextStyle(fontSize: 12),
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

                      DropdownButtonFormField<String>(
                        key: ValueKey('cs-$selectedCs'),
                        initialValue: selectedCs,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Filter CS',
                          prefixIcon: Icon(Icons.groups_outlined),
                        ),
                        items: csNames.map((name) {
                          return DropdownMenuItem(
                            value: name,
                            child: Text(name == 'semua' ? 'Semua CS' : name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => selectedCs = value);
                          }
                        },
                      ),

                      const SizedBox(height: 12),

                      DropdownButtonFormField<String>(
                        key: ValueKey('status-$selectedStatus'),
                        initialValue: selectedStatus,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Filter Status',
                          prefixIcon: Icon(Icons.filter_list),
                        ),
                        items: statuses.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(statusLabel(status)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => selectedStatus = value);
                          }
                        },
                      ),

                      const SizedBox(height: 8),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: resetFilters,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reset Filter'),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Daftar Pesanan',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.navy,
                        ),
                      ),
                    ),
                    Text(
                      '${orders.length} pesanan',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                if (orders.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.search_off_outlined,
                          size: 45,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Pesanan tidak ditemukan',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Coba ubah pencarian atau filter.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black54, fontSize: 12),
                        ),
                      ],
                    ),
                  )
                else
                  ...orders.map(orderCard),

                const SizedBox(height: 15),

                const Center(
                  child: Text(
                    'Data simulasi — belum terhubung API',
                    style: TextStyle(fontSize: 11, color: Colors.black45),
                  ),
                ),

                const SizedBox(height: 15),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
