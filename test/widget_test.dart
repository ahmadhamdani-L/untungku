import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:untungku_pro/data/database.dart';
import 'package:untungku_pro/data/store.dart';
import 'package:untungku_pro/features/app.dart';

void main() {
  testWidgets('onboarding to empty dashboard and product validation', (
    tester,
  ) async {
    final db = AppDatabase(NativeDatabase.memory());
    final store = Store(db);
    await store.load();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [storeProvider.overrideWith((ref) => store)],
        child: const UntungkuApp(),
      ),
    );
    expect(find.text('Usaha rapi.\nUntung lebih pasti.'), findsOneWidget);
    await tester.tap(find.text('Mulai / lewati pengenalan'));
    await tester.pumpAndSettle();
    expect(find.text('Kabar usaha Anda'), findsOneWidget);
    await tester.tap(find.text('Produk'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tambah produk'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Simpan produk'), 300);
    await tester.tap(find.text('Simpan produk'));
    await tester.pumpAndSettle();
    expect(find.text('Wajib diisi'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    store.dispose();
    await db.close();
  });
}
