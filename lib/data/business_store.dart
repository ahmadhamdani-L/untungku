part of 'store.dart';

String canonicalJson(Object? value) {
  Object? sorted(Object? v) {
    if (v is Map) {
      final keys = v.keys.map((e) => e.toString()).toList()..sort();
      return {for (final k in keys) k: sorted(v[k])};
    }
    if (v is List) return v.map(sorted).toList();
    return v;
  }

  return jsonEncode(sorted(value));
}

extension BusinessStore on Store {
  Future<bool> businessOperation(
    String id,
    String kind,
    Map<String, dynamic> data,
    Future<void> Function() write,
  ) async {
    requiredText(id, 'Referensi operasi');
    final payload = canonicalJson({'kind': kind, 'data': data});
    return db.transaction(() async {
      final existing = await (db.select(
        db.operationRows,
      )..where((r) => r.id.equals(id))).getSingleOrNull();
      if (existing != null) {
        if (existing.payload != payload) {
          throw StateError(
            'Referensi operasi telah dipakai untuk data berbeda',
          );
        }
        return false;
      }
      await write();
      await db
          .into(db.operationRows)
          .insert(OperationRowsCompanion.insert(id: id, payload: payload));
      return true;
    });
  }

  Future<Map<String, List<Map<String, dynamic>>>> businessSnapshot() async => {
    'customers': (await db.select(db.customerRows).get())
        .map((r) => r.toJson())
        .toList(),
    'suppliers': (await db.select(db.supplierRows).get())
        .map((r) => r.toJson())
        .toList(),
    'cashAccounts': (await db.select(db.cashAccountRows).get())
        .map((r) => r.toJson())
        .toList(),
    'operations': (await db.select(db.operationRows).get())
        .map((r) => r.toJson())
        .toList(),
    'purchases': (await db.select(db.purchaseRows).get())
        .map((r) => r.toJson())
        .toList(),
    'receipts': (await db.select(db.stockReceiptRows).get())
        .map((r) => r.toJson())
        .toList(),
    'purchasePayments': (await db.select(db.purchasePaymentRows).get())
        .map((r) => r.toJson())
        .toList(),
    'saleCustomers': (await db.select(db.saleCustomerRows).get())
        .map((r) => r.toJson())
        .toList(),
    'returns': (await db.select(db.returnRows).get())
        .map((r) => r.toJson())
        .toList(),
    'refunds': (await db.select(db.refundRows).get())
        .map((r) => r.toJson())
        .toList(),
    'opnames': (await db.select(db.opnameRows).get())
        .map((r) => r.toJson())
        .toList(),
    'cashMovements': (await db.select(db.cashMovementRows).get())
        .map((r) => r.toJson())
        .toList(),
  };
  Future<void> clearBusinessDataForRestore() async {
    await db.delete(db.refundRows).go();
    await db.delete(db.returnRows).go();
    await db.delete(db.saleCustomerRows).go();
    await db.delete(db.stockReceiptRows).go();
    await db.delete(db.purchasePaymentRows).go();
    await db.delete(db.purchaseRows).go();
    await db.delete(db.opnameRows).go();
    await db.delete(db.cashMovementRows).go();
    await db.delete(db.customerRows).go();
    await db.delete(db.supplierRows).go();
    await db.delete(db.cashAccountRows).go();
    await db.delete(db.operationRows).go();
  }

  Future<void> restoreBusinessSnapshot(Map<String, dynamic> j) async {
    for (final r in j['customers']) {
      await db
          .into(db.customerRows)
          .insert(CustomerRow.fromJson(Map<String, dynamic>.from(r)));
    }
    for (final r in j['suppliers']) {
      await db
          .into(db.supplierRows)
          .insert(SupplierRow.fromJson(Map<String, dynamic>.from(r)));
    }
    for (final r in j['cashAccounts']) {
      await db
          .into(db.cashAccountRows)
          .insert(CashAccountRow.fromJson(Map<String, dynamic>.from(r)));
    }
    for (final r in j['operations']) {
      await db
          .into(db.operationRows)
          .insert(OperationRow.fromJson(Map<String, dynamic>.from(r)));
    }
    for (final r in j['purchases']) {
      await db
          .into(db.purchaseRows)
          .insert(PurchaseRow.fromJson(Map<String, dynamic>.from(r)));
    }
    for (final r in j['receipts']) {
      await db
          .into(db.stockReceiptRows)
          .insert(StockReceiptRow.fromJson(Map<String, dynamic>.from(r)));
    }
    for (final r in j['purchasePayments']) {
      await db
          .into(db.purchasePaymentRows)
          .insert(PurchasePaymentRow.fromJson(Map<String, dynamic>.from(r)));
    }
    for (final r in j['saleCustomers']) {
      await db
          .into(db.saleCustomerRows)
          .insert(SaleCustomerRow.fromJson(Map<String, dynamic>.from(r)));
    }
    for (final r in j['returns']) {
      await db
          .into(db.returnRows)
          .insert(ReturnRow.fromJson(Map<String, dynamic>.from(r)));
    }
    for (final r in j['refunds']) {
      await db
          .into(db.refundRows)
          .insert(RefundRow.fromJson(Map<String, dynamic>.from(r)));
    }
    for (final r in j['opnames']) {
      await db
          .into(db.opnameRows)
          .insert(OpnameRow.fromJson(Map<String, dynamic>.from(r)));
    }
    for (final r in j['cashMovements']) {
      await db
          .into(db.cashMovementRows)
          .insert(CashMovementRow.fromJson(Map<String, dynamic>.from(r)));
    }
  }

  Future<List<Contact>> contacts({bool suppliers = false}) async {
    if (suppliers) {
      return (await db.select(db.supplierRows).get())
          .map((r) => Contact.fromJson(jsonDecode(r.payload)))
          .toList();
    }
    return (await db.select(db.customerRows).get())
        .map((r) => Contact.fromJson(jsonDecode(r.payload)))
        .toList();
  }

  Future<void> saveContact(
    Contact contact, {
    bool supplier = false,
    String? expectedUpdated,
  }) async {
    contact.validate();
    await db.transaction(() async {
      final existing = supplier
          ? (await (db.select(
                  db.supplierRows,
                )..where((r) => r.id.equals(contact.id))).getSingleOrNull())
                ?.payload
          : (await (db.select(
                  db.customerRows,
                )..where((r) => r.id.equals(contact.id))).getSingleOrNull())
                ?.payload;
      if (existing != null &&
          expectedUpdated != null &&
          Contact.fromJson(jsonDecode(existing)).updated != expectedUpdated) {
        throw StateError('Kontak berubah; buka kembali formulir');
      }
      if (supplier) {
        await db
            .into(db.supplierRows)
            .insertOnConflictUpdate(
              SupplierRowsCompanion.insert(
                id: contact.id,
                payload: jsonEncode(contact.toJson()),
              ),
            );
      } else {
        await db
            .into(db.customerRows)
            .insertOnConflictUpdate(
              CustomerRowsCompanion.insert(
                id: contact.id,
                payload: jsonEncode(contact.toJson()),
              ),
            );
      }
    });
    await load();
  }

  Future<Map<String, String>> customerLinks() async => {
    for (final r in await db.select(db.saleCustomerRows).get())
      r.saleId: r.customerId,
  };
  Future<void> linkCustomerInTransaction(
    String saleId,
    String customerId,
  ) async {
    final row = await (db.select(
      db.customerRows,
    )..where((r) => r.id.equals(customerId))).getSingle();
    if (Contact.fromJson(jsonDecode(row.payload)).archived) {
      throw ArgumentError('Pelanggan diarsipkan');
    }
    await db
        .into(db.saleCustomerRows)
        .insertOnConflictUpdate(
          SaleCustomerRowsCompanion.insert(
            saleId: saleId,
            customerId: customerId,
          ),
        );
  }

  Future<void> linkCustomer(
    String saleId,
    String customerId, {
    String? operationId,
  }) async {
    await businessOperation(operationId ?? uuid.v4(), 'linkCustomer', {
      'sale': saleId,
      'customer': customerId,
    }, () => linkCustomerInTransaction(saleId, customerId));
    await load();
  }

  Future<List<CashAccount>> cashAccounts() async =>
      (await db.select(db.cashAccountRows).get())
          .map((r) => CashAccount.fromJson(jsonDecode(r.payload)))
          .toList();
  Future<void> saveCashAccount(CashAccount account) async {
    account.validate();
    await db
        .into(db.cashAccountRows)
        .insertOnConflictUpdate(
          CashAccountRowsCompanion.insert(
            id: account.id,
            payload: jsonEncode(account.toJson()),
          ),
        );
    await load();
  }

  Future<void> checkAccount(String? id, {bool allowArchived = false}) async {
    if (id == null) return;
    final row = await (db.select(
      db.cashAccountRows,
    )..where((r) => r.id.equals(id))).getSingle();
    if (!allowArchived &&
        CashAccount.fromJson(jsonDecode(row.payload)).archived) {
      throw ArgumentError('Akun kas diarsipkan');
    }
  }

  Future<void> postCash({
    required String id,
    required String reference,
    required String date,
    required String category,
    required int amount,
    String? accountId,
  }) async {
    requiredText(id, 'ID posting kas');
    validDate(date);
    validMoney(amount.abs());
    requiredText(reference, 'Referensi kas');
    requiredText(category, 'Kategori kas');
    await db.transaction(() async {
      final existing = await (db.select(
        db.cashMovementRows,
      )..where((r) => r.id.equals(id))).getSingleOrNull();
      if (existing != null) {
        if (existing.accountId != accountId ||
            existing.reference != reference ||
            existing.category != category ||
            existing.date != date ||
            existing.amount != amount) {
          throw StateError('Posting kas berbeda memakai referensi yang sama');
        }
        return;
      }
      if (amount == 0) return;
      await checkAccount(
        accountId,
        allowArchived:
            category == 'expense_reversal' ||
            category == 'sale_receipt_revision',
      );
      await db
          .into(db.cashMovementRows)
          .insert(
            CashMovementRowsCompanion.insert(
              id: id,
              accountId: Value(accountId),
              reference: reference,
              date: date,
              category: category,
              amount: amount,
            ),
          );
    });
  }

  Future<List<CashMovementRow>> cashLedger() =>
      db.select(db.cashMovementRows).get();
  Future<CashflowReport> cashflow({
    required DateTime start,
    required DateTime end,
    bool allAccounts = true,
    String? accountId,
  }) async => cashflowReport(
    (await cashLedger()).map(
      (r) => CashEntry(
        id: r.id,
        reference: r.reference,
        category: r.category,
        date: r.date,
        amount: r.amount,
        accountId: r.accountId,
      ),
    ),
    start: start,
    end: end,
    allAccounts: allAccounts,
    accountId: accountId,
  );

  Future<Map<String?, int>> cashBalances() async {
    final result = <String?, int>{};
    for (final row in await cashLedger()) {
      result.update(
        row.accountId,
        (v) => v + row.amount,
        ifAbsent: () => row.amount,
      );
    }
    return result;
  }

  Future<void> recordCash({
    required String id,
    required String accountId,
    required int amount,
    required String category,
    required String date,
    String? destination,
  }) async {
    if (![
      'owner_capital',
      'owner_withdrawal',
      'opening_adjustment',
      'transfer',
      'fee_settlement',
    ].contains(category)) {
      throw ArgumentError('Kategori pencatatan kas tidak valid');
    }
    if (amount == 0 || (category != 'opening_adjustment' && amount < 0)) {
      throw ArgumentError('Nominal kas tidak valid');
    }
    if (category == 'transfer' &&
        (destination == null || destination == accountId)) {
      throw ArgumentError('Pilih akun tujuan berbeda');
    }
    await businessOperation(
      id,
      'cash',
      {
        'account': accountId,
        'amount': amount,
        'category': category,
        'date': date,
        'destination': destination,
      },
      () async {
        final sign =
            [
              'owner_withdrawal',
              'transfer',
              'fee_settlement',
            ].contains(category)
            ? -1
            : 1;
        await postCash(
          id: '$id:out',
          reference: id,
          date: date,
          category: category,
          amount: amount * sign,
          accountId: accountId,
        );
        if (category == 'transfer') {
          await postCash(
            id: '$id:in',
            reference: id,
            date: date,
            category: category,
            amount: amount,
            accountId: destination,
          );
        }
      },
    );
    await load();
  }

  /// Explicitly derived/unallocated history, never assigned to a real cash account.
  Future<void> initializeLegacyCash() async {
    await db.transaction(() async {
      final marker =
          await (db.select(db.operationRows)
                ..where((r) => r.id.equals('migration:legacy-cash:v2')))
              .getSingleOrNull();
      if (marker != null) return;
      for (final sale in sales.where((s) => !s.voided)) {
        if (!sale.credit) {
          await postCash(
            id: 'sale:${sale.id}:cash',
            reference: sale.id,
            date: sale.date,
            category: 'legacy_sale_receipt',
            amount: sale.result.revenue,
          );
        } else {
          for (final p in sale.payments) {
            await postCash(
              id: 'payment:${sale.id}:${p.id}',
              reference: sale.id,
              date: p.date,
              category: 'legacy_collection',
              amount: p.amount,
            );
          }
        }
      }
      for (final e in expenses) {
        await postCash(
          id: 'expense:${e.id}',
          reference: e.id,
          date: e.date,
          category: 'legacy_expense',
          amount: -e.amount,
        );
      }
      await db
          .into(db.operationRows)
          .insert(
            OperationRowsCompanion.insert(
              id: 'migration:legacy-cash:v2',
              payload:
                  'Derived from active historical records; account allocations and actual opening balances unknown',
            ),
          );
    });
  }

  Future<void> syncSaleCash(Sale? old, Sale sale) async {
    if (old != null && !old.credit) {
      await postCash(
        id: 'sale:${sale.id}:revision:${uuid.v4()}',
        reference: sale.id,
        date: DateTime.now().toIso8601String(),
        category: 'sale_receipt_revision',
        amount: -old.result.revenue,
        accountId: old.accountId,
      );
    }
    if (!sale.credit) {
      await postCash(
        id: old == null
            ? 'sale:${sale.id}:cash'
            : 'sale:${sale.id}:revision:${uuid.v4()}',
        reference: sale.id,
        date: sale.date,
        category: 'sale_receipt',
        amount: sale.result.revenue,
        accountId: sale.accountId,
      );
    } else if (old == null) {
      for (final p in sale.payments) {
        await postCash(
          id: 'payment:${sale.id}:${p.id}',
          reference: sale.id,
          date: p.date,
          category: 'sale_receipt',
          amount: p.amount,
          accountId: p.accountId,
        );
      }
    }
  }

  Future<Map<String?, int>> expenseCashTotals(String expenseId) async {
    final rows = await (db.select(
      db.cashMovementRows,
    )..where((r) => r.reference.equals(expenseId))).get();
    final totals = <String?, int>{};
    for (final r in rows.where(
      (r) => const {
        'operational_expense',
        'legacy_expense',
        'expense_reversal',
      }.contains(r.category),
    )) {
      totals.update(r.accountId, (v) => v + r.amount, ifAbsent: () => r.amount);
    }
    return totals..removeWhere((key, value) => value == 0);
  }

  Future<void> reverseExpenseCash(String expenseId) async {
    final totals = await expenseCashTotals(expenseId);
    for (final e in totals.entries.where((e) => e.value != 0)) {
      await postCash(
        id: 'expense-reversal:${uuid.v4()}',
        reference: expenseId,
        date: DateTime.now().toIso8601String(),
        category: 'expense_reversal',
        amount: -e.value,
        accountId: e.key,
      );
    }
  }

  Future<List<Map<String, dynamic>>> purchasePaymentHistory(String id) async =>
      (await (db.select(
            db.purchasePaymentRows,
          )..where((r) => r.purchaseId.equals(id))).get())
          .map((r) => Map<String, dynamic>.from(jsonDecode(r.payload)))
          .toList();
  Future<List<Map<String, dynamic>>> opnameSessions() async =>
      (await db.select(db.opnameRows).get())
          .map((r) => Map<String, dynamic>.from(jsonDecode(r.payload)))
          .toList();

  Future<List<SupplierPayable>> payableReport() => db.transaction(() async {
    final payments = <String, int>{};
    for (final row in await db.select(db.purchasePaymentRows).get()) {
      final amount = jsonDecode(row.payload)['amount'] as int;
      payments.update(
        row.purchaseId,
        (v) => v + amount,
        ifAbsent: () => amount,
      );
    }
    return supplierPayables(await purchases(), payments);
  });

  Future<List<Purchase>> purchases() async =>
      (await db.select(db.purchaseRows).get())
          .map((r) => Purchase.fromJson(jsonDecode(r.payload)))
          .toList();
  Future<Purchase> purchase(String id) async => Purchase.fromJson(
    jsonDecode(
      (await (db.select(
        db.purchaseRows,
      )..where((r) => r.id.equals(id))).getSingle()).payload,
    ),
  );
  Future<void> writePurchase(Purchase p) async => db
      .into(db.purchaseRows)
      .insertOnConflictUpdate(
        PurchaseRowsCompanion.insert(
          id: p.id,
          supplierId: Value(p.supplierId),
          payload: jsonEncode(p.toJson()),
        ),
      );
  Future<void> savePurchaseDraft(Purchase p) async {
    p.validate();
    if (p.status != 'draft') throw ArgumentError('Hanya draf dapat diubah');
    await db.transaction(() async {
      final row = await (db.select(
        db.purchaseRows,
      )..where((r) => r.id.equals(p.id))).getSingleOrNull();
      if (row != null &&
          Purchase.fromJson(jsonDecode(row.payload)).status != 'draft') {
        throw StateError('Pembelian telah dikonfirmasi');
      }
      if (p.supplierId != null) {
        final s = await (db.select(
          db.supplierRows,
        )..where((r) => r.id.equals(p.supplierId!))).getSingle();
        if (Contact.fromJson(jsonDecode(s.payload)).archived) {
          throw ArgumentError('Pemasok diarsipkan');
        }
      }
      for (final l in p.lines) {
        final product = await productInTransaction(l.productId);
        if (product.archived) throw ArgumentError('Produk diarsipkan');
      }
      await writePurchase(p);
    });
    await load();
  }

  Future<void> confirmPurchase(String id, String operationId) async {
    await businessOperation(
      operationId,
      'confirmPurchase',
      {'purchase': id},
      () async {
        final p = await purchase(id);
        if (p.status == 'confirmed') return;
        if (p.status != 'draft') {
          throw StateError('Pembelian tidak dapat dikonfirmasi');
        }
        await writePurchase(
          Purchase.fromJson({...p.toJson(), 'status': 'confirmed'}),
        );
      },
    );
    await load();
  }

  Future<Map<String, int>> receivedQuantities(String purchaseId) async {
    final result = <String, int>{};
    for (final r in await (db.select(
      db.stockReceiptRows,
    )..where((r) => r.purchaseId.equals(purchaseId))).get()) {
      final j = jsonDecode(r.payload);
      final sign = j['reversed'] == true ? -1 : 1;
      for (final e in (j['quantities'] as Map).entries) {
        result.update(
          e.key,
          (v) => v + (e.value as int) * sign,
          ifAbsent: () => (e.value as int) * sign,
        );
      }
    }
    return result;
  }

  Future<int> purchasePaid(String id) async =>
      (await (db.select(
        db.purchasePaymentRows,
      )..where((r) => r.purchaseId.equals(id))).get()).fold<int>(
        0,
        (v, r) => v + (jsonDecode(r.payload)['amount'] as int),
      );
  Future<void> receivePurchase({
    required String id,
    required String purchaseId,
    required Map<String, int> quantities,
    required String date,
  }) async {
    validDate(date);
    await businessOperation(
      id,
      'receivePurchase',
      {'purchase': purchaseId, 'quantities': quantities, 'date': date},
      () async {
        final p = await purchase(purchaseId);
        if (p.status != 'confirmed' ||
            quantities.isEmpty ||
            quantities.values.any((q) => q < 1)) {
          throw StateError('Penerimaan tidak valid');
        }
        final previous = await receivedQuantities(purchaseId);
        final originals = <String, dynamic>{};
        final sequence = (await (db.select(
          db.stockReceiptRows,
        )..where((r) => r.purchaseId.equals(purchaseId))).get()).length;
        for (final e in quantities.entries) {
          final index = p.lines.indexWhere((l) => l.productId == e.key);
          if (index < 0) throw ArgumentError('Produk bukan bagian pembelian');
          final before = previous[e.key] ?? 0;
          if (before + e.value > p.lines[index].quantity) {
            throw ArgumentError('Jumlah melebihi pesanan');
          }
          final product = await productInTransaction(e.key);
          originals[product.id] = product.toJson();
          final newStock = product.stock + e.value;
          if (newStock > 1000000000 || product.archived) {
            throw ArgumentError('Produk tidak dapat diterima');
          }
          final value = p.receivedValue(index, before, e.value);
          final cost = weightedAverageCost(
            oldQuantity: product.stock,
            oldCost: product.cost,
            receivedQuantity: e.value,
            receivedValue: value,
          );
          await put('product', product.id, {
            ...product.toJson(),
            'stock': newStock,
            'cost': cost,
            'updated': DateTime.now().toIso8601String(),
          });
          await movement(
            product.id,
            e.value,
            'Penerimaan $id • pembelian $purchaseId',
            reference: purchaseId,
            operationId: id,
          );
        }
        await db
            .into(db.stockReceiptRows)
            .insert(
              StockReceiptRowsCompanion.insert(
                id: id,
                purchaseId: purchaseId,
                payload: jsonEncode({
                  'id': id,
                  'date': date,
                  'quantities': quantities,
                  'reversed': false,
                  'before': originals,
                  'sequence': sequence,
                }),
              ),
            );
      },
    );
    await load();
  }

  Future<void> paySupplier({
    required String id,
    required String purchaseId,
    required int amount,
    required String date,
    required String method,
    String? accountId,
  }) async {
    validMoney(amount);
    validDate(date);
    requiredText(method, 'Metode pembayaran');
    if (amount == 0) throw ArgumentError('Pembayaran harus positif');
    await businessOperation(
      id,
      'supplierPayment',
      {
        'purchase': purchaseId,
        'amount': amount,
        'date': date,
        'method': method,
        'account': accountId,
      },
      () async {
        final p = await purchase(purchaseId);
        if (p.status != 'confirmed' ||
            await purchasePaid(p.id) + amount > p.total) {
          throw ArgumentError(
            'Pembayaran melebihi utang atau pembelian tidak aktif',
          );
        }
        await postCash(
          id: 'supplier:$id',
          reference: p.id,
          date: date,
          category: 'supplier_payment',
          amount: -amount,
          accountId: accountId,
        );
        await db
            .into(db.purchasePaymentRows)
            .insert(
              PurchasePaymentRowsCompanion.insert(
                id: id,
                purchaseId: p.id,
                payload: jsonEncode({
                  'id': id,
                  'amount': amount,
                  'date': date,
                  'method': method,
                  'accountId': accountId,
                }),
              ),
            );
      },
    );
    await load();
  }

  Future<void> cancelPurchase(
    String purchaseId,
    String operationId,
    String reason,
  ) async {
    requiredText(reason, 'Alasan pembatalan');
    await businessOperation(
      operationId,
      'cancelPurchase',
      {'purchase': purchaseId, 'reason': reason},
      () async {
        final p = await purchase(purchaseId);
        if (p.status == 'cancelled') return;
        if (await purchasePaid(p.id) != 0) {
          throw StateError(
            'Pembelian yang sudah dibayar tidak dapat dibatalkan; catat penyelesaian pemasok dahulu',
          );
        }
        final quantities = await receivedQuantities(p.id);
        final receipts =
            (await (db.select(
                  db.stockReceiptRows,
                )..where((r) => r.purchaseId.equals(p.id))).get())
                .map((r) => Map<String, dynamic>.from(jsonDecode(r.payload)))
                .where((j) => j['reversed'] != true)
                .toList()
              ..sort(
                (a, b) =>
                    (b['sequence'] as int).compareTo(a['sequence'] as int),
              );
        for (final e in quantities.entries.where((e) => e.value > 0)) {
          final product = await productInTransaction(e.key);
          final history = await (db.select(
            db.movementRows,
          )..where((r) => r.productId.equals(e.key))).get();
          if (history.isEmpty ||
              !(jsonDecode(history.last.payload)['reason'] as String).contains(
                'pembelian $purchaseId',
              )) {
            throw StateError(
              'Stok telah dipakai/diubah; pembelian tidak memenuhi syarat pembatalan',
            );
          }
          final latest = receipts.firstWhere(
            (j) => (j['quantities'] as Map).containsKey(e.key),
          );
          final before = Product.fromJson(
            Map<String, dynamic>.from(latest['before'][e.key]),
          );
          if (product.stock !=
              before.stock + (latest['quantities'][e.key] as int)) {
            throw StateError('Stok berubah setelah penerimaan');
          }
        }
        for (final receipt in receipts) {
          for (final e in (receipt['quantities'] as Map).entries) {
            final before = Product.fromJson(
              Map<String, dynamic>.from(receipt['before'][e.key]),
            );
            final current = await productInTransaction(e.key);
            if (current.stock != before.stock + (e.value as int)) {
              throw StateError('Saldo penerimaan tidak cocok');
            }
            if (!allowNegativeStock && before.stock < 0) {
              throw StateError('Pembatalan akan menghasilkan stok minus');
            }
            await put('product', before.id, {
              ...current.toJson(),
              'stock': before.stock,
              'cost': before.cost,
              'updated': DateTime.now().toIso8601String(),
            });
            await movement(
              before.id,
              -(e.value as int),
              'Pembatalan pembelian $purchaseId • $operationId',
              reference: purchaseId,
              operationId: operationId,
            );
          }
          await db
              .into(db.stockReceiptRows)
              .insert(
                StockReceiptRowsCompanion.insert(
                  id: '$operationId:${receipt['id']}',
                  purchaseId: p.id,
                  payload: jsonEncode({
                    ...receipt,
                    'id': '$operationId:${receipt['id']}',
                    'reversed': true,
                    'reason': reason,
                  }),
                ),
              );
        }
        await writePurchase(
          Purchase.fromJson({
            ...p.toJson(),
            'status': 'cancelled',
            'note': '${p.note}\nDibatalkan: $reason',
          }),
        );
      },
    );
    await load();
  }

  Future<void> saveOpnameDraft({
    required String id,
    required List<OpnameItem> items,
    required String reason,
  }) async {
    requiredText(id, 'Nomor opname');
    requiredText(reason, 'Alasan opname');
    if (items.isEmpty ||
        items.map((i) => i.productId).toSet().length != items.length ||
        items.any((i) => i.counted < 0 || i.counted > 1000000000)) {
      throw ArgumentError('Daftar opname tidak valid');
    }
    await db.transaction(() async {
      final old = await (db.select(
        db.opnameRows,
      )..where((r) => r.id.equals(id))).getSingleOrNull();
      if (old != null && jsonDecode(old.payload)['confirmed'] == true) {
        throw StateError('Opname sudah diposting');
      }
      for (final i in items) {
        await productInTransaction(i.productId);
      }
      await db
          .into(db.opnameRows)
          .insertOnConflictUpdate(
            OpnameRowsCompanion.insert(
              id: id,
              payload: jsonEncode({
                'id': id,
                'items': items.map((i) => i.toJson()).toList(),
                'reason': reason,
                'confirmed': false,
              }),
            ),
          );
    });
    await load();
  }

  Future<void> confirmOpname(String id, String operationId) async {
    await businessOperation(
      operationId,
      'confirmOpname',
      {'opname': id},
      () async {
        final row = await (db.select(
          db.opnameRows,
        )..where((r) => r.id.equals(id))).getSingle();
        final j = Map<String, dynamic>.from(jsonDecode(row.payload));
        if (j['confirmed'] == true) return;
        for (final raw in j['items']) {
          final i = OpnameItem.fromJson(Map<String, dynamic>.from(raw));
          final p = await productInTransaction(i.productId);
          if (p.stock != i.expectedStock || p.updated != i.expectedUpdated) {
            throw StateError(
              'Stok ${p.name} berubah sejak dihitung; hitung ulang',
            );
          }
          if (i.difference != 0) {
            await put('product', p.id, p.copy(stock: i.counted).toJson());
            await movement(
              p.id,
              i.difference,
              'Opname $id • ${j['reason']}',
              reference: id,
              operationId: operationId,
            );
          }
        }
        await db
            .into(db.opnameRows)
            .insertOnConflictUpdate(
              OpnameRowsCompanion.insert(
                id: id,
                payload: jsonEncode({
                  ...j,
                  'confirmed': true,
                  'date': DateTime.now().toIso8601String(),
                }),
              ),
            );
      },
    );
    await load();
  }
}

void validateBusinessSnapshot(
  Map<String, dynamic> j,
  Set<String> productIds,
  Map<String, Sale> validatedSales,
) {
  final saleIds = validatedSales.keys.toSet();
  final names = [
    'customers',
    'suppliers',
    'cashAccounts',
    'operations',
    'purchases',
    'receipts',
    'purchasePayments',
    'saleCustomers',
    'returns',
    'refunds',
    'opnames',
    'cashMovements',
  ];
  final ids = <String, Set<String>>{};
  for (final name in names) {
    if (j[name] is! List) {
      throw FormatException('Bagian backup $name tidak valid');
    }
    final seen = <String>{};
    ids[name] = seen;
    for (final raw in j[name]) {
      final r = Map<String, dynamic>.from(raw);
      final id = r[name == 'saleCustomers' ? 'saleId' : 'id'];
      if (id is! String || id.isEmpty || !seen.add(id)) {
        throw FormatException('ID $name tidak valid/duplikat');
      }
      if (name != 'cashMovements' &&
          name != 'saleCustomers' &&
          r['payload'] is! String) {
        throw FormatException('Payload $name tidak valid');
      }
    }
  }
  void ref(
    Object? id,
    Set<String> valid,
    String field, {
    bool optional = false,
  }) {
    if (id == null && optional) return;
    if (id is! String || !valid.contains(id)) {
      throw FormatException('Referensi $field tidak ditemukan');
    }
  }

  for (final name in ['customers', 'suppliers']) {
    for (final r in j[name]) {
      final c = Contact.fromJson(jsonDecode(r['payload']));
      c.validate();
      if (c.id != r['id']) throw const FormatException('ID kontak tidak cocok');
    }
  }
  for (final r in j['cashAccounts']) {
    final a = CashAccount.fromJson(jsonDecode(r['payload']));
    a.validate();
    if (a.id != r['id']) throw const FormatException('ID akun tidak cocok');
  }
  final purchases = <String, Purchase>{};
  for (final r in j['purchases']) {
    final p = Purchase.fromJson(jsonDecode(r['payload']));
    p.validate();
    if (p.id != r['id'] || p.supplierId != r['supplierId']) {
      throw const FormatException('Identitas pembelian tidak cocok');
    }
    ref(p.supplierId, ids['suppliers']!, 'pemasok', optional: true);
    for (final l in p.lines) {
      ref(l.productId, productIds, 'produk pembelian');
    }
    purchases[p.id] = p;
  }
  final received = <String, Map<String, int>>{};
  final paid = <String, int>{};
  for (final r in j['receipts']) {
    ref(r['purchaseId'], ids['purchases']!, 'penerimaan');
    final p = purchases[r['purchaseId']]!;
    final d = Map<String, dynamic>.from(jsonDecode(r['payload']));
    validDate(d['date']);
    if (d['id'] != r['id'] ||
        d['quantities'] is! Map ||
        d['reversed'] is! bool ||
        d['sequence'] is! int ||
        d['before'] is! Map) {
      throw const FormatException('Data penerimaan tidak valid');
    }
    final counts = received.putIfAbsent(p.id, () => {});
    for (final e in (d['quantities'] as Map).entries) {
      ref(e.key, p.lines.map((l) => l.productId).toSet(), 'produk penerimaan');
      if (e.value is! int || (e.value as int) < 1) {
        throw const FormatException('Jumlah penerimaan tidak valid');
      }
      counts.update(
        e.key,
        (v) => v + (d['reversed'] ? -1 : 1) * (e.value as int),
        ifAbsent: () => (d['reversed'] ? -1 : 1) * (e.value as int),
      );
      final before = Product.fromJson(
        Map<String, dynamic>.from(d['before'][e.key]),
      );
      before.validate(allowNegativeStock: true);
    }
  }
  for (final e in received.entries) {
    for (final l in purchases[e.key]!.lines) {
      final q = e.value[l.productId] ?? 0;
      if (q < 0 || q > l.quantity) {
        throw const FormatException('Penerimaan melebihi pembelian');
      }
    }
  }
  for (final r in j['purchasePayments']) {
    ref(r['purchaseId'], ids['purchases']!, 'pembayaran pemasok');
    final d = jsonDecode(r['payload']);
    validDate(d['date']);
    validMoney(d['amount']);
    if (d['id'] != r['id'] || d['amount'] == 0) {
      throw const FormatException('Pembayaran tidak valid');
    }
    ref(
      d['accountId'],
      ids['cashAccounts']!,
      'akun pembayaran',
      optional: true,
    );
    paid.update(
      r['purchaseId'],
      (v) => v + (d['amount'] as int),
      ifAbsent: () => d['amount'],
    );
  }
  for (final e in paid.entries) {
    if (e.value > purchases[e.key]!.total) {
      throw const FormatException('Pembayaran pemasok berlebih');
    }
  }
  for (final r in j['saleCustomers']) {
    ref(r['saleId'], saleIds, 'penjualan pelanggan');
    ref(r['customerId'], ids['customers']!, 'pelanggan');
  }
  final returnModels = <String, ReturnAdjustment>{};
  final returnCounts = <String, Map<int, int>>{};
  final returnRevenue = <String, int>{};
  for (final row in j['returns']) {
    ref(row['saleId'], saleIds, 'retur penjualan');
    final r = ReturnAdjustment.fromJson(jsonDecode(row['payload']));
    r.validate();
    if (r.id != row['id'] || r.saleId != row['saleId']) {
      throw const FormatException('Identitas retur tidak cocok');
    }
    final sale = validatedSales[r.saleId]!;
    if (validDate(r.date).isBefore(validDate(sale.date))) {
      throw const FormatException('Tanggal retur sebelum penjualan');
    }
    final counts = returnCounts.putIfAbsent(sale.id, () => {});
    if (r.kind == 'cancellation') {
      if (!sale.voided ||
          r.quantities.isNotEmpty ||
          r.revenueReduction != 0 ||
          r.restoredCost != 0 ||
          r.recoveredFees != 0 ||
          r.refundEntitlement != sale.paid ||
          returnModels.values.any((v) => v.saleId == sale.id)) {
        throw const FormatException('Pembatalan tidak konsisten');
      }
    } else {
      if (sale.voided || r.quantities.isEmpty) {
        throw const FormatException('Retur penjualan batal/tanpa barang');
      }
      final gross = sale.lines.fold<int>(0, (v, l) => v + l.quantity * l.price);
      var revenue = 0, cost = 0, fees = 0;
      for (final e in r.quantities.entries) {
        if (e.key < 0 || e.key >= sale.lines.length) {
          throw const FormatException('Baris retur tidak ditemukan');
        }
        final line = sale.lines[e.key];
        final before = counts[e.key] ?? 0;
        if (before + e.value > line.quantity) {
          throw const FormatException('Jumlah retur berlebih');
        }
        final grossBefore = sale.lines
            .take(e.key)
            .fold<int>(0, (v, l) => v + l.price * l.quantity);
        revenue += returnedUnitShare(
          total: sale.originalResult.revenue,
          grossTotal: gross,
          lineGrossBefore: grossBefore,
          unitPrice: line.price,
          alreadyReturned: before,
          quantity: e.value,
        );
        fees += returnedUnitShare(
          total: sale.originalResult.fees,
          grossTotal: gross,
          lineGrossBefore: grossBefore,
          unitPrice: line.price,
          alreadyReturned: before,
          quantity: e.value,
        );
        if (r.restocked.contains(e.key)) cost += line.cost * e.value;
        counts[e.key] = before + e.value;
      }
      final beforeRevenue = returnRevenue[sale.id] ?? 0;
      final beforeExcess =
          (sale.paid - (sale.originalResult.revenue - beforeRevenue)).clamp(
            0,
            maxMoney,
          );
      final afterExcess =
          (sale.paid - (sale.originalResult.revenue - beforeRevenue - revenue))
              .clamp(0, maxMoney);
      if (r.revenueReduction != revenue ||
          r.restoredCost != cost ||
          (r.recoveredFees != 0 && r.recoveredFees != fees) ||
          r.refundEntitlement != afterExcess - beforeExcess) {
        throw const FormatException('Nilai finansial retur tidak cocok');
      }
      returnRevenue[sale.id] = beforeRevenue + revenue;
    }
    returnModels[r.id] = r;
  }
  final refunded = <String, int>{};
  for (final row in j['refunds']) {
    ref(row['returnId'], ids['returns']!, 'pengembalian dana');
    final d = jsonDecode(row['payload']);
    validDate(d['date']);
    validMoney(d['amount']);
    ref(
      d['accountId'],
      ids['cashAccounts']!,
      'akun pengembalian',
      optional: true,
    );
    if (d['id'] != row['id'] ||
        d['amount'] == 0 ||
        validDate(
          d['date'],
        ).isBefore(validDate(returnModels[row['returnId']]!.date))) {
      throw const FormatException('Data pengembalian dana tidak valid');
    }
    refunded.update(
      row['returnId'],
      (v) => v + (d['amount'] as int),
      ifAbsent: () => d['amount'],
    );
  }
  for (final e in refunded.entries) {
    if (e.value > returnModels[e.key]!.refundEntitlement) {
      throw const FormatException('Pengembalian dana berlebih');
    }
  }
  for (final r in j['opnames']) {
    final d = jsonDecode(r['payload']);
    if (d['confirmed'] is! bool) {
      throw const FormatException('Status opname tidak valid');
    }
    for (final raw in d['items']) {
      final i = OpnameItem.fromJson(Map<String, dynamic>.from(raw));
      ref(i.productId, productIds, 'produk opname');
      if (i.counted < 0 || i.counted > 1000000000) {
        throw const FormatException('Jumlah opname tidak valid');
      }
    }
  }
  for (final r in j['cashMovements']) {
    ref(r['accountId'], ids['cashAccounts']!, 'akun kas', optional: true);
    validDate(r['date']);
    validMoney((r['amount'] as int).abs());
    requiredText(r['reference'], 'Referensi kas');
    requiredText(r['category'], 'Kategori kas');
  }
}
