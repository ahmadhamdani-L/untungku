part of 'app.dart';

class Dashboard extends ConsumerStatefulWidget {
  const Dashboard({super.key});
  @override
  ConsumerState<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends ConsumerState<Dashboard> {
  int days = 1;
  DateTimeRange? range;
  @override
  Widget build(BuildContext c) {
    final store = ref.watch(storeProvider);
    final now = DateTime.now();
    final start =
        range?.start ?? DateTime(now.year, now.month, now.day - days + 1);
    final end = range == null
        ? DateTime(now.year, now.month, now.day + 1)
        : DateTime(range!.end.year, range!.end.month, range!.end.day + 1);
    bool inPeriod(String date) {
      final d = DateTime.parse(date).toLocal();
      return !d.isBefore(start) && d.isBefore(end);
    }

    final sales = store.sales
        .where((s) => !s.voided && inPeriod(s.date))
        .toList();
    final expenses = store.expenses
        .where((e) => inPeriod(e.date))
        .fold(0, (v, e) => v + e.amount);
    final revenue = sales.fold(0, (v, s) => v + s.result.revenue);
    final previousStart = DateTime(
      start.year,
      start.month,
      start.day - (end.difference(start).inHours / 24).round(),
    );
    final previous = store.sales.where((s) {
      final d = DateTime.parse(s.date).toLocal();
      return !s.voided && !d.isBefore(previousStart) && d.isBefore(start);
    }).toList();
    final previousRevenue = previous.fold(0, (v, s) => v + s.result.revenue);
    final comparison = previous.isEmpty
        ? 'Belum cukup data periode sebelumnya'
        : previousRevenue == 0
        ? 'Periode sebelumnya: Rp 0'
        : '${((revenue - previousRevenue) * 100 / previousRevenue).toStringAsFixed(1)}% dibanding periode sebelumnya';
    final gross = sales.fold(0, (v, s) => v + s.result.gross);
    final net = sales.fold(0, (v, s) => v + s.result.net) - expenses;
    final low = store.products
        .where((p) => !p.archived && p.stock <= p.threshold)
        .toList();
    final units = sales.fold(
      0,
      (v, s) => v + s.lines.fold(0, (v, l) => v + l.quantity),
    );
    final best = bestSellerCounts(sales);
    final names = {for (final p in store.products) p.id: p.name};
    final ranking = best.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return PageBody(
      children: [
        heading(
          c,
          'Kabar usaha Anda',
          DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(now),
        ),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () => Navigator.push(
                  c,
                  MaterialPageRoute(builder: (_) => const SaleForm()),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Catat penjualan'),
              ),
            ),
            const SizedBox(width: 12),
            IconButton.filledTonal(
              tooltip: 'Catat pengeluaran',
              onPressed: () => expenseDialog(c, store),
              icon: const Icon(Icons.remove),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            spacing: 8,
            children: [
              for (final d in [1, 7, 30])
                ChoiceChip(
                  label: Text(d == 1 ? 'Hari ini' : '$d hari'),
                  selected: range == null && days == d,
                  onSelected: (_) => setState(() {
                    days = d;
                    range = null;
                  }),
                ),
              ActionChip(
                label: Text(
                  range == null
                      ? 'Pilih tanggal'
                      : '${DateFormat('dd/MM').format(range!.start)}–${DateFormat('dd/MM').format(range!.end)}',
                ),
                avatar: const Icon(Icons.date_range, size: 18),
                onPressed: () async {
                  final value = await showDateRangePicker(
                    context: c,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (value != null) {
                    setState(() => range = value);
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0043B8), Color(0xFF008BFF)],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PENDAPATAN TERCATAT',
                style: TextStyle(
                  color: Color(0xFFD6EBFF),
                  letterSpacing: 1.5,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
              FittedBox(
                child: Text(
                  rupiah(revenue),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${sales.length} transaksi  •  $units unit terjual\n$comparison',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (c, box) => Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final metric in [
                ('Laba kotor', gross, Icons.trending_up),
                ('Estimasi laba', net, Icons.savings_outlined),
                ('Pengeluaran', expenses, Icons.payments_outlined),
                ('Stok menipis', low.length, Icons.inventory_2_outlined),
              ])
                SizedBox(
                  width: (box.maxWidth - 12) / 2,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(metric.$3, color: const Color(0xFF0066E6)),
                          const SizedBox(height: 14),
                          Text(metric.$1),
                          const SizedBox(height: 6),
                          FittedBox(
                            child: Text(
                              metric.$1 == 'Stok menipis'
                                  ? '${metric.$2} produk'
                                  : rupiah(metric.$2),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Aksi cepat',
          style: Theme.of(
            c,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: () => Navigator.push(
                c,
                MaterialPageRoute(builder: (_) => const PosPage()),
              ),
              icon: const Icon(Icons.shopping_cart_outlined),
              label: const Text('Kasir cepat'),
            ),
            OutlinedButton.icon(
              onPressed: () => Navigator.push(
                c,
                MaterialPageRoute(builder: (_) => const ProductForm()),
              ),
              icon: const Icon(Icons.add_box_outlined),
              label: const Text('Tambah produk'),
            ),
            OutlinedButton.icon(
              onPressed: () => expenseDialog(c, store),
              icon: const Icon(Icons.payments_outlined),
              label: const Text('Pengeluaran'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Card(
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: const CircleAvatar(
              child: Icon(Icons.account_balance_wallet_outlined),
            ),
            title: const Text('Piutang pelanggan'),
            subtitle: Text(
              rupiah(
                store.sales
                    .where((s) => s.credit && !s.voided)
                    .fold(0, (v, s) => v + s.outstanding),
              ),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              c,
              MaterialPageRoute(builder: (_) => const ReceivablesPage()),
            ),
          ),
        ),
        const SizedBox(height: 16),
        FutureBuilder<List<CashMovementRow>>(
          future: store.cashLedger(),
          builder: (context, snapshot) {
            final received = (snapshot.data ?? <CashMovementRow>[])
                .where(
                  (r) =>
                      inPeriod(r.date) &&
                      {
                        'sale_receipt',
                        'sale_receipt_revision',
                        'receivable_collection',
                        'legacy_sale_receipt',
                        'legacy_collection',
                      }.contains(r.category),
                )
                .fold<int>(0, (v, r) => v + r.amount);
            return Card(
              child: ListTile(
                leading: const Icon(Icons.payments_outlined),
                title: const Text('Penerimaan penjualan'),
                subtitle: const Text(
                  'Pembayaran tercatat pada periode terpilih; refund ditampilkan di arus kas',
                ),
                trailing: Text(
                  snapshot.hasData ? rupiah(received) : '...',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            );
          },
        ),
        FutureBuilder(
          future: store.payableReport(),
          builder: (context, snapshot) => Card(
            child: ListTile(
              leading: const Icon(Icons.local_shipping_outlined),
              title: const Text('Utang pemasok'),
              subtitle: Text(
                snapshot.hasData
                    ? rupiah(
                        snapshot.data!.fold<int>(
                          0,
                          (v, r) => v + r.outstanding,
                        ),
                      )
                    : 'Memuat...',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                c,
                MaterialPageRoute(builder: (_) => const PurchasesPage()),
              ),
            ),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.insights_outlined),
            title: const Text('Asisten usaha offline'),
            subtitle: const Text(
              'Tren, restok, margin dan tagihan dari catatan usaha',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              c,
              MaterialPageRoute(builder: (_) => const BusinessInsightsPage()),
            ),
          ),
        ),
        const SizedBox(height: 12),
        RevenueTrend(sales: sales, start: start, end: end),
        const SizedBox(height: 24),
        Text('Produk terlaris', style: Theme.of(c).textTheme.titleLarge),
        if (ranking.isEmpty)
          empty(
            'Belum ada penjualan',
            'Mulai catat transaksi untuk melihat performa usaha.',
            Icons.auto_graph_rounded,
          ),
        for (final e in ranking.take(5))
          Card(
            child: ListTile(
              leading: const Icon(Icons.local_fire_department_outlined),
              title: Text(names[e.key] ?? e.key),
              trailing: Text('${e.value} unit'),
            ),
          ),
        if (low.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text('Perlu restok', style: Theme.of(c).textTheme.titleLarge),
          for (final p in low.take(5))
            ListTile(
              onTap: () => Navigator.push(
                c,
                MaterialPageRoute(builder: (_) => ProductForm(product: p)),
              ),
              title: Text(p.name),
              trailing: Text(
                '${p.stock} tersisa',
                style: const TextStyle(color: Colors.orange),
              ),
            ),
        ],
        const SizedBox(height: 16),
        const Text(
          'Pendapatan = penjualan setelah diskon. Laba kotor = pendapatan − modal barang. Estimasi laba = laba setelah kemasan, biaya transaksi, dan pengeluaran tercatat. Bukan laporan akuntansi lengkap.',
          style: TextStyle(fontSize: 12, height: 1.5),
        ),
      ],
    );
  }
}
