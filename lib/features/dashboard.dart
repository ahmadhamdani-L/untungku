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
        range?.start ??
        DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(Duration(days: days - 1));
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
    final best = <String, int>{};
    for (final s in sales) {
      for (final l in s.lines) {
        best.update(l.name, (v) => v + l.quantity, ifAbsent: () => l.quantity);
      }
    }
    final ranking = best.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return PageBody(
      children: [
        heading(c, 'Kabar usaha Anda', 'Angka nyata, keputusan lebih terarah.'),
        Wrap(
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
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF07583F), Color(0xFF10966B)],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PENDAPATAN TERCATAT',
                style: TextStyle(
                  color: Color(0xFFBEECD8),
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
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 20),
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
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(metric.$3, color: const Color(0xFF087F5B)),
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
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: () => Navigator.push(
            c,
            MaterialPageRoute(builder: (_) => const SaleForm()),
          ),
          icon: const Icon(Icons.add),
          label: const Text('Catat penjualan'),
        ),
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
              title: Text(e.key),
              trailing: Text('${e.value} unit'),
            ),
          ),
        if (low.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text('Perlu restok', style: Theme.of(c).textTheme.titleLarge),
          for (final p in low)
            ListTile(
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
