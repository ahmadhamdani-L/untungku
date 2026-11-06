part of 'store.dart';

extension ProductImportStore on Store {
  Future<void> commitProductImport(ProductImportPlan plan) async {
    if (!plan.valid) {
      throw ArgumentError('Perbaiki semua baris CSV sebelum impor');
    }
    await businessOperation(plan.id, 'productImport', plan.intent(), () async {
      final current = {
        for (final r in await db.select(db.productRows).get())
          r.id: Product.fromJson(jsonDecode(r.payload)),
      };
      final skus = <String, Set<String>>{}, barcodes = <String, Set<String>>{};
      void index(Product p) {
        if (p.sku.isNotEmpty) skus.putIfAbsent(p.sku, () => {}).add(p.id);
        if (p.barcode.isNotEmpty) {
          barcodes.putIfAbsent(p.barcode, () => {}).add(p.id);
        }
      }

      for (final p in current.values) {
        index(p);
      }
      for (final row in plan.rows.where((r) => !r.skipped)) {
        final product = row.product!;
        product.validate(allowNegativeStock: allowNegativeStock);
        final old = current[product.id];
        if (row.existing == null
            ? old != null
            : old == null ||
                  canonicalJson(old.toJson()) !=
                      canonicalJson(row.existing!.toJson())) {
          throw StateError(
            'Produk berubah sejak pratinjau. Buat pratinjau ulang.',
          );
        }
        if ((barcodes[product.barcode] ?? {}).any((id) => id != product.id) ||
            (skus[product.sku] ?? {}).any((id) => id != product.id)) {
          throw StateError(
            'SKU atau barcode telah dipakai. Buat pratinjau ulang.',
          );
        }
        final delta = product.stock - (old?.stock ?? 0);
        await put('product', product.id, product.toJson());
        if (delta != 0) {
          await movement(
            product.id,
            delta,
            'Impor CSV ${plan.id}',
            reference: product.id,
            operationId: plan.id,
          );
        }
        if (old != null) {
          skus[old.sku]?.remove(old.id);
          barcodes[old.barcode]?.remove(old.id);
        }
        current[product.id] = product;
        index(product);
      }
    });
    await load();
  }
}
