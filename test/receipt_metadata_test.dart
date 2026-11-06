import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter_test/flutter_test.dart';
import 'package:untungku_pro/domain/receipt.dart';
import 'package:untungku_pro/domain/models.dart';
import 'package:untungku_pro/services/receipts/receipt_pdf.dart';
import 'package:untungku_pro/services/receipts/receipt_image.dart';

void main() {
  testWidgets(
    'optional phone/logo export offline and invalid logo falls back to text',
    (tester) async {
      final recorder = ui.PictureRecorder();
      ui.Canvas(recorder).drawRect(
        const ui.Rect.fromLTWH(0, 0, 2, 2),
        ui.Paint()..color = const ui.Color(0xFF1565C0),
      );
      final picture = recorder.endRecording();
      final png = await tester.runAsync(() async {
        final image = await picture.toImage(2, 2);
        try {
          return (await image.toByteData(
            format: ui.ImageByteFormat.png,
          ))!.buffer.asUint8List();
        } finally {
          image.dispose();
          picture.dispose();
        }
      });
      const sale = Sale(
        id: 's',
        date: '2026-11-05',
        lines: [
          SaleLine(
            productId: 'p',
            name: 'Kopi',
            quantity: 1,
            price: 10000,
            cost: 5000,
            packaging: 0,
            extra: 0,
          ),
        ],
      );
      final receipt = ReceiptSnapshot.fromSettings(sale, {
        'business': 'Toko',
        'receiptAddress': 'Jl. Usaha',
        'receiptPhone': '08123456789',
        'receiptLogo': base64Encode(png!),
      });
      expect(receipt.text(), contains('08123456789'));
      expect(receipt.logo, isNotNull);
      final pdf = await tester.runAsync(() => receiptPdf(receipt));
      expect(String.fromCharCodes(pdf!.take(5)), '%PDF-');
      final image = await tester.runAsync(() => receiptImage(receipt));
      expect(image!.take(8), [137, 80, 78, 71, 13, 10, 26, 10]);
      expect(ReceiptSnapshot.decodeLogo('not-base64'), isNull);
      final broken = ReceiptSnapshot(
        sale: sale,
        business: 'Toko',
        logo: png.sublist(0, 24),
      );
      expect(
        (await tester.runAsync(() => receiptPdf(broken)))!.length,
        greaterThan(0),
      );
    },
  );
}
