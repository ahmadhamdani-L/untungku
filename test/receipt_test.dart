import 'dart:convert';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:untungku_pro/data/database.dart';
import 'package:untungku_pro/data/store.dart';
import 'package:untungku_pro/domain/models.dart';
import 'package:untungku_pro/domain/receipt.dart';
import 'package:untungku_pro/domain/business/returns.dart';
import 'package:untungku_pro/features/app.dart';
import 'package:untungku_pro/services/receipts/receipt_pdf.dart';
import 'package:untungku_pro/services/receipts/receipt_image.dart';

void main() {
  setUpAll(() => initializeDateFormatting('id_ID'));
  test(
    'returned receipt distinguishes refunded cash from remaining liability',
    () {
      const sale = Sale(
        id: 'returned',
        date: '2026-11-05T10:00:00',
        lines: [
          SaleLine(
            productId: 'p',
            name: 'Kopi',
            quantity: 2,
            price: 10000,
            cost: 5000,
            packaging: 0,
            extra: 0,
          ),
        ],
        adjustments: [
          ReturnAdjustment(
            id: 'r',
            saleId: 'returned',
            date: '2026-11-05T11:00:00',
            reason: 'Barang rusak',
            quantities: {0: 1},
            restocked: {},
            revenueReduction: 10000,
            restoredCost: 0,
            recoveredFees: 0,
            refundEntitlement: 10000,
            refunded: 4000,
          ),
        ],
      );
      final before = jsonEncode(sale.toJson());
      final receipt = ReceiptSnapshot(sale: sale, business: 'Toko');
      expect(receipt.text(), contains('Total setelah retur: Rp 10.000'));
      expect(receipt.text(), contains('Pembayaran diterima: Rp 20.000'));
      expect(receipt.text(), contains('Refund sudah dibayar: Rp 4.000'));
      expect(
        receipt.text(),
        contains('Pembayaran bersih setelah refund: Rp 16.000'),
      );
      expect(receipt.text(), contains('Refund belum dibayar: Rp 6.000'));
      expect(receipt.text(), isNot(contains('5.000')));
      expect(jsonEncode(sale.toJson()), before);
    },
  );
  testWidgets(
    'receipt exports saved prices and partial credit balances without changing ledger',
    (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      final store = Store(db);
      await store.load();
      const date = '2026-11-01T10:00:00';
      await store.saveProduct(
        const Product(
          id: 'p',
          name: 'Nama baru',
          price: 20000,
          cost: 9000,
          stock: 10,
          created: date,
          updated: date,
        ),
      );
      await store.saveSale(
        const Sale(
          id: 's',
          date: date,
          lines: [
            SaleLine(
              productId: 'p',
              name: 'Nama saat jual',
              quantity: 2,
              price: 10000,
              cost: 5000,
              packaging: 0,
              extra: 0,
            ),
          ],
          discount: 1000,
          credit: true,
          customer: 'Rina',
        ),
      );
      await store.recordPayment(
        's',
        const SalePayment(id: 'pay', date: date, amount: 5000, method: 'Tunai'),
      );
      final raw = (await db.select(db.saleRows).get()).single.payload;
      final ledger = (await store.cashLedger()).map((r) => r.toJson()).toList();
      final receipt = ReceiptSnapshot(
        sale: store.sales.single,
        business: 'Toko Uji',
      );
      expect(receipt.text(), contains('Nama saat jual'));
      expect(receipt.text(), isNot(contains('Nama baru')));
      expect(receipt.text(), contains('14.000'));
      expect(receipt.text(), isNot(contains('laba')));
      for (final width in [58, 80]) {
        final pdf = await receiptPdf(receipt, paperWidth: width);
        expect(latin1.decode(pdf).startsWith('%PDF-'), true);
        final png = await tester.runAsync(
          () => receiptImage(receipt, paperWidth: width),
        );
        expect(png!.take(8).toList(), [137, 80, 78, 71, 13, 10, 26, 10]);
      }
      await tester.pumpWidget(
        ProviderScope(
          overrides: [storeProvider.overrideWith((ref) => store)],
          child: const MaterialApp(home: ReceiptPage(saleId: 's')),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('Nama saat jual'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Bagikan PDF struk'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Bagikan PDF struk'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('80 mm'),
        -200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('80 mm'));
      await tester.pumpAndSettle();
      expect((await db.select(db.saleRows).get()).single.payload, raw);
      expect(
        (await store.cashLedger()).map((r) => r.toJson()).toList(),
        ledger,
      );
      expect(store.products.single.stock, 8);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await db.close();
    },
  );
}
