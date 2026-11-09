part of 'app.dart';

class ReceiptPage extends ConsumerStatefulWidget {
  final String saleId;
  const ReceiptPage({super.key, required this.saleId});
  @override
  ConsumerState<ReceiptPage> createState() => _ReceiptState();
}

class _ReceiptState extends ConsumerState<ReceiptPage> {
  int width = 58;
  bool busy = false;
  @override
  void initState() {
    super.initState();
    width = ref.read(storeProvider).settings['receiptWidth'] == 80 ? 80 : 58;
  }

  Future<void> run(Future<void> Function() work) => action(context, () async {
    if (busy) return;
    setState(() => busy = true);
    try {
      await work();
    } finally {
      if (mounted) setState(() => busy = false);
    }
  });
  Future<void> share(Uint8List bytes, String filename, String mime) async {
    if (!mounted) return;
    final box = context.findRenderObject() as RenderBox?;
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile.fromData(bytes, mimeType: mime)],
        fileNameOverrides: [filename],
        sharePositionOrigin: box == null
            ? null
            : box.localToGlobal(Offset.zero) & box.size,
      ),
    );
  }

  @override
  Widget build(BuildContext c) {
    final store = ref.watch(storeProvider);
    final sale = store.sales.where((s) => s.id == widget.saleId).firstOrNull;
    if (sale == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Struk')),
        body: const Center(child: Text('Penjualan tidak tersedia')),
      );
    }
    final receipt = ReceiptSnapshot.fromSettings(sale, store.settings);
    final filename =
        'struk-${sale.id.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_')}';
    return Scaffold(
      appBar: AppBar(title: const Text('Struk penjualan')),
      body: PageBody(
        children: [
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 58, label: Text('58 mm')),
              ButtonSegment(value: 80, label: Text('80 mm')),
            ],
            selected: {width},
            onSelectionChanged: busy
                ? null
                : (values) => setState(() => width = values.single),
          ),
          const SizedBox(height: 16),
          RepaintBoundary(
            child: ColoredBox(
              color: Colors.white,
              child: SizedBox(
                width: width == 58 ? 320 : 440,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (receipt.logo != null)
                        Image.memory(
                          receipt.logo!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => const SizedBox(),
                        ),
                      Text(
                        receipt.text(),
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'monospace',
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            icon: const Icon(Icons.print_outlined),
            label: const Text('Cetak Bluetooth'),
            onPressed: busy
                ? null
                : () => run(() async {
                    final address =
                        store.settings['printerAddress']?.toString() ?? '';
                    if (address.isEmpty) {
                      throw StateError('Pilih printer di Pengaturan printer.');
                    }
                    await ReceiptPrinter().printBytes(
                      address,
                      receiptEscPos(receipt, paperWidth: width),
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Data dikirim ke printer. Periksa hasil cetak.',
                          ),
                        ),
                      );
                    }
                  }),
          ),
          TextButton(
            onPressed: busy
                ? null
                : () => Navigator.push(
                    c,
                    MaterialPageRoute(
                      builder: (_) => const PrinterSettingsPage(),
                    ),
                  ),
            child: const Text('Pengaturan printer'),
          ),
          OutlinedButton.icon(
            icon: const Icon(Icons.save_alt),
            label: const Text('Simpan PDF struk'),
            onPressed: busy
                ? null
                : () => run(() async {
                    final bytes = await receiptPdf(receipt, paperWidth: width);
                    if (!mounted) return;
                    final saved = await FilePicker.saveFile(
                      fileName: '$filename.pdf',
                      bytes: bytes,
                      mimeType: 'application/pdf',
                    );
                    if (mounted && saved != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('PDF struk disimpan.')),
                      );
                    }
                  }),
          ),
          FilledButton.icon(
            icon: const Icon(Icons.share_outlined),
            label: const Text('Bagikan PDF struk'),
            onPressed: busy
                ? null
                : () => run(() async {
                    await share(
                      await receiptPdf(receipt, paperWidth: width),
                      '$filename.pdf',
                      'application/pdf',
                    );
                  }),
          ),
          OutlinedButton.icon(
            icon: const Icon(Icons.image_outlined),
            label: const Text('Bagikan gambar struk'),
            onPressed: busy
                ? null
                : () => run(() async {
                    await share(
                      await receiptImage(receipt, paperWidth: width),
                      '$filename.png',
                      'image/png',
                    );
                  }),
          ),
          OutlinedButton.icon(
            icon: const Icon(Icons.chat_outlined),
            label: const Text('Bagikan teks struk (WhatsApp / SMS)'),
            onPressed: busy
                ? null
                : () => run(() async {
                    final box = context.findRenderObject() as RenderBox?;
                    await SharePlus.instance.share(
                      ShareParams(
                        text: receipt.text(),
                        sharePositionOrigin: box == null
                            ? null
                            : box.localToGlobal(Offset.zero) & box.size,
                      ),
                    );
                  }),
          ),
          TextButton(
            onPressed: () => Navigator.push(
              c,
              MaterialPageRoute(
                builder: (_) => SaleDetailPage(saleId: sale.id),
              ),
            ),
            child: const Text('Detail penjualan'),
          ),
        ],
      ),
    );
  }
}
