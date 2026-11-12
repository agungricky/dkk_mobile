import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daha_digital_kreasi/app/app.dart';

void main() {
  testWidgets('Halaman Login Daha Digital Kreasi tampil', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const DahaDigitalKreasiApp());

    expect(find.text('Daha Digital Kreasi'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Masuk'), findsOneWidget);
  });
}
