part of 'app.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});
  @override
  ConsumerState<SettingsPage> createState() => _SettingsState();
}

class _SettingsState extends ConsumerState<SettingsPage> {
  late TextEditingController name, fee;
  bool busy = false;
  @override
  void initState() {
    super.initState();
    final s = ref.read(storeProvider).settings;
    name = TextEditingController(text: s['business'] ?? 'Usaha Saya');
    fee = TextEditingController(text: ((s['feeBps'] ?? 0) / 100).toString());
  }

  @override
  void dispose() {
    name.dispose();
    fee.dispose();
    super.dispose();
  }

  Future<void> export(BuildContext c, String text, String filename) async {
    final bytes = Uint8List.fromList(utf8.encode(text));
    final path = await FilePicker.saveFile(
      dialogTitle: 'Simpan file',
      fileName: filename,
      bytes: bytes,
      mimeType: filename.endsWith('.json') ? 'application/json' : 'text/csv',
    );
    if (path != null && c.mounted) {
      ScaffoldMessenger.of(
        c,
      ).showSnackBar(const SnackBar(content: Text('File berhasil disimpan.')));
    }
  }

  @override
  Widget build(BuildContext c) {
    final store = ref.watch(storeProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan usaha')),
      body: PageBody(
        children: [
          heading(c, 'Sesuai cara Anda', 'Preferensi dan keamanan data usaha.'),
          TextField(
            controller: name,
            decoration: const InputDecoration(labelText: 'Nama usaha'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: fee,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Asumsi biaya transaksi (%)',
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: store.settings['theme'] ?? 'system',
            decoration: const InputDecoration(labelText: 'Tema'),
            items: const [
              DropdownMenuItem(value: 'system', child: Text('Ikuti sistem')),
              DropdownMenuItem(value: 'light', child: Text('Terang')),
              DropdownMenuItem(value: 'dark', child: Text('Gelap')),
            ],
            onChanged: (v) => action(
              c,
              () => store.saveSettings({...store.settings, 'theme': v}),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => action(c, () async {
              if (name.text.trim().isEmpty) {
                throw ArgumentError('Nama usaha wajib');
              }
              await store.saveSettings({
                ...store.settings,
                'business': name.text.trim(),
                'feeBps': parseBps(fee.text),
              });
              if (c.mounted) {
                ScaffoldMessenger.of(c).showSnackBar(
                  const SnackBar(content: Text('Pengaturan disimpan')),
                );
              }
            }),
            child: const Text('Simpan preferensi'),
          ),
          const SizedBox(height: 20),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Izinkan stok minus'),
            subtitle: const Text(
              'Default ditolak. Aktifkan hanya untuk pesanan barang yang belum tersedia; stok minus tetap tercatat dan perlu dipenuhi.',
            ),
            value: store.allowNegativeStock,
            onChanged: (value) => action(c, () async {
              if (value &&
                  !await confirm(
                    c,
                    'Izinkan penjualan melebihi stok?',
                    'Stok dapat menjadi minus. Angka minus menunjukkan unit yang belum tersedia dan wajib Anda penuhi. Estimasi laba tetap memakai modal yang dicatat.',
                  )) {
                return;
              }
              await store.saveSettings({
                ...store.settings,
                'allowNegativeStock': value,
              });
            }),
          ),
          const SizedBox(height: 28),
          Text('Backup & ekspor', style: Theme.of(c).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text(
            'Data hanya tersimpan di perangkat ini. Uninstall atau kehilangan perangkat dapat menghapus data. Simpan backup di lokasi aman secara berkala.',
          ),
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: const Text('Simpan backup JSON'),
            subtitle: const Text(
              'Termasuk produk, transaksi, stok, dan pengaturan',
            ),
            onTap: busy
                ? null
                : () => action(
                    c,
                    () => export(
                      c,
                      store.backup(),
                      'lariskas-backup-${DateFormat('yyyyMMdd-HHmmss').format(DateTime.now())}.json',
                    ),
                  ),
          ),
          ListTile(
            leading: const Icon(Icons.table_view_outlined),
            title: const Text('Ekspor transaksi CSV'),
            subtitle: const Text('Bisa dibuka di aplikasi spreadsheet'),
            onTap: () => action(
              c,
              () => export(c, store.csv(), 'lariskas-transaksi.csv'),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Pulihkan backup'),
            subtitle: const Text('Mengganti seluruh data setelah validasi'),
            onTap: busy
                ? null
                : () => action(c, () async {
                    final f = await FilePicker.pickFile(
                      type: FileType.custom,
                      allowedExtensions: ['json'],
                    );
                    if (f == null) {
                      return;
                    }
                    if ((await f.length() ?? 0) > 20000000) {
                      throw const FormatException('Backup terlalu besar');
                    }
                    final buffer = BytesBuilder(copy: false);
                    await for (final chunk in f.readAsByteStream()) {
                      if (buffer.length + chunk.length > 20000000) {
                        throw const FormatException('Backup terlalu besar');
                      }
                      buffer.add(chunk);
                    }
                    final source = utf8.decode(buffer.takeBytes());
                    final b = Store.validateBackup(source);
                    if (!c.mounted) {
                      return;
                    }
                    if (!await confirm(
                      c,
                      'Ganti seluruh data?',
                      'Backup valid: ${(b['products'] as List).length} produk, ${(b['sales'] as List).length} penjualan. Data sekarang diganti. Salinan pemulihan otomatis disimpan di perangkat.',
                    )) {
                      return;
                    }
                    setState(() => busy = true);
                    try {
                      final dir = await getApplicationSupportDirectory();
                      await File(
                        '${dir.path}/recovery-${DateTime.now().millisecondsSinceEpoch}.json',
                      ).writeAsString(store.backup(), flush: true);
                      await store.restore(source);
                      if (c.mounted) {
                        final messenger = ScaffoldMessenger.of(c);
                        Navigator.pop(c);
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Backup berhasil dipulihkan'),
                          ),
                        );
                      }
                    } finally {
                      if (mounted) {
                        setState(() => busy = false);
                      }
                    }
                  }),
          ),
          ListTile(
            leading: const Icon(Icons.undo),
            title: const Text('Pulihkan salinan pemulihan terakhir'),
            subtitle: const Text(
              'Kembali ke data sebelum restore terakhir pada perangkat ini',
            ),
            onTap: busy
                ? null
                : () => action(c, () async {
                    final dir = await getApplicationSupportDirectory();
                    final snapshots = await dir
                        .list()
                        .where(
                          (f) =>
                              f is File &&
                              f.path.split('/').last.startsWith('recovery-') &&
                              f.path.endsWith('.json'),
                        )
                        .toList();
                    snapshots.sort((a, b) => b.path.compareTo(a.path));
                    if (snapshots.isEmpty) {
                      throw StateError('Belum ada salinan pemulihan.');
                    }
                    final source = await File(
                      snapshots.first.path,
                    ).readAsString();
                    Store.validateBackup(source);
                    if (!c.mounted ||
                        !await confirm(
                          c,
                          'Pulihkan data sebelumnya?',
                          'Seluruh data sekarang akan diganti dengan salinan sebelum restore terakhir.',
                        )) {
                      return;
                    }
                    setState(() => busy = true);
                    try {
                      await File(
                        '${dir.path}/recovery-${DateTime.now().millisecondsSinceEpoch}.json',
                      ).writeAsString(store.backup(), flush: true);
                      await store.restore(source);
                      if (c.mounted) {
                        final messenger = ScaffoldMessenger.of(c);
                        Navigator.pop(c);
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Salinan pemulihan berhasil dibuka'),
                          ),
                        );
                      }
                    } finally {
                      if (mounted) {
                        setState(() => busy = false);
                      }
                    }
                  }),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Kebijakan privasi'),
            subtitle: const Text(
              'Data usaha, backup, iklan, dan kontak pengelola. Bisa dibaca offline.',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              c,
              MaterialPageRoute<void>(
                builder: (_) => const PrivacyPolicyPage(),
              ),
            ),
          ),
          const OptionalAdBanner(),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('LarisKas 1.0.1'),
            subtitle: Text(
              'Estimasi laba bukan nasihat keuangan. Retur parsial: revisi transaksi. Pembatalan penuh mengembalikan stok. Stok minus ditolak secara default dan hanya diizinkan melalui pengaturan eksplisit.',
            ),
          ),
        ],
      ),
    );
  }
}
