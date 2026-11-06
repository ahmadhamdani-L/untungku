part of 'store.dart';

extension ReturnsStore on Store {
  Future<List<ReturnAdjustment>> salesReturns({String? saleId}) async {
    final rows =
        await (db.select(db.returnRows)..where(
              (r) => saleId == null
                  ? const Constant(true)
                  : r.saleId.equals(saleId),
            ))
            .get();
    final refunds = await db.select(db.refundRows).get();
    final amounts = <String, int>{};
    for (final row in refunds) {
      final j = jsonDecode(row.payload);
      amounts.update(
        row.returnId,
        (v) => v + (j['amount'] as int),
        ifAbsent: () => j['amount'],
      );
    }
    return rows
        .map(
          (r) => ReturnAdjustment.fromJson(
            jsonDecode(r.payload),
            refunded: amounts[r.id] ?? 0,
          ),
        )
        .toList();
  }

  Future<List<Sale>> attachReturns(List<Sale> input) async {
    final grouped = <String, List<ReturnAdjustment>>{};
    for (final r in await salesReturns()) {
      grouped.putIfAbsent(r.saleId, () => []).add(r);
    }
    return input
        .map(
          (s) =>
              Sale.fromJson(s.toJson(), adjustments: grouped[s.id] ?? const []),
        )
        .toList();
  }

  Future<void> cancellationRefundLiability(Sale sale) async {
    if (sale.paid == 0) return;
    final r = ReturnAdjustment(
      id: 'cancel:${sale.id}',
      saleId: sale.id,
      date: DateTime.now().toIso8601String(),
      reason: 'Pembatalan penjualan; pengembalian dana belum dicatat',
      kind: 'cancellation',
      quantities: const {},
      restocked: const {},
      revenueReduction: 0,
      restoredCost: 0,
      recoveredFees: 0,
      refundEntitlement: sale.paid,
    );
    await db
        .into(db.returnRows)
        .insert(
          ReturnRowsCompanion.insert(
            id: r.id,
            saleId: sale.id,
            payload: jsonEncode(r.toJson()),
          ),
        );
  }

  Future<void> recordReturn({
    required String id,
    required String saleId,
    required Map<int, int> quantities,
    required Set<int> restock,
    required String reason,
    required String date,
    bool recoverFees = false,
    Map<int, String> dispositions = const {},
  }) async {
    requiredText(reason, 'Alasan retur');
    validDate(date);
    await businessOperation(
      id,
      'salesReturn',
      {
        'sale': saleId,
        'quantities': {
          for (final e in quantities.entries) e.key.toString(): e.value,
        },
        'restock': restock.toList()..sort(),
        'reason': reason,
        'date': date,
        'recoverFees': recoverFees,
        if (dispositions.isNotEmpty)
          'dispositions': {
            for (final e in dispositions.entries) e.key.toString(): e.value,
          },
      },
      () async {
        final row = await (db.select(
          db.saleRows,
        )..where((r) => r.id.equals(saleId))).getSingle();
        final sale = (await attachReturns([
          Sale.fromJson(jsonDecode(row.payload)),
        ])).single;
        if (sale.voided ||
            quantities.isEmpty ||
            quantities.values.any((q) => q < 1) ||
            !restock.every(quantities.containsKey) ||
            validDate(date).isBefore(validDate(sale.date))) {
          throw ArgumentError('Retur tidak valid');
        }
        final counts = <int, int>{};
        for (final r in sale.adjustments) {
          for (final e in r.quantities.entries) {
            counts.update(e.key, (v) => v + e.value, ifAbsent: () => e.value);
          }
        }
        final gross = sale.lines.fold(0, (v, l) => v + l.price * l.quantity);
        int revenue = 0, cost = 0, fees = 0;
        for (final e in quantities.entries) {
          if (e.key < 0 || e.key >= sale.lines.length) {
            throw ArgumentError('Baris barang tidak ditemukan');
          }
          final line = sale.lines[e.key], before = counts[e.key] ?? 0;
          if (before + e.value > line.quantity) {
            throw ArgumentError('Retur melebihi jumlah tersisa');
          }
          final grossBefore = sale.lines
              .take(e.key)
              .fold(0, (v, l) => v + l.price * l.quantity);
          revenue += returnedUnitShare(
            total: sale.originalResult.revenue,
            grossTotal: gross,
            lineGrossBefore: grossBefore,
            unitPrice: line.price,
            alreadyReturned: before,
            quantity: e.value,
          );
          if (recoverFees) {
            fees += returnedUnitShare(
              total: sale.originalResult.fees,
              grossTotal: gross,
              lineGrossBefore: grossBefore,
              unitPrice: line.price,
              alreadyReturned: before,
              quantity: e.value,
            );
          }
          if (restock.contains(e.key)) {
            cost += line.cost * e.value;
            final product = await productInTransaction(line.productId);
            final stock = product.stock + e.value;
            if (stock > 1000000000) {
              throw ArgumentError('Stok setelah retur melebihi batas');
            }
            final newCost = weightedAverageCost(
              oldQuantity: product.stock,
              oldCost: product.cost,
              receivedQuantity: e.value,
              receivedValue: line.cost * e.value,
            );
            await put('product', product.id, {
              ...product.copy(stock: stock).toJson(),
              'cost': newCost,
            });
            await movement(
              product.id,
              e.value,
              'Retur $id • $reason',
              reference: saleId,
              operationId: id,
            );
          }
        }
        final oldExcess = (sale.paid - sale.result.revenue).clamp(0, maxMoney),
            newExcess = (sale.paid - (sale.result.revenue - revenue)).clamp(
              0,
              maxMoney,
            );
        final adjustment = ReturnAdjustment(
          id: id,
          saleId: saleId,
          date: date,
          reason: reason,
          quantities: quantities,
          restocked: restock,
          revenueReduction: revenue,
          restoredCost: cost,
          recoveredFees: fees,
          refundEntitlement: newExcess - oldExcess,
          dispositions: dispositions,
        );
        adjustment.validate();
        await db
            .into(db.returnRows)
            .insert(
              ReturnRowsCompanion.insert(
                id: id,
                saleId: saleId,
                payload: jsonEncode(adjustment.toJson()),
              ),
            );
      },
    );
    await load();
  }

  Future<void> refundCustomer({
    required String id,
    required String returnId,
    required int amount,
    required String date,
    required String method,
    String? accountId,
  }) async {
    validMoney(amount);
    validDate(date);
    requiredText(method, 'Metode pengembalian');
    if (amount == 0) throw ArgumentError('Pengembalian harus positif');
    await businessOperation(
      id,
      'customerRefund',
      {
        'return': returnId,
        'amount': amount,
        'date': date,
        'method': method,
        'account': accountId,
      },
      () async {
        final adjustment = (await salesReturns()).firstWhere(
          (r) => r.id == returnId,
        );
        if (amount > adjustment.refundOutstanding ||
            validDate(date).isBefore(validDate(adjustment.date))) {
          throw ArgumentError(
            'Pengembalian melebihi kewajiban atau tanggal tidak valid',
          );
        }
        await postCash(
          id: 'refund:$id',
          reference: adjustment.saleId,
          date: date,
          category: 'customer_refund',
          amount: -amount,
          accountId: accountId,
        );
        await db
            .into(db.refundRows)
            .insert(
              RefundRowsCompanion.insert(
                id: id,
                returnId: returnId,
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
}
