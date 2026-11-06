part of 'app.dart';

class PrinterSettingsPage extends ConsumerStatefulWidget {
  const PrinterSettingsPage({super.key});
  @override
  ConsumerState<PrinterSettingsPage> createState() => _PrinterSettingsState();
}

class _PrinterSettingsState extends ConsumerState<PrinterSettingsPage> {
  final printer = ReceiptPrinter();
  final fields = <String, TextEditingController>{};
  @override
  void initState() {
    super.initState();
    final settings = ref.read(storeProvider).settings;
    for (final key in ['receiptAddress', 'receiptPhone', 'receiptFooter']) {
      fields[key] = TextEditingController(
        text: settings[key]?.toString() ?? '',
      );
    }
  }

  @override
  void dispose() {
    for (final field in fields.values) {
      field.dispose();
    }
    super.dispose();
  }

  List<Map<String, String>> devices = [];
  String status = 'Belum terhubung';
  bool busy = false;
  Future<void> run(Future<void> Function() work) => action(context, () async {
    if (busy) return;
    setState(() => busy = true);
    try {
      await work();
    } finally {
      if (mounted) setState(() => busy = false);
    }
  });
  @override
  Widget build(BuildContext context) {
    final store = ref.watch(storeProvider);
    final address = store.settings['printerAddress']?.toString() ?? '';
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan printer')),
      body: PageBody(
        children: [
          const Text(
            'Printer Bluetooth Classic SPP dengan teks ESC/POS. Pasangkan printer melalui pengaturan Bluetooth Android dahulu. Printer BLE/vendor lain mungkin tidak didukung. Logo tidak dikirim; teks tetap tersedia. Cetak fisik belum diverifikasi pada perangkat ini.',
          ),
          for (final entry in fields.entries)
            TextField(
              controller: entry.value,
              maxLength: 200,
              decoration: InputDecoration(
                labelText: switch (entry.key) {
                  'receiptAddress' => 'Alamat struk',
                  'receiptPhone' => 'Telepon usaha',
                  _ => 'Pesan penutup struk',
                },
              ),
            ),
          OutlinedButton(
            onPressed: busy
                ? null
                : () => run(
                    () => store.saveSettings({
                      ...store.settings,
                      for (final entry in fields.entries)
                        entry.key: entry.value.text.trim(),
                    }),
                  ),
            child: const Text('Simpan informasi struk'),
          ),
          OutlinedButton(
            onPressed: busy
                ? null
                : () => run(() async {
                    final file = await FilePicker.pickFile(
                      type: FileType.custom,
                      allowedExtensions: ['png'],
                    );
                    if (file == null) return;
                    final buffer = BytesBuilder(copy: false);
                    await for (final chunk in file.readAsByteStream()) {
                      if (buffer.length + chunk.length > 300000) {
                        throw ArgumentError(
                          'Logo PNG maksimal 300 KB dan 512 x 512 piksel',
                        );
                      }
                      buffer.add(chunk);
                    }
                    final bytes = buffer.takeBytes();
                    final encoded = base64Encode(bytes);
                    if (ReceiptSnapshot.decodeLogo(encoded) == null) {
                      throw ArgumentError(
                        'Gunakan PNG maksimal 512 x 512 piksel',
                      );
                    }
                    final decoded = await decodeImageFromList(bytes);
                    decoded.dispose();
                    await store.saveSettings({
                      ...store.settings,
                      'receiptLogo': encoded,
                    });
                  }),
            child: const Text('Pilih logo PNG'),
          ),
          if (store.settings['receiptLogo'] != null)
            TextButton(
              onPressed: busy
                  ? null
                  : () => run(
                      () => store.saveSettings(
                        {...store.settings}..remove('receiptLogo'),
                      ),
                    ),
              child: const Text('Hapus logo struk'),
            ),
          Text('Status: $status'),
          Text(
            'Pilihan tersimpan: ${store.settings['printerName'] ?? 'Belum dipilih'}',
          ),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 58, label: Text('58 mm')),
              ButtonSegment(value: 80, label: Text('80 mm')),
            ],
            selected: {store.settings['receiptWidth'] == 80 ? 80 : 58},
            onSelectionChanged: busy
                ? null
                : (values) => run(
                    () => store.saveSettings({
                      ...store.settings,
                      'receiptWidth': values.single,
                    }),
                  ),
          ),
          OutlinedButton(
            onPressed: busy
                ? null
                : () => run(() async {
                    final found = await printer.paired();
                    if (mounted) {
                      setState(() {
                        devices = found;
                        status = found.isEmpty
                            ? 'Tidak ada perangkat berpasangan'
                            : 'Daftar perangkat dimuat';
                      });
                    }
                  }),
            child: const Text('Muat printer berpasangan'),
          ),
          for (final device in devices)
            ListTile(
              title: Text(device['name']!),
              subtitle: Text(device['address']!),
              leading: Icon(
                address == device['address']
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
              ),
              onTap: busy
                  ? null
                  : () => run(() async {
                      await store.saveSettings({
                        ...store.settings,
                        'printerAddress': device['address'],
                        'printerName': device['name'],
                      });
                    }),
            ),
          FilledButton(
            onPressed: busy || address.isEmpty
                ? null
                : () => run(() async {
                    if (mounted) {
                      setState(
                        () => status = 'Menghubungkan / mengirim uji cetak...',
                      );
                    }
                    try {
                      await printer.printBytes(
                        address,
                        Uint8List.fromList([
                          27,
                          64,
                          ...'UNTUNGKU PRO\nUji cetak ESC/POS\n0123456789\nPeriksa teks dan lebar kertas.\n\n\n'
                              .codeUnits,
                        ]),
                      );
                      if (mounted) {
                        setState(
                          () => status =
                              'Data terkirim; koneksi ditutup. Periksa hasil cetak.',
                        );
                      }
                    } catch (_) {
                      if (mounted) {
                        setState(
                          () => status =
                              'Gagal / koneksi ditutup. Periksa cetakan sebelum mengulang.',
                        );
                      }
                      rethrow;
                    }
                  }),
            child: const Text('Uji cetak'),
          ),
          const Text(
            'Retry hanya mencetak ulang; tidak membuat penjualan baru. Jika koneksi putus, sebagian data mungkin telah tercetak.',
          ),
        ],
      ),
    );
  }
}
