part of 'app.dart';

class SalesReturnsPage extends ConsumerWidget {
  final String saleId;
  const SalesReturnsPage({super.key, required this.saleId});
  @override
  Widget build(BuildContext c, WidgetRef ref) {
    final store = ref.watch(storeProvider);
    final sale = store.sales.where((s) => s.id == saleId).firstOrNull;
    return Scaffold(
      appBar: AppBar(title: const Text('Retur & pengembalian dana')),
      body: sale == null
          ? const Center(child: Text('Penjualan tidak tersedia'))
          : PageBody(
              children: [
                const Text(
                  'Retur dicatat terpisah dari penjualan asli. Uang baru keluar saat pengembalian dana dicatat.',
                ),
                if (!sale.voided)
                  FilledButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Catat retur barang'),
                    onPressed: () => Navigator.push(
                      c,
                      MaterialPageRoute(
                        builder: (_) => ReturnForm(saleId: saleId),
                      ),
                    ),
                  ),
                FutureBuilder<List<ReturnAdjustment>>(
                  future: store.salesReturns(saleId: saleId),
                  builder: (c, snapshot) {
                    if (snapshot.hasError) {
                      return const Text('Riwayat retur tidak dapat dibuka');
                    }
                    if (!snapshot.hasData) {
                      return const LinearProgressIndicator();
                    }
                    return Column(
                      children: [
                        if (snapshot.data!.isEmpty)
                          const Text(
                            'Belum ada retur atau kewajiban pengembalian dana.',
                          ),
                        for (final r in snapshot.data!)
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    r.kind == 'cancellation'
                                        ? 'Pembatalan penjualan'
                                        : 'Konfirmasi retur',
                                    style: Theme.of(c).textTheme.titleMedium,
                                  ),
                                  Text(
                                    '${r.date.substring(0, 10)} • ${r.reason}',
                                  ),
                                  SelectableText('Referensi: ${r.id}'),
                                  for (final entry in r.quantities.entries)
                                    Text(
                                      '${sale.lines[entry.key].name} × ${entry.value} • ${r.restocked.contains(entry.key)
                                          ? 'Kembali ke stok'
                                          : r.dispositions[entry.key] == 'damaged'
                                          ? 'Rusak'
                                          : 'Tidak layak jual'}',
                                    ),
                                  metricRow(
                                    'Pengurang pendapatan',
                                    rupiah(r.revenueReduction),
                                  ),
                                  metricRow(
                                    'Kewajiban pengembalian',
                                    rupiah(r.refundEntitlement),
                                  ),
                                  metricRow(
                                    'Sudah dikembalikan',
                                    rupiah(r.refunded),
                                  ),
                                  metricRow(
                                    'Belum dikembalikan',
                                    rupiah(r.refundOutstanding),
                                  ),
                                  if (r.refundOutstanding > 0)
                                    FilledButton.icon(
                                      icon: const Icon(Icons.payments_outlined),
                                      label: const Text(
                                        'Catat pengembalian dana',
                                      ),
                                      onPressed: () =>
                                          refundDialog(c, store, r),
                                    ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
    );
  }
}

class ReturnForm extends ConsumerStatefulWidget {
  final String saleId;
  const ReturnForm({super.key, required this.saleId});
  @override
  ConsumerState<ReturnForm> createState() => _ReturnFormState();
}

class _ReturnFormState extends ConsumerState<ReturnForm> {
  final id = uuid.v4(), reason = TextEditingController();
  final counts = <int, TextEditingController>{};
  final conditions = <int, String>{};
  late DateTime date;
  bool recoverFees = false, busy = false;
  @override
  void initState() {
    super.initState();
    date = DateTime.now();
    final sale = ref
        .read(storeProvider)
        .sales
        .firstWhere((s) => s.id == widget.saleId);
    for (var i = 0; i < sale.lines.length; i++) {
      counts[i] = TextEditingController(text: '0');
      conditions[i] = 'non_resellable';
    }
  }

  @override
  void dispose() {
    reason.dispose();
    for (final c in counts.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext c) {
    final store = ref.watch(storeProvider);
    final sale = store.sales.firstWhere((s) => s.id == widget.saleId);
    final returned = <int, int>{};
    for (final r in sale.adjustments) {
      for (final e in r.quantities.entries) {
        returned.update(e.key, (v) => v + e.value, ifAbsent: () => e.value);
      }
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Retur barang')),
      body: PageBody(
        children: [
          const Text(
            'Hanya barang layak jual yang menambah stok. Pilih jumlah tersisa dan kondisi setiap barang.',
          ),
          for (final e in counts.entries)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      '${sale.lines[e.key].name} • Sisa dapat diretur ${sale.lines[e.key].quantity - (returned[e.key] ?? 0)}',
                    ),
                    IntegerField(
                      controller: e.value,
                      label: 'Jumlah retur ${sale.lines[e.key].name}',
                      max: sale.lines[e.key].quantity - (returned[e.key] ?? 0),
                    ),
                    DropdownButtonFormField<String>(
                      initialValue: conditions[e.key],
                      decoration: const InputDecoration(
                        labelText: 'Kondisi barang',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'resellable',
                          child: Text('Layak jual — kembali ke stok'),
                        ),
                        DropdownMenuItem(
                          value: 'damaged',
                          child: Text('Rusak — tidak menambah stok'),
                        ),
                        DropdownMenuItem(
                          value: 'non_resellable',
                          child: Text('Tidak layak jual — tidak menambah stok'),
                        ),
                      ],
                      onChanged: busy
                          ? null
                          : (v) => setState(() => conditions[e.key] = v!),
                    ),
                  ],
                ),
              ),
            ),
          TextFormField(
            controller: reason,
            decoration: const InputDecoration(labelText: 'Alasan retur'),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (v) => requiredInputError(v, label: 'Alasan retur'),
          ),
          TextButton.icon(
            icon: const Icon(Icons.event),
            label: Text(DateFormat('dd MMM yyyy', 'id_ID').format(date)),
            onPressed: busy
                ? null
                : () async {
                    final picked = await showDatePicker(
                      context: c,
                      initialDate: date,
                      firstDate: DateTime.parse(sale.date),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null && mounted) {
                      setState(() => date = picked);
                    }
                  },
          ),
          SwitchListTile(
            title: const Text('Biaya transaksi ikut dikembalikan'),
            value: recoverFees,
            onChanged: busy ? null : (v) => setState(() => recoverFees = v),
          ),
          FilledButton(
            onPressed: busy
                ? null
                : () => action(c, () async {
                    if (busy) return;
                    setState(() => busy = true);
                    try {
                      final quantities = {
                        for (final e in counts.entries)
                          e.key: parseIntegerInput(
                            e.value.text,
                            'Jumlah retur',
                            max:
                                sale.lines[e.key].quantity -
                                (returned[e.key] ?? 0),
                          ),
                      }..removeWhere((k, v) => v == 0);
                      if (quantities.isEmpty) {
                        throw ArgumentError('Pilih barang yang diretur');
                      }
                      if (!await confirm(
                        c,
                        'Konfirmasi retur?',
                        'Retur akan mengurangi penjualan. Barang layak jual menambah stok. Pengembalian uang dicatat terpisah.',
                      )) {
                        return;
                      }
                      await store.recordReturn(
                        id: id,
                        saleId: sale.id,
                        quantities: quantities,
                        restock: {
                          for (final key in quantities.keys)
                            if (conditions[key] == 'resellable') key,
                        },
                        dispositions: {
                          for (final key in quantities.keys)
                            key: conditions[key]!,
                        },
                        reason: reason.text.trim(),
                        date: date.toIso8601String(),
                        recoverFees: recoverFees,
                      );
                      if (c.mounted) Navigator.pop(c);
                    } finally {
                      if (mounted) setState(() => busy = false);
                    }
                  }),
            child: const Text('Tinjau & simpan retur'),
          ),
        ],
      ),
    );
  }
}

Future<void> refundDialog(
  BuildContext c,
  Store store,
  ReturnAdjustment adjustment,
) async {
  final accounts = await store.cashAccounts();
  if (!c.mounted) return;
  final id = uuid.v4(),
      amount = TextEditingController(
        text: adjustment.refundOutstanding.toString(),
      );
  String? accountId;
  var method = 'Tunai', busy = false;
  final date = DateTime.now().toIso8601String();
  await formDialog(
    context: c,
    builder: (d) => StatefulBuilder(
      builder: (d, set) => AlertDialog(
        title: const Text('Pengembalian dana'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Sisa kewajiban ${rupiah(adjustment.refundOutstanding)}'),
              IntegerField(
                controller: amount,
                label: 'Nominal pengembalian (Rp)',
                min: 1,
                max: adjustment.refundOutstanding,
              ),
              accountDropdown(
                accounts,
                accountId,
                (v) => set(() => accountId = v),
              ),
              DropdownButtonFormField<String>(
                initialValue: method,
                decoration: const InputDecoration(
                  labelText: 'Metode pengembalian',
                ),
                items: [
                  for (final m in ['Tunai', 'Transfer', 'QRIS', 'Lainnya'])
                    DropdownMenuItem(value: m, child: Text(m)),
                ],
                onChanged: busy ? null : (v) => set(() => method = v!),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: busy ? null : () => Navigator.pop(d),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: busy
                ? null
                : () => action(d, () async {
                    if (busy) return;
                    set(() => busy = true);
                    try {
                      await store.refundCustomer(
                        id: id,
                        returnId: adjustment.id,
                        amount: parseIntegerInput(
                          amount.text,
                          'Nominal pengembalian',
                          min: 1,
                          max: adjustment.refundOutstanding,
                        ),
                        date: date,
                        method: method,
                        accountId: accountId,
                      );
                      if (d.mounted) Navigator.pop(d);
                    } finally {
                      if (d.mounted) set(() => busy = false);
                    }
                  }),
            child: const Text('Simpan pengembalian'),
          ),
        ],
      ),
    ),
  );
  amount.dispose();
}
