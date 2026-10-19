import '../domain/dates.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../domain/models.dart';
import '../domain/money.dart';
import 'database.dart';

const uuid = Uuid();

class Store extends ChangeNotifier {
  final AppDatabase db;
  List<Product> products = [];
  List<Sale> sales = [];
  List<Expense> expenses = [];
  List<Map<String, dynamic>> movements = [];
  Map<String, dynamic> settings = {};
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

  Future<void> movement(String productId, int delta, String reason) async {
    final id = uuid.v4();
    await put('movement', id, {
      'id': id,
      'productId': productId,
      'delta': delta,
      'reason': reason,
      'date': DateTime.now().toIso8601String(),
    });
  }

  Future<void> saveProduct(Product product, {String? expectedUpdated}) async {
    product.validate();
    await db.transaction(() async {
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

  Future<void> adjustStock(String id, int delta, String reason) async {
    if (reason.trim().isEmpty || delta == 0) {
      throw ArgumentError('Jumlah dan alasan wajib diisi');
    }
    await db.transaction(() async {
      final p = await productInTransaction(id);
      if (p.stock + delta < 0) {
        throw ArgumentError('Stok tidak cukup');
      }
      await put('product', id, p.copy(stock: p.stock + delta).toJson());
      await movement(id, delta, reason);
    });
    await load();
  }

  Future<void> saveSale(Sale sale) async {
    sale.result;
    validDate(sale.date);
    if (sale.voided) {
      throw ArgumentError('Transaksi batal tidak dapat disimpan');
    }
    await db.transaction(() async {
      final existing = await (db.select(
        db.saleRows,
      )..where((r) => r.id.equals(sale.id))).getSingleOrNull();
      if (existing != null) {
        final old = Sale.fromJson(jsonDecode(existing.payload));
        if (old.voided) {
          throw ArgumentError('Transaksi sudah dibatalkan');
        }
        for (final l in old.lines) {
          final p = await productInTransaction(l.productId);
          await put(
            'product',
            p.id,
            p.copy(stock: p.stock + l.quantity).toJson(),
          );
          await movement(p.id, l.quantity, 'Revisi ${sale.id}');
        }
      }
      for (final l in sale.lines) {
        final p = await productInTransaction(l.productId);
        if (p.archived || p.stock < l.quantity) {
          throw ArgumentError(
            'Stok ${p.name} tidak cukup atau produk diarsipkan',
          );
        }
        await put(
          'product',
          p.id,
          p.copy(stock: p.stock - l.quantity).toJson(),
        );
        await movement(p.id, -l.quantity, 'Penjualan ${sale.id}');
      }
      await put('sale', sale.id, sale.toJson());
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
      for (final l in sale.lines) {
        final p = await productInTransaction(l.productId);
        await put(
          'product',
          p.id,
          p.copy(stock: p.stock + l.quantity).toJson(),
        );
        await movement(p.id, l.quantity, 'Batal $id');
      }
      await put('sale', id, {...sale.toJson(), 'voided': true});
    });
    await load();
  }

  Future<void> saveExpense(Expense e) async {
    validMoney(e.amount);
    validDate(e.date);
    if (e.category.trim().isEmpty) {
      throw ArgumentError('Kategori wajib');
    }
    await put('expense', e.id, e.toJson());
    await load();
  }

  Future<void> deleteExpense(String id) async {
    await (db.delete(db.expenseRows)..where((r) => r.id.equals(id))).go();
    await load();
  }

  Future<void> saveSettings(Map<String, dynamic> s) async {
    await put('settings', 'settings', s);
    await load();
  }

  String backup() => jsonEncode({
    'app': 'untungku-pro',
    'version': 1,
    'created': DateTime.now().toIso8601String(),
    'products': products.map((p) => p.toJson()).toList(),
    'sales': sales.map((s) => s.toJson()).toList(),
    'expenses': expenses.map((e) => e.toJson()).toList(),
    'movements': movements,
    'settings': settings,
  });
  static Map<String, dynamic> validateBackup(String source) {
    if (source.length > 20000000) {
      throw const FormatException('Backup terlalu besar');
    }
    final b = Map<String, dynamic>.from(jsonDecode(source));
    if (b['app'] != 'untungku-pro' || b['version'] != 1) {
      throw const FormatException('Format atau versi backup tidak didukung');
    }
    final ps = (b['products'] as List)
        .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    final ids = <String>{};
    for (final p in ps) {
      p.validate();
      if (!ids.add(p.id)) {
        throw const FormatException('ID produk duplikat');
      }
    }
    final saleIds = <String>{};
    for (final e in b['sales'] as List) {
      final s = Sale.fromJson(Map<String, dynamic>.from(e));
      s.result;
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
    final settings = Map<String, dynamic>.from(b['settings']);
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
    return b;
  }

  Future<void> restore(String source) async {
    final b = validateBackup(source);
    await db.transaction(() async {
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
        ],
      ),
      ...expenses.map(
        (e) => ['pengeluaran', e.id, e.date, e.note, 0, 0, e.amount, 'aktif'],
      ),
    ];
    return '\uFEFF${rows.map((r) => r.map(escape).join(',')).join('\r\n')}';
  }
}
