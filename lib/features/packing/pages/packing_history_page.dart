import 'package:flutter/material.dart';

import '../../../app/app_theme.dart';
import '../../../mock/mock_packing.dart';

class PackingHistoryPage extends StatefulWidget {
  const PackingHistoryPage({super.key});

  @override
  State<PackingHistoryPage> createState() => _PackingHistoryPageState();
}

class _PackingHistoryPageState extends State<PackingHistoryPage> {
  final store = PackingDemoStore.instance;
  final searchController = TextEditingController();

  String selectedChannel = 'SEMUA';
  DateTime? selectedDate;

  static const channels = ['SEMUA', 'META', 'SHOPEE', 'TIKTOK'];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  String twoDigits(int number) {
    return number.toString().padLeft(2, '0');
  }

  String formatDate(DateTime? date) {
    if (date == null) return '-';

    return '${twoDigits(date.day)}/'
        '${twoDigits(date.month)}/'
        '${date.year} '
        '${twoDigits(date.hour)}:'
        '${twoDigits(date.minute)}:'
        '${twoDigits(date.second)}';
  }

  String dateOnly(DateTime? date) {
    if (date == null) return '-';

    return '${twoDigits(date.day)}/'
        '${twoDigits(date.month)}/'
        '${date.year}';
  }

  bool isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  List<PackingOrder> get filteredOrders {
    final query = searchController.text.trim().toLowerCase();

    final orders = store.dispatchedOrders.where((order) {
      final matchesChannel =
          selectedChannel == 'SEMUA' || order.channel == selectedChannel;

      final searchable = [
        order.number,
        order.resi,
        order.buyer,
        order.channel,
        order.dispatchedBy ?? '',
        ...order.products.map((item) => item.name),
      ].join(' ').toLowerCase();

      final matchesSearch = query.isEmpty || searchable.contains(query);

      final matchesDate =
          selectedDate == null ||
          (order.dispatchedAt != null &&
              isSameDate(order.dispatchedAt!, selectedDate!));

      return matchesChannel && matchesSearch && matchesDate;
    }).toList();

    orders.sort((a, b) {
      final aDate = a.dispatchedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.dispatchedAt ?? DateTime.fromMillisecondsSinceEpoch(0);

      return bDate.compareTo(aDate);
    });

    return orders;
  }

  Future<void> chooseDate() async {
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: DateTime(2024),
      lastDate: now,
    );

    if (!mounted || date == null) return;

    setState(() {
      selectedDate = date;
    });
  }

  void resetFilters() {
    searchController.clear();

    setState(() {
      selectedChannel = 'SEMUA';
      selectedDate = null;
    });
  }

  Color channelColor(String channel) {
    switch (channel) {
      case 'META':
        return const Color(0xFF1873B4);
      case 'SHOPEE':
        return const Color(0xFFE76A22);
      case 'TIKTOK':
        return const Color(0xFF0F6970);
      default:
        return AppTheme.primary;
    }
  }

  Widget channelBadge(String channel) {
    final color = channelColor(channel);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        channel,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
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
            width: 112,
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

  void showDetail(PackingOrder order) {
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
          builder: (context, controller) {
            return Column(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Detail Riwayat Pengiriman',
                      style: TextStyle(
                        color: AppTheme.navy,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView(
                    controller: controller,
                    padding: const EdgeInsets.all(20),
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              order.resi,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.navy,
                              ),
                            ),
                          ),
                          channelBadge(order.channel),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF7F0),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.check_circle, color: Color(0xFF0B8B65)),
                            SizedBox(width: 9),
                            Expanded(
                              child: Text(
                                'Dikirim Internal',
                                style: TextStyle(
                                  color: Color(0xFF0B8B65),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Informasi Pengiriman',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      detailRow('Nomor Resi', order.resi),
                      detailRow('Pesanan', order.number),
                      detailRow('Channel', order.channel),
                      detailRow('Petugas', order.dispatchedBy ?? '-'),
                      detailRow('Waktu Kirim', formatDate(order.dispatchedAt)),
                      const Divider(height: 28),
                      const Text(
                        'Informasi Pembeli',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      detailRow('Nama', order.buyer),
                      detailRow('No. HP', order.phone),
                      detailRow('Alamat', order.address),
                      const Divider(height: 28),
                      const Text(
                        'Rincian Produk',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...order.products.map(
                        (product) => Container(
                          margin: const EdgeInsets.only(bottom: 9),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F6FA),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                product.variant,
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Jumlah: ${product.quantity} pcs',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (order.isMeta) ...[
                        const Divider(height: 28),
                        detailRow('Foto Meta', '${order.photos.length} foto'),
                        detailRow(
                          'Selesai Packing',
                          formatDate(order.packedAt),
                        ),
                      ],
                      const SizedBox(height: 12),
                      const Text(
                        'Status Dikirim Internal tidak berarti '
                        'paket sudah diterima ekspedisi '
                        'atau pembeli.',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 11,
                          height: 1.5,
                        ),
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
                        onPressed: () => Navigator.pop(sheetContext),
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

  Widget historyCard(PackingOrder order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
                        order.resi,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.navy,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    channelBadge(order.channel),
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
                const SizedBox(height: 6),
                Text(
                  'Pesanan: ${order.number}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF61758A),
                  ),
                ),
                const SizedBox(height: 11),
                const Divider(height: 1),
                const SizedBox(height: 11),
                detailRow('Petugas', order.dispatchedBy ?? '-'),
                detailRow('Waktu', formatDate(order.dispatchedAt)),
                const SizedBox(height: 7),
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFF0B8B65),
                      size: 16,
                    ),
                    const SizedBox(width: 5),
                    const Expanded(
                      child: Text(
                        'Dikirim Internal',
                        style: TextStyle(
                          color: Color(0xFF0B8B65),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Text(
                      'Lihat Detail',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: AppTheme.primary,
                      size: 18,
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
                  'Riwayat Pengiriman',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Pesanan yang sudah diproses secara internal',
                  style: TextStyle(fontSize: 12, color: Color(0xFFD2E5F7)),
                ),
              ],
            ),
          ),
          Expanded(
            child: AnimatedBuilder(
              animation: store,
              builder: (context, _) {
                final orders = filteredOrders;
                final totalSent = store.dispatchedOrders.length;

                return ListView(
                  padding: const EdgeInsets.all(15),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5EBF2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.local_shipping_outlined,
                            color: Color(0xFF0B8B65),
                            size: 31,
                          ),
                          const SizedBox(width: 13),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$totalSent',
                                  style: const TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.navy,
                                  ),
                                ),
                                const Text(
                                  'Resi Dikirim Internal',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // PENCARIAN DAN FILTER
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
                              hintText: 'Cari resi / nomor / pembeli...',
                              hintStyle: const TextStyle(fontSize: 12),
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: searchController.text.isEmpty
                                  ? null
                                  : IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () {
                                        searchController.clear();
                                        setState(() {});
                                      },
                                    ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            key: ValueKey(selectedChannel),
                            initialValue: selectedChannel,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Filter Channel',
                              prefixIcon: Icon(Icons.storefront_outlined),
                            ),
                            items: channels.map((channel) {
                              return DropdownMenuItem(
                                value: channel,
                                child: Text(
                                  channel == 'SEMUA'
                                      ? 'Semua Channel'
                                      : channel,
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  selectedChannel = value;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: chooseDate,
                            icon: const Icon(Icons.calendar_month_outlined),
                            label: Text(
                              selectedDate == null
                                  ? 'Filter Tanggal Pengiriman'
                                  : dateOnly(selectedDate),
                            ),
                          ),
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
                            'Daftar Riwayat',
                            style: TextStyle(
                              color: AppTheme.navy,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          '${orders.length} resi',
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
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
                            Icon(Icons.history, size: 45, color: Colors.grey),
                            SizedBox(height: 12),
                            Text(
                              'Belum ada riwayat pengiriman',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 7),
                            Text(
                              'Resi yang berhasil diproses '
                              'melalui Scan Kirim akan muncul di sini.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ...orders.map(historyCard),

                    const SizedBox(height: 12),
                    const Center(
                      child: Text(
                        'Riwayat simulasi lokal — belum tersimpan '
                        'di Laravel API',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black45, fontSize: 11),
                      ),
                    ),
                    const SizedBox(height: 25),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
