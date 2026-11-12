import 'package:flutter/material.dart';

import '../../../app/app_theme.dart';
import '../../../mock/mock_orders.dart';
import '../../orders/models/order_model.dart';

class CsOrdersPage extends StatefulWidget {
  final VoidCallback onAddOrder;

  const CsOrdersPage({super.key, required this.onAddOrder});

  @override
  State<CsOrdersPage> createState() => _CsOrdersPageState();
}

class _CsOrdersPageState extends State<CsOrdersPage> {
  final searchController = TextEditingController();
  String selectedStatus = 'semua';

  static const statuses = [
    'semua',
    'proses',
    'packing',
    'kirim',
    'selesai',
    'batal',
  ];

  List<OrderModel> get filteredOrders {
    final keyword = searchController.text.trim().toLowerCase();

    final results = MockOrders.csOrders.where((order) {
      final matchesSearch =
          keyword.isEmpty ||
          order.number.toLowerCase().contains(keyword) ||
          order.buyer.toLowerCase().contains(keyword) ||
          order.phone.contains(keyword);

      final matchesStatus =
          selectedStatus == 'semua' || order.status == selectedStatus;

      return matchesSearch && matchesStatus;
    }).toList();

    results.sort((a, b) => b.orderDate.compareTo(a.orderDate));

    return results;
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  String rupiah(int amount) {
    final digits = amount.toString();
    final formatted = digits.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
    return 'Rp$formatted';
  }

  String formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
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

  void showOrderDetail(OrderModel order) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: FractionallySizedBox(
            heightFactor: 0.85,
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD6E0EA),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 18),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Detail Pesanan',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.navy,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 25),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              order.number,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          _StatusBadge(
                            label: statusLabel(order.status),
                            color: statusColor(order.status),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Tanggal order: ${formatDate(order.orderDate)}',
                        style: const TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 24),
                      const _SectionTitle('Informasi Pembeli'),
                      _DetailRow('Nama', order.buyer),
                      _DetailRow('No. HP', order.phone),
                      _DetailRow('Alamat', order.address),
                      const SizedBox(height: 20),
                      const _SectionTitle('Informasi Produk'),
                      _DetailRow('Produk', order.product),
                      _DetailRow('Jumlah', '${order.quantity} pcs'),
                      const SizedBox(height: 20),
                      const _SectionTitle('Pembayaran'),
                      _DetailRow('Metode', order.paymentMethod),
                      _DetailRow('Total Harga', rupiah(order.totalPrice)),
                      if (order.note.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        const _SectionTitle('Catatan Pesanan'),
                        Text(order.note),
                      ],
                      const SizedBox(height: 24),
                      const Text(
                        'Detail ini menggunakan data simulasi.',
                        style: TextStyle(fontSize: 12, color: Colors.black45),
                      ),
                    ],
                  ),
                ),
                Padding(
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
              ],
            ),
          ),
        );
      },
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
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 22),
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
                  'Pesanan Saya',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Lihat dan kelola pesanan Meta milikmu',
                  style: TextStyle(color: Color(0xFFD2E5F7), fontSize: 12),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(15),
              children: [
                // TOMBOL TAMBAH
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: widget.onAddOrder,
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Tambah Pesanan'),
                  ),
                ),

                const SizedBox(height: 16),

                // PENCARIAN
                TextField(
                  controller: searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Cari nomor / nama / telepon...',
                    hintStyle: const TextStyle(fontSize: 13),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchController.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Hapus pencarian',
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              searchController.clear();
                              setState(() {});
                            },
                          ),
                  ),
                ),

                const SizedBox(height: 12),

                // FILTER STATUS
                DropdownButtonFormField<String>(
                  initialValue: selectedStatus,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Filter Status',
                    prefixIcon: Icon(Icons.filter_list),
                  ),
                  items: statuses.map((status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(
                        status == 'semua'
                            ? 'Semua Status'
                            : statusLabel(status),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedStatus = value;
                      });
                    }
                  },
                ),

                const SizedBox(height: 18),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Daftar Pesanan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.navy,
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

                // HASIL PENCARIAN
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
                          size: 44,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Pesanan tidak ditemukan',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Coba ubah kata pencarian atau filter.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black54, fontSize: 12),
                        ),
                      ],
                    ),
                  )
                else
                  ...orders.map(
                    (order) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _OrderCard(
                        order: order,
                        date: formatDate(order.orderDate),
                        price: rupiah(order.totalPrice),
                        statusLabel: statusLabel(order.status),
                        statusColor: statusColor(order.status),
                        onTap: () => showOrderDetail(order),
                      ),
                    ),
                  ),

                const SizedBox(height: 12),

                const Center(
                  child: Text(
                    'Data simulasi — belum terhubung API',
                    style: TextStyle(fontSize: 11, color: Colors.black45),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// KARTU PESANAN
class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final String date;
  final String price;
  final String statusLabel;
  final Color statusColor;
  final VoidCallback onTap;

  const _OrderCard({
    required this.order,
    required this.date,
    required this.price,
    required this.statusLabel,
    required this.statusColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
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
                      order.number,
                      style: const TextStyle(
                        color: AppTheme.navy,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  _StatusBadge(label: statusLabel, color: statusColor),
                ],
              ),
              const SizedBox(height: 11),
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
                style: const TextStyle(fontSize: 12, color: Color(0xFF61758A)),
              ),
              const SizedBox(height: 13),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    date,
                    style: const TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                  const Spacer(),
                  Text(
                    price,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.navy,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 11),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Lihat Detail',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_right,
                    size: 17,
                    color: AppTheme.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: AppTheme.navy,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
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
}
