part of 'app.dart';

class BusinessInsightsPage extends ConsumerStatefulWidget {
  const BusinessInsightsPage({super.key});
  @override
  ConsumerState<BusinessInsightsPage> createState() => _BusinessInsightsState();
}

class _BusinessInsightsState extends ConsumerState<BusinessInsightsPage> {
  int days = 7;
  bool showHidden = false;
  @override
  void initState() {
    super.initState();
    final value = ref.read(storeProvider).settings['insightWindowDays'];
    days = value == 30 ? 30 : 7;
  }

  @override
  Widget build(BuildContext c) {
    final store = ref.watch(storeProvider), now = DateTime.now();
    final insights = businessInsights(
      products: store.products,
      sales: store.sales,
      expenses: store.expenses,
      now: now,
      windowDays: days,
    );
    final raw = store.settings['insightSnoozes'];
    final snoozes = raw is Map
        ? Map<String, dynamic>.from(raw)
        : <String, dynamic>{};
    bool hidden(BusinessInsight insight) =>
        DateTime.tryParse(
          snoozes[insight.id]?.toString() ?? '',
        )?.isAfter(now) ??
        false;
    final visible = insights.where((i) => showHidden || !hidden(i)).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Asisten usaha offline')),
      body: PageBody(
        children: [
          const Text(
            'Tinjau pola dari catatan usaha. Perkiraan stok mengikuti penjualan terbaru dan dapat berubah.',
          ),
          Wrap(
            spacing: 8,
            children: [
              for (final value in [7, 30])
                ChoiceChip(
                  label: Text('$value hari'),
                  selected: days == value,
                  onSelected: (_) => action(c, () async {
                    setState(() => days = value);
                    await store.saveSettings({
                      ...store.settings,
                      'insightWindowDays': value,
                    });
                  }),
                ),
            ],
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  metricRow(
                    'Perlu perhatian',
                    '${insights.where((i) => i.severity != InsightSeverity.info).length} catatan',
                  ),
                  metricRow(
                    'Informasi',
                    '${insights.where((i) => i.severity == InsightSeverity.info).length} catatan',
                  ),
                  metricRow(
                    'Disembunyikan sementara',
                    '${insights.where(hidden).length} catatan',
                  ),
                ],
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('Tampilkan catatan yang disembunyikan'),
            value: showHidden,
            onChanged: (v) => setState(() => showHidden = v),
          ),
          if (visible.isEmpty)
            empty(
              'Belum ada pola yang perlu ditampilkan',
              'Tambahkan catatan usaha. Perbandingan dan perkiraan muncul setelah datanya memadai.',
              Icons.insights,
            ),
          for (final insight in visible)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          insight.severity == InsightSeverity.critical
                              ? Icons.error_outline
                              : insight.severity == InsightSeverity.warning
                              ? Icons.warning_amber
                              : Icons.info_outline,
                          color: insight.severity == InsightSeverity.critical
                              ? Theme.of(c).colorScheme.error
                              : Theme.of(c).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            insight.title,
                            style: Theme.of(c).textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(insight.explanation),
                    Text(insight.recommendation),
                    Wrap(
                      spacing: 8,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.push(
                            c,
                            MaterialPageRoute(
                              builder: (_) => switch (insight.destination) {
                                InsightDestination.products => Scaffold(
                                  appBar: AppBar(title: const Text('Produk')),
                                  body: const ProductsPage(),
                                ),
                                InsightDestination.transactions => Scaffold(
                                  appBar: AppBar(
                                    title: const Text('Transaksi'),
                                  ),
                                  body: const TransactionsPage(),
                                ),
                                InsightDestination.receivables =>
                                  const ReceivablesPage(),
                              },
                            ),
                          ),
                          child: const Text('Buka catatan terkait'),
                        ),
                        TextButton(
                          onPressed: () => action(c, () async {
                            await store.saveSettings({
                              ...store.settings,
                              'insightSnoozes': {
                                ...snoozes,
                                insight.id:
                                    (hidden(insight)
                                            ? now
                                            : now.add(const Duration(days: 7)))
                                        .toIso8601String(),
                              },
                            });
                          }),
                          child: Text(
                            hidden(insight)
                                ? 'Tampilkan kembali'
                                : 'Sembunyikan 7 hari',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
