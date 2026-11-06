import 'dart:convert';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:untungku_pro/data/database.dart';
import 'package:untungku_pro/data/store.dart';
import 'package:untungku_pro/domain/models.dart';
import 'package:untungku_pro/features/app.dart';

void main() {
  setUpAll(() => initializeDateFormatting('id_ID'));
  testWidgets(
    'partial return distinguishes damaged stock, shows liability and records partial refund',
    (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      final store = Store(db);
      await store.load();
      const date = '2026-11-01T10:00:00';
      for (final id in ['Kopi', 'Teh']) {
        await store.saveProduct(
          Product(
            id: id,
            name: id,
            price: 10000,
            cost: 5000,
            stock: 10,
            created: date,
            updated: date,
          ),
        );
      }
      await store.saveSale(
        Sale(
          id: 'sale',
          date: date,
          lines: [
            for (final id in ['Kopi', 'Teh'])
              SaleLine(
                productId: id,
                name: id,
                quantity: 2,
                price: 10000,
                cost: 5000,
                packaging: 0,
                extra: 0,
              ),
          ],
        ),
      );
      final raw = (await db.select(db.saleRows).get()).single.payload;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [storeProvider.overrideWith((ref) => store)],
          child: const MaterialApp(home: SalesReturnsPage(saleId: 'sale')),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Catat retur barang'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Jumlah retur Kopi'),
        '1',
      );
      await tester.tap(find.byType(DropdownButtonFormField<String>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Layak jual — kembali ke stok').last);
      await tester.pumpAndSettle();
      final tea = find.widgetWithText(TextFormField, 'Jumlah retur Teh');
      await tester.ensureVisible(tea);
      await tester.enterText(tea, '1');
      final condition = find.byType(DropdownButtonFormField<String>).last;
      await tester.ensureVisible(condition);
      await tester.tap(condition);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rusak — tidak menambah stok').last);
      await tester.pumpAndSettle();
      final reason = find.widgetWithText(TextFormField, 'Alasan retur');
      await tester.ensureVisible(reason);
      await tester.enterText(reason, 'Retur sebagian');
      tester.testTextInput.hide();
      await tester.ensureVisible(find.text('Tinjau & simpan retur'));
      await tester.tap(find.text('Tinjau & simpan retur'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lanjutkan'));
      await tester.pumpAndSettle();
      expect(store.products.singleWhere((p) => p.id == 'Kopi').stock, 9);
      expect(store.products.singleWhere((p) => p.id == 'Teh').stock, 8);
      final returns = await store.salesReturns(saleId: 'sale');
      expect(returns.single.dispositions, {0: 'resellable', 1: 'damaged'});
      expect(returns.single.refundOutstanding, 20000);
      expect((await db.select(db.saleRows).get()).single.payload, raw);
      expect(find.text('Konfirmasi retur'), findsOneWidget);
      final refundButton = find.text('Catat pengembalian dana');
      await tester.ensureVisible(refundButton);
      await tester.tap(refundButton);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nominal pengembalian (Rp)'),
        '10000',
      );
      await tester.tap(find.text('Simpan pengembalian'));
      await tester.pumpAndSettle();
      expect((await store.salesReturns()).single.refundOutstanding, 10000);
      expect((await store.cashBalances())[null], 30000);
      expect((await db.select(db.refundRows).get()).length, 1);
      final backup = store.backup();
      await store.restore(backup);
      expect((await store.salesReturns()).single.dispositions[1], 'damaged');
      expect((jsonDecode(backup)['business']['returns'] as List).length, 1);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await db.close();
    },
  );
}
