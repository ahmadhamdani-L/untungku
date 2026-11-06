part of 'app.dart';

class ProductsPage extends ConsumerStatefulWidget {
  const ProductsPage({super.key});
  @override
  ConsumerState<ProductsPage> createState() => _ProductsState();
}

class _ProductsState extends ConsumerState<ProductsPage> {
  String query = '', category = 'Semua', sort = 'Nama';
  bool archived = false;
  @override
  Widget build(BuildContext c) {
    final store = ref.watch(storeProvider);
    final categories = {
      'Semua',
      ...store.products.map((p) => p.category).where((v) => v.isNotEmpty),
    };
    final selectedCategory = categories.contains(category) ? category : 'Semua';
    final ps =
        store.products
            .where(
              (p) =>
                  p.archived == archived &&
                  (selectedCategory == 'Semua' ||
                      p.category == selectedCategory) &&
                  '${p.name} ${p.sku} ${p.barcode}'.toLowerCase().contains(
                    query.toLowerCase(),
                  ),
            )
            .toList()
          ..sort(
            (a, b) => sort == 'Stok'
                ? a.stock.compareTo(b.stock)
                : a.name.compareTo(b.name),
          );
    return PageBody(
      children: [
        heading(c, 'Katalog produk', 'Stok terjaga, jualan lebih tenang.'),
        FilledButton.icon(
          onPressed: () => Navigator.push(
            c,
            MaterialPageRoute(builder: (_) => const ProductForm()),
          ),
          icon: const Icon(Icons.add),
          label: const Text('Tambah produk'),
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: const InputDecoration(
            hintText: 'Cari nama atau SKU',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (v) => setState(() => query = v),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            DropdownButton<String>(
              value: selectedCategory,
              items: categories
                  .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                  .toList(),
              onChanged: (v) => setState(() => category = v!),
            ),
            DropdownButton<String>(
              value: sort,
              items: ['Nama', 'Stok']
                  .map(
                    (v) => DropdownMenuItem(value: v, child: Text('Urut: $v')),
                  )
                  .toList(),
              onChanged: (v) => setState(() => sort = v!),
            ),
            FilterChip(
              label: const Text('Arsip'),
              selected: archived,
              onSelected: (v) => setState(() => archived = v),
            ),
          ],
        ),
        if (ps.isEmpty)
          empty(
            'Katalog masih kosong',
            'Tambahkan produk pertama beserta modal dan stok awal.',
            Icons.inventory_2_outlined,
          ),
        for (final p in ps)
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                child: Text(p.name.characters.first.toUpperCase()),
              ),
              title: Text(
                p.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    [
                      p.category.isEmpty ? 'Tanpa kategori' : p.category,
                      if (p.sku.isNotEmpty) p.sku,
                    ].join(' • '),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    rupiah(p.price),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(c).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: p.stock <= p.threshold
                          ? Theme.of(c).colorScheme.errorContainer
                          : Theme.of(c).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Stok ${p.stock}${p.stock <= p.threshold ? ' • Perlu restok' : ''}',
                      style: TextStyle(
                        fontSize: 12,
                        color: p.stock <= p.threshold
                            ? Theme.of(c).colorScheme.onErrorContainer
                            : Theme.of(c).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
              isThreeLine: true,
              onTap: () => Navigator.push(
                c,
                MaterialPageRoute(builder: (_) => ProductForm(product: p)),
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (v) async {
                  if (v == 'archive') {
                    await action(
                      c,
                      () => store.archiveProduct(p.id, !p.archived),
                    );
                  } else {
                    await stockDialog(c, store, p);
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'stock',
                    child: Text('Koreksi & riwayat stok'),
                  ),
                  PopupMenuItem(
                    value: 'archive',
                    child: Text(p.archived ? 'Aktifkan' : 'Arsipkan'),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

Future<void> stockDialog(BuildContext c, Store store, Product p) async {
  bool busy = false;
  final operationId = uuid.v4();
  final delta = TextEditingController(), reason = TextEditingController();
  await formDialog(
    context: c,
    builder: (d) => AlertDialog(
      title: Text('Stok ${p.name}'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Stok sekarang: ${p.stock}'),
              TextField(
                controller: delta,
                keyboardType: const TextInputType.numberWithOptions(
                  signed: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Perubahan (+/- unit)',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reason,
                decoration: const InputDecoration(labelText: 'Alasan koreksi'),
              ),
              const SizedBox(height: 16),
              for (final m
                  in store.movements
                      .where((m) => m['productId'] == p.id)
                      .toList()
                      .reversed
                      .take(20))
                ListTile(
                  dense: true,
                  title: Text('${m['delta']} • ${m['reason']}'),
                  subtitle: Text(m['date']),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(d),
          child: const Text('Tutup'),
        ),
        FilledButton(
          onPressed: () => action(d, () async {
            if (busy) return;
            busy = true;
            try {
              await store.adjustStock(
                p.id,
                int.parse(delta.text),
                reason.text,
                operationId: operationId,
              );
              if (d.mounted) Navigator.pop(d);
            } catch (_) {
              busy = false;
              rethrow;
            }
          }),
          child: const Text('Simpan'),
        ),
      ],
    ),
  );
  delta.dispose();
  reason.dispose();
}

class ProductForm extends ConsumerStatefulWidget {
  final Product? product;
  final String? initialBarcode;
  const ProductForm({super.key, this.product, this.initialBarcode});
  @override
  ConsumerState<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends ConsumerState<ProductForm> {
  final key = GlobalKey<FormState>();
  late final String productId, createdAt;
  late final TextEditingController barcode;
  bool favorite = false;
  late final List<TextEditingController> fields;
  bool busy = false;
  @override
  void initState() {
    super.initState();
    final p = widget.product;
    productId = p?.id ?? uuid.v4();
    barcode = TextEditingController(
      text: p?.barcode ?? widget.initialBarcode ?? '',
    );
    favorite = p?.favorite ?? false;
    createdAt = p?.created ?? DateTime.now().toIso8601String();
    fields = [
      p?.name ?? '',
      p?.sku ?? '',
      p?.category ?? '',
      (p?.cost ?? 0).toString(),
      (p?.price ?? 0).toString(),
      (p?.packaging ?? 0).toString(),
      (p?.extra ?? 0).toString(),
      (p?.stock ?? 0).toString(),
      (p?.threshold ?? 5).toString(),
    ].map((s) => TextEditingController(text: s)).toList();
  }

  @override
  void dispose() {
    barcode.dispose();
    for (final f in fields) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(
      title: Text(widget.product == null ? 'Produk baru' : 'Edit produk'),
    ),
    body: PageBody(
      children: [
        Form(
          key: key,
          child: Column(
            children: [
              for (int i = 0; i < fields.length; i++) ...[
                if ([0, 3, 7].contains(i))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        i == 0
                            ? 'Identitas produk'
                            : i == 3
                            ? 'Harga & biaya per unit'
                            : 'Persediaan',
                        style: Theme.of(c).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextFormField(
                    controller: fields[i],
                    keyboardType: i >= 3
                        ? TextInputType.numberWithOptions(signed: i == 7)
                        : TextInputType.text,
                    decoration: InputDecoration(
                      labelText: [
                        'Nama produk',
                        'SKU / kode',
                        'Kategori',
                        'Modal per unit (Rp)',
                        'Harga jual (Rp)',
                        'Kemasan per unit (Rp)',
                        'Biaya tambahan per unit (Rp)',
                        'Stok',
                        'Batas stok menipis',
                      ][i],
                    ),
                    validator: (v) {
                      if (i == 0 && (v ?? '').trim().isEmpty) {
                        return 'Wajib diisi';
                      }
                      if (i >= 3 &&
                          (int.tryParse(v ?? '') == null ||
                              (int.parse(v!) < 0 &&
                                  (i != 7 ||
                                      !ref
                                          .read(storeProvider)
                                          .allowNegativeStock)) ||
                              int.parse(v).abs() >
                                  (i >= 7 ? 1000000000 : maxMoney))) {
                        return 'Masukkan bilangan bulat sesuai kebijakan dan batas nilai';
                      }
                      return null;
                    },
                  ),
                ),
              ],
              TextFormField(
                controller: barcode,
                decoration: InputDecoration(
                  labelText: 'Barcode (opsional)',
                  suffixIcon: IconButton(
                    tooltip: 'Pindai barcode produk',
                    icon: const Icon(Icons.qr_code_scanner),
                    onPressed: () async {
                      final code = await Navigator.push<String>(
                        c,
                        MaterialPageRoute(
                          builder: (_) => const BarcodeScanPage(),
                        ),
                      );
                      if (code != null && mounted) {
                        setState(() => barcode.text = code);
                      }
                    },
                  ),
                ),
                validator: (value) => (value ?? '').trim().length > 256
                    ? 'Barcode maksimal 256 karakter'
                    : null,
              ),
              SwitchListTile(
                title: const Text('Produk favorit'),
                value: favorite,
                onChanged: (v) => setState(() => favorite = v),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: busy
                    ? null
                    : () => action(c, () async {
                        if (busy) return;
                        if (!key.currentState!.validate()) {
                          return;
                        }
                        setState(() => busy = true);
                        try {
                          final now = DateTime.now().toIso8601String();
                          int n(int i) => int.parse(fields[i].text);
                          await ref
                              .read(storeProvider)
                              .saveProduct(
                                Product(
                                  id: productId,
                                  name: fields[0].text.trim(),
                                  sku: fields[1].text.trim(),
                                  barcode: barcode.text.trim(),
                                  favorite: favorite,
                                  category: fields[2].text.trim(),
                                  cost: n(3),
                                  price: n(4),
                                  packaging: n(5),
                                  extra: n(6),
                                  stock: n(7),
                                  threshold: n(8),
                                  created: createdAt,
                                  updated: now,
                                  archived: widget.product?.archived ?? false,
                                ),
                                expectedUpdated: widget.product?.updated,
                              );
                          if (c.mounted) {
                            Navigator.pop(c);
                          }
                        } finally {
                          if (mounted) {
                            setState(() => busy = false);
                          }
                        }
                      }),
                child: Text(busy ? 'Menyimpan…' : 'Simpan produk'),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
