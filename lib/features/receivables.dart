part of 'app.dart';

class ReceivablesPage extends ConsumerStatefulWidget {
  const ReceivablesPage({super.key});
  @override
  ConsumerState<ReceivablesPage> createState() => _ReceivablesState();
}

class _ReceivablesState extends ConsumerState<ReceivablesPage> {
  String query = '', filter = 'Aktif';
  @override
  Widget build(BuildContext context) {
    final sales = ref
        .watch(storeProvider)
        .sales
        .where((s) => s.credit && !s.voided)
        .toList();
    final active = sales.where((s) => s.outstanding > 0).toList();
    final total = active.fold(0, (v, s) => v + s.outstanding);
    final visible =
        sales
            .where(
              (s) =>
                  s.customer.toLowerCase().contains(query.toLowerCase()) &&
                  (filter == 'Semua' ||
                      (filter == 'Aktif'
                          ? s.outstanding > 0
                          : s.overdueAt(DateTime.now()))),
            )
            .toList()
          ..sort(
            (a, b) => (a.dueDate ?? '9999').compareTo(b.dueDate ?? '9999'),
          );
    return Scaffold(
      appBar: AppBar(title: const Text('Piutang pelanggan')),
      body: PageBody(
        children: [
          balanceCard(
            context,
            'PIUTANG BELUM DITERIMA',
            rupiah(total),
            '${active.length} transaksi perlu dilunasi',
            Icons.account_balance_wallet_outlined,
          ),
          const SizedBox(height: 20),
          TextField(
            decoration: const InputDecoration(
              hintText: 'Cari nama pelanggan',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (v) => setState(() => query = v),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              for (final f in ['Aktif', 'Lewat tempo', 'Semua'])
                ChoiceChip(
                  label: Text(f),
                  selected: filter == f,
                  onSelected: (_) => setState(() => filter = f),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (visible.isEmpty)
            empty(
              'Tidak ada piutang di daftar ini',
              'Penjualan tempo dan riwayat pelunasannya akan muncul di sini.',
              Icons.task_alt,
            ),
          for (final s in visible)
            Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  child: Icon(
                    s.outstanding == 0 ? Icons.check : Icons.person_outline,
                  ),
                ),
                title: Text(
                  s.customer,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  '${s.paymentStatus}${s.overdueAt(DateTime.now()) ? ' • Lewat tempo' : ''}\n${s.dueDate == null ? 'Tanpa jatuh tempo' : 'Jatuh tempo ${s.dueDate}'}',
                ),
                trailing: Text(
                  rupiah(s.outstanding),
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: s.overdueAt(DateTime.now())
                        ? Theme.of(context).colorScheme.error
                        : null,
                  ),
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SaleDetailPage(saleId: s.id),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class SaleDetailPage extends ConsumerWidget {
  final String saleId;
  const SaleDetailPage({super.key, required this.saleId});
  @override
  Widget build(BuildContext c, WidgetRef ref) {
    final store = ref.watch(storeProvider);
    final s = store.sales.where((s) => s.id == saleId).firstOrNull;
    if (s == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail penjualan')),
        body: const Center(child: Text('Transaksi tidak tersedia')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Detail penjualan')),
      body: PageBody(
        children: [
          balanceCard(
            c,
            s.paymentStatus.toUpperCase(),
            rupiah(s.result.revenue),
            s.customer.isEmpty ? s.payment : s.customer,
            Icons.receipt_long_outlined,
          ),
          OutlinedButton.icon(
            onPressed: () => Navigator.push(
              c,
              MaterialPageRoute(builder: (_) => ReceiptPage(saleId: s.id)),
            ),
            icon: const Icon(Icons.receipt_long),
            label: const Text('Lihat / bagikan struk'),
          ),
          const SizedBox(height: 16),
          Text(
            DateFormat(
              'dd MMM yyyy • HH:mm',
              'id_ID',
            ).format(DateTime.parse(s.date).toLocal()),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  for (final l in s.lines)
                    metricRow(
                      '${l.name} × ${l.quantity}',
                      rupiah(l.price * l.quantity),
                    ),
                  const Divider(),
                  metricRow('Diskon', rupiah(s.discount)),
                  metricRow('Pendapatan', rupiah(s.result.revenue)),
                  metricRow('Biaya transaksi', rupiah(s.result.fees + s.fixed)),
                  metricRow('Estimasi laba', rupiah(s.result.net)),
                  if (s.credit) ...[
                    const Divider(),
                    metricRow('Sudah dibayar', rupiah(s.paid)),
                    metricRow('Sisa piutang', rupiah(s.outstanding)),
                    metricRow('Jatuh tempo', s.dueDate ?? 'Tidak ditentukan'),
                  ],
                ],
              ),
            ),
          ),
          if (s.note.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(s.note),
            ),
          if (s.credit) ...[
            const SizedBox(height: 20),
            Text('Riwayat pembayaran', style: Theme.of(c).textTheme.titleLarge),
            if (s.payments.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text('Belum ada pembayaran.'),
              ),
            for (final p in s.payments)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.check_circle_outline),
                title: Text(rupiah(p.amount)),
                subtitle: Text(
                  '${DateFormat('dd MMM yyyy • HH:mm', 'id_ID').format(DateTime.parse(p.date).toLocal())} • ${p.method}',
                ),
              ),
            if (!s.voided && s.outstanding > 0) ...[
              FilledButton.icon(
                onPressed: () => paymentDialog(c, store, s),
                icon: const Icon(Icons.add_card),
                label: const Text('Catat pelunasan'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () async {
                  final business =
                      store.settings['business']?.toString() ?? 'Toko Kami';
                  final dateStr = DateFormat(
                    'dd/MM/yyyy',
                  ).format(DateTime.parse(s.date).toLocal());
                  final dueStr = s.dueDate != null
                      ? 'Jatuh tempo: ${s.dueDate}\n'
                      : '';
                  final message =
                      'Halo ${s.customer.isEmpty ? 'Pelanggan' : s.customer},\n'
                      'Berikut pengingat tagihan dari *$business*:\n'
                      '• No. Transaksi: ${s.id}\n'
                      '• Tanggal: $dateStr\n'
                      '• Total Belanja: ${rupiah(s.result.revenue)}\n'
                      '• Sudah Dibayar: ${rupiah(s.paid)}\n'
                      '• *Sisa Tagihan: ${rupiah(s.outstanding)}*\n'
                      '$dueStr\n'
                      'Mohon konfirmasi jika pembayaran telah dilakukan. Terima kasih!';
                  final box = c.findRenderObject() as RenderBox?;
                  await SharePlus.instance.share(
                    ShareParams(
                      text: message,
                      sharePositionOrigin: box == null
                          ? null
                          : box.localToGlobal(Offset.zero) & box.size,
                    ),
                  );
                },
                icon: const Icon(Icons.send_outlined),
                label: const Text('Kirim pengingat tagihan (WhatsApp)'),
              ),
            ],
          ],
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => Navigator.push(
              c,
              MaterialPageRoute(builder: (_) => SalesReturnsPage(saleId: s.id)),
            ),
            icon: const Icon(Icons.assignment_return_outlined),
            label: const Text('Retur & pengembalian dana'),
          ),
          if (!s.voided) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => Navigator.push(
                c,
                MaterialPageRoute(builder: (_) => SaleForm(sale: s)),
              ),
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Edit penjualan'),
            ),
            TextButton(
              onPressed: () async {
                if (await confirm(
                  c,
                  'Batalkan penjualan?',
                  'Stok dikembalikan satu kali. Riwayat pembayaran tetap disimpan. Jika sudah menerima uang, lakukan pengembalian dana kepada pelanggan secara terpisah.',
                )) {
                  if (c.mounted) await action(c, () => store.voidSale(s.id));
                }
              },
              child: const Text('Batalkan penjualan'),
            ),
          ],
        ],
      ),
    );
  }
}

Future<void> paymentDialog(BuildContext c, Store store, Sale sale) async {
  final amount = TextEditingController(text: sale.outstanding.toString());
  final accounts = await store.cashAccounts();
  String? accountId;
  if (!c.mounted) {
    amount.dispose();
    return;
  }
  final id = uuid.v4();
  var method = 'Tunai', busy = false;
  await formDialog(
    context: c,
    builder: (d) => StatefulBuilder(
      builder: (d, set) => AlertDialog(
        title: const Text('Catat pelunasan'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${sale.customer} • Sisa ${rupiah(sale.outstanding)}'),
              const SizedBox(height: 16),
              TextField(
                controller: amount,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Pembayaran (Rp)'),
              ),
              const SizedBox(height: 16),
              accountDropdown(
                accounts,
                accountId,
                (value) => set(() => accountId = value),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: method,
                decoration: const InputDecoration(
                  labelText: 'Metode pembayaran',
                ),
                items: ['Tunai', 'Transfer', 'QRIS', 'Lainnya']
                    .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                    .toList(),
                onChanged: busy ? null : (v) => set(() => method = v!),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: busy ? null : () => Navigator.pop(d),
            child: const Text('Kembali'),
          ),
          FilledButton(
            onPressed: busy
                ? null
                : () => action(d, () async {
                    if (busy) return;
                    set(() => busy = true);
                    try {
                      await store.recordPayment(
                        sale.id,
                        SalePayment(
                          id: id,
                          date: DateTime.now().toIso8601String(),
                          amount: parseIntegerInput(
                            amount.text,
                            'Pembayaran',
                            min: 1,
                          ),
                          method: method,
                          accountId: accountId,
                        ),
                      );
                      if (d.mounted) {
                        Navigator.pop(d);
                        if (c.mounted) {
                          await showSaveSuccess(
                            c,
                            'Pembayaran berhasil dicatat',
                          );
                        }
                      }
                    } finally {
                      if (d.mounted) set(() => busy = false);
                    }
                  }),
            child: const Text('Simpan pembayaran'),
          ),
        ],
      ),
    ),
  );
  amount.dispose();
}
