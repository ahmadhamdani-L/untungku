import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:untungku_pro/domain/models.dart';
import 'package:untungku_pro/domain/receipt.dart';
import 'package:untungku_pro/services/receipts/receipt_pdf.dart';
import 'package:untungku_pro/services/receipts/receipt_image.dart';

Sale fixture({bool voided = false, int count = 1}) => Sale(
  id: 'receipt-edge',
  date: '2026-11-05T10:00:00',
  voided: voided,
  credit: true,
  customer: 'Pelanggan',
  dueDate: '2026-11-10',
  lines: List.generate(
    count,
    (i) => SaleLine(
      productId: 'p$i',
      name: 'Barang $i ${List.filled(12, 'nama panjang').join(' ')}',
      quantity: 1,
      price: 10000,
      cost: 5000,
      packaging: 0,
      extra: 0,
    ),
  ),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'cancelled receipt keeps historical totals and marks cancellation',
    () async {
      final sale = fixture(voided: true);
      final receipt = ReceiptSnapshot(sale: sale, business: 'Toko');
      final before = jsonEncode(sale.toJson());
      expect(receipt.text(), contains('STRUK PENJUALAN - DIBATALKAN'));
      expect(receipt.text(), contains('Status: Dibatalkan'));
      expect(receipt.text(), contains('Total penjualan asli: Rp 10.000'));
      expect(receipt.text(), contains('Sisa piutang: Rp 0'));
      for (final width in [58, 80]) {
        final bytes = await receiptPdf(receipt, paperWidth: width);
        expect(latin1.decode(bytes), startsWith('%PDF-'));
      }
      expect(jsonEncode(sale.toJson()), before);
    },
  );

  test('long names and 100 items export across pages at both widths', () async {
    final sale = fixture(count: 100);
    final before = jsonEncode(sale.toJson());
    final receipt = ReceiptSnapshot(sale: sale, business: 'Toko');
    for (final width in [58, 80]) {
      final bytes = await receiptPdf(receipt, paperWidth: width);
      final pages = RegExp(r'/Type\s*/Page\b').allMatches(latin1.decode(bytes));
      expect(pages.length, greaterThan(1));
    }
    expect(jsonEncode(sale.toJson()), before);
  });

  test(
    'oversized image directs user to PDF and invalid widths are rejected',
    () async {
      final receipt = ReceiptSnapshot(
        sale: fixture(count: 100),
        business: 'Toko',
      );
      await expectLater(
        receiptImage(receipt),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('Gunakan PDF'),
          ),
        ),
      );
      await expectLater(
        receiptPdf(receipt, paperWidth: 60),
        throwsArgumentError,
      );
      await expectLater(
        receiptImage(receipt, paperWidth: 60),
        throwsArgumentError,
      );
    },
  );
}
