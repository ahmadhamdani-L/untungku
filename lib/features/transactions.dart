part of 'app.dart';

class TransactionsPage extends ConsumerStatefulWidget {
  const TransactionsPage({super.key});
  @override
  ConsumerState<TransactionsPage> createState() => _TransactionsState();
}

class _TransactionsState extends ConsumerState<TransactionsPage> {
  String query = '', type = 'Semua';
  DateTimeRange? range;
  @override
  Widget build(BuildContext c) {
    final store = ref.watch(storeProvider);
    bool match(String date, String text) {
      final d = DateTime.parse(date).toLocal();
      return text.toLowerCase().contains(query.toLowerCase()) &&
          (range == null ||
              (!d.isBefore(range!.start) &&
                  d.isBefore(range!.end.add(const Duration(days: 1)))));
    }

    final rows = <({String date, Widget child})>[
      if (type != 'Pengeluaran')
        for (final s in store.sales.where(
          (s) => match(
            s.date,
            '${s.id} ${s.note} ${s.lines.map((l) => l.name).join(' ')}',
          ),
        ))
          (
            date: s.date,
            child: Card(
              child: ListTile(
                leading: Icon(
                  s.voided
                      ? Icons.cancel_outlined
                      : Icons.arrow_downward_rounded,
                  color: s.voided ? Colors.grey : const Color(0xFF087F5B),
                ),
                title: Text(
                  s.lines.map((l) => '${l.name} ×${l.quantity}').join(', '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  '${DateFormat('dd MMM yyyy • HH:mm', 'id_ID').format(DateTime.parse(s.date).toLocal())}\n${s.payment} • ${s.voided
                      ? 'Dibatalkan'
                      : s.note.isEmpty
                      ? 'Penjualan'
                      : s.note}',
                ),
                isThreeLine: true,
                trailing: Text(rupiah(s.result.revenue)),
                onTap: () => showDialog(
                  context: c,
                  builder: (d) => AlertDialog(
                    title: const Text('Detail penjualan'),
                    content: Text(
                      '${s.lines.map((l) => '${l.name} × ${l.quantity}: ${rupiah(l.price * l.quantity)}').join('\n')}\n\nPendapatan: ${rupiah(s.result.revenue)}\nEstimasi laba: ${rupiah(s.result.net)}\nDiskon: ${rupiah(s.discount)}\nBiaya: ${rupiah(s.result.fees + s.fixed)}\n${s.note}',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(d),
                        child: const Text('Tutup'),
                      ),
                      if (!s.voided) ...[
                        TextButton(
                          onPressed: () {
                            Navigator.pop(d);
                            Navigator.push(
                              c,
                              MaterialPageRoute(
                                builder: (_) => SaleForm(sale: s),
                              ),
                            );
                          },
                          child: const Text('Edit'),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(d);
                            if (await confirm(
                              c,
                              'Batalkan penjualan?',
                              'Stok akan dikembalikan satu kali. Riwayat tetap disimpan.',
                            )) {
                              if (c.mounted) {
                                await action(c, () => store.voidSale(s.id));
                              }
                            }
                          },
                          child: const Text('Batalkan'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
      if (type != 'Penjualan')
        for (final e in store.expenses.where(
          (e) => match(e.date, '${e.category} ${e.note}'),
        ))
          (
            date: e.date,
            child: Card(
              child: ListTile(
                leading: const Icon(
                  Icons.arrow_upward_rounded,
                  color: Colors.orange,
                ),
                title: Text(e.category),
                subtitle: Text(
                  '${DateFormat('dd MMM yyyy').format(DateTime.parse(e.date).toLocal())} • ${e.note}',
                ),
                trailing: Text('− ${rupiah(e.amount)}'),
                onTap: () => expenseDialog(c, store, e),
              ),
            ),
          ),
    ]..sort((a, b) => b.date.compareTo(a.date));
    return PageBody(
      children: [
        heading(
          c,
          'Riwayat transaksi',
          'Setiap pemasukan dan pengeluaran tercatat.',
        ),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: () => Navigator.push(
                c,
                MaterialPageRoute(builder: (_) => const SaleForm()),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Penjualan'),
            ),
            OutlinedButton.icon(
              onPressed: () => expenseDialog(c, store),
              icon: const Icon(Icons.remove),
              label: const Text('Pengeluaran'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Cari produk, catatan, atau kategori',
          ),
          onChanged: (v) => setState(() => query = v),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            for (final t in ['Semua', 'Penjualan', 'Pengeluaran'])
              ChoiceChip(
                label: Text(t),
                selected: type == t,
                onSelected: (_) => setState(() => type = t),
              ),
            ActionChip(
              avatar: const Icon(Icons.date_range, size: 18),
              label: Text(
                range == null
                    ? 'Tanggal'
                    : '${DateFormat('dd/MM').format(range!.start)}–${DateFormat('dd/MM').format(range!.end)}',
              ),
              onPressed: () async {
                final r = await showDateRangePicker(
                  context: c,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (r != null) {
                  setState(() => range = r);
                }
              },
            ),
            if (range != null)
              ActionChip(
                label: const Text('Reset tanggal'),
                onPressed: () => setState(() => range = null),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (rows.isEmpty)
          empty(
            'Belum ada transaksi',
            'Penjualan dan pengeluaran akan muncul di sini.',
            Icons.receipt_long_outlined,
          ),
        ...rows.map((r) => r.child),
      ],
    );
  }
}

Future<void> expenseDialog(BuildContext c, Store store, [Expense? e]) async {
  final category = TextEditingController(text: e?.category ?? ''),
      amount = TextEditingController(text: e?.amount.toString() ?? ''),
      note = TextEditingController(text: e?.note ?? '');
  var date = e == null ? DateTime.now() : DateTime.parse(e.date);
  bool busy = false;
  await showDialog(
    context: c,
    builder: (d) => StatefulBuilder(
      builder: (d, set) => AlertDialog(
        title: Text(e == null ? 'Catat pengeluaran' : 'Edit pengeluaran'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: category,
                decoration: const InputDecoration(labelText: 'Kategori'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amount,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Jumlah (Rp)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: note,
                decoration: const InputDecoration(labelText: 'Catatan'),
              ),
              TextButton.icon(
                onPressed: () async {
                  final value = await showDatePicker(
                    context: d,
                    initialDate: date,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (value != null) {
                    set(() => date = value);
                  }
                },
                icon: const Icon(Icons.calendar_month),
                label: Text(DateFormat('dd/MM/yyyy').format(date)),
              ),
            ],
          ),
        ),
        actions: [
          if (e != null)
            TextButton(
              onPressed: busy
                  ? null
                  : () async {
                      if (await confirm(
                        d,
                        'Hapus pengeluaran?',
                        'Catatan pengeluaran ini akan dihapus.',
                      )) {
                        if (d.mounted) {
                          await action(d, () async {
                            await store.deleteExpense(e.id);
                            if (d.mounted) {
                              Navigator.pop(d);
                            }
                          });
                        }
                      }
                    },
              child: const Text('Hapus'),
            ),
          TextButton(
            onPressed: busy ? null : () => Navigator.pop(d),
            child: const Text('Kembali'),
          ),
          FilledButton(
            onPressed: busy
                ? null
                : () => action(d, () async {
                    set(() => busy = true);
                    try {
                      await store.saveExpense(
                        Expense(
                          id: e?.id ?? uuid.v4(),
                          date: date.toIso8601String(),
                          category: category.text.trim(),
                          note: note.text,
                          amount: int.parse(amount.text),
                        ),
                      );
                      if (d.mounted) {
                        Navigator.pop(d);
                      }
                    } finally {
                      if (d.mounted) {
                        set(() => busy = false);
                      }
                    }
                  }),
            child: const Text('Simpan'),
          ),
        ],
      ),
    ),
  );
  category.dispose();
  amount.dispose();
  note.dispose();
}

class CartEntry {
  final Product product;
  final TextEditingController quantity, price;
  final SaleLine? original;
  CartEntry(this.product, {this.original})
    : quantity = TextEditingController(
        text: (original?.quantity ?? 1).toString(),
      ),
      price = TextEditingController(
        text: (original?.price ?? product.price).toString(),
      );
  void dispose() {
    quantity.dispose();
    price.dispose();
  }
}

class SaleForm extends ConsumerStatefulWidget {
  final Sale? sale;
  const SaleForm({super.key, this.sale});
  @override
  ConsumerState<SaleForm> createState() => _SaleFormState();
}

class _SaleFormState extends ConsumerState<SaleForm> {
  final cart = <CartEntry>[];
  late final TextEditingController discount, fixed, fee, note;
  String payment = 'Tunai';
  bool busy = false;
  late DateTime date;
  @override
  void initState() {
    super.initState();
    final s = widget.sale;
    discount = TextEditingController(text: (s?.discount ?? 0).toString());
    fixed = TextEditingController(text: (s?.fixed ?? 0).toString());
    fee = TextEditingController(
      text:
          ((s?.feeBps ?? ref.read(storeProvider).settings['feeBps'] ?? 0) / 100)
              .toString(),
    );
    note = TextEditingController(text: s?.note ?? '');
    payment = s?.payment ?? 'Tunai';
    date = s == null ? DateTime.now() : DateTime.parse(s.date);
    if (s != null) {
      for (final l in s.lines) {
        cart.add(
          CartEntry(
            ref
                .read(storeProvider)
                .products
                .firstWhere((p) => p.id == l.productId),
            original: l,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    for (final e in cart) {
      e.dispose();
    }
    for (final e in [discount, fixed, fee, note]) {
      e.dispose();
    }
    super.dispose();
  }

  Sale sale() => Sale(
    id: widget.sale?.id ?? uuid.v4(),
    date: date.toIso8601String(),
    lines: cart
        .map(
          (e) => SaleLine(
            productId: e.product.id,
            name: e.original?.name ?? e.product.name,
            quantity: int.parse(e.quantity.text),
            price: int.parse(e.price.text),
            cost: e.original?.cost ?? e.product.cost,
            packaging: e.original?.packaging ?? e.product.packaging,
            extra: e.original?.extra ?? e.product.extra,
          ),
        )
        .toList(),
    discount: int.parse(discount.text),
    fixed: int.parse(fixed.text),
    feeBps: parseBps(fee.text),
    payment: payment,
    note: note.text,
  );
  @override
  Widget build(BuildContext c) {
    final products = ref
        .watch(storeProvider)
        .products
        .where((p) => !p.archived && !cart.any((e) => e.product.id == p.id))
        .toList();
    ProfitResult? result;
    try {
      result = sale().result;
    } catch (_) {}
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.sale == null ? 'Catat penjualan' : 'Revisi penjualan',
        ),
      ),
      body: PageBody(
        children: [
          const Text(
            'Pilih produk dan harga jual aktual. Stok diperbarui saat disimpan.',
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: null,
            decoration: const InputDecoration(labelText: 'Tambahkan produk'),
            items: products
                .map(
                  (p) => DropdownMenuItem(
                    value: p.id,
                    child: Text(
                      '${p.name} • stok ${p.stock}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: (id) {
              if (id != null) {
                setState(
                  () => cart.add(
                    CartEntry(products.firstWhere((p) => p.id == id)),
                  ),
                );
              }
            },
            isExpanded: true,
          ),
          const SizedBox(height: 12),
          for (final e in cart)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            e.product.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() => cart.remove(e));
                            e.dispose();
                          },
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: e.quantity,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Jumlah',
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: e.price,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Harga/unit (Rp)',
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          for (final pair in [
            (discount, 'Diskon total penjual (Rp)'),
            (fixed, 'Biaya tetap transaksi (Rp)'),
            (fee, 'Biaya marketplace / pembayaran (%)'),
            (note, 'Catatan'),
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: TextField(
                controller: pair.$1,
                keyboardType: pair.$1 == note
                    ? TextInputType.text
                    : const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: pair.$2),
                onChanged: (_) => setState(() {}),
              ),
            ),
          DropdownButtonFormField<String>(
            initialValue: payment,
            decoration: const InputDecoration(labelText: 'Pembayaran'),
            items: [
              'Tunai',
              'Transfer',
              'QRIS',
              'Lainnya',
            ].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
            onChanged: (v) => setState(() => payment = v!),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () async {
              final d = await showDatePicker(
                context: c,
                initialDate: date,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (d != null) {
                setState(() => date = d);
              }
            },
            icon: const Icon(Icons.event),
            label: Text(DateFormat('dd MMM yyyy', 'id_ID').format(date)),
          ),
          if (result != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    metricRow('Pendapatan', rupiah(result.revenue)),
                    metricRow('Modal barang', rupiah(result.cogs)),
                    metricRow('Estimasi laba', rupiah(result.net)),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: busy
                ? null
                : () => action(c, () async {
                    setState(() => busy = true);
                    try {
                      await ref.read(storeProvider).saveSale(sale());
                      if (c.mounted) {
                        Navigator.pop(c);
                      }
                    } finally {
                      if (mounted) {
                        setState(() => busy = false);
                      }
                    }
                  }),
            icon: const Icon(Icons.check),
            label: Text(busy ? 'Menyimpan…' : 'Simpan penjualan'),
          ),
        ],
      ),
    );
  }
}

int parseBps(String input) {
  if (!RegExp(r'^\d{1,2}([.,]\d{1,2})?$').hasMatch(input)) {
    throw ArgumentError('Persentase harus 0–99,99% (maksimal 2 desimal)');
  }
  final parts = input.replaceAll(',', '.').split('.');
  return int.parse(parts[0]) * 100 +
      (parts.length == 1 ? 0 : int.parse(parts[1].padRight(2, '0')));
}

Widget metricRow(String label, String value) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 7),
  child: Row(
    children: [
      Expanded(child: Text(label)),
      Flexible(
        child: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w700),
          textAlign: TextAlign.right,
        ),
      ),
    ],
  ),
);
