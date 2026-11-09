import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:untungku_pro/data/database.dart';
import 'package:untungku_pro/data/store.dart';
import 'package:untungku_pro/domain/models.dart';
import 'package:untungku_pro/features/app.dart';
import 'package:untungku_pro/services/ads.dart';

void main() {
  test(
    'first warm resume qualifies, short returns and ad lifecycle do not',
    () {
      var now = DateTime(2026, 11, 9);
      final policy = WarmResumePolicy(clock: () => now);
      expect(policy.resume(), isFalse); // Cold start.
      policy.background(fullscreen: false);
      now = now.add(const Duration(seconds: 29));
      expect(policy.resume(), isFalse);
      policy.background(fullscreen: false);
      now = now.add(const Duration(seconds: 30));
      expect(policy.resume(), isTrue); // No two-return skip.
      expect(policy.resume(), isFalse); // Consumed once.
      policy.background(fullscreen: true);
      now = now.add(const Duration(minutes: 2));
      expect(policy.resume(), isFalse);
    },
  );

  test(
    'reward unlock expires exactly, is process only and leaves ad quiet time separate',
    () {
      var now = DateTime(2026, 11, 9);
      final access = RewardAccess(clock: () => now);
      addTearDown(access.dispose);
      expect(access.unlocked, isFalse);
      access.earn();
      expect(access.unlocked, isTrue);
      now = now.add(const Duration(minutes: 30));
      expect(access.unlocked, isFalse);
      final restarted = RewardAccess(clock: () => now);
      addTearDown(restarted.dispose);
      expect(restarted.unlocked, isFalse);
    },
  );

  testWidgets(
    'new product is committed before completion confirmation; edits do not show it',
    (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      final store = Store(db);
      await store.load();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [storeProvider.overrideWith((ref) => store)],
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: FilledButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProductForm()),
                  ),
                  child: const Text('New product'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('New product'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(0), 'New item');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Simpan produk').hitTestable(),
        250,
        scrollable: find
            .descendant(
              of: find.byType(ProductForm),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Simpan produk'));
      await tester.pumpAndSettle();
      expect(store.products.single.name, 'New item');
      expect(find.text('Produk tersimpan'), findsOneWidget);
      expect(find.byType(ProductForm), findsOneWidget);
      await tester.tap(find.text('Selesai'));
      await tester.pumpAndSettle();
      expect(find.byType(ProductForm), findsNothing);
      final context = tester.element(find.text('New product'));
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductForm(product: store.products.single),
        ),
      );
      await tester.pumpAndSettle();
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Simpan produk').hitTestable(),
        250,
        scrollable: find
            .descendant(
              of: find.byType(ProductForm),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Simpan produk'));
      await tester.pumpAndSettle();
      expect(find.text('Produk tersimpan'), findsNothing);
      expect(find.byType(ProductForm), findsNothing);
      expect(store.products, hasLength(1));
      await tester.pumpWidget(const SizedBox());
      await db.close();
    },
    skip: liveAdsEnabled,
  );

  testWidgets(
    'native slots follow every third filtered product, selected tab only',
    (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      final store = Store(db);
      await store.load();
      for (var i = 0; i < 7; i++) {
        await store.saveProduct(
          Product(
            id: 'p$i',
            name: 'Item $i',
            sku: '',
            category: '',
            cost: 100,
            price: 200,
            packaging: 0,
            extra: 0,
            stock: 1,
            threshold: 0,
            created: '2026-11-09',
            updated: '2026-11-09',
            archived: false,
          ),
        );
      }
      Future<void> show(bool active, double width) async {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1;
        await tester.pumpWidget(
          ProviderScope(
            overrides: [storeProvider.overrideWith((ref) => store)],
            child: MaterialApp(
              home: Scaffold(body: ProductsPage(active: active)),
            ),
          ),
        );
        await tester.pump();
      }

      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      List<Widget> children() =>
          tester.widget<PageBody>(find.byType(PageBody)).children;
      await show(true, 400);
      final rows = children()
          .where((w) => w is Card || w is OptionalNativeAd)
          .toList();
      expect(rows.map((w) => w is OptionalNativeAd).toList(), [
        false,
        false,
        false,
        true,
        false,
        false,
        false,
        true,
        false,
      ]);
      await tester.enterText(find.byType(TextField), 'Item 0');
      await tester.pump();
      expect(children().whereType<OptionalNativeAd>(), isEmpty);
      await tester.enterText(find.byType(TextField), '');
      await show(false, 400);
      expect(children().whereType<OptionalNativeAd>(), isEmpty);
      await show(true, 320);
      expect(children().whereType<OptionalNativeAd>(), isEmpty);
      await tester.pumpWidget(const SizedBox());
      await db.close();
    },
    skip: liveAdsEnabled,
  );
}
