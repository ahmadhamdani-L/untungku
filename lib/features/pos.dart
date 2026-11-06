part of 'app.dart';

class BarcodeScanPage extends StatefulWidget {
  const BarcodeScanPage({super.key});
  @override
  State<BarcodeScanPage> createState() => _BarcodeScanState();
}

class _BarcodeScanState extends State<BarcodeScanPage> {
  bool completed = false;
  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: const Text('Pindai barcode')),
    body: Column(
      children: [
        Expanded(
          child: MobileScanner(
            onDetect: (capture) {
              if (completed || !mounted) return;
              final code = capture.barcodes
                  .map((b) => b.rawValue)
                  .whereType<String>()
                  .where((s) => s.trim().isNotEmpty)
                  .firstOrNull;
              if (code == null) return;
              completed = true;
              Navigator.pop(c, code.trim());
            },
            errorBuilder: (c, error) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Kamera tidak tersedia atau izin ditolak. Anda tetap dapat memasukkan barcode atau memilih produk secara manual.',
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(c),
                      child: const Text('Kembali ke input manual'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        TextButton.icon(
          onPressed: () {
            completed = true;
            Navigator.pop(c);
          },
          icon: const Icon(Icons.keyboard),
          label: const Text('Masukkan barcode manual'),
        ),
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Arahkan kamera ke barcode. Kembali untuk memilih produk tanpa kamera.',
          ),
        ),
      ],
    ),
  );
}

class PosPage extends ConsumerStatefulWidget {
  const PosPage({super.key});
  @override
  ConsumerState<PosPage> createState() => _PosState();
}

class _PosState extends ConsumerState<PosPage> {
  final cart = PosCart(), barcode = TextEditingController();
  String query = '', category = 'Semua';
  bool favorites = false;
  @override
  void dispose() {
    barcode.dispose();
    super.dispose();
  }

  Future<void> addBarcode(String value) async {
    final store = ref.read(storeProvider);
    final product = store.products
        .where(
          (p) =>
              !p.archived && p.barcode.isNotEmpty && p.barcode == value.trim(),
        )
        .firstOrNull;
    if (product == null) {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (d) => AlertDialog(
          title: const Text('Barcode belum terdaftar'),
          content: Text(
            '$value\nPilih produk dari daftar atau daftarkan produk baru.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(d),
              child: const Text('Pilih dari daftar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(d);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductForm(initialBarcode: value.trim()),
                  ),
                );
              },
              child: const Text('Produk baru'),
            ),
          ],
        ),
      );
      return;
    }
    setState(
      () => cart.add(product, allowNegativeStock: store.allowNegativeStock),
    );
    barcode.clear();
  }

  @override
  Widget build(BuildContext c) {
    final store = ref.watch(storeProvider);
    final categories = {
      'Semua',
      ...store.products
          .where((p) => !p.archived && p.category.isNotEmpty)
          .map((p) => p.category),
    };
    final products = store.products
        .where(
          (p) =>
              !p.archived &&
              (!favorites || p.favorite) &&
              (category == 'Semua' || category == p.category) &&
              '${p.name} ${p.sku} ${p.barcode}'.toLowerCase().contains(
                query.toLowerCase(),
              ),
        )
        .toList();
    final total = cart.quantities.entries.fold<int>(
      0,
      (sum, e) =>
          sum + store.products.firstWhere((p) => p.id == e.key).price * e.value,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Kasir cepat')),
      body: PageBody(
        children: [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Cari produk / SKU / barcode',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (v) => setState(() => query = v),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: barcode,
            decoration: InputDecoration(
              labelText: 'Barcode manual',
              suffixIcon: IconButton(
                tooltip: 'Tambah barcode',
                icon: const Icon(Icons.add),
                onPressed: () => action(c, () => addBarcode(barcode.text)),
              ),
            ),
            onSubmitted: (v) => action(c, () => addBarcode(v)),
          ),
          OutlinedButton.icon(
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Pindai barcode'),
            onPressed: () => action(c, () async {
              final code = await Navigator.push<String>(
                c,
                MaterialPageRoute(builder: (_) => const BarcodeScanPage()),
              );
              if (code != null && mounted) await addBarcode(code);
            }),
          ),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('Favorit'),
                selected: favorites,
                onSelected: (v) => setState(() => favorites = v),
              ),
              for (final value in categories)
                ChoiceChip(
                  label: Text(value),
                  selected: category == value,
                  onSelected: (_) => setState(() => category = value),
                ),
            ],
          ),
          for (final product in products)
            Card(
              child: ListTile(
                title: Text(product.name),
                subtitle: Text(
                  '${rupiah(product.price)} • Stok ${product.stock}',
                ),
                trailing: IconButton(
                  tooltip: 'Tambah ${product.name}',
                  icon: const Icon(Icons.add_shopping_cart),
                  onPressed: () => action(c, () async {
                    setState(
                      () => cart.add(
                        product,
                        allowNegativeStock: store.allowNegativeStock,
                      ),
                    );
                  }),
                ),
              ),
            ),
          const Divider(),
          Text('Keranjang', style: Theme.of(c).textTheme.titleLarge),
          if (cart.quantities.isEmpty) const Text('Keranjang masih kosong'),
          for (final entry in cart.quantities.entries)
            Builder(
              builder: (c) {
                final product = store.products.firstWhere(
                  (p) => p.id == entry.key,
                );
                void change(int value) => action(c, () async {
                  setState(
                    () => cart.setQuantity(
                      product,
                      value,
                      allowNegativeStock: store.allowNegativeStock,
                    ),
                  );
                });
                return Card(
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(product.name),
                        subtitle: Text(
                          'Jumlah ${entry.value} • ${rupiah(product.price * entry.value)}',
                        ),
                        trailing: IconButton(
                          tooltip: 'Hapus ${product.name}',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => change(0),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            tooltip: 'Kurangi ${product.name}',
                            icon: const Icon(Icons.remove),
                            onPressed: () => change(entry.value - 1),
                          ),
                          Text('${entry.value}'),
                          IconButton(
                            tooltip: 'Tambah jumlah ${product.name}',
                            icon: const Icon(Icons.add),
                            onPressed: () => change(entry.value + 1),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          metricRow('Subtotal barang', rupiah(total)),
          FilledButton.icon(
            icon: const Icon(Icons.point_of_sale),
            label: const Text('Lanjut pembayaran'),
            onPressed: cart.quantities.isEmpty
                ? null
                : () async {
                    final result = await Navigator.push<String>(
                      c,
                      MaterialPageRoute(
                        builder: (_) => SaleForm(
                          initialCart: cart.quantities,
                          previewAfterSave: true,
                        ),
                      ),
                    );
                    if (result != null && mounted) setState(cart.clear);
                  },
          ),
        ],
      ),
    );
  }
}
