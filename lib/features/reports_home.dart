part of 'app.dart';

/// Read-only report hub; all figures keep the existing reporting rules.
class ReportsPage extends StatelessWidget {
  final bool active;
  const ReportsPage({super.key, this.active = true});

  @override
  Widget build(BuildContext context) => PageBody(
    children: [
      heading(
        context,
        'Laporan usaha',
        'Pahami penjualan, stok, dan arus kas Anda.',
      ),
      for (final item in <(String, String, IconData, Widget)>[
        (
          'Ringkasan & tren',
          'Pendapatan, laba, dan produk terlaris',
          Icons.bar_chart_rounded,
          const Dashboard(),
        ),
        (
          'Arus kas',
          'Penerimaan, pembayaran, dan saldo akun',
          Icons.account_balance_wallet_outlined,
          const CashflowPage(),
        ),
        (
          'Asisten usaha',
          'Analisis lokal berdasarkan catatan usaha',
          Icons.insights_outlined,
          const BusinessInsightsPage(),
        ),
        (
          'Piutang pelanggan',
          'Pantau sisa pembayaran pelanggan',
          Icons.people_outline,
          const ReceivablesPage(),
        ),
        (
          'Stok produk',
          'Ketersediaan dan produk yang perlu restok',
          Icons.inventory_2_outlined,
          const ProductsPage(),
        ),
        (
          'Kalkulator harga',
          'Hitung harga dan margin sebelum menjual',
          Icons.calculate_outlined,
          const CalculatorPage(),
        ),
      ])
        Card(
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: CircleAvatar(child: Icon(item.$3)),
            title: Text(
              item.$1,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(item.$2),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    item.$4 is Dashboard ||
                        item.$4 is ProductsPage ||
                        item.$4 is CalculatorPage
                    ? Scaffold(
                        appBar: AppBar(title: Text(item.$1)),
                        body: item.$4,
                      )
                    : item.$4,
              ),
            ),
          ),
        ),
      if (active && MediaQuery.sizeOf(context).width >= 360)
        const OptionalNativeAd(),
    ],
  );
}
