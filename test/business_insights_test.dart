import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:untungku_pro/data/database.dart';
import 'package:untungku_pro/data/store.dart';
import 'package:untungku_pro/domain/models.dart';
import 'package:untungku_pro/domain/business/insights.dart';
import 'package:untungku_pro/domain/business/returns.dart';
import 'package:untungku_pro/features/app.dart';

final now = DateTime(2026, 11, 4, 12);
Product product({int stock = 3, String created = '2026-10-01'}) => Product(
  id: 'p',
  name: 'Kopi',
  price: 10000,
  cost: 9999,
  stock: stock,
  threshold: 1,
  created: created,
  updated: created,
);
Sale sale(
  String id,
  String date, {
  int price = 10000,
  int cost = 5000,
  bool voided = false,
}) => Sale(
  id: id,
  date: date,
  voided: voided,
  lines: [
    SaleLine(
      productId: 'p',
      name: 'Nama saat jual',
      quantity: 2,
      price: price,
      cost: cost,
      packaging: 0,
      extra: 0,
    ),
  ],
);
void main() {
  setUpAll(() => initializeDateFormatting('id_ID'));
  test(
    'empty and insufficient data do not predict stock or claim a revenue comparison',
    () {
      expect(
        businessInsights(products: [], sales: [], expenses: [], now: now),
        isEmpty,
      );
      final insights = businessInsights(
        products: [product(created: '2026-11-03')],
        sales: [sale('s', '2026-11-04')],
        expenses: [],
        now: now,
      );
      expect(insights.where((i) => i.id.startsWith('depletion')), isEmpty);
      expect(insights.where((i) => i.id == 'revenue-trend'), isEmpty);
      expect(
        insights.where((i) => i.id.startsWith('margin')),
        isEmpty,
      ); // Snapshot cost, not current cost.
    },
  );
  test(
    'revenue, profit and depletion rules have deterministic periods and explain calculations',
    () {
      final sales = [
        for (final date in ['2026-10-30', '2026-11-01', '2026-11-03'])
          sale(date, date),
        for (final date in ['2026-10-23', '2026-10-25', '2026-10-27'])
          sale(date, date, price: 20000),
      ];
      final first = businessInsights(
        products: [product()],
        sales: sales,
        expenses: [],
        now: now,
      );
      final second = businessInsights(
        products: [product()],
        sales: sales.reversed.toList(),
        expenses: [],
        now: now,
      );
      expect(
        first.map((i) => (i.id, i.title, i.explanation)),
        second.map((i) => (i.id, i.title, i.explanation)),
      );
      expect(
        first.singleWhere((i) => i.id == 'revenue-trend').title,
        contains('turun 50%'),
      );
      final stock = first.singleWhere((i) => i.id == 'depletion:p');
      expect(stock.title, contains('4 hari'));
      expect(stock.explanation, contains('6 unit bersih'));
      expect(stock.explanation, contains('2026-10-29'));
      expect(first.any((i) => i.id == 'profit-decline'), true);
      expect(first.any((i) => i.id.startsWith('margin')), false);
    },
  );
  test(
    'returns, cancellations and future sales do not inflate velocity or negative-stock predictions',
    () {
      final original = sale('returned', '2026-11-01');
      final returned = Sale.fromJson(
        original.toJson(),
        adjustments: [
          const ReturnAdjustment(
            id: 'r',
            saleId: 'returned',
            date: '2026-11-02',
            reason: 'Retur',
            quantities: {0: 2},
            restocked: {0},
            revenueReduction: 20000,
            restoredCost: 10000,
            recoveredFees: 0,
            refundEntitlement: 20000,
          ),
        ],
      );
      final insights = businessInsights(
        products: [product(stock: -1)],
        sales: [
          returned,
          sale('void', '2026-11-03', voided: true),
          sale('future', '2026-11-05'),
        ],
        expenses: [],
        now: now,
      );
      expect(insights.single.id, 'stock-empty');
      expect(insights.single.severity, InsightSeverity.critical);
    },
  );
  test(
    'overdue balances subtract partial payment and expense alerts exclude unknown baselines',
    () {
      final credit = Sale.fromJson({
        ...sale('credit', '2026-10-20').toJson(),
        'credit': true,
        'customer': 'Rina',
        'dueDate': '2026-10-25',
        'payments': [
          const SalePayment(
            id: 'pay',
            date: '2026-11-01',
            amount: 5000,
            method: 'Tunai',
          ).toJson(),
        ],
      });
      final insights = businessInsights(
        products: [],
        sales: [credit],
        expenses: [
          const Expense(
            id: 'e',
            date: '2026-11-01',
            category: 'Ongkir',
            note: '',
            amount: 4000,
          ),
        ],
        now: now,
      );
      expect(
        insights.singleWhere((i) => i.id == 'receivables-overdue').explanation,
        contains('15000 Rupiah'),
      );
      expect(insights.any((i) => i.id == 'expense-increase'), false);
      expect(insights.any((i) => i.id == 'profit-negative'), true);
    },
  );
  testWidgets(
    'insight snooze survives backup and can be restored without financial changes',
    (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      final store = Store(db);
      await store.load();
      await store.saveProduct(product(stock: 0));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [storeProvider.overrideWith((ref) => store)],
          child: const MaterialApp(home: BusinessInsightsPage()),
        ),
      );
      await tester.pumpAndSettle();
      final hide = find.text('Sembunyikan 7 hari');
      await tester.ensureVisible(hide);
      await tester.tap(hide);
      await tester.pumpAndSettle();
      expect(find.text('Sembunyikan 7 hari'), findsNothing);
      await store.restore(store.backup());
      await tester.pumpAndSettle();
      expect(find.text('Sembunyikan 7 hari'), findsNothing);
      await tester.tap(find.text('Tampilkan catatan yang disembunyikan'));
      await tester.pumpAndSettle();
      final restore = find.text('Tampilkan kembali');
      await tester.ensureVisible(restore);
      await tester.tap(restore);
      await tester.pumpAndSettle();
      expect(find.text('Sembunyikan 7 hari'), findsOneWidget);
      expect(store.sales, isEmpty);
      expect(await store.cashLedger(), isEmpty);
      await tester.pumpWidget(const SizedBox());
      await db.close();
    },
  );
}
