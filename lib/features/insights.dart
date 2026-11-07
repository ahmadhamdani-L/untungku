part of 'app.dart';

class RevenueTrend extends StatelessWidget {
  final List<Sale> sales;
  final DateTime start, end;
  const RevenueTrend({
    super.key,
    required this.sales,
    required this.start,
    required this.end,
  });
  @override
  Widget build(BuildContext c) {
    final length = DateUtils.dateOnly(
      end,
    ).difference(DateUtils.dateOnly(start)).inDays.clamp(1, 100000);
    final count = length > 14 ? 7 : length;
    final totals = List<int>.filled(count, 0);
    for (final s in sales) {
      final day = DateUtils.dateOnly(
        DateTime.parse(s.date).toLocal(),
      ).difference(DateUtils.dateOnly(start)).inDays;
      if (day >= 0 && day < length) {
        totals[(day * count ~/ length).clamp(0, count - 1)] += s.result.revenue;
      }
    }
    final maximum = totals.fold(0, (v, t) => t > v ? t : v);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Tren pendapatan',
                    style: Theme.of(c).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Icon(Icons.bar_chart_rounded, color: Color(0xFF0066E6)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              maximum == 0
                  ? 'Belum ada penjualan pada periode ini'
                  : 'Tertinggi per ${length > 14 ? 'kelompok hari' : 'hari'}: ${rupiah(maximum)}',
              style: Theme.of(c).textTheme.bodySmall,
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 100,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var i = 0; i < count; i++)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Tooltip(
                          message:
                              '${DateFormat('dd MMM', 'id_ID').format(start.add(Duration(days: (i * length / count).ceil())))}: ${rupiah(totals[i])}',
                          child: Container(
                            height: maximum == 0
                                ? 4
                                : 4 + totals[i] / maximum * 96,
                            decoration: BoxDecoration(
                              color: maximum > 0 && totals[i] == maximum
                                  ? const Color(0xFF0066E6)
                                  : Theme.of(c).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(DateFormat('dd MMM', 'id_ID').format(start)),
                Text(
                  DateFormat(
                    'dd MMM',
                    'id_ID',
                  ).format(end.subtract(const Duration(days: 1))),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
