import '../domain/dates.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../domain/models.dart';
import '../domain/receipt.dart';
import '../domain/money.dart';
import 'database.dart';
import 'package:drift/drift.dart' show Value, Constant;
import '../domain/business/entities.dart';
import '../domain/business/returns.dart';
import '../domain/business/payables.dart';
import '../domain/business/cashflow.dart';
import '../domain/business/product_import.dart';
part 'returns_store.dart';
part 'business_store.dart';
part 'product_import_store.dart';

const uuid = Uuid();

class Store extends ChangeNotifier {
  final AppDatabase db;
  List<Product> products = [];
  List<Sale> sales = [];
  List<Expense> expenses = [];
  List<Map<String, dynamic>> movements = [];
  Map<String, dynamic> settings = {};
  Map<String, List<Map<String, dynamic>>> businessData = {};
  bool get allowNegativeStock => settings['allowNegativeStock'] == true;
  Store(this.db);
  Future<void> load() async {
    Map<String, dynamic> decode(String value) =>
        Map<String, dynamic>.from(jsonDecode(value));
    products = (await db.select(db.productRows).get())
        .map((r) => Product.fromJson(decode(r.payload)))
        .toList();
    sales = (await db.select(db.saleRows).get())
        .map((r) => Sale.fromJson(decode(r.payload)))
        .toList();
    expenses = (await db.select(db.expenseRows).get())
        .map((r) => Expense.fromJson(decode(r.payload)))
        .toList();
    movements = (await db.select(db.movementRows).get())
        .map((r) => decode(r.payload))
        .toList();
    settings =
        (await db.select(db.settingRows).get())
            .map((r) => decode(r.payload))
            .firstOrNull ??
        {};
    sales = await attachReturns(sales);
    await initializeLegacyCash();
    businessData = await businessSnapshot();
    notifyListeners();
  }

  Future<void> put(String kind, String id, Map<String, dynamic> value) async {
    final payload = jsonEncode(value);
    switch (kind) {
      case 'product':
        await db
            .into(db.productRows)
            .insertOnConflictUpdate(
              ProductRowsCompanion.insert(id: id, payload: payload),
            );
      case 'sale':
        await db
            .into(db.saleRows)
            .insertOnConflictUpdate(
              SaleRowsCompanion.insert(id: id, payload: payload),
            );
        await (db.delete(
          db.saleItemRows,
        )..where((r) => r.saleId.equals(id))).go();
        final lines = value['lines'] as List;
        for (var i = 0; i < lines.length; i++) {
          await db
              .into(db.saleItemRows)
              .insert(
                SaleItemRowsCompanion.insert(
                  saleId: id,
                  lineIndex: i,
                  productId: lines[i]['productId'],
                ),
              );
        }
      case 'expense':
        await db
            .into(db.expenseRows)
            .insertOnConflictUpdate(
              ExpenseRowsCompanion.insert(id: id, payload: payload),
            );
      case 'movement':
        await db
            .into(db.movementRows)
            .insert(
              MovementRowsCompanion.insert(
                id: id,
                productId: value['productId'],
                payload: payload,
              ),
            );
      case 'settings':
        await db
            .into(db.settingRows)
            .insertOnConflictUpdate(
              SettingRowsCompanion.insert(id: id, payload: payload),
            );
      default:
        throw ArgumentError('Unknown record kind');
    }
  }

  Future<Product> productInTransaction(String id) async {
    final row = await (db.select(
      db.productRows,
    )..where((r) => r.id.equals(id))).getSingle();
    return Product.fromJson(jsonDecode(row.payload));
  }

  Future<void> movement(
    String productId,
    int delta,
    String reason, {
    String? reference,
    String? operationId,
  }) async {
    final id = uuid.v4();
    await put('movement', id, {
      'id': id,
      'productId': productId,
      'delta': delta,
      'reason': reason,
      'reference': ?reference,
      'operationId': ?operationId,
      'date': DateTime.now().toIso8601String(),
    });
  }

  Future<void> saveProduct(Product product, {String? expectedUpdated}) async {
    product.validate(allowNegativeStock: allowNegativeStock);
    await db.transaction(() async {
      if (product.barcode.isNotEmpty) {
        final current = await db.select(db.productRows).get();
        if (current.any(
          (r) =>
              r.id != product.id &&
              Product.fromJson(jsonDecode(r.payload)).barcode ==
                  product.barcode,
        )) {
          throw ArgumentError('Barcode sudah digunakan produk lain');
        }
      }
      final old = await (db.select(
        db.productRows,
      )..where((r) => r.id.equals(product.id))).getSingleOrNull();
      if (old != null &&
          expectedUpdated != null &&
          Product.fromJson(jsonDecode(old.payload)).updated !=
              expectedUpdated) {
        throw StateError(
          'Produk berubah sejak formulir dibuka. Buka kembali sebelum menyimpan.',
        );
      }
      final oldStock = old == null
          ? 0
          : Product.fromJson(jsonDecode(old.payload)).stock;
      await put('product', product.id, product.toJson());
      if (product.stock != oldStock) {
        await movement(
          product.id,
          product.stock - oldStock,
          old == null ? 'Stok awal' : 'Koreksi melalui edit produk',
        );
      }
    });
    await load();
  }

  Future<void> archiveProduct(String id, bool archived) async {
    await db.transaction(() async {
      final product = await productInTransaction(id);
      await put('product', id, product.copy(archived: archived).toJson());
    });
    await load();
  }

  Future<void> adjustStock(
    String id,
    int delta,
    String reason, {
    String? operationId,
  }) async {
    if (reason.trim().isEmpty || delta == 0 || delta.abs() > 1000000000) {
      throw ArgumentError('Jumlah dan alasan wajib diisi');
    }
    // Callers can retain this key across retries; legacy callers remain valid.
    final key = operationId ?? uuid.v4();
    await businessOperation(
      key,
      'stockAdjustment',
      {'product': id, 'delta': delta, 'reason': reason},
      () async {
        final p = await productInTransaction(id);
        if (p.archived ||
            (!allowNegativeStock && p.stock + delta < 0) ||
            (p.stock + delta).abs() > 1000000000) {
          throw ArgumentError('Stok tidak cukup atau produk diarsipkan');
        }
        await put('product', id, p.copy(stock: p.stock + delta).toJson());
        await movement(id, delta, reason, reference: id, operationId: key);
      },
    );
    await load();
  }

  Future<void> saveSale(
    Sale sale, {
    String? checkoutOperationId,
    String? customerId,
  }) async {
    sale.result;
    sale.validatePayments();
    validDate(sale.date);
    if (sale.voided) {
      throw ArgumentError('Transaksi batal tidak dapat disimpan');
    }
    await db.transaction(() async {
      final operationPayload = canonicalJson({
        'sale': sale.toJson(),
        'customerId': customerId,
      });
      if (checkoutOperationId != null) {
        final op = await (db.select(
          db.operationRows,
        )..where((r) => r.id.equals(checkoutOperationId))).getSingleOrNull();
        if (op != null) {
          if (op.payload != operationPayload) {
            throw StateError('Checkout berbeda memakai referensi sama');
          }
          return;
        }
      }

      final existing = await (db.select(
        db.saleRows,
      )..where((r) => r.id.equals(sale.id))).getSingleOrNull();
      if (existing != null) {
        final old = Sale.fromJson(jsonDecode(existing.payload));
        if (canonicalJson(old.toJson()) == canonicalJson(sale.toJson())) {
          if (customerId != null) {
            await linkCustomerInTransaction(sale.id, customerId);
          }
          if (checkoutOperationId != null) {
            await db
                .into(db.operationRows)
                .insert(
                  OperationRowsCompanion.insert(
                    id: checkoutOperationId,
                    payload: operationPayload,
                  ),
                );
          }
          return;
        }
        if (old.voided) {
          throw ArgumentError('Transaksi sudah dibatalkan');
        }
        if ((await (db.select(
          db.returnRows,
        )..where((r) => r.saleId.equals(sale.id))).get()).isNotEmpty) {
          throw StateError(
            'Penjualan memiliki retur; gunakan alur retur, bukan revisi',
          );
        }
        if (old.credit != sale.credit ||
            old.customer != sale.customer ||
            old.dueDate != sale.dueDate ||
            jsonEncode(old.payments.map((p) => p.toJson()).toList()) !=
                jsonEncode(sale.payments.map((p) => p.toJson()).toList())) {
          throw StateError(
            'Data pembayaran berubah. Buka kembali transaksi sebelum menyimpan.',
          );
        }
        for (final l in old.lines) {
          final p = await productInTransaction(l.productId);
          if (p.stock + l.quantity > 1000000000) {
            throw ArgumentError('Stok setelah pengembalian melebihi batas');
          }
          await put(
            'product',
            p.id,
            p.copy(stock: p.stock + l.quantity).toJson(),
          );
          await movement(
            p.id,
            l.quantity,
            'Revisi ${sale.id}',
            reference: sale.id,
            operationId: checkoutOperationId,
          );
        }
      }
      for (final l in sale.lines) {
        final p = await productInTransaction(l.productId);
        if (p.archived ||
            (!allowNegativeStock && p.stock < l.quantity) ||
            p.stock - l.quantity < -1000000000) {
          throw ArgumentError(
            'Stok ${p.name} tidak cukup atau produk diarsipkan',
          );
        }
        await put(
          'product',
          p.id,
          p.copy(stock: p.stock - l.quantity).toJson(),
        );
        await movement(
          p.id,
          -l.quantity,
          'Penjualan ${sale.id}',
          reference: sale.id,
          operationId: checkoutOperationId,
        );
      }
      await put('sale', sale.id, sale.toJson());
      await syncSaleCash(
        existing == null ? null : Sale.fromJson(jsonDecode(existing.payload)),
        sale,
      );
      if (customerId != null) {
        await linkCustomerInTransaction(sale.id, customerId);
      }
      if (checkoutOperationId != null) {
        await db
            .into(db.operationRows)
            .insert(
              OperationRowsCompanion.insert(
                id: checkoutOperationId,
                payload: operationPayload,
              ),
            );
      }
    });
    await load();
  }

  Future<void> recordPayment(String saleId, SalePayment payment) async {
    await db.transaction(() async {
      final row = await (db.select(
        db.saleRows,
      )..where((r) => r.id.equals(saleId))).getSingle();
      final sale = (await attachReturns([
        Sale.fromJson(jsonDecode(row.payload)),
      ])).single;
      if (!sale.credit || sale.voided) {
        throw StateError('Transaksi tidak menerima pelunasan');
      }
      final existing = sale.payments
          .where((p) => p.id == payment.id)
          .firstOrNull;
      if (existing != null) {
        if (jsonEncode(existing.toJson()) != jsonEncode(payment.toJson())) {
          throw StateError('ID pembayaran sudah digunakan');
        }
        return;
      }
      if (payment.amount > sale.outstanding) {
        throw ArgumentError('Pembayaran melebihi sisa piutang setelah retur');
      }
      final updated = Sale.fromJson({
        ...sale.toJson(),
        'payments': [...sale.payments.map((p) => p.toJson()), payment.toJson()],
      });
      updated.validatePayments();
      await put('sale', saleId, updated.toJson());
      await postCash(
        id: 'payment:$saleId:${payment.id}',
        reference: saleId,
        date: payment.date,
        category: 'receivable_collection',
        amount: payment.amount,
        accountId: payment.accountId,
      );
    });
    await load();
  }

  Future<void> voidSale(String id) async {
    await db.transaction(() async {
      final row = await (db.select(
        db.saleRows,
      )..where((r) => r.id.equals(id))).getSingle();
      final sale = Sale.fromJson(jsonDecode(row.payload));
      if (sale.voided) {
        return;
      }
      if ((await (db.select(
        db.returnRows,
      )..where((r) => r.saleId.equals(id))).get()).isNotEmpty) {
        throw StateError('Sudah ada retur; lakukan retur sisa barang');
      }
      for (final l in sale.lines) {
        final p = await productInTransaction(l.productId);
        if (p.stock + l.quantity > 1000000000) {
          throw ArgumentError('Stok setelah pengembalian melebihi batas');
        }
        await put(
          'product',
          p.id,
          p.copy(stock: p.stock + l.quantity).toJson(),
        );
        await movement(p.id, l.quantity, 'Batal $id', reference: id);
      }
      await put('sale', id, {...sale.toJson(), 'voided': true});
      await cancellationRefundLiability(sale);
    });
    await load();
  }

  Future<void> saveExpense(Expense e, {String? accountId}) async {
    validMoney(e.amount);
    validDate(e.date);
    if (e.category.trim().isEmpty) throw ArgumentError('Kategori wajib');
    await db.transaction(() async {
      final old = await (db.select(
        db.expenseRows,
      )..where((r) => r.id.equals(e.id))).getSingleOrNull();
      if (old != null &&
          canonicalJson(jsonDecode(old.payload)) == canonicalJson(e.toJson())) {
        final totals = await expenseCashTotals(e.id);
        if ((e.amount == 0 && totals.isEmpty) ||
            (totals.length == 1 && totals[accountId] == -e.amount)) {
          return;
        }
      }
      if (old != null) await reverseExpenseCash(e.id);
      await put('expense', e.id, e.toJson());
      await postCash(
        id: old == null ? 'expense:${e.id}' : 'expense:${e.id}:${uuid.v4()}',
        reference: e.id,
        date: e.date,
        category: 'operational_expense',
        amount: -e.amount,
        accountId: accountId,
      );
    });
    await load();
  }

  Future<void> deleteExpense(String id) async {
    await db.transaction(() async {
      await reverseExpenseCash(id);
      await (db.delete(db.expenseRows)..where((r) => r.id.equals(id))).go();
    });
    await load();
  }

  Future<void> saveSettings(Map<String, dynamic> s) async {
    if (s['allowNegativeStock'] != null && s['allowNegativeStock'] is! bool) {
      throw ArgumentError('Kebijakan stok tidak valid');
    }
    if (s['allowNegativeStock'] != true && products.any((p) => p.stock < 0)) {
      throw ArgumentError(
        'Selesaikan stok minus sebelum menonaktifkan kebijakan ini',
      );
    }
    await put('settings', 'settings', s);
    await load();
  }

  String backup() => jsonEncode({
    'app': 'untungku-pro',
    'version': 3,
    'created': DateTime.now().toIso8601String(),
    'products': products.map((p) => p.toJson()).toList(),
    'sales': sales.map((s) => s.toJson()).toList(),
    'expenses': expenses.map((e) => e.toJson()).toList(),
    'movements': movements,
    'settings': settings,
    'business': businessData,
  });
  static Map<String, dynamic> validateBackup(String source) {
    if (source.length > 20000000) {
      throw const FormatException('Backup terlalu besar');
    }
    final b = Map<String, dynamic>.from(jsonDecode(source));
    if (b['app'] != 'untungku-pro' || ![1, 2, 3].contains(b['version'])) {
      throw const FormatException('Format atau versi backup tidak didukung');
    }
    final settings = Map<String, dynamic>.from(b['settings']);
    if (settings['allowNegativeStock'] != null &&
        settings['allowNegativeStock'] is! bool) {
      throw const FormatException('Kebijakan stok tidak valid');
    }
    for (final key in [
      'receiptAddress',
      'receiptPhone',
      'receiptFooter',
      'printerName',
    ]) {
      if (settings[key] != null &&
          (settings[key] is! String ||
              (settings[key] as String).length > 200)) {
        throw const FormatException('Informasi struk/printer tidak valid');
      }
    }
    if (settings['receiptWidth'] != null &&
        ![58, 80].contains(settings['receiptWidth'])) {
      throw const FormatException('Lebar struk tidak valid');
    }
    if (settings['receiptLogo'] != null &&
        ReceiptSnapshot.decodeLogo(settings['receiptLogo']) == null) {
      throw const FormatException('Logo struk tidak valid');
    }
    final printer = settings['printerAddress'];
    if (printer != null &&
        (printer is! String ||
            !RegExp(
              r'^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$',
            ).hasMatch(printer))) {
      throw const FormatException('Alamat printer tidak valid');
    }
    final ps = (b['products'] as List)
        .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    final ids = <String>{}, barcodes = <String>{};
    for (final p in ps) {
      p.validate(allowNegativeStock: settings['allowNegativeStock'] == true);
      if (p.barcode.isNotEmpty && !barcodes.add(p.barcode)) {
        throw const FormatException('Barcode produk duplikat');
      }
      if (!ids.add(p.id)) {
        throw const FormatException('ID produk duplikat');
      }
    }
    final saleIds = <String>{};
    final validatedSales = <String, Sale>{};
    for (final e in b['sales'] as List) {
      final s = Sale.fromJson(Map<String, dynamic>.from(e));
      s.result;
      s.validatePayments();
      validatedSales[s.id] = s;
      validDate(s.date);
      if (!saleIds.add(s.id)) {
        throw const FormatException('ID transaksi duplikat');
      }
      for (final l in s.lines) {
        if (!ids.contains(l.productId)) {
          throw const FormatException('Referensi produk hilang');
        }
      }
    }
    final expenseIds = <String>{};
    for (final e in b['expenses'] as List) {
      final x = Expense.fromJson(Map<String, dynamic>.from(e));
      validMoney(x.amount);
      validDate(x.date);
      if (!expenseIds.add(x.id)) {
        throw const FormatException('ID pengeluaran duplikat');
      }
    }
    final moveIds = <String>{};
    final totals = <String, int>{};
    for (final e in b['movements'] as List) {
      if (e['id'] is! String ||
          !moveIds.add(e['id']) ||
          !ids.contains(e['productId']) ||
          e['delta'] is! int ||
          (e['delta'] as int).abs() > 2000000000 ||
          e['reason'] is! String) {
        throw const FormatException('Mutasi tidak valid');
      }
      validDate(e['date']);
      totals.update(
        e['productId'],
        (v) => v + (e['delta'] as int),
        ifAbsent: () => e['delta'] as int,
      );
    }
    for (final p in ps) {
      if ((totals[p.id] ?? 0) != p.stock) {
        throw const FormatException('Stok tidak konsisten dengan mutasi');
      }
    }
    if (settings['business'] != null && settings['business'] is! String) {
      throw const FormatException('Nama usaha tidak valid');
    }
    if (settings['feeBps'] != null &&
        (settings['feeBps'] is! int ||
            settings['feeBps'] < 0 ||
            settings['feeBps'] >= 10000)) {
      throw const FormatException('Biaya tidak valid');
    }
    if (settings['onboarded'] != null && settings['onboarded'] is! bool) {
      throw const FormatException('Status onboarding tidak valid');
    }
    if (settings['theme'] != null &&
        !['system', 'light', 'dark'].contains(settings['theme'])) {
      throw const FormatException('Tema tidak valid');
    }
    if (b['version'] == 3) {
      validateBusinessSnapshot(
        Map<String, dynamic>.from(b['business']),
        ids,
        validatedSales,
      );
    }
    return b;
  }

  Future<void> restore(String source) async {
    final b = validateBackup(source);
    await db.transaction(() async {
      await clearBusinessDataForRestore();
      await db.delete(db.saleItemRows).go();
      await db.delete(db.movementRows).go();
      await db.delete(db.saleRows).go();
      await db.delete(db.expenseRows).go();
      await db.delete(db.productRows).go();
      await db.delete(db.settingRows).go();
      for (final pair in [
        ('products', 'product'),
        ('sales', 'sale'),
        ('expenses', 'expense'),
        ('movements', 'movement'),
      ]) {
        for (final e in b[pair.$1]) {
          await put(pair.$2, e['id'], Map<String, dynamic>.from(e));
        }
      }
      await put(
        'settings',
        'settings',
        Map<String, dynamic>.from(b['settings']),
      );
      if (b['version'] == 3) {
        await restoreBusinessSnapshot(Map<String, dynamic>.from(b['business']));
      }
    });
    await load();
  }

  String csv() {
    String escape(Object? v) {
      var text = v.toString();
      if (v is String && RegExp(r'^[=+@\-\t\r]').hasMatch(text)) {
        text = "'$text";
      }
      return '"${text.replaceAll('"', '""')}"';
    }

    final rows = <List<Object?>>[
      [
        'jenis',
        'id',
        'tanggal',
        'keterangan',
        'pendapatan',
        'laba_estimasi',
        'pengeluaran',
        'status',
        'pelanggan',
        'status_pembayaran',
        'dibayar',
        'sisa_piutang',
        'jatuh_tempo',
        'riwayat_pembayaran_json',
      ],
      ...sales.map(
        (s) => [
          'penjualan',
          s.id,
          s.date,
          s.note,
          s.result.revenue,
          s.result.net,
          0,
          s.voided ? 'batal' : 'aktif',
          s.customer,
          s.paymentStatus,
          s.paid,
          s.outstanding,
          s.dueDate ?? '',
          jsonEncode(s.payments.map((p) => p.toJson()).toList()),
        ],
      ),
      ...expenses.map(
        (e) => [
          'pengeluaran',
          e.id,
          e.date,
          e.note,
          0,
          0,
          e.amount,
          'aktif',
          '',
          '',
          '',
          '',
          '',
          '',
        ],
      ),
    ];
    return '\uFEFF${rows.map((r) => r.map(escape).join(',')).join('\r\n')}';
  }
}
