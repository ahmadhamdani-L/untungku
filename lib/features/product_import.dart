part of 'app.dart';

class ProductImportPage extends ConsumerStatefulWidget {
  const ProductImportPage({super.key});
  @override
  ConsumerState<ProductImportPage> createState() => _ProductImportState();
}

class _ProductImportState extends ConsumerState<ProductImportPage> {
  CsvTable? table;
  ProductImportPlan? plan;
  final mapping = <String, int?>{};
  String id = uuid.v4(), timestamp = DateTime.now().toIso8601String();
  String? filename;
  ImportDuplicatePolicy policy = ImportDuplicatePolicy.skip;
  bool busy = false, committed = false;
  Future<void> run(Future<void> Function() task) => action(context, () async {
    if (busy) return;
    setState(() => busy = true);
    try {
      await task();
    } finally {
      if (mounted) setState(() => busy = false);
    }
  });
  @override
  Widget build(BuildContext c) {
    final store = ref.watch(storeProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Impor produk CSV')),
      body: PageBody(
        children: [
          const Text(
            'Impor memakai SKU/barcode sebagai identitas, bukan nama produk. Tinjau perubahan stok sebelum menyimpan. Tidak ada perubahan sebelum konfirmasi.',
          ),
          OutlinedButton.icon(
            icon: const Icon(Icons.download),
            label: const Text('Simpan template CSV'),
            onPressed: busy
                ? null
                : () => run(() async {
                    await FilePicker.saveFile(
                      fileName: 'template-produk.csv',
                      bytes: Uint8List.fromList(
                        utf8.encode(productCsvTemplate),
                      ),
                      mimeType: 'text/csv',
                    );
                  }),
          ),
          FilledButton.icon(
            icon: const Icon(Icons.file_open_outlined),
            label: const Text('Pilih file CSV'),
            onPressed: busy
                ? null
                : () => run(() async {
                    final file = await FilePicker.pickFile(
                      type: FileType.custom,
                      allowedExtensions: ['csv'],
                    );
                    if (file == null) return;
                    if ((await file.length() ?? 0) > 5000000) {
                      throw ArgumentError('CSV maksimal 5 MB');
                    }
                    final buffer = BytesBuilder(copy: false);
                    await for (final chunk in file.readAsByteStream()) {
                      if (buffer.length + chunk.length > 5000000) {
                        throw ArgumentError('CSV maksimal 5 MB');
                      }
                      buffer.add(chunk);
                    }
                    final bytes = buffer.takeBytes();
                    final parsed = await compute(parseProductCsvBytes, bytes);
                    if (!mounted) return;
                    setState(() {
                      table = parsed;
                      plan = null;
                      filename = file.name;
                      committed = false;
                      id = uuid.v4();
                      timestamp = DateTime.now().toIso8601String();
                      mapping.clear();
                      for (final field in productCsvColumns) {
                        final index = parsed.headers.indexWhere(
                          (h) => h.toLowerCase() == field,
                        );
                        mapping[field] = index < 0 ? null : index;
                      }
                    });
                  }),
          ),
          if (table != null) ...[
            Text('$filename • ${table!.rows.length} baris'),
            const Text(
              'Petakan kolom. Nama dan harga_jual wajib dipilih; kolom numerik yang tidak dipetakan memakai nilai awal template.',
            ),
            for (final field in productCsvColumns)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: DropdownButtonFormField<int>(
                  key: ValueKey('$id:$field'),
                  initialValue: mapping[field],
                  isExpanded: true,
                  decoration: InputDecoration(labelText: field),
                  items: [
                    const DropdownMenuItem<int>(
                      value: null,
                      child: Text('Tidak dipetakan'),
                    ),
                    for (var i = 0; i < table!.headers.length; i++)
                      DropdownMenuItem(
                        value: i,
                        child: Text(table!.headers[i]),
                      ),
                  ],
                  onChanged: busy || committed
                      ? null
                      : (value) => setState(() {
                          mapping[field] = value;
                          plan = null;
                        }),
                ),
              ),
            DropdownButtonFormField<ImportDuplicatePolicy>(
              initialValue: policy,
              decoration: const InputDecoration(
                labelText: 'Produk dengan SKU/barcode yang sudah ada',
              ),
              items: const [
                DropdownMenuItem(
                  value: ImportDuplicatePolicy.skip,
                  child: Text('Lewati duplikat'),
                ),
                DropdownMenuItem(
                  value: ImportDuplicatePolicy.update,
                  child: Text('Perbarui produk yang cocok'),
                ),
                DropdownMenuItem(
                  value: ImportDuplicatePolicy.createOnly,
                  child: Text('Buat produk baru saja'),
                ),
              ],
              onChanged: busy || committed
                  ? null
                  : (value) => setState(() {
                      policy = value!;
                      plan = null;
                    }),
            ),
            OutlinedButton(
              onPressed: busy || committed
                  ? null
                  : () => run(() async {
                      final csv = table!,
                          columns = Map<String, int?>.of(mapping),
                          products = List<Product>.of(store.products);
                      final batch = id,
                          time = timestamp,
                          chosen = policy,
                          allowNegative = store.allowNegativeStock;
                      final result = await compute(buildProductImport, (
                        table: csv,
                        columns: columns,
                        products: products,
                        id: batch,
                        timestamp: time,
                        policy: chosen,
                        allowNegativeStock: allowNegative,
                      ));
                      if (mounted) setState(() => plan = result);
                    }),
              child: const Text('Validasi & pratinjau'),
            ),
          ],
          if (plan case final ProductImportPlan preview) ...[
            Text(
              '${preview.created} baru • ${preview.updated} diperbarui • ${preview.skipped} dilewati • ${preview.rows.where((r) => r.error != null).length} bermasalah',
            ),
            for (final row in preview.rows.take(100))
              ListTile(
                title: Text(
                  'Baris ${row.line}: ${row.product?.name ?? 'Tidak valid'}',
                ),
                subtitle: Text(
                  row.error ??
                      (row.skipped
                          ? 'Dilewati'
                          : 'Stok ${row.existing?.stock ?? 0} → ${row.product!.stock} • Harga ${rupiah(row.product!.price)}'),
                ),
              ),
            if (preview.rows.length > 100)
              const Text(
                'Pratinjau menampilkan 100 baris pertama; semua baris tetap divalidasi.',
              ),
            TextButton(
              onPressed: busy
                  ? null
                  : () => run(() async {
                      await FilePicker.saveFile(
                        fileName: 'hasil-validasi-impor.json',
                        bytes: Uint8List.fromList(
                          utf8.encode(
                            jsonEncode({
                              'baru': preview.created,
                              'diperbarui': preview.updated,
                              'dilewati': preview.skipped,
                              'baris': [
                                for (final row in preview.rows)
                                  {
                                    'baris': row.line,
                                    'nama': row.product?.name,
                                    'error': row.error,
                                    'dilewati': row.skipped,
                                  },
                              ],
                            }),
                          ),
                        ),
                        mimeType: 'application/json',
                      );
                    }),
              child: const Text('Simpan hasil validasi'),
            ),
            FilledButton(
              onPressed: busy || committed || !preview.valid
                  ? null
                  : () => run(() async {
                      if (!await confirm(
                        c,
                        'Konfirmasi impor produk?',
                        '${preview.created} produk baru dan ${preview.updated} pembaruan. Stok diperbarui sesuai pratinjau dan dicatat dalam audit.',
                      )) {
                        return;
                      }
                      await store.commitProductImport(preview);
                      if (mounted) setState(() => committed = true);
                    }),
              child: Text(committed ? 'Impor selesai' : 'Konfirmasi impor'),
            ),
          ],
          if (busy) const LinearProgressIndicator(),
        ],
      ),
    );
  }
}
