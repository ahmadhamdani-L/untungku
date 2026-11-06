part of 'app.dart';

class CashReportsPage extends ConsumerStatefulWidget {
  const CashReportsPage({super.key});
  @override
  ConsumerState<CashReportsPage> createState() => _CashReportsState();
}

class _CashReportsState extends ConsumerState<CashReportsPage> {
  late DateTime start, end;
  String period = 'Hari ini';
  String? accountId;
  bool allAccounts = true;
  final counted = TextEditingController();
  @override
  void initState() {
    super.initState();
    selectPeriod(period);
  }

  @override
  void dispose() {
    counted.dispose();
    super.dispose();
  }

  void selectPeriod(String value) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    period = value;
    end = DateTime(today.year, today.month, today.day + 1);
    start = switch (value) {
      'Kemarin' => DateTime(today.year, today.month, today.day - 1),
      '7 hari terakhir' => DateTime(today.year, today.month, today.day - 6),
      '30 hari terakhir' => DateTime(today.year, today.month, today.day - 29),
      'Bulan ini' => DateTime(today.year, today.month, 1),
      _ => today,
    };
    if (value == 'Kemarin') end = today;
  }

  @override
  Widget build(BuildContext c) {
    final store = ref.watch(storeProvider);
    Future<(List<CashAccount>, CashflowReport)> details() async => (
      await store.cashAccounts(),
      await store.cashflow(
        start: start,
        end: end,
        allAccounts: allAccounts,
        accountId: accountId,
      ),
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Laporan arus kas')),
      body: PageBody(
        children: [
          Wrap(
            spacing: 8,
            children: [
              for (final value in [
                'Hari ini',
                'Kemarin',
                '7 hari terakhir',
                '30 hari terakhir',
                'Bulan ini',
              ])
                ChoiceChip(
                  label: Text(value),
                  selected: period == value,
                  onSelected: (_) => setState(() => selectPeriod(value)),
                ),
              ActionChip(
                label: const Text('Rentang khusus'),
                onPressed: () async {
                  final range = await showDateRangePicker(
                    context: c,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2200),
                    initialDateRange: DateTimeRange(
                      start: start,
                      end: end.subtract(const Duration(days: 1)),
                    ),
                  );
                  if (range != null && mounted) {
                    setState(() {
                      period = 'Khusus';
                      start = range.start;
                      end = DateTime(
                        range.end.year,
                        range.end.month,
                        range.end.day + 1,
                      );
                    });
                  }
                },
              ),
            ],
          ),
          Text(
            '${DateFormat('dd MMM yyyy', 'id_ID').format(start)} – ${DateFormat('dd MMM yyyy', 'id_ID').format(end.subtract(const Duration(days: 1)))}',
          ),
          const SizedBox(height: 16),
          FutureBuilder(
            future: details(),
            builder: (c, snapshot) {
              if (snapshot.hasError) {
                return const Text('Laporan tidak dapat dibuka');
              }
              if (!snapshot.hasData) return const LinearProgressIndicator();
              final accounts = snapshot.data!.$1, report = snapshot.data!.$2;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<String>(
                    key: ValueKey((allAccounts, accountId)),
                    initialValue: allAccounts
                        ? 'all'
                        : accountId == null
                        ? 'unallocated'
                        : 'account:$accountId',
                    decoration: const InputDecoration(
                      labelText: 'Cakupan akun',
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: 'all',
                        child: Text('Semua akun'),
                      ),
                      const DropdownMenuItem(
                        value: 'unallocated',
                        child: Text('Belum dialokasikan'),
                      ),
                      for (final a in accounts)
                        DropdownMenuItem(
                          value: 'account:${a.id}',
                          child: Text(a.name),
                        ),
                    ],
                    onChanged: (value) => setState(() {
                      allAccounts = value == 'all';
                      accountId = value != null && value.startsWith('account:')
                          ? value.substring(8)
                          : null;
                    }),
                  ),
                  const SizedBox(height: 16),
                  metricRow('Saldo awal tercatat', rupiah(report.opening)),
                  metricRow('Kas masuk selain transfer', rupiah(report.inflow)),
                  metricRow(
                    'Kas keluar selain transfer',
                    rupiah(report.outflow),
                  ),
                  metricRow('Transfer bersih', rupiah(report.transferNet)),
                  metricRow('Saldo akhir tercatat', rupiah(report.closing)),
                  const Text(
                    'Saldo ini berasal dari catatan, termasuk penyesuaian yang dimasukkan. Riwayat belum dialokasikan tidak membuktikan saldo akun aktual.',
                  ),
                  const SizedBox(height: 16),
                  for (final entry in report.categories.entries)
                    metricRow(cashCategory(entry.key), rupiah(entry.value)),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.download),
                    label: const Text('Ekspor CSV arus kas'),
                    onPressed: () => action(c, () async {
                      await FilePicker.saveFile(
                        dialogTitle: 'Simpan laporan',
                        fileName:
                            'arus-kas-${DateFormat('yyyy-MM-dd').format(start)}.csv',
                        bytes: Uint8List.fromList(utf8.encode(report.csv())),
                        mimeType: 'text/csv',
                      );
                    }),
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.picture_as_pdf_outlined),
                    label: const Text('Ekspor PDF arus kas'),
                    onPressed: () => action(c, () async {
                      final bytes = await cashflowPdf(
                        report,
                        business:
                            store.settings['business']?.toString() ??
                            'Usaha Saya',
                        scope: allAccounts
                            ? 'Semua akun'
                            : accounts
                                      .where((a) => a.id == accountId)
                                      .firstOrNull
                                      ?.name ??
                                  'Belum dialokasikan',
                        counted: end.difference(start).inDays == 1
                            ? int.tryParse(counted.text)
                            : null,
                      );
                      await FilePicker.saveFile(
                        dialogTitle: 'Simpan laporan PDF',
                        fileName:
                            'arus-kas-${DateFormat('yyyy-MM-dd').format(start)}.pdf',
                        bytes: bytes,
                        mimeType: 'application/pdf',
                      );
                    }),
                  ),
                  if (end.difference(start).inDays == 1) ...[
                    const Divider(),
                    Text(
                      'Tutup harian',
                      style: Theme.of(c).textTheme.titleLarge,
                    ),
                    const Text(
                      'Bandingkan uang fisik untuk cakupan akun yang dipilih. Perbandingan ini tidak mengubah saldo.',
                    ),
                    IntegerField(
                      controller: counted,
                      label: 'Uang dihitung (Rp)',
                      onChanged: (_) => setState(() {}),
                    ),
                    if (int.tryParse(counted.text) case final int value
                        when value >= 0 && value <= maxMoney)
                      metricRow(
                        'Selisih terhadap catatan',
                        rupiah(report.variance(value)),
                      ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
