part of 'app.dart';

/// Reports are calculated from the local ledger and remain usable offline.
class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  bool inventory = false;

  @override
  void initState() {
    super.initState();
    // Preloading cannot open an interstitial; only the explicit exit can.
    unawaited(AdManager.instance.prepareInterstitial());
  }

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(storeProvider);
    final sales = store.sales.where((s) => !s.voided).toList();
    final revenue = sales.fold<int>(0, (sum, s) => sum + s.result.revenue);
    final gross = sales.fold<int>(0, (sum, s) => sum + s.result.gross);
    final expenses = store.expenses.fold<int>(0, (sum, e) => sum + e.amount);
    final estimatedNet =
        sales.fold<int>(0, (sum, s) => sum + s.result.net) - expenses;
    final products = store.products.where((p) => !p.archived).toList();
    final stockValue = products.fold<int>(
      0,
      (sum, p) => sum + p.stock * p.cost,
    );
    final low = products.where((p) => p.stock <= p.threshold).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Laporan usaha')),
      body: PageBody(
        children: [
          heading(
            context,
            'Laporan usaha',
            'Ringkasan dari data yang tersimpan di perangkat.',
          ),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('Keuangan')),
              ButtonSegment(value: true, label: Text('Persediaan')),
            ],
            selected: {inventory},
            onSelectionChanged: (value) =>
                setState(() => inventory = value.first),
          ),
          const SizedBox(height: 20),
          if (inventory) ...[
            _reportRow('Produk aktif', '${products.length}'),
            _reportRow('Nilai stok tercatat', rupiah(stockValue)),
            _reportRow('Produk stok menipis', '${low.length}'),
            for (final product in low)
              ListTile(
                title: Text(product.name),
                subtitle: Text('Batas ${product.threshold} unit'),
                trailing: Text('${product.stock} unit'),
              ),
            const Text(
              'Nilai stok memakai modal per unit saat ini. Stok minus dapat menghasilkan nilai negatif.',
            ),
          ] else ...[
            _reportRow('Transaksi aktif', '${sales.length}'),
            _reportRow('Pendapatan', rupiah(revenue)),
            _reportRow('Laba kotor', rupiah(gross)),
            _reportRow('Pengeluaran', rupiah(expenses)),
            _reportRow('Estimasi laba', rupiah(estimatedNet)),
            const Text(
              'Estimasi berdasarkan seluruh transaksi yang belum dibatalkan dan pengeluaran tercatat. Ini bukan laporan akuntansi bersertifikat.',
            ),
          ],
          OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
              AdManager.instance.showPreparedAtNavigationBreak();
            },
            child: const Text('Selesai lihat laporan'),
          ),
          const SizedBox(height: 48),
          const OptionalAdBanner(),
        ],
      ),
    );
  }

  Widget _reportRow(String label, String value) => Card(
    child: ListTile(
      title: Text(label),
      trailing: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
  );
}
