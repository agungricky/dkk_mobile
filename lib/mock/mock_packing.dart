import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class PackingProduct {
  final String name;
  final String variant;
  final int quantity;

  const PackingProduct({
    required this.name,
    required this.variant,
    required this.quantity,
  });
}

class PackingOrder {
  final String number;
  final String buyer;
  final String phone;
  final String address;
  final String resi;
  final String channel;
  final String group;
  final List<PackingProduct> products;

  String status;
  final List<XFile> photos;
  DateTime? packedAt;
  DateTime? dispatchedAt;
  String? dispatchedBy;

  PackingOrder({
    required this.number,
    required this.buyer,
    required this.phone,
    required this.address,
    required this.resi,
    required this.channel,
    required this.group,
    required this.products,
    this.status = 'menunggu',
    List<XFile>? photos,
    this.packedAt,
    this.dispatchedAt,
    this.dispatchedBy,
  }) : photos = photos ?? [];

  bool get isMeta => channel == 'META';
  bool get isPacked => status == 'dipacking';
  bool get isDispatched => status == 'dikirim';
}

class PackingDemoStore extends ChangeNotifier {
  PackingDemoStore._();

  static final PackingDemoStore instance = PackingDemoStore._();

  final List<PackingOrder> orders = [
    PackingOrder(
      number: '261112001A',
      buyer: 'Yanto',
      phone: '6281234500001',
      address: 'Prambon, Nganjuk, Jawa Timur',
      resi: 'META260001',
      channel: 'META',
      group: 'Akrilik',
      products: [
        const PackingProduct(
          name: 'Emblem Akrilik Timbul Custom',
          variant: 'Gold, 10 CM',
          quantity: 1,
        ),
      ],
    ),
    PackingOrder(
      number: '261112002A',
      buyer: 'Budi',
      phone: '6281234500002',
      address: 'Mojoroto, Kediri, Jawa Timur',
      resi: 'META260002',
      channel: 'META',
      group: 'Stiker',
      products: [
        const PackingProduct(
          name: 'Stiker Kaca Mobil Custom',
          variant: 'Putih, 60 x 12 CM',
          quantity: 2,
        ),
      ],
    ),
    PackingOrder(
      number: '261112003A',
      buyer: 'Siti',
      phone: '6281234500003',
      address: 'Pare, Kediri, Jawa Timur',
      resi: 'META260003',
      channel: 'META',
      group: 'Kaligrafi',
      products: [
        const PackingProduct(
          name: 'Kaligrafi Allah Muhammad',
          variant: 'Hitam Gold, 60 x 20 CM',
          quantity: 1,
        ),
      ],
    ),
    PackingOrder(
      number: '261112004A',
      buyer: 'Andi',
      phone: '6281234500004',
      address: 'Kertosono, Nganjuk, Jawa Timur',
      resi: 'META260004',
      channel: 'META',
      group: 'Akrilik',
      products: [
        const PackingProduct(
          name: 'Gantungan Kunci Akrilik Custom',
          variant: 'Custom Foto',
          quantity: 5,
        ),
      ],
    ),
    PackingOrder(
      number: '261112005A',
      buyer: 'Rina',
      phone: '6281234500005',
      address: 'Blitar, Jawa Timur',
      resi: 'META260005',
      channel: 'META',
      group: 'Stiker',
      products: [
        const PackingProduct(
          name: 'Stiker Sunstrip Custom',
          variant: 'Hitam, 100 x 15 CM',
          quantity: 1,
        ),
      ],
    ),
    PackingOrder(
      number: '261112006A',
      buyer: 'Doni',
      phone: '6281234500006',
      address: 'Tulungagung, Jawa Timur',
      resi: 'META260006',
      channel: 'META',
      group: 'Kaligrafi',
      products: [
        const PackingProduct(
          name: 'Mihrab Minimalis',
          variant: 'Kayu Gold',
          quantity: 1,
        ),
      ],
    ),

    // PESANAN MARKETPLACE:
    // Sudah siap kirim berdasarkan status packing demo.
    PackingOrder(
      number: '261112007A',
      buyer: 'Pelanggan Shopee',
      phone: '6281234500007',
      address: 'Malang, Jawa Timur',
      resi: 'SPX260007',
      channel: 'SHOPEE',
      group: 'Akrilik',
      status: 'dipacking',
      products: [
        const PackingProduct(
          name: 'Emblem Akrilik',
          variant: 'Silver',
          quantity: 1,
        ),
      ],
    ),
    PackingOrder(
      number: '261112008A',
      buyer: 'Pelanggan TikTok',
      phone: '6281234500008',
      address: 'Surabaya, Jawa Timur',
      resi: 'TT260008',
      channel: 'TIKTOK',
      group: 'Stiker',
      status: 'dipacking',
      products: [
        const PackingProduct(
          name: 'Stiker Mobil',
          variant: 'Custom',
          quantity: 2,
        ),
      ],
    ),
  ];

  List<PackingOrder> get metaOrders =>
      orders.where((item) => item.isMeta).toList();

  List<PackingOrder> get readyOrders =>
      orders.where((item) => item.isPacked).toList();

  List<PackingOrder> get dispatchedOrders =>
      orders.where((item) => item.isDispatched).toList();

  int get pendingMetaCount => orders
      .where(
        (item) =>
            item.isMeta &&
            item.status != 'dipacking' &&
            item.status != 'dikirim',
      )
      .length;

  int get totalMetaPhotos =>
      metaOrders.fold<int>(0, (sum, item) => sum + item.photos.length);

  void addPhotos(PackingOrder order, List<XFile> files) {
    if (order.isDispatched || order.isPacked) return;

    order.photos.addAll(files);
    order.status = 'difoto';
    notifyListeners();
  }

  void removePhoto(PackingOrder order, XFile photo) {
    if (order.isDispatched || order.isPacked) return;

    order.photos.remove(photo);

    if (order.photos.isEmpty) {
      order.status = 'menunggu';
    }

    notifyListeners();
  }

  bool confirmPacking(PackingOrder order) {
    if (!order.isMeta ||
        order.isDispatched ||
        order.isPacked ||
        order.photos.isEmpty) {
      return false;
    }

    order.status = 'dipacking';
    order.packedAt = DateTime.now();

    notifyListeners();
    return true;
  }

  // MENCARI PESANAN BERDASARKAN NOMOR RESI
  PackingOrder? findByResi(String resi) {
    final normalized = resi.trim().toUpperCase();

    if (normalized.isEmpty) return null;

    for (final order in orders) {
      if (order.resi.trim().toUpperCase() == normalized) {
        return order;
      }
    }

    return null;
  }

  // PROSES PENGIRIMAN INTERNAL
  // HANYA BOLEH JIKA PACKING SUDAH SELESAI
  String dispatchOrder({required String resi, required String officer}) {
    final order = findByResi(resi);

    if (order == null) {
      return 'NOT_FOUND';
    }

    if (order.isDispatched) {
      return 'ALREADY_SENT';
    }

    if (!order.isPacked) {
      return 'NOT_READY';
    }

    order.status = 'dikirim';
    order.dispatchedAt = DateTime.now();
    order.dispatchedBy = officer;

    notifyListeners();

    return 'SUCCESS';
  }
}
