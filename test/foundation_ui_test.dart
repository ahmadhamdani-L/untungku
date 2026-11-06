import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:untungku_pro/data/database.dart';
import 'package:untungku_pro/data/store.dart';
import 'package:untungku_pro/domain/input_validation.dart';
import 'package:untungku_pro/features/app.dart';
import 'package:untungku_pro/features/shared/integer_field.dart';

void main() {
  setUpAll(() => initializeDateFormatting('id_ID'));
  test(
    'money inputs reject decimals, grouping, exponent, overflow and empty input',
    () {
      for (final source in [
        '',
        '1.000',
        '1,5',
        '1e3',
        '0x10',
        'NaN',
        '-1',
        '1000000000001',
        '999999999999999999999',
      ]) {
        expect(
          () => parseIntegerInput(source, 'Rupiah'),
          throwsArgumentError,
          reason: source,
        );
      }
      expect(parseIntegerInput(' 1500 ', 'Rupiah'), 1500);
      expect(parseIntegerInput('-20', 'Koreksi', min: -100), -20);
      expect(requiredInputError('   ', label: 'Nama'), 'Nama wajib diisi');
    },
  );
  testWidgets('shared integer field shows actionable errors without rounding', (
    tester,
  ) async {
    final controller = TextEditingController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: IntegerField(
            controller: controller,
            label: 'Jumlah',
            min: 1,
            max: 10,
          ),
        ),
      ),
    );
    await tester.enterText(find.byType(TextFormField), '1.5');
    await tester.pump();
    expect(
      find.text('Jumlah harus berupa angka bulat tanpa pemisah'),
      findsOneWidget,
    );
    await tester.enterText(find.byType(TextFormField), '11');
    await tester.pump();
    expect(find.text('Jumlah harus antara 1 dan 10'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), '2');
    await tester.pump();
    expect(find.text('Jumlah harus antara 1 dan 10'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });
  testWidgets(
    'management navigation opens every foundation module and retains local state',
    (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      final store = Store(db);
      await store.load();
      await store.saveSettings({'onboarded': true, 'business': 'Toko Uji'});
      await tester.pumpWidget(
        ProviderScope(
          overrides: [storeProvider.overrideWith((ref) => store)],
          child: const UntungkuApp(),
        ),
      );
      await tester.tap(find.text('Lainnya'));
      await tester.pumpAndSettle();
      for (final title in [
        'Pelanggan',
        'Pemasok',
        'Pembelian',
        'Kas & rekening',
        'Stock opname',
        'Piutang pelanggan',
        'Pengaturan & backup',
      ]) {
        final tile = find.widgetWithText(ListTile, title);
        await tester.ensureVisible(tile);
        await tester.tap(tile);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: title);
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();
        expect(find.byType(ManagementPage), findsOneWidget);
        expect(find.text('Lainnya'), findsOneWidget);
      }
      expect(store.settings['business'], 'Toko Uji');
      expect(store.sales, isEmpty);
      expect(await store.cashLedger(), isEmpty);
      await tester.pumpWidget(const SizedBox());
      await db.close();
    },
  );
}
