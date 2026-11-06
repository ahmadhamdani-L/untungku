import 'dart:convert';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:untungku_pro/data/database.dart';
import 'package:untungku_pro/data/store.dart';
import 'package:untungku_pro/domain/business/cashflow.dart';
import 'package:untungku_pro/domain/business/entities.dart';
import 'package:untungku_pro/domain/models.dart';
import 'package:untungku_pro/features/app.dart';
import 'package:untungku_pro/services/reports/cashflow_pdf.dart';

void main() {
  final start = DateTime(2026, 11, 4), end = DateTime(2026, 11, 5);
  const date = '2026-11-04T10:00:00';
  setUpAll(() => initializeDateFormatting('id_ID'));
  test(
    'date boundaries and account scopes reconcile without treating transfers as receipts',
    () {
      final ledger = [
        const CashEntry(
          id: 'opening',
          reference: 'o',
          category: 'owner_capital',
          date: '2026-11-03',
          amount: 100000,
          accountId: 'cash',
        ),
        const CashEntry(
          id: 'sale',
          reference: '=sale',
          category: 'sale_receipt',
          date: '2026-11-04',
          amount: 20000,
          accountId: 'cash',
        ),
        const CashEntry(
          id: 'out',
          reference: 't',
          category: 'transfer',
          date: date,
          amount: -30000,
          accountId: 'cash',
        ),
        const CashEntry(
          id: 'in',
          reference: 't',
          category: 'transfer',
          date: date,
          amount: 30000,
          accountId: 'bank',
        ),
        const CashEntry(
          id: 'legacy',
          reference: 'legacy',
          category: 'legacy_collection',
          date: date,
          amount: 5000,
        ),
        const CashEntry(
          id: 'expense',
          reference: 'e',
          category: 'operational_expense',
          date: date,
          amount: -2000,
          accountId: 'cash',
        ),
        const CashEntry(
          id: 'tomorrow',
          reference: 'next',
          category: 'sale_receipt',
          date: '2026-11-05',
          amount: 99999,
          accountId: 'cash',
        ),
      ];
      final all = cashflowReport(ledger, start: start, end: end);
      expect(all.opening, 100000);
      expect(all.inflow, 25000);
      expect(all.outflow, 2000);
      expect(all.transferNet, 0);
      expect(all.closing, 123000);
      final cash = cashflowReport(
        ledger,
        start: start,
        end: end,
        allAccounts: false,
        accountId: 'cash',
      );
      final bank = cashflowReport(
        ledger,
        start: start,
        end: end,
        allAccounts: false,
        accountId: 'bank',
      );
      final legacy = cashflowReport(
        ledger,
        start: start,
        end: end,
        allAccounts: false,
      );
      expect(cash.closing, 88000);
      expect(bank.closing, 30000);
      expect(legacy.closing, 5000);
      expect(cash.closing + bank.closing + legacy.closing, all.closing);
      expect(cash.variance(87000), -1000);
      expect(all.csv(), contains('"\'=sale"'));
      expect(all.csv(), contains('Belum dialokasikan'));
      expect(all.csv(), isNot(contains('tomorrow')));
      expect(
        () => cashflowReport(ledger, start: end, end: start),
        throwsArgumentError,
      );
    },
  );
  test(
    'expense account correction appends compensation, repeats safely and can reverse archived source',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      final store = Store(db);
      addTearDown(() async {
        store.dispose();
        await db.close();
      });
      await store.load();
      await store.saveCashAccount(const CashAccount(id: 'cash', name: 'Laci'));
      await store.saveCashAccount(const CashAccount(id: 'bank', name: 'Bank'));
      const expense = Expense(
        id: 'e',
        date: date,
        category: 'Transportasi',
        note: '',
        amount: 2000,
      );
      await store.saveExpense(expense, accountId: 'cash');
      final original = (await store.cashLedger()).single.toJson();
      await store.saveCashAccount(
        const CashAccount(id: 'cash', name: 'Laci', archived: true),
      );
      await store.saveExpense(expense, accountId: 'bank');
      await store.saveExpense(expense, accountId: 'bank');
      expect(await store.cashBalances(), {'cash': 0, 'bank': -2000});
      expect((await store.cashLedger()).length, 3);
      expect((await store.cashLedger()).first.toJson(), original);
      final report = await store.cashflow(start: start, end: DateTime(2200));
      expect(report.closing, -2000);
      expect(report.categories['expense_reversal'], 2000);
    },
  );
  test(
    'daily closing includes collection cash but never invents cash for unpaid credit',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      final store = Store(db);
      addTearDown(() async {
        store.dispose();
        await db.close();
      });
      await store.load();
      await store.saveProduct(
        const Product(
          id: 'p',
          name: 'Kopi',
          price: 10000,
          cost: 5000,
          stock: 10,
          created: date,
          updated: date,
        ),
      );
      await store.saveCashAccount(const CashAccount(id: 'cash', name: 'Laci'));
      await store.saveSale(
        const Sale(
          id: 'credit',
          date: date,
          credit: true,
          customer: 'Rina',
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
        ),
      );
      expect((await store.cashflow(start: start, end: end)).closing, 0);
      await store.recordPayment(
        'credit',
        const SalePayment(
          id: 'pay',
          date: date,
          amount: 4000,
          method: 'Tunai',
          accountId: 'cash',
        ),
      );
      final report = await store.cashflow(start: start, end: end);
      expect(report.inflow, 4000);
      expect(report.closing, 4000);
      expect(report.variance(3500), -500);
      expect(store.sales.single.result.revenue, 10000);
      expect(store.sales.single.outstanding, 6000);
      expect(await store.cashBalances(), {'cash': 4000});
    },
  );
  test(
    'offline PDF paginates a large ledger and includes closing summary',
    () async {
      final report = cashflowReport(
        [
          for (var i = 0; i < 600; i++)
            CashEntry(
              id: '$i',
              reference: 'sale-$i',
              category: 'sale_receipt',
              date: date,
              amount: 1000,
              accountId: 'cash',
            ),
        ],
        start: start,
        end: end,
      );
      final bytes = await cashflowPdf(
        report,
        business: 'Toko Uji',
        counted: 599000,
      );
      final pdf = latin1.decode(bytes);
      expect(pdf.startsWith('%PDF-'), true);
      expect(pdf.trimRight().endsWith('%%EOF'), true);
      expect(RegExp(r'/Type\s*/Page\b').allMatches(pdf).length, greaterThan(1));
      expect(report.closing, 600000);
      expect(report.variance(599000), -1000);
    },
  );
  testWidgets(
    'report filters and daily counted cash do not write financial records',
    (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      final store = Store(db);
      await store.load();
      await store.saveCashAccount(const CashAccount(id: 'cash', name: 'Laci'));
      await store.recordCash(
        id: 'capital',
        accountId: 'cash',
        amount: 10000,
        category: 'owner_capital',
        date: DateTime.now().toIso8601String(),
      );
      final before = (await store.cashLedger()).map((r) => r.toJson()).toList();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [storeProvider.overrideWith((ref) => store)],
          child: const MaterialApp(home: CashReportsPage()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Saldo akhir tercatat'), findsOneWidget);
      final counted = find.widgetWithText(TextFormField, 'Uang dihitung (Rp)');
      await tester.ensureVisible(counted);
      await tester.enterText(counted, '9000');
      await tester.pumpAndSettle();
      expect(find.text('Selisih terhadap catatan'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Kemarin').hitTestable(),
        -200,
        scrollable: find
            .descendant(
              of: find.byType(CashReportsPage),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.tap(find.text('Kemarin'));
      await tester.pumpAndSettle();
      expect(
        (await store.cashLedger()).map((r) => r.toJson()).toList(),
        before,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await db.close();
    },
  );
}
