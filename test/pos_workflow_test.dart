import 'dart:convert';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:untungku_pro/data/database.dart';
import 'package:untungku_pro/data/store.dart';
import 'package:untungku_pro/domain/models.dart';
import 'package:untungku_pro/domain/business/pos_cart.dart';
import 'package:untungku_pro/features/app.dart';

const date = '2026-11-04';
Product product(String id, {String barcode = '12345678', int stock = 5}) =>
    Product(
      id: id,
      name: id,
      price: 10000,
      cost: 5000,
      stock: stock,
      barcode: barcode,
      favorite: true,
      created: date,
      updated: date,
    );

class DeniedCamera extends MobileScannerPlatform {
  @override
  Stream<BarcodeCapture?> get barcodesStream => const Stream.empty();
  @override
  Stream<TorchState> get torchStateStream => const Stream.empty();
  @override
  Stream<double> get zoomScaleStateStream => const Stream.empty();
  @override
  Future<MobileScannerViewAttributes> start(StartOptions options) async =>
      throw const MobileScannerException(
        errorCode: MobileScannerErrorCode.permissionDenied,
      );
  @override
  Future<void> stop() async {}
  @override
  Future<void> dispose() async {}
}

void main() {
  setUpAll(() => initializeDateFormatting('id_ID'));
  test(
    'cart aggregates repeated scans, enforces stock policy and removes zero quantity',
    () {
      final cart = PosCart(), p = product('a', stock: 2);
      cart.add(p);
      cart.add(p);
      expect(cart.quantities, {'a': 2});
      expect(() => cart.add(p), throwsArgumentError);
      cart.add(p, allowNegativeStock: true);
      expect(cart.quantities['a'], 3);
      cart.setQuantity(p, 0);
      expect(cart.quantities, isEmpty);
      expect(() => cart.add(p.copy(archived: true)), throwsArgumentError);
    },
  );
  test(
    'concurrent barcode assignments and duplicate-barcode backup are rejected atomically',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      final store = Store(db);
      addTearDown(() async {
        store.dispose();
        await db.close();
      });
      await store.load();
      final outcomes = await Future.wait(
        ['a', 'b'].map((id) async {
          try {
            await store.saveProduct(product(id));
            return true;
          } on ArgumentError {
            return false;
          }
        }),
      );
      expect(outcomes.where((v) => v).length, 1);
      expect(store.products.length, 1);
      final duplicate = jsonDecode(store.backup());
      duplicate['products'].add({
        ...duplicate['products'][0],
        'id': 'duplicate',
      });
      await expectLater(
        store.restore(jsonEncode(duplicate)),
        throwsFormatException,
      );
      expect(store.products.length, 1);
      await expectLater(
        store.saveProduct(product('bad', barcode: '123\n456')),
        throwsArgumentError,
      );
    },
  );
  testWidgets(
    'scan accepts one nonblank result and ignores repeated callbacks',
    (tester) async {
      final previous = MobileScannerPlatform.instance;
      MobileScannerPlatform.instance = DeniedCamera();
      addTearDown(() => MobileScannerPlatform.instance = previous);
      String? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return TextButton(
                onPressed: () async {
                  result = await Navigator.push<String>(
                    context,
                    MaterialPageRoute(builder: (_) => const BarcodeScanPage()),
                  );
                },
                child: const Text('Open scanner'),
              );
            },
          ),
        ),
      );
      await tester.tap(find.text('Open scanner'));
      await tester.pumpAndSettle();
      final detect = tester
          .widget<MobileScanner>(find.byType(MobileScanner))
          .onDetect!;
      detect(BarcodeCapture(barcodes: [Barcode(rawValue: '  ')]));
      await tester.pump();
      expect(find.byType(BarcodeScanPage), findsOneWidget);
      final capture = BarcodeCapture(
        barcodes: [Barcode(rawValue: ' 12345678 ')],
      );
      detect(capture);
      detect(capture);
      await tester.pumpAndSettle();
      expect(result, '12345678');
      expect(find.text('Open scanner'), findsOneWidget);
      detect(capture);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Open scanner'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Masukkan barcode manual'));
      await tester.pumpAndSettle();
      expect(result, isNull);
      expect(find.text('Open scanner'), findsOneWidget);
    },
  );
  testWidgets(
    'camera denial returns to manual barcode checkout without duplicate sale',
    (tester) async {
      final previous = MobileScannerPlatform.instance;
      MobileScannerPlatform.instance = DeniedCamera();
      addTearDown(() => MobileScannerPlatform.instance = previous);
      final db = AppDatabase(NativeDatabase.memory());
      final store = Store(db);
      await store.load();
      await store.saveProduct(product('Kopi'));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [storeProvider.overrideWith((ref) => store)],
          child: const MaterialApp(home: PosPage()),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pindai barcode'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Kamera tidak tersedia atau izin ditolak'),
        findsOneWidget,
      );
      await tester.tap(find.text('Kembali ke input manual'));
      await tester.pumpAndSettle();
      final input = find.widgetWithText(TextField, 'Barcode manual');
      for (var i = 0; i < 2; i++) {
        await tester.enterText(input, '12345678');
        await tester.tap(find.byTooltip('Tambah barcode'));
        await tester.pumpAndSettle();
      }
      tester.testTextInput.hide();
      await tester.scrollUntilVisible(
        find.text('Lanjut pembayaran').hitTestable(),
        200,
        scrollable: find
            .descendant(
              of: find.byType(PosPage),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.tap(find.text('Lanjut pembayaran'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TextField, 'Jumlah'), findsOneWidget);
      expect(
        tester
            .widget<TextField>(find.widgetWithText(TextField, 'Jumlah'))
            .controller!
            .text,
        '2',
      );
      await tester.scrollUntilVisible(
        find.text('Simpan penjualan').hitTestable(),
        200,
        scrollable: find
            .descendant(
              of: find.byType(SaleForm),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.tap(find.text('Simpan penjualan'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lanjutkan'));
      await tester.pumpAndSettle();
      expect(find.byType(ReceiptPage), findsOneWidget);
      expect(store.sales.length, 1);
      expect(store.sales.single.lines.single.quantity, 2);
      expect(store.products.single.stock, 3);
      expect((await store.cashBalances())[null], 20000);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('Keranjang masih kosong'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await db.close();
    },
  );
}
