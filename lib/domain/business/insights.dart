import '../models.dart';
import '../dates.dart';

enum InsightSeverity { info, warning, critical }

enum InsightDestination { products, transactions, receivables }

class BusinessInsight {
  final String id, title, explanation, recommendation;
  final InsightSeverity severity;
  final InsightDestination destination;
  const BusinessInsight(
    this.id,
    this.title,
    this.explanation,
    this.recommendation,
    this.severity,
    this.destination,
  );
}

/// Deterministic local rules. No external inference and no financial writes.
List<BusinessInsight> businessInsights({
  required List<Product> products,
  required List<Sale> sales,
  required List<Expense> expenses,
  required DateTime now,
  int windowDays = 7,
}) {
  if (windowDays < 7 || windowDays > 90) {
    throw ArgumentError('Periode harus 7–90 hari');
  }
  final end = DateTime(now.year, now.month, now.day + 1);
  final start = DateTime(now.year, now.month, now.day + 1 - windowDays);
  final previousStart = DateTime(
    start.year,
    start.month,
    start.day - windowDays,
  );
  bool within(String date, DateTime from) {
    final d = validDate(date);
    return !d.isBefore(from) && d.isBefore(end) && !d.isAfter(now);
  }

  final eligible = sales
      .where((s) => !s.voided && !validDate(s.date).isAfter(now))
      .map(
        (s) => Sale.fromJson(
          s.toJson(),
          adjustments: s.adjustments
              .where((r) => !validDate(r.date).isAfter(now))
              .toList(),
        ),
      )
      .toList();
  final recent = eligible.where((s) => within(s.date, start)).toList();
  final previous = eligible
      .where(
        (s) =>
            within(s.date, previousStart) && validDate(s.date).isBefore(start),
      )
      .toList();
  int revenue(List<Sale> rows) =>
      rows.fold(0, (sum, s) => sum + s.result.revenue);
  final currentRevenue = revenue(recent), previousRevenue = revenue(previous);
  final period =
      '${start.toIso8601String().substring(0, 10)} s.d. ${now.toIso8601String().substring(0, 10)} ($windowDays hari)';
  final result = <BusinessInsight>[];
  void add(
    String id,
    String title,
    String why,
    String suggestion,
    InsightSeverity severity,
    InsightDestination destination,
  ) => result.add(
    BusinessInsight(
      id,
      title,
      '$period. $why',
      suggestion,
      severity,
      destination,
    ),
  );
  if (recent.length >= 3 && previous.length >= 3 && previousRevenue > 0) {
    final percentage =
        (currentRevenue - previousRevenue) * 100 ~/ previousRevenue;
    if (percentage <= -10 || percentage >= 10) {
      add(
        'revenue-trend',
        'Pendapatan ${percentage < 0 ? 'turun' : 'naik'} ${percentage.abs()}%',
        'Pendapatan tercatat $currentRevenue Rupiah dibanding $previousRevenue Rupiah pada $windowDays hari sebelumnya. '
            'Perbandingan ini tidak menjelaskan penyebab perubahan.',
        'Buka transaksi untuk membandingkan produk dan tanggal penjualan.',
        percentage < 0 ? InsightSeverity.warning : InsightSeverity.info,
        InsightDestination.transactions,
      );
    }
  }
  final active = products.where((p) => !p.archived).toList();
  final exhausted = active.where((p) => p.stock <= 0).toList();
  if (exhausted.isNotEmpty) {
    add(
      'stock-empty',
      '${exhausted.length} produk kosong atau stok minus',
      exhausted.take(5).map((p) => '${p.name}: ${p.stock}').join(', '),
      'Periksa stok fisik dan penerimaan sebelum menawarkan barang.',
      InsightSeverity.critical,
      InsightDestination.products,
    );
  }
  final low = active
      .where((p) => p.stock > 0 && p.stock <= p.threshold)
      .toList();
  if (low.isNotEmpty) {
    add(
      'stock-low',
      '${low.length} produk perlu ditinjau untuk restok',
      low
          .take(5)
          .map((p) => '${p.name}: ${p.stock}, batas ${p.threshold}')
          .join(', '),
      'Tinjau batas stok dan kebutuhan pembelian.',
      InsightSeverity.warning,
      InsightDestination.products,
    );
  }
  final units = <String, int>{},
      days = <String, Set<String>>{},
      productRevenue = <String, int>{},
      productProfit = <String, int>{};
  for (final sale in recent) {
    final returned = <int, int>{};
    for (final r in sale.adjustments) {
      for (final e in r.quantities.entries) {
        returned.update(e.key, (v) => v + e.value, ifAbsent: () => e.value);
      }
    }
    final gross = [
      for (var i = 0; i < sale.lines.length; i++)
        sale.lines[i].price * (sale.lines[i].quantity - (returned[i] ?? 0)),
    ];
    final total = gross.fold<int>(0, (sum, value) => sum + value);
    var before = 0;
    for (var i = 0; i < sale.lines.length; i++) {
      final line = sale.lines[i], netUnits = line.quantity - (returned[i] ?? 0);
      if (netUnits <= 0) continue;
      units.update(
        line.productId,
        (v) => v + netUnits,
        ifAbsent: () => netUnits,
      );
      days
          .putIfAbsent(line.productId, () => {})
          .add(sale.date.substring(0, 10));
      if (total > 0) {
        final allocatedRevenue =
            sale.result.revenue * (before + gross[i]) ~/ total -
            sale.result.revenue * before ~/ total;
        final allocatedProfit =
            sale.result.net * (before + gross[i]) ~/ total -
            sale.result.net * before ~/ total;
        productRevenue.update(
          line.productId,
          (v) => v + allocatedRevenue,
          ifAbsent: () => allocatedRevenue,
        );
        productProfit.update(
          line.productId,
          (v) => v + allocatedProfit,
          ifAbsent: () => allocatedProfit,
        );
      }
      before += gross[i];
    }
  }
  for (final product in active) {
    final sold = units[product.id] ?? 0;
    final oldEnough = !validDate(product.created).isAfter(start);
    if (product.stock > 0 &&
        sold > 0 &&
        oldEnough &&
        (days[product.id]?.length ?? 0) >= 3) {
      final projected = (product.stock * windowDays + sold - 1) ~/ sold;
      if (projected <= 7) {
        add(
          'depletion:${product.id}',
          '${product.name}: stok diperkirakan cukup sekitar $projected hari',
          '$sold unit bersih terjual selama $windowDays hari pada ${days[product.id]!.length} hari penjualan; stok ${product.stock}. '
              'Perkiraan memakai laju rata-rata dan dapat berubah mengikuti musim/permintaan.',
          'Periksa stok fisik dan rencanakan restok.',
          InsightSeverity.warning,
          InsightDestination.products,
        );
      }
    }
    if (product.stock > 0 &&
        sold == 0 &&
        now.difference(validDate(product.created)).inDays >= 28) {
      add(
        'slow:${product.id}',
        '${product.name}: belum terjual pada periode ini',
        'Tidak ada unit bersih terjual selama $windowDays hari; stok ${product.stock}.',
        'Periksa permintaan dan umur stok sebelum membeli lagi.',
        InsightSeverity.info,
        InsightDestination.products,
      );
    }
    final value = productRevenue[product.id] ?? 0,
        profit = productProfit[product.id] ?? 0;
    if (value > 0 &&
        currentRevenue > 0 &&
        value * 5 >= currentRevenue &&
        profit * 100 < value * 10) {
      add(
        'margin:${product.id}',
        '${product.name}: kontribusi tinggi, margin rendah',
        'Alokasi pendapatan $value Rupiah dan laba $profit Rupiah. '
            'Produk menyumbang minimal 20% pendapatan dan margin di bawah 10%; alokasi proporsional nilai barang per transaksi.',
        'Tinjau modal snapshot, diskon, dan biaya transaksi.',
        InsightSeverity.warning,
        InsightDestination.transactions,
      );
    }
  }
  if (units.isNotEmpty) {
    final sorted = units.entries.toList()
      ..sort((a, b) {
        final order = b.value.compareTo(a.value);
        return order == 0 ? a.key.compareTo(b.key) : order;
      });
    final top = sorted.first;
    final name =
        products.where((p) => p.id == top.key).firstOrNull?.name ?? top.key;
    add(
      'bestseller',
      '$name: produk terlaris pada periode ini',
      '${top.value} unit bersih setelah retur; transaksi batal dikecualikan.',
      'Tinjau ketersediaan dan margin sebelum menambah persediaan.',
      InsightSeverity.info,
      InsightDestination.products,
    );
  }
  final overdue = eligible
      .where((s) => s.overdueAt(now) && s.outstanding > 0)
      .toList();
  if (overdue.isNotEmpty) {
    add(
      'receivables-overdue',
      '${overdue.length} tagihan melewati jatuh tempo',
      'Sisa piutang ${overdue.fold<int>(0, (v, s) => v + s.outstanding)} Rupiah; pembayaran parsial telah dikurangkan.',
      'Buka piutang untuk meninjau tagihan dan riwayat pembayaran.',
      InsightSeverity.warning,
      InsightDestination.receivables,
    );
  }
  final recentExpense = expenses
      .where((e) => within(e.date, start))
      .fold<int>(0, (v, e) => v + e.amount);
  final previousExpense = expenses
      .where(
        (e) =>
            within(e.date, previousStart) && validDate(e.date).isBefore(start),
      )
      .fold<int>(0, (v, e) => v + e.amount);
  if (previousExpense > 0 && recentExpense * 100 >= previousExpense * 150) {
    add(
      'expense-increase',
      'Pengeluaran operasional meningkat',
      '$recentExpense Rupiah dibanding $previousExpense Rupiah pada $windowDays hari sebelumnya. Pembelian persediaan tidak termasuk biaya operasional.',
      'Periksa kategori dan bukti pengeluaran.',
      InsightSeverity.warning,
      InsightDestination.transactions,
    );
  }
  final profit =
      recent.fold<int>(0, (v, s) => v + s.result.net) - recentExpense;
  final priorProfit =
      previous.fold<int>(0, (v, s) => v + s.result.net) - previousExpense;
  if (recent.length >= 3 &&
      previous.length >= 3 &&
      priorProfit > 0 &&
      profit >= 0 &&
      profit * 100 <= priorProfit * 80) {
    add(
      'profit-decline',
      'Estimasi laba menurun',
      'Estimasi laba $profit Rupiah dibanding $priorProfit Rupiah pada periode sebelumnya; penurunan minimal 20%.',
      'Tinjau penjualan dan pengeluaran yang mendasari.',
      InsightSeverity.warning,
      InsightDestination.transactions,
    );
  }
  if (profit < 0) {
    add(
      'profit-negative',
      'Estimasi laba periode ini negatif',
      'Estimasi laba setelah pengeluaran operasional: $profit Rupiah. Perhitungan mengikuti snapshot modal penjualan.',
      'Tinjau diskon, biaya dan transaksi yang mendasari.',
      InsightSeverity.critical,
      InsightDestination.transactions,
    );
  }
  result.sort((a, b) {
    final severity = b.severity.index.compareTo(a.severity.index);
    return severity == 0 ? a.id.compareTo(b.id) : severity;
  });
  return result;
}
