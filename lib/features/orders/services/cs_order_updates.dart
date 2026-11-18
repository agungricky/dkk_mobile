import 'package:flutter/foundation.dart';

/// Memberi tahu halaman CS yang masih hidup di IndexedStack bahwa
/// ada pesanan baru yang telah dikonfirmasi tersimpan oleh server.
class CsOrderUpdates {
  CsOrderUpdates._();

  static final ValueNotifier<int> version = ValueNotifier<int>(0);

  static void orderCreated() {
    version.value = version.value + 1;
  }
}
