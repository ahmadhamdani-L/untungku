import 'dart:convert';
import 'dart:typed_data';
import '../models.dart';
import '../input_validation.dart';
import '../money.dart';

const productCsvColumns = [
  'nama',
  'sku',
  'barcode',
  'kategori',
  'modal',
  'harga_jual',
  'kemasan',
  'biaya_tambahan',
  'stok',
  'batas_stok',
];
const productCsvTemplate =
    'nama,sku,barcode,kategori,modal,harga_jual,kemasan,biaya_tambahan,stok,batas_stok\r\n"Kopi, Susu",KOPI-01,8990000000010,Minuman,5000,10000,500,0,10,5\r\n';

enum ImportDuplicatePolicy { skip, update, createOnly }

class CsvTable {
  final List<String> headers;
  final List<List<String>> rows;
  const CsvTable(this.headers, this.rows);
}

/// Strict RFC-style CSV quoting. Blank rows are skipped; malformed quotes fail.
CsvTable parseProductCsv(String source) {
  if (source.length > 5000000) throw const FormatException('CSV maksimal 5 MB');
  if (source.startsWith('\uFEFF')) source = source.substring(1);
  final rows = <List<String>>[], row = <String>[];
  var field = StringBuffer(), quoted = false, afterQuote = false;
  void finishField() {
    row.add(field.toString());
    field = StringBuffer();
    afterQuote = false;
  }

  void finishRow() {
    finishField();
    if (row.any((v) => v.trim().isNotEmpty)) rows.add(List.of(row));
    row.clear();
    if (rows.length > 5001) {
      throw const FormatException('CSV maksimal 5.000 baris data');
    }
  }

  for (var i = 0; i < source.length; i++) {
    final char = source[i];
    if (quoted) {
      if (char == '"') {
        if (i + 1 < source.length && source[i + 1] == '"') {
          field.write('"');
          i++;
        } else {
          quoted = false;
          afterQuote = true;
        }
      } else {
        field.write(char);
      }
      continue;
    }
    if (afterQuote && char != ',' && char != '\r' && char != '\n') {
      throw const FormatException('Ada teks setelah penutup kutip CSV');
    }
    if (char == '"') {
      if (field.isNotEmpty) {
        throw const FormatException('Kutip harus di awal isian CSV');
      }
      quoted = true;
    } else if (char == ',') {
      finishField();
    } else if (char == '\r' || char == '\n') {
      finishRow();
      if (char == '\r' && i + 1 < source.length && source[i + 1] == '\n') i++;
    } else {
      field.write(char);
    }
  }
  if (quoted) throw const FormatException('Kutip CSV tidak ditutup');
  if (field.isNotEmpty || row.isNotEmpty || afterQuote) finishRow();
  if (rows.isEmpty || rows.first.any((h) => h.trim().isEmpty)) {
    throw const FormatException('Header CSV tidak valid');
  }
  final headers = rows.first.map((v) => v.trim()).toList();
  if (headers.toSet().length != headers.length) {
    throw const FormatException('Header CSV duplikat');
  }
  return CsvTable(headers, rows.skip(1).toList());
}

int importInteger(
  String source,
  String label, {
  int min = 0,
  int max = maxMoney,
}) {
  var value = source.trim();
  // A zero fractional part is lossless for integer Rupiah; nonzero fractions fail.
  if (RegExp(r',0+$').hasMatch(value)) {
    value = value.substring(0, value.indexOf(','));
  }
  if (RegExp(r'^-?[0-9]{1,3}(\.[0-9]{3})+$').hasMatch(value)) {
    value = value.replaceAll('.', '');
  }
  return parseIntegerInput(value, label, min: min, max: max);
}

class ProductImportRow {
  final int line;
  final Product? product, existing;
  final String? error;
  final bool skipped;
  const ProductImportRow({
    required this.line,
    this.product,
    this.existing,
    this.error,
    this.skipped = false,
  });
}

class ProductImportPlan {
  final String id;
  final ImportDuplicatePolicy policy;
  final List<ProductImportRow> rows;
  const ProductImportPlan(this.id, this.policy, this.rows);
  bool get valid => rows.isNotEmpty && rows.every((r) => r.error == null);
  int get created => rows
      .where((r) => r.error == null && !r.skipped && r.existing == null)
      .length;
  int get updated => rows
      .where((r) => r.error == null && !r.skipped && r.existing != null)
      .length;
  int get skipped => rows.where((r) => r.skipped).length;
  Map<String, dynamic> intent() => {
    'policy': policy.name,
    'rows': [
      for (final r in rows)
        {
          'line': r.line,
          'product': r.product?.toJson(),
          'existing': r.existing?.toJson(),
          'skipped': r.skipped,
        },
    ],
  };
}

ProductImportPlan planProductImport(
  CsvTable table,
  Map<String, int?> mapping,
  List<Product> current, {
  required String id,
  required String timestamp,
  required ImportDuplicatePolicy policy,
  bool allowNegativeStock = false,
}) {
  for (final key in ['nama', 'harga_jual']) {
    if (mapping[key] == null) throw ArgumentError('Petakan kolom $key');
  }
  final seenSkus = <String>{}, seenBarcodes = <String>{}, targets = <String>{};
  final rows = <ProductImportRow>[];
  for (var index = 0; index < table.rows.length; index++) {
    try {
      final values = table.rows[index];
      if (values.length != table.headers.length) {
        throw ArgumentError('Jumlah kolom berbeda dari header');
      }
      String text(String key, [String fallback = '']) {
        final column = mapping[key];
        if (column == null) return fallback;
        if (column < 0 || column >= values.length) {
          throw ArgumentError('Pemetaan kolom tidak valid');
        }
        return values[column].trim();
      }

      final sku = text('sku'), barcode = text('barcode');
      if ((sku.isNotEmpty && !seenSkus.add(sku)) ||
          (barcode.isNotEmpty && !seenBarcodes.add(barcode))) {
        throw ArgumentError('SKU atau barcode duplikat di CSV');
      }
      final matches = current
          .where(
            (p) =>
                (sku.isNotEmpty && p.sku == sku) ||
                (barcode.isNotEmpty && p.barcode == barcode),
          )
          .toList();
      if (matches.length > 1) {
        throw ArgumentError(
          'SKU/barcode merujuk beberapa produk; perbaiki identitas',
        );
      }
      final existing = matches.singleOrNull;
      if (existing != null && !targets.add(existing.id)) {
        throw ArgumentError('Beberapa baris mengubah produk yang sama');
      }
      final product = Product(
        id: existing?.id ?? '$id:row:${index + 2}',
        name: text('nama'),
        sku: sku,
        barcode: barcode,
        category: text('kategori'),
        cost: importInteger(text('modal', '0'), 'Modal'),
        price: importInteger(text('harga_jual'), 'Harga jual'),
        packaging: importInteger(text('kemasan', '0'), 'Kemasan'),
        extra: importInteger(text('biaya_tambahan', '0'), 'Biaya tambahan'),
        stock: importInteger(
          text('stok', '0'),
          'Stok',
          min: allowNegativeStock ? -1000000000 : 0,
          max: 1000000000,
        ),
        threshold: importInteger(
          text('batas_stok', '5'),
          'Batas stok',
          max: 1000000000,
        ),
        favorite: existing?.favorite ?? false,
        archived: existing?.archived ?? false,
        created: existing?.created ?? timestamp,
        updated: timestamp,
      );
      product.validate(allowNegativeStock: allowNegativeStock);
      rows.add(
        ProductImportRow(
          line: index + 2,
          product: product,
          existing: existing,
          skipped: existing != null && policy != ImportDuplicatePolicy.update,
        ),
      );
    } catch (e) {
      rows.add(
        ProductImportRow(
          line: index + 2,
          error: e.toString().replaceFirst('Invalid argument(s): ', ''),
        ),
      );
    }
  }
  return ProductImportPlan(id, policy, rows);
}

// Top-level isolate callbacks avoid capturing Riverpod, widgets or plugin handles.
CsvTable parseProductCsvBytes(Uint8List bytes) =>
    parseProductCsv(utf8.decode(bytes));
typedef ProductImportRequest = ({
  CsvTable table,
  Map<String, int?> columns,
  List<Product> products,
  String id,
  String timestamp,
  ImportDuplicatePolicy policy,
  bool allowNegativeStock,
});
ProductImportPlan buildProductImport(ProductImportRequest request) =>
    planProductImport(
      request.table,
      request.columns,
      request.products,
      id: request.id,
      timestamp: request.timestamp,
      policy: request.policy,
      allowNegativeStock: request.allowNegativeStock,
    );
