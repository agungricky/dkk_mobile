import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/app_theme.dart';

class CsAddOrderPage extends StatefulWidget {
  final VoidCallback onCancel;
  final bool isLeader;

  const CsAddOrderPage({
    super.key,
    required this.onCancel,
    this.isLeader = false,
  });

  @override
  State<CsAddOrderPage> createState() => _CsAddOrderPageState();
}

class _ProductInput {
  String? category;
  String? product;
  String variant = 'Custom';

  final qty = TextEditingController(text: '1');
  final custom = TextEditingController();
  final note = TextEditingController();
  final List<XFile> photos = [];

  void dispose() {
    qty.dispose();
    custom.dispose();
    note.dispose();
  }
}

class _CsAddOrderPageState extends State<CsAddOrderPage> {
  // Penanggung jawab selalu akun yang sedang login (simulasi).
  // Tidak ada pilihan CS lain pada form Leader.
  String get responsibleName => widget.isLeader ? 'Leader CS Demo' : 'CS Demo';
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  final buyer = TextEditingController();
  final phone = TextEditingController(text: '62');
  final province = TextEditingController();
  final city = TextEditingController();
  final district = TextEditingController();
  final village = TextEditingController();
  final address = TextEditingController();

  final cod = TextEditingController(text: '0');
  final nonCod = TextEditingController(text: '0');
  final dp = TextEditingController(text: '0');
  final generalNote = TextEditingController();

  final List<_ProductInput> products = [_ProductInput()];

  String payment = 'COD';
  XFile? paymentProof;

  DateTime chatDate = DateTime.now();
  DateTime orderDate = DateTime.now();

  // Identitas lokal untuk preview saja.
  late final String demoNumber =
      'DEMO-${DateTime.now().millisecondsSinceEpoch}';

  static const Map<String, List<String>> masterDemo = {
    'Emblem': ['Emblem Akrilik Timbul Custom', 'Emblem UV Universal'],
    'Gantungan Kunci': ['Gantungan Kunci Akrilik Custom'],
    'Stiker': ['Stiker Kaca Mobil Custom', 'Stiker Sunstrip'],
    'Kaligrafi': ['Kaligrafi Allah Muhammad'],
    'Mihrab': ['Mihrab Minimalis'],
  };

  static const List<String> variants = [
    'Custom',
    'Gold',
    'Silver',
    'Hitam',
    'Putih',
    '30x10',
    '100x15',
  ];

  @override
  void dispose() {
    for (final controller in [
      buyer,
      phone,
      province,
      city,
      district,
      village,
      address,
      cod,
      nonCod,
      dp,
      generalNote,
    ]) {
      controller.dispose();
    }

    for (final product in products) {
      product.dispose();
    }

    super.dispose();
  }

  int amount(TextEditingController controller) {
    return int.tryParse(controller.text.trim()) ?? 0;
  }

  int get totalPrice {
    switch (payment) {
      case 'NON COD':
        return amount(nonCod);
      case 'DP':
        return amount(dp) + amount(cod);
      default:
        return amount(cod);
    }
  }

  String rupiah(int value) {
    final formatted = value.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
    return 'Rp$formatted';
  }

  String dateLabel(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    return '$day/$month/${value.year}';
  }

  Future<void> selectDate({required bool isChat}) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: isChat ? chatDate : orderDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );

    if (!mounted || selected == null) return;

    setState(() {
      if (isChat) {
        chatDate = selected;
      } else {
        orderDate = selected;
      }
    });
  }

  Future<void> selectPaymentProof() async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (!mounted || file == null) return;

      setState(() {
        paymentProof = file;
      });
    } catch (error) {
      showMessage('Tidak dapat memilih bukti bayar: $error');
    }
  }

  Future<void> selectProductPhotos(_ProductInput item) async {
    try {
      final files = await _picker.pickMultiImage(imageQuality: 85);

      if (!mounted || files.isEmpty) return;

      if (item.photos.length + files.length > 5) {
        showMessage('Maksimal 5 foto untuk setiap produk.');
        return;
      }

      setState(() {
        item.photos.addAll(files);
      });
    } catch (error) {
      showMessage('Tidak dapat memilih foto produk: $error');
    }
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  void addProduct() {
    setState(() {
      products.add(_ProductInput());
    });
  }

  void removeProduct(_ProductInput item) {
    if (products.length == 1) {
      showMessage('Minimal harus ada satu produk.');
      return;
    }

    setState(() {
      products.remove(item);
    });

    item.dispose();
  }

  void previewOrder() {
    if (!_formKey.currentState!.validate()) {
      showMessage('Lengkapi semua kolom yang wajib diisi.');
      return;
    }

    final chatDay = DateUtils.dateOnly(chatDate);
    final orderDay = DateUtils.dateOnly(orderDate);
    if (orderDay.isBefore(chatDay)) {
      showMessage('Tanggal order tidak boleh sebelum tanggal chat masuk.');
      return;
    }

    if (totalPrice <= 0) {
      showMessage('Total pembayaran harus lebih dari nol.');
      return;
    }

    if (payment == 'DP' && (amount(dp) <= 0 || amount(cod) <= 0)) {
      showMessage('Isi nominal DP dan sisa COD.');
      return;
    }

    if (payment != 'COD' && paymentProof == null) {
      showMessage('Pilih foto bukti pembayaran.');
      return;
    }

    for (final item in products) {
      if (item.category == null || item.product == null) {
        showMessage('Pilih kategori dan nama setiap produk.');
        return;
      }

      if (amount(item.qty) < 1) {
        showMessage('Jumlah produk minimal 1.');
        return;
      }
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            10,
            20,
            MediaQuery.viewInsetsOf(context).bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Preview Pesanan Demo',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.navy,
                  ),
                ),
                const SizedBox(height: 16),
                _info('Nomor', demoNumber),
                _info('Penanggung Jawab', responsibleName),
                _info('Pembeli', buyer.text),
                _info('Telepon', phone.text),
                _info('Pembayaran', payment),
                _info('Jumlah Produk', '${products.length} jenis'),
                _info('Total Harga', rupiah(totalPrice)),
                const Divider(height: 28),
                ...products.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      '${item.product} (${item.qty.text} pcs) '
                      '• ${item.photos.length} foto',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Mode demo: data belum disimpan atau dikirim ke server.',
                  style: TextStyle(color: Colors.deepOrange, fontSize: 12),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Kembali ke Form'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(color: Colors.black54)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget section(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5EBF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
          ...children,
        ],
      ),
    );
  }

  Widget field(
    String label,
    TextEditingController controller, {
    bool required = true,
    int lines = 1,
    TextInputType? keyboard,
    List<TextInputFormatter>? formatters,
    ValueChanged<String>? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: TextFormField(
        controller: controller,
        maxLines: lines,
        keyboardType: keyboard,
        inputFormatters: formatters,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          alignLabelWithHint: lines > 1,
        ),
        validator: (value) {
          final text = value?.trim() ?? '';

          if (required && text.isEmpty) {
            return '$label wajib diisi';
          }

          if (controller == phone &&
              !RegExp(r'^62[0-9]{8,13}$').hasMatch(text)) {
            return 'Nomor HP harus diawali 62';
          }

          return null;
        },
      ),
    );
  }

  Widget moneyField(String title, TextEditingController controller) {
    return field(
      title,
      controller,
      keyboard: TextInputType.number,
      formatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: (_) => setState(() {}),
    );
  }

  Widget dateField(String label, DateTime date, bool isChat) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: OutlinedButton.icon(
        onPressed: () => selectDate(isChat: isChat),
        icon: const Icon(Icons.calendar_today_outlined),
        label: Text('$label: ${dateLabel(date)}'),
        style: OutlinedButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.all(14),
        ),
      ),
    );
  }

  Widget productCard(_ProductInput item, int index) {
    final names = item.category == null
        ? <String>[]
        : masterDemo[item.category]!;

    return Container(
      key: ObjectKey(item),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFE),
        border: Border.all(color: const Color(0xFFDCE7F3)),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Produk ${index + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.navy,
                  ),
                ),
              ),
              if (products.length > 1)
                IconButton(
                  tooltip: 'Hapus produk',
                  onPressed: () => removeProduct(item),
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                ),
            ],
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            key: ValueKey('category-${identityHashCode(item)}'),
            initialValue: item.category,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Kategori Produk'),
            items: masterDemo.keys
                .map((name) => DropdownMenuItem(value: name, child: Text(name)))
                .toList(),
            onChanged: (value) {
              setState(() {
                item.category = value;
                item.product = null;
              });
            },
          ),
          const SizedBox(height: 13),
          DropdownButtonFormField<String>(
            key: ValueKey('product-${identityHashCode(item)}-${item.category}'),
            initialValue: item.product,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Nama Produk'),
            items: names
                .map(
                  (name) => DropdownMenuItem(
                    value: name,
                    child: Text(name, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
            onChanged: names.isEmpty
                ? null
                : (value) {
                    setState(() => item.product = value);
                  },
          ),
          const SizedBox(height: 13),
          DropdownButtonFormField<String>(
            initialValue: item.variant,
            decoration: const InputDecoration(labelText: 'Variasi (Demo)'),
            items: variants
                .map(
                  (variant) =>
                      DropdownMenuItem(value: variant, child: Text(variant)),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => item.variant = value);
              }
            },
          ),
          const SizedBox(height: 13),
          field(
            'Jumlah',
            item.qty,
            keyboard: TextInputType.number,
            formatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          field('Request Custom', item.custom, required: false),
          field('Catatan Produk', item.note, required: false, lines: 2),
          OutlinedButton.icon(
            onPressed: () => selectProductPhotos(item),
            icon: const Icon(Icons.add_photo_alternate_outlined),
            label: Text('Pilih Foto Produk (${item.photos.length}/5)'),
          ),
          if (item.photos.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: item.photos.map((photo) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(9),
                      child: Image.file(
                        File(photo.path),
                        width: 75,
                        height: 75,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            item.photos.remove(photo);
                          });
                        },
                        child: const CircleAvatar(
                          radius: 11,
                          backgroundColor: Colors.red,
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 8),
          const Text(
            'SKU dan HPP akan diambil dari master produk API.',
            style: TextStyle(fontSize: 11, color: Colors.black54),
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 22),
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
                  'Tambah Pesanan',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Form pemesanan Meta • Mode Demo',
                  style: TextStyle(color: Color(0xFFD2E5F7), fontSize: 12),
                ),
              ],
            ),
          ),
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(15),
                children: [
                  section('01 · Identitas Pesanan', [
                    InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Nomor Pesanan (Demo)',
                        prefixIcon: Icon(Icons.tag),
                      ),
                      child: Text(
                        demoNumber,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.navy,
                        ),
                      ),
                    ),
                    const SizedBox(height: 13),
                    InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Penanggung Jawab Pesanan',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      child: Text(
                        responsibleName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.navy,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    dateField('Tanggal Chat Masuk', chatDate, true),
                    dateField('Tanggal Order', orderDate, false),
                    field('Nama Pembeli', buyer),
                    field(
                      'No. HP (awalan 62)',
                      phone,
                      keyboard: TextInputType.phone,
                      formatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ]),

                  section('02 · Alamat Pengiriman', [
                    field('Provinsi', province),
                    field('Kabupaten / Kota', city),
                    field('Kecamatan', district),
                    field('Desa / Kelurahan', village, required: false),
                    field('Alamat Lengkap', address, lines: 3),
                  ]),

                  section('03 · Pembayaran', [
                    DropdownButtonFormField<String>(
                      initialValue: payment,
                      decoration: const InputDecoration(
                        labelText: 'Metode Pembayaran',
                      ),
                      items: const [
                        DropdownMenuItem(value: 'COD', child: Text('COD')),
                        DropdownMenuItem(
                          value: 'NON COD',
                          child: Text('NON COD'),
                        ),
                        DropdownMenuItem(
                          value: 'DP',
                          child: Text('DP + Sisa COD'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            payment = value;
                            paymentProof = null;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 15),
                    if (payment == 'COD' || payment == 'DP')
                      moneyField('Nominal COD (Rp)', cod),
                    if (payment == 'NON COD')
                      moneyField('Nominal NON COD (Rp)', nonCod),
                    if (payment == 'DP') moneyField('Nominal DP (Rp)', dp),
                    if (payment != 'COD') ...[
                      OutlinedButton.icon(
                        onPressed: selectPaymentProof,
                        icon: const Icon(Icons.upload_file),
                        label: Text(
                          paymentProof == null
                              ? 'Pilih Bukti Transfer'
                              : 'Ganti Bukti Transfer',
                        ),
                      ),
                      if (paymentProof != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          paymentProof!.name,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ],
                  ]),

                  section('04 · Produk Pesanan', [
                    const Text(
                      'Produk di bawah hanya master simulasi.',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    const SizedBox(height: 13),
                    for (int i = 0; i < products.length; i++)
                      productCard(products[i], i),
                    OutlinedButton.icon(
                      onPressed: addProduct,
                      icon: const Icon(Icons.add),
                      label: const Text('Tambah Produk Lagi'),
                    ),
                  ]),

                  section('05 · Rincian Pesanan', [
                    _info('Metode Bayar', payment),
                    if (payment == 'COD' || payment == 'DP')
                      _info('COD', rupiah(amount(cod))),
                    if (payment == 'NON COD')
                      _info('Transfer', rupiah(amount(nonCod))),
                    if (payment == 'DP') _info('DP', rupiah(amount(dp))),
                    const Divider(),
                    _info('Total Harga', rupiah(totalPrice)),
                    _info('Jumlah Produk', '${products.length} jenis'),
                    const SizedBox(height: 8),
                    const Text(
                      'HPP, biaya admin, ongkir, dan biaya iklan '
                      'belum dihitung.',
                      style: TextStyle(fontSize: 11, color: Colors.black54),
                    ),
                    const SizedBox(height: 16),
                    field(
                      'Catatan Pesanan Umum',
                      generalNote,
                      required: false,
                      lines: 3,
                    ),
                  ]),

                  FilledButton.icon(
                    onPressed: previewOrder,
                    icon: const Icon(Icons.visibility_outlined),
                    label: const Text('Preview Pesanan Demo'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: widget.onCancel,
                    child: const Text('Kembali ke Pesanan'),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
