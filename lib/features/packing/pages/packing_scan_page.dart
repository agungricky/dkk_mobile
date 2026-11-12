import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../app/app_theme.dart';
import '../../../mock/mock_packing.dart';

class PackingScanPage extends StatefulWidget {
  const PackingScanPage({super.key});

  @override
  State<PackingScanPage> createState() => _PackingScanPageState();
}

class _PackingScanPageState extends State<PackingScanPage> {
  final store = PackingDemoStore.instance;
  final resiController = TextEditingController();

  bool processing = false;
  String? lastSuccessResi;

  @override
  void dispose() {
    resiController.dispose();
    super.dispose();
  }

  void message(String value) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(value), behavior: SnackBarBehavior.floating),
    );
  }

  String formatDate(DateTime? date) {
    if (date == null) return '-';

    String two(int value) => value.toString().padLeft(2, '0');

    return '${two(date.day)}/${two(date.month)}/${date.year} '
        '${two(date.hour)}:${two(date.minute)}:${two(date.second)}';
  }

  // MENGECEK RESI DAN MEMINTA KONFIRMASI PENGIRIMAN
  Future<void> processResi([String? scannedValue]) async {
    if (processing) return;

    final resi = (scannedValue ?? resiController.text).trim().toUpperCase();

    if (resi.isEmpty) {
      message('Nomor resi wajib diisi.');
      return;
    }

    setState(() {
      processing = true;
    });

    try {
      final order = store.findByResi(resi);

      if (order == null) {
        message('Resi $resi tidak ditemukan.');
        return;
      }

      if (order.isDispatched) {
        message('Resi $resi sudah pernah dikirim.');
        return;
      }

      if (!order.isPacked) {
        message(
          'Pesanan ${order.number} belum selesai packing. '
          'Pengiriman ditolak.',
        );
        return;
      }

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Konfirmasi Pengiriman'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                detailLine('Nomor Resi', order.resi),
                detailLine('Pesanan', order.number),
                detailLine('Pembeli', order.buyer),
                detailLine('Channel', order.channel),
                const SizedBox(height: 12),
                const Text(
                  'Paket telah selesai dipacking. '
                  'Tandai sebagai Dikirim Internal?',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext, false);
                },
                child: const Text('Batal'),
              ),
              FilledButton.icon(
                onPressed: () {
                  Navigator.pop(dialogContext, true);
                },
                icon: const Icon(Icons.local_shipping_outlined),
                label: const Text('Ya, Kirim'),
              ),
            ],
          );
        },
      );

      if (!mounted || confirmed != true) return;

      final result = store.dispatchOrder(
        resi: resi,
        officer: 'Petugas Packing Demo',
      );

      if (result == 'SUCCESS') {
        setState(() {
          lastSuccessResi = resi;
          resiController.clear();
        });

        message('Resi $resi berhasil dikirim internal (demo).');
      } else if (result == 'ALREADY_SENT') {
        message('Resi sudah pernah dikirim.');
      } else if (result == 'NOT_READY') {
        message('Paket belum siap dikirim.');
      } else {
        message('Resi tidak ditemukan.');
      }
    } finally {
      if (mounted) {
        setState(() {
          processing = false;
        });
      }
    }
  }

  // MEMBUKA KAMERA SCANNER
  Future<void> openCameraScanner() async {
    final scannedValue = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const PackingCameraScannerPage()),
    );

    if (!mounted || scannedValue == null) return;

    resiController.text = scannedValue;

    await processResi(scannedValue);
  }

  static Widget detailLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 95,
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

  Widget panel(String title, Widget child) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 15),
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
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget readyOrderCard(PackingOrder order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(15),
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
                  order.number,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.navy,
                    fontSize: 14,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF7F0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Siap Dikirim',
                  style: TextStyle(
                    color: Color(0xFF0B8B65),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          detailLine('Pembeli', order.buyer),
          detailLine('Channel', order.channel),
          detailLine('No. Resi', order.resi),
          detailLine(
            'Produk',
            order.products.map((item) => item.name).join(', '),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: processing
                  ? null
                  : () {
                      resiController.text = order.resi;
                      processResi(order.resi);
                    },
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Proses Resi Demo'),
            ),
          ),
        ],
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
                  'Scan Pengiriman',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Scan resi semua channel setelah packing selesai',
                  style: TextStyle(color: Color(0xFFD2E5F7), fontSize: 12),
                ),
              ],
            ),
          ),

          Expanded(
            child: AnimatedBuilder(
              animation: store,
              builder: (context, _) {
                final readyOrders = store.readyOrders;

                return ListView(
                  padding: const EdgeInsets.all(15),
                  children: [
                    // INFORMASI ATURAN
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
                              'Berlaku untuk Meta, Shopee, dan TikTok. '
                              'Resi hanya dapat diproses apabila '
                              'packing sudah selesai.',
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

                    // INPUT RESI
                    panel(
                      'Scan atau Masukkan Resi',
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            controller: resiController,
                            textCapitalization: TextCapitalization.characters,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => processResi(),
                            decoration: const InputDecoration(
                              labelText: 'Nomor Resi',
                              hintText: 'Scan barcode atau ketik resi',
                              prefixIcon: Icon(Icons.qr_code_scanner),
                            ),
                          ),
                          const SizedBox(height: 14),
                          FilledButton.icon(
                            onPressed: processing ? null : processResi,
                            icon: const Icon(Icons.send_outlined),
                            label: Text(
                              processing ? 'Memproses...' : 'Proses Resi',
                            ),
                          ),
                          const SizedBox(height: 9),
                          OutlinedButton.icon(
                            onPressed: processing ? null : openCameraScanner,
                            icon: const Icon(Icons.camera_alt_outlined),
                            label: const Text('Scan Barcode dengan Kamera'),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Scanner barcode fisik dapat digunakan '
                            'melalui input nomor resi. '
                            'Tekan Enter untuk memproses.',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.black54,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (lastSuccessResi != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF7F0),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Color(0xFF0B8B65),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Resi $lastSuccessResi berhasil '
                                'diproses sebagai Dikirim Internal.',
                                style: const TextStyle(
                                  color: Color(0xFF0B8B65),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Antrean Siap Dikirim',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.navy,
                            ),
                          ),
                        ),
                        Text(
                          '${readyOrders.length} pesanan',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (readyOrders.isEmpty)
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
                              size: 43,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Belum ada paket siap dikirim',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      )
                    else
                      ...readyOrders.map(readyOrderCard),

                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF4E6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Dikirim Internal tidak berarti paket '
                        'sudah diterima ekspedisi atau pembeli.\n'
                        'Semua data masih simulasi lokal.',
                        style: TextStyle(
                          color: Color(0xFF8D570F),
                          fontSize: 11,
                          height: 1.5,
                        ),
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

// HALAMAN SCANNER KAMERA
class PackingCameraScannerPage extends StatefulWidget {
  const PackingCameraScannerPage({super.key});

  @override
  State<PackingCameraScannerPage> createState() =>
      _PackingCameraScannerPageState();
}

class _PackingCameraScannerPageState extends State<PackingCameraScannerPage> {
  final MobileScannerController scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  bool detected = false;

  void onDetect(BarcodeCapture capture) {
    if (detected) return;

    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue?.trim();

      if (value == null || value.isEmpty) continue;

      detected = true;

      Navigator.pop(context, value);
      return;
    }
  }

  @override
  void dispose() {
    scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan Barcode Resi'),
        backgroundColor: AppTheme.navy,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            MobileScanner(controller: scannerController, onDetect: onDetect),

            Align(
              alignment: Alignment.center,
              child: IgnorePointer(
                child: Container(
                  width: 280,
                  height: 180,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 3),
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                color: Colors.black.withValues(alpha: 0.60),
                child: const Text(
                  'Arahkan kamera ke barcode atau QR code '
                  'pada label resi paket.\n'
                  'Setelah terdeteksi, aplikasi akan '
                  'memeriksa status packing.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
