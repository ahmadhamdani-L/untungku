part of 'app.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});
  @override
  State<CalculatorPage> createState() => _CalculatorState();
}

class _CalculatorState extends State<CalculatorPage> {
  final controllers = List.generate(
    10,
    (i) => TextEditingController(
      text: i == 4
          ? '1'
          : i == 9
          ? '20'
          : '0',
    ),
  );
  @override
  void dispose() {
    for (final c in controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext c) {
    ProfitResult? r;
    int? breakEven, target, targetProfitPrice;
    String? error;
    try {
      int n(int i) => int.parse(controllers[i].text);
      final input = ProfitInput(
        price: n(0),
        cost: n(1),
        packaging: n(2),
        extra: n(3),
        quantity: n(4),
        discount: n(5),
        fixed: n(6),
        feeBps: parseBps(controllers[7].text),
      );
      r = input.calculate();
      breakEven = input.targetPrice(0);
      target = input.targetPrice(parseBps(controllers[9].text));
      targetProfitPrice = input.priceForProfit(n(8));
    } catch (e) {
      error = e.toString().replaceFirst('Invalid argument(s): ', '');
    }
    return PageBody(
      children: [
        heading(
          c,
          'Rencanakan untung',
          'Simulasi harga dengan biaya usaha Anda.',
        ),
        const Text(
          'Persentase biaya dihitung dari penjualan setelah diskon. Semua biaya tetap dan diskon berlaku per transaksi.',
        ),
        const SizedBox(height: 20),
        for (final i in [0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: TextField(
              controller: controllers[i],
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: [
                  'Harga jual/unit (Rp)',
                  'Modal/unit (Rp)',
                  'Kemasan/unit (Rp)',
                  'Biaya tambahan/unit (Rp)',
                  'Jumlah unit',
                  'Diskon total (Rp)',
                  'Biaya tetap total (Rp)',
                  'Biaya marketplace (%)',
                  'Target laba total (Rp)',
                  'Target margin (%)',
                ][i],
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
        if (error != null)
          Text(error, style: TextStyle(color: Theme.of(c).colorScheme.error)),
        if (r != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  metricRow('Pendapatan', rupiah(r.revenue)),
                  metricRow('Laba kotor', rupiah(r.gross)),
                  metricRow('Estimasi laba total', rupiah(r.net)),
                  metricRow(
                    'Margin',
                    r.margin == null
                        ? 'Tidak terdefinisi'
                        : '${NumberFormat('0.00', 'id_ID').format(r.margin!)}%',
                  ),
                  metricRow(
                    'Markup',
                    r.markup == null
                        ? 'Tidak terdefinisi'
                        : '${NumberFormat('0.00', 'id_ID').format(r.markup!)}%',
                  ),
                  metricRow(
                    'Harga impas/unit',
                    breakEven == null ? '—' : rupiah(breakEven),
                  ),
                  metricRow(
                    'Harga target margin/unit',
                    target == null ? '—' : rupiah(target),
                  ),
                  metricRow(
                    'Harga target laba/unit',
                    targetProfitPrice == null ? '—' : rupiah(targetProfitPrice),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
