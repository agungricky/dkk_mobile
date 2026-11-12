import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/app_theme.dart';
import '../../../mock/mock_packing.dart';

class PackingPhotoPage extends StatefulWidget {
  const PackingPhotoPage({super.key});

  @override
  State<PackingPhotoPage> createState() => _PackingPhotoPageState();
}

class _PackingPhotoPageState extends State<PackingPhotoPage> {
  final store = PackingDemoStore.instance;
  final searchController = TextEditingController();

  String selectedGroup = 'Semua Grup';

  static const groups = ['Semua Grup', 'Akrilik', 'Stiker', 'Kaligrafi'];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  String statusLabel(String status) {
    switch (status) {
      case 'difoto':
        return 'Sudah Difoto';
      case 'dipacking':
        return 'Siap Dikirim';
      case 'dikirim':
        return 'Dikirim';
      default:
        return 'Menunggu Foto';
    }
  }

  Color statusColor(String status) {
    switch (status) {
      case 'difoto':
        return const Color(0xFF1873B4);
      case 'dipacking':
        return const Color(0xFF0B8B65);
      case 'dikirim':
        return const Color(0xFF6956B5);
      default:
        return const Color(0xFFA65A04);
    }
  }

  List<PackingOrder> get filteredOrders {
    final query = searchController.text.trim().toLowerCase();

    return store.metaOrders.where((order) {
      // Pesanan yang sudah dikirim tidak masuk antrean foto.
      if (order.isDispatched) return false;

      final matchesGroup =
          selectedGroup == 'Semua Grup' || order.group == selectedGroup;

      final searchable = [
        order.number,
        order.buyer,
        order.resi,
        order.group,
        ...order.products.map((item) => item.name),
      ].join(' ').toLowerCase();

      final matchesSearch = query.isEmpty || searchable.contains(query);

      return matchesGroup && matchesSearch;
    }).toList();
  }

  void openDetail(PackingOrder order) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PackingPhotoDetailPage(order: order)),
    );
  }

  Widget statusBadge(String status) {
    final color = statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        statusLabel(status),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget orderCard(PackingOrder order) {
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
          onTap: () => openDetail(order),
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
                          color: AppTheme.navy,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
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
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  order.products.map((item) => item.name).join(', '),
                  style: const TextStyle(
                    color: Color(0xFF61758A),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Resi: ${order.resi}',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.category_outlined,
                      color: AppTheme.primary,
                      size: 17,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        order.group,
                        style: const TextStyle(
                          color: AppTheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '${order.photos.length} Foto',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right, color: AppTheme.primary),
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
                  'Foto Packing Meta',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Foto barang sebelum dipacking',
                  style: TextStyle(color: Color(0xFFD2E5F7), fontSize: 12),
                ),
              ],
            ),
          ),
          Expanded(
            child: AnimatedBuilder(
              animation: store,
              builder: (context, _) {
                final orders = filteredOrders;

                return ListView(
                  padding: const EdgeInsets.all(15),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(13),
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
                              'Hanya pesanan Meta. '
                              'Foto barang sebelum dibungkus, '
                              'lalu konfirmasi selesai packing.',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.navy,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
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
                              hintText: 'Nomor pesanan / pembeli / resi',
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
                          const SizedBox(height: 13),
                          DropdownButtonFormField<String>(
                            key: ValueKey(selectedGroup),
                            initialValue: selectedGroup,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Kelompok Produk',
                              prefixIcon: Icon(Icons.category_outlined),
                            ),
                            items: groups.map((group) {
                              return DropdownMenuItem(
                                value: group,
                                child: Text(group),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  selectedGroup = value;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Antrean Foto Meta',
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
                    const SizedBox(height: 13),
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
                              Icons.inventory_2_outlined,
                              size: 42,
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
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ...orders.map(orderCard),
                    const SizedBox(height: 15),
                    const Center(
                      child: Text(
                        'Data demo — belum terhubung API',
                        style: TextStyle(fontSize: 11, color: Colors.black45),
                      ),
                    ),
                    const SizedBox(height: 20),
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

// HALAMAN DETAIL DAN FOTO BARANG
class PackingPhotoDetailPage extends StatefulWidget {
  final PackingOrder order;

  const PackingPhotoDetailPage({super.key, required this.order});

  @override
  State<PackingPhotoDetailPage> createState() => _PackingPhotoDetailPageState();
}

class _PackingPhotoDetailPageState extends State<PackingPhotoDetailPage> {
  final store = PackingDemoStore.instance;
  final picker = ImagePicker();

  PackingOrder get order => widget.order;

  void message(String value) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(value), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> takeCameraPhoto() async {
    if (order.isPacked || order.isDispatched) return;

    try {
      final photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100,
      );

      if (!mounted || photo == null) return;

      store.addPhotos(order, [photo]);
    } catch (error) {
      message('Gagal membuka kamera: $error');
    }
  }

  Future<void> pickGalleryPhotos() async {
    if (order.isPacked || order.isDispatched) return;

    try {
      final photos = await picker.pickMultiImage(imageQuality: 100);

      if (!mounted || photos.isEmpty) return;

      store.addPhotos(order, photos);
    } catch (error) {
      message('Gagal memilih foto: $error');
    }
  }

  Future<void> confirmPacking() async {
    if (order.photos.isEmpty) {
      message('Foto barang wajib ditambahkan terlebih dahulu.');
      return;
    }

    if (order.isPacked || order.isDispatched) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Packing'),
          content: Text(
            'Pastikan seluruh produk pesanan '
            '${order.number} sudah diperiksa, '
            'difoto, dan selesai dipacking.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Ya, Sudah Dipacking'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) return;

    final success = store.confirmPacking(order);

    if (success) {
      message('Packing berhasil dikonfirmasi (demo).');
    } else {
      message('Konfirmasi packing tidak dapat diproses.');
    }
  }

  Widget infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              title,
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
          const SizedBox(height: 13),
          content,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Detail Packing Meta'),
        backgroundColor: AppTheme.navy,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: store,
          builder: (context, _) {
            final locked = order.isPacked || order.isDispatched;

            return ListView(
              padding: const EdgeInsets.all(15),
              children: [
                panel(
                  'Identitas Pesanan',
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      infoRow('Nomor', order.number),
                      infoRow('Pembeli', order.buyer),
                      infoRow('No. HP', order.phone),
                      infoRow('Alamat', order.address),
                      infoRow('No. Resi', order.resi),
                      infoRow('Channel', order.channel),
                      infoRow('Kelompok', order.group),
                      infoRow(
                        'Status',
                        order.isPacked
                            ? 'Siap Dikirim'
                            : order.isDispatched
                            ? 'Dikirim'
                            : order.photos.isNotEmpty
                            ? 'Sudah Difoto'
                            : 'Menunggu Foto',
                      ),
                    ],
                  ),
                ),
                panel(
                  'Rincian Produk',
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: order.products.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '${item.variant} • ${item.quantity} pcs',
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                            const Divider(height: 20),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                panel(
                  'Foto Barang Sebelum Packing',
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Foto kondisi barang asli sebelum dibungkus.',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                      const SizedBox(height: 15),
                      if (!locked) ...[
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: takeCameraPhoto,
                            icon: const Icon(Icons.camera_alt_outlined),
                            label: const Text('Ambil dari Kamera'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: pickGalleryPhotos,
                            icon: const Icon(Icons.photo_library_outlined),
                            label: const Text('Pilih dari Galeri'),
                          ),
                        ),
                      ],
                      const SizedBox(height: 13),
                      Text(
                        '${order.photos.length} foto dipilih',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (order.photos.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 15),
                          child: Center(
                            child: Text(
                              'Belum ada foto barang.',
                              style: TextStyle(
                                color: Colors.black45,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        )
                      else
                        Wrap(
                          spacing: 9,
                          runSpacing: 9,
                          children: order.photos.map((photo) {
                            return Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    File(photo.path),
                                    width: 94,
                                    height: 94,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                if (!locked)
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: InkWell(
                                      onTap: () {
                                        store.removePhoto(order, photo);
                                      },
                                      child: const CircleAvatar(
                                        radius: 12,
                                        backgroundColor: Colors.red,
                                        child: Icon(
                                          Icons.close,
                                          size: 15,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          }).toList(),
                        ),
                      const SizedBox(height: 17),
                      if (locked)
                        Container(
                          padding: const EdgeInsets.all(13),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF7F0),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Color(0xFF0B8B65),
                              ),
                              SizedBox(width: 9),
                              Expanded(
                                child: Text(
                                  'Packing telah dikonfirmasi. '
                                  'Foto tidak dapat diubah.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF0B8B65),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: confirmPacking,
                            icon: const Icon(Icons.inventory_2_outlined),
                            label: const Text('Konfirmasi Sudah Dipacking'),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'Foto dan status hanya tersimpan '
                    'sementara selama sesi demo.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: Colors.black45),
                  ),
                ),
                const SizedBox(height: 25),
              ],
            );
          },
        ),
      ),
    );
  }
}
