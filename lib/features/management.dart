part of 'app.dart';

class ManagementPage extends StatelessWidget {
  const ManagementPage({super.key});
  @override
  Widget build(BuildContext c) => PageBody(
    children: [
      heading(
        c,
        'Kelola usaha',
        'Pelanggan, pembelian, persediaan, dan pencatatan kas.',
      ),
      for (final item in <(String, String, IconData, Widget)>[
        (
          'Kasir cepat',
          'Pencarian, favorit, barcode, dan keranjang',
          Icons.point_of_sale,
          const PosPage(),
        ),
        (
          'Impor produk CSV',
          'Template, pemetaan kolom, validasi, dan pratinjau',
          Icons.upload_file,
          const ProductImportPage(),
        ),
        (
          'Asisten usaha',
          'Tren, persediaan, margin, dan tagihan',
          Icons.insights,
          const BusinessInsightsPage(),
        ),
        (
          'Pelanggan',
          'Kontak, riwayat belanja, dan piutang',
          Icons.people_outline,
          const ContactsPage(),
        ),
        (
          'Pemasok',
          'Kontak pemasok dan riwayat pembelian',
          Icons.local_shipping_outlined,
          const ContactsPage(suppliers: true),
        ),
        (
          'Pembelian',
          'Pesanan, penerimaan stok, dan utang pemasok',
          Icons.shopping_bag_outlined,
          const PurchasesPage(),
        ),
        (
          'Kas & rekening',
          'Pencatatan uang masuk, keluar, dan transfer',
          Icons.account_balance_wallet_outlined,
          const CashflowPage(),
        ),
        (
          'Stock opname',
          'Bandingkan stok fisik dengan catatan',
          Icons.fact_check_outlined,
          const OpnamePage(),
        ),
        (
          'Piutang pelanggan',
          'Pembayaran bertahap dan jatuh tempo',
          Icons.payments_outlined,
          const ReceivablesPage(),
        ),
        (
          'Pengaturan & backup',
          'Preferensi dan keamanan data',
          Icons.settings_outlined,
          const SettingsPage(),
        ),
      ])
        Card(
          child: ListTile(
            leading: Icon(item.$3),
            title: Text(item.$1),
            subtitle: Text(item.$2),
            trailing: const Icon(Icons.chevron_right),
            onTap: () =>
                Navigator.push(c, MaterialPageRoute(builder: (_) => item.$4)),
          ),
        ),
    ],
  );
}

class ContactsPage extends ConsumerStatefulWidget {
  final bool suppliers;
  const ContactsPage({super.key, this.suppliers = false});
  @override
  ConsumerState<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends ConsumerState<ContactsPage> {
  String query = '';
  bool archived = false;
  @override
  Widget build(BuildContext c) {
    final store = ref.watch(storeProvider);
    return Scaffold(
      appBar: AppBar(title: Text(widget.suppliers ? 'Pemasok' : 'Pelanggan')),
      body: PageBody(
        children: [
          FilledButton.icon(
            onPressed: () => Navigator.push(
              c,
              MaterialPageRoute(
                builder: (_) => ContactForm(supplier: widget.suppliers),
              ),
            ),
            icon: const Icon(Icons.add),
            label: Text(
              widget.suppliers ? 'Tambah pemasok' : 'Tambah pelanggan',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Cari nama atau telepon',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (v) => setState(() => query = v),
          ),
          FilterChip(
            label: const Text('Arsip'),
            selected: archived,
            onSelected: (v) => setState(() => archived = v),
          ),
          FutureBuilder(
            future: store.contacts(suppliers: widget.suppliers),
            builder: (c, s) {
              if (s.hasError) {
                return Text('Kontak tidak dapat dibuka: ${s.error}');
              }
              if (!s.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final contacts =
                  s.data!
                      .where(
                        (p) =>
                            p.archived == archived &&
                            '${p.name} ${p.phone}'.toLowerCase().contains(
                              query.toLowerCase(),
                            ),
                      )
                      .toList()
                    ..sort((a, b) => a.name.compareTo(b.name));
              if (contacts.isEmpty) {
                return empty(
                  'Belum ada kontak di daftar ini',
                  'Tambahkan kontak atau ubah pencarian.',
                  Icons.people_outline,
                );
              }
              return Column(
                children: [
                  for (final p in contacts)
                    Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.person_outline),
                        ),
                        title: Text(p.name),
                        subtitle: Text(
                          p.phone.isEmpty ? 'Tanpa nomor telepon' : p.phone,
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.push(
                          c,
                          MaterialPageRoute(
                            builder: (_) => ContactDetail(
                              id: p.id,
                              supplier: widget.suppliers,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class ContactForm extends ConsumerStatefulWidget {
  final Contact? contact;
  final bool supplier;
  const ContactForm({super.key, this.contact, this.supplier = false});
  @override
  ConsumerState<ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends ConsumerState<ContactForm> {
  late final List<TextEditingController> fields;
  late final String id, created;
  bool busy = false;
  @override
  void initState() {
    super.initState();
    final p = widget.contact;
    id = p?.id ?? uuid.v4();
    created = p?.created ?? DateTime.now().toIso8601String();
    fields = [
      p?.name ?? '',
      p?.phone ?? '',
      p?.address ?? '',
      p?.notes ?? '',
    ].map((v) => TextEditingController(text: v)).toList();
  }

  @override
  void dispose() {
    for (final f in fields) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(
      title: Text(widget.supplier ? 'Data pemasok' : 'Data pelanggan'),
    ),
    body: PageBody(
      children: [
        for (var i = 0; i < fields.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: TextFormField(
              controller: fields[i],
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) => i == 0
                  ? requiredInputError(value, label: 'Nama')
                  : (value != null && value.length > 4000
                        ? 'Maksimal 4000 karakter'
                        : null),
              keyboardType: i == 1 ? TextInputType.phone : TextInputType.text,
              decoration: InputDecoration(
                labelText: [
                  'Nama',
                  'Telepon (opsional)',
                  'Alamat (opsional)',
                  'Catatan (opsional)',
                ][i],
              ),
            ),
          ),
        FilledButton(
          onPressed: busy
              ? null
              : () => action(c, () async {
                  if (busy) return;
                  setState(() => busy = true);
                  try {
                    await ref
                        .read(storeProvider)
                        .saveContact(
                          Contact(
                            id: id,
                            name: fields[0].text.trim(),
                            phone: fields[1].text.trim(),
                            address: fields[2].text.trim(),
                            notes: fields[3].text.trim(),
                            created: created,
                            updated: DateTime.now().toIso8601String(),
                            archived: widget.contact?.archived ?? false,
                          ),
                          supplier: widget.supplier,
                          expectedUpdated: widget.contact?.updated,
                        );
                    if (c.mounted) Navigator.pop(c);
                  } finally {
                    if (mounted) setState(() => busy = false);
                  }
                }),
          child: const Text('Simpan kontak'),
        ),
      ],
    ),
  );
}

class ContactDetail extends ConsumerWidget {
  final String id;
  final bool supplier;
  const ContactDetail({super.key, required this.id, this.supplier = false});
  @override
  Widget build(BuildContext c, WidgetRef ref) {
    final store = ref.watch(storeProvider);
    Future<(Contact, Map<String, String>, List<Purchase>)> details() async => (
      (await store.contacts(suppliers: supplier)).firstWhere((p) => p.id == id),
      await store.customerLinks(),
      await store.purchases(),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(supplier ? 'Detail pemasok' : 'Detail pelanggan'),
      ),
      body: FutureBuilder(
        future: details(),
        builder: (c, s) {
          if (s.hasError) {
            return Center(child: Text('Kontak tidak dapat dibuka: ${s.error}'));
          }
          if (!s.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final p = s.data!.$1, links = s.data!.$2;
          final sales = store.sales
              .where((sale) => links[sale.id] == id)
              .toList();
          final active = sales.where((s) => !s.voided).toList();
          final purchases = s.data!.$3
              .where((p) => p.supplierId == id)
              .toList();
          return PageBody(
            children: [
              heading(
                c,
                p.name,
                p.archived
                    ? 'Kontak diarsipkan'
                    : p.phone.isEmpty
                    ? 'Kontak usaha'
                    : p.phone,
              ),
              if (p.phone.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  children: [
                    ActionChip(
                      avatar: const Icon(Icons.chat_outlined, size: 16),
                      label: const Text('Kirim pesan / WhatsApp'),
                      onPressed: () async {
                        final business =
                            store.settings['business']?.toString() ??
                            'Toko Kami';
                        final box = c.findRenderObject() as RenderBox?;
                        await SharePlus.instance.share(
                          ShareParams(
                            text: 'Halo ${p.name}, salam dari $business.',
                            sharePositionOrigin: box == null
                                ? null
                                : box.localToGlobal(Offset.zero) & box.size,
                          ),
                        );
                      },
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.copy_outlined, size: 16),
                      label: const Text('Salin nomor'),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: p.phone));
                        ScaffoldMessenger.of(c).showSnackBar(
                          SnackBar(content: Text('Nomor ${p.phone} disalin')),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              if (p.address.isNotEmpty) Text(p.address),
              if (p.notes.isNotEmpty) Text(p.notes),
              OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  c,
                  MaterialPageRoute(
                    builder: (_) => ContactForm(contact: p, supplier: supplier),
                  ),
                ),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit kontak'),
              ),
              TextButton(
                onPressed: () => action(c, () async {
                  await store.saveContact(
                    Contact.fromJson({
                      ...p.toJson(),
                      'archived': !p.archived,
                      'updated': DateTime.now().toIso8601String(),
                    }),
                    supplier: supplier,
                    expectedUpdated: p.updated,
                  );
                }),
                child: Text(p.archived ? 'Aktifkan kontak' : 'Arsipkan kontak'),
              ),
              if (!supplier) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        metricRow(
                          'Total pembelian tercatat',
                          rupiah(
                            active.fold(0, (v, s) => v + s.result.revenue),
                          ),
                        ),
                        metricRow(
                          'Sisa piutang',
                          rupiah(active.fold(0, (v, s) => v + s.outstanding)),
                        ),
                        metricRow(
                          'Lewat jatuh tempo',
                          rupiah(
                            active
                                .where((s) => s.overdueAt(DateTime.now()))
                                .fold(0, (v, s) => v + s.outstanding),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (!p.archived)
                  OutlinedButton.icon(
                    onPressed: () => linkLegacySaleDialog(c, store, p, links),
                    icon: const Icon(Icons.link),
                    label: const Text('Hubungkan transaksi lama'),
                  ),
                Text(
                  'Riwayat transaksi',
                  style: Theme.of(c).textTheme.titleLarge,
                ),
                if (sales.isEmpty)
                  const Text('Belum ada transaksi yang dihubungkan.'),
                for (final sale in sales)
                  Card(
                    child: ListTile(
                      title: Text(rupiah(sale.result.revenue)),
                      subtitle: Text(
                        '${sale.date.substring(0, 10)} • ${sale.paymentStatus}\nNama saat transaksi: ${sale.customer.isEmpty ? 'Tanpa nama' : sale.customer}',
                      ),
                      onTap: () => Navigator.push(
                        c,
                        MaterialPageRoute(
                          builder: (_) => SaleDetailPage(saleId: sale.id),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  'Riwayat pembayaran',
                  style: Theme.of(c).textTheme.titleLarge,
                ),
                for (final sale in sales)
                  for (final payment in sale.payments)
                    ListTile(
                      title: Text(rupiah(payment.amount)),
                      subtitle: Text(
                        '${payment.date.substring(0, 10)} • ${payment.method}',
                      ),
                    ),
              ] else ...[
                Text(
                  'Riwayat pembelian',
                  style: Theme.of(c).textTheme.titleLarge,
                ),
                if (purchases.isEmpty)
                  const Text('Belum ada pembelian dari pemasok ini.'),
                for (final po in purchases)
                  Card(
                    child: ListTile(
                      title: Text(rupiah(po.total)),
                      subtitle: Text(
                        '${po.date.substring(0, 10)} • ${purchaseStatus(po.status)}',
                      ),
                      onTap: () => Navigator.push(
                        c,
                        MaterialPageRoute(
                          builder: (_) => PurchaseDetail(id: po.id),
                        ),
                      ),
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}

Future<void> linkLegacySaleDialog(
  BuildContext c,
  Store store,
  Contact customer,
  Map<String, String> links,
) async {
  String? saleId;
  bool busy = false;
  final sales = store.sales.where((s) => !links.containsKey(s.id)).toList();
  await formDialog(
    context: c,
    builder: (d) => StatefulBuilder(
      builder: (d, set) => AlertDialog(
        title: const Text('Hubungkan transaksi lama'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Pilih transaksi milik ${customer.name}. Nama yang sama belum tentu orang yang sama. Nama asli pada transaksi tidak diubah.',
            ),
            DropdownButtonFormField<String>(
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Transaksi'),
              items: sales
                  .map(
                    (s) => DropdownMenuItem(
                      value: s.id,
                      child: Text(
                        '${s.customer.isEmpty ? 'Tanpa nama' : s.customer} • ${s.date.substring(0, 10)} • ${rupiah(s.result.revenue)}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) => set(() => saleId = v),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: busy ? null : () => Navigator.pop(d),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: busy || saleId == null
                ? null
                : () => action(d, () async {
                    if (busy) return;
                    set(() => busy = true);
                    try {
                      await store.linkCustomer(saleId!, customer.id);
                      if (d.mounted) Navigator.pop(d);
                    } finally {
                      if (d.mounted) set(() => busy = false);
                    }
                  }),
            child: const Text('Hubungkan'),
          ),
        ],
      ),
    ),
  );
}

String purchaseStatus(String status) => switch (status) {
  'draft' => 'Draf',
  'confirmed' => 'Dikonfirmasi',
  'cancelled' => 'Dibatalkan',
  _ => status,
};

class PurchasesPage extends ConsumerWidget {
  const PurchasesPage({super.key});
  @override
  Widget build(BuildContext c, WidgetRef ref) {
    final store = ref.watch(storeProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Pembelian & utang pemasok')),
      body: PageBody(
        children: [
          FutureBuilder(
            future: store.payableReport(),
            builder: (c, snapshot) {
              if (snapshot.hasError) {
                return const Text('Laporan utang tidak dapat dibuka');
              }
              if (!snapshot.hasData) return const LinearProgressIndicator();
              final report = snapshot.data!;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      metricRow(
                        'Total utang pemasok',
                        rupiah(
                          report.fold<int>(0, (v, p) => v + p.outstanding),
                        ),
                      ),
                      for (final group in report.where(
                        (p) => p.outstanding > 0,
                      ))
                        FutureBuilder(
                          future: store.contacts(suppliers: true),
                          builder: (c, contacts) => metricRow(
                            contacts.data
                                    ?.where((p) => p.id == group.supplierId)
                                    .firstOrNull
                                    ?.name ??
                                'Tanpa pemasok',
                            rupiah(group.outstanding),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => Navigator.push(
              c,
              MaterialPageRoute(builder: (_) => const PurchaseForm()),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Buat pembelian'),
          ),
          const SizedBox(height: 16),
          FutureBuilder(
            future: store.purchases(),
            builder: (c, s) {
              if (s.hasError) return Text('${s.error}');
              if (!s.hasData) return const CircularProgressIndicator();
              final ps = s.data!..sort((a, b) => b.date.compareTo(a.date));
              if (ps.isEmpty) {
                return empty(
                  'Belum ada pembelian',
                  'Buat draf pesanan, konfirmasi, lalu catat penerimaan stok.',
                  Icons.shopping_bag_outlined,
                );
              }
              return Column(
                children: [
                  for (final p in ps)
                    Card(
                      child: ListTile(
                        title: Text(rupiah(p.total)),
                        subtitle: Text(
                          '${p.date.substring(0, 10)} • ${purchaseStatus(p.status)}\n${p.lines.length} produk',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.push(
                          c,
                          MaterialPageRoute(
                            builder: (_) => PurchaseDetail(id: p.id),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class PurchaseForm extends ConsumerStatefulWidget {
  const PurchaseForm({super.key});
  @override
  ConsumerState<PurchaseForm> createState() => _PurchaseFormState();
}

class _PurchaseFormState extends ConsumerState<PurchaseForm> {
  final id = uuid.v4();
  final lines = <String, (TextEditingController, TextEditingController)>{};
  final discount = TextEditingController(text: '0'),
      additional = TextEditingController(text: '0'),
      note = TextEditingController();
  String? supplier;
  bool busy = false;
  DateTime date = DateTime.now();
  @override
  void dispose() {
    for (final pair in lines.values) {
      pair.$1.dispose();
      pair.$2.dispose();
    }
    discount.dispose();
    additional.dispose();
    note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) {
    final store = ref.watch(storeProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Draf pembelian')),
      body: PageBody(
        children: [
          FutureBuilder(
            future: store.contacts(suppliers: true),
            builder: (c, s) => DropdownButtonFormField<String>(
              initialValue: supplier,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Pemasok (opsional)',
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('Tanpa pemasok'),
                ),
                for (final p in s.data ?? <Contact>[])
                  if (!p.archived)
                    DropdownMenuItem(value: p.id, child: Text(p.name)),
              ],
              onChanged: (v) => setState(() => supplier = v),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            key: ValueKey(lines.length),
            initialValue: null,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Tambahkan produk'),
            items: store.products
                .where((p) => !p.archived && !lines.containsKey(p.id))
                .map((p) => DropdownMenuItem(value: p.id, child: Text(p.name)))
                .toList(),
            onChanged: (v) {
              if (v != null) {
                final p = store.products.firstWhere((p) => p.id == v);
                setState(
                  () => lines[v] = (
                    TextEditingController(text: '1'),
                    TextEditingController(text: p.cost.toString()),
                  ),
                );
              }
            },
          ),
          for (final e in lines.entries)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            store.products
                                .firstWhere((p) => p.id == e.key)
                                .name,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            final pair = e.value;
                            setState(() => lines.remove(e.key));
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              pair.$1.dispose();
                              pair.$2.dispose();
                            });
                          },
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    IntegerField(
                      controller: e.value.$1,
                      label: 'Jumlah dibeli',
                      min: 1,
                      max: 1000000,
                    ),
                    const SizedBox(height: 12),
                    IntegerField(
                      controller: e.value.$2,
                      label: 'Modal beli per unit (Rp)',
                    ),
                  ],
                ),
              ),
            ),
          for (final p in [
            (discount, 'Diskon pembelian (Rp)'),
            (additional, 'Biaya perolehan tambahan (Rp)'),
            (note, 'Catatan'),
          ])
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: TextField(
                controller: p.$1,
                keyboardType: p.$1 == note
                    ? TextInputType.text
                    : TextInputType.number,
                decoration: InputDecoration(labelText: p.$2),
              ),
            ),
          TextButton.icon(
            onPressed: () async {
              final d = await showDatePicker(
                context: c,
                initialDate: date,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (d != null) setState(() => date = d);
            },
            icon: const Icon(Icons.event),
            label: Text(DateFormat('dd MMM yyyy', 'id_ID').format(date)),
          ),
          const Text(
            'Menyimpan draf belum menambah stok atau mencatat pembayaran. Biaya perolehan dialokasikan ke modal barang saat diterima.',
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: busy
                ? null
                : () => action(c, () async {
                    if (busy) return;
                    setState(() => busy = true);
                    try {
                      await store.savePurchaseDraft(
                        Purchase(
                          id: id,
                          date: date.toIso8601String(),
                          supplierId: supplier,
                          lines: [
                            for (final e in lines.entries)
                              PurchaseLine(
                                productId: e.key,
                                name: store.products
                                    .firstWhere((p) => p.id == e.key)
                                    .name,
                                quantity: parseIntegerInput(
                                  e.value.$1.text,
                                  'Jumlah dibeli',
                                  min: 1,
                                  max: 1000000,
                                ),
                                unitCost: parseIntegerInput(
                                  e.value.$2.text,
                                  'Modal beli',
                                ),
                              ),
                          ],
                          discount: parseIntegerInput(discount.text, 'Diskon'),
                          additional: parseIntegerInput(
                            additional.text,
                            'Biaya tambahan',
                          ),
                          note: note.text.trim(),
                        ),
                      );
                      if (c.mounted) {
                        Navigator.pushReplacement(
                          c,
                          MaterialPageRoute(
                            builder: (_) => PurchaseDetail(id: id),
                          ),
                        );
                      }
                    } finally {
                      if (mounted) setState(() => busy = false);
                    }
                  }),
            child: const Text('Simpan draf'),
          ),
        ],
      ),
    );
  }
}

class PurchaseDetail extends ConsumerWidget {
  final String id;
  const PurchaseDetail({super.key, required this.id});
  @override
  Widget build(BuildContext c, WidgetRef ref) {
    final store = ref.watch(storeProvider);
    Future<(Purchase, Map<String, int>, int)> details() async => (
      await store.purchase(id),
      await store.receivedQuantities(id),
      await store.purchasePaid(id),
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Detail pembelian')),
      body: FutureBuilder(
        future: details(),
        builder: (c, s) {
          if (s.hasError) return Center(child: Text('${s.error}'));
          if (!s.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final p = s.data!.$1, received = s.data!.$2;
          final paid = s.data!.$3;
          return PageBody(
            children: [
              balanceCard(
                c,
                purchaseStatus(p.status).toUpperCase(),
                rupiah(p.total),
                'Tanggal ${p.date.substring(0, 10)}',
                Icons.shopping_bag_outlined,
              ),
              const SizedBox(height: 16),
              for (final l in p.lines)
                Card(
                  child: ListTile(
                    title: Text(l.name),
                    subtitle: Text(
                      '${l.quantity} × ${rupiah(l.unitCost)}\nDiterima: ${received[l.productId] ?? 0}/${l.quantity}',
                    ),
                    trailing: Text(rupiah(l.subtotal)),
                  ),
                ),
              metricRow('Diskon', rupiah(p.discount)),
              metricRow('Biaya perolehan', rupiah(p.additional)),
              metricRow('Sudah dibayar', rupiah(paid)),
              metricRow(
                'Sisa utang',
                rupiah(p.status == 'cancelled' ? 0 : p.total - paid),
              ),
              if (p.note.isNotEmpty) Text(p.note),
              if (p.status == 'draft')
                FilledButton(
                  onPressed: () => action(
                    c,
                    () => store.confirmPurchase(p.id, 'confirm:${p.id}'),
                  ),
                  child: const Text('Konfirmasi pembelian'),
                ),
              if (p.status == 'confirmed') ...[
                OutlinedButton.icon(
                  onPressed: () => receiveDialog(c, store, p, received),
                  icon: const Icon(Icons.inventory_2_outlined),
                  label: const Text('Catat penerimaan stok'),
                ),
                if (paid < p.total)
                  FilledButton.icon(
                    onPressed: () =>
                        supplierPaymentDialog(c, store, p, p.total - paid),
                    icon: const Icon(Icons.payments_outlined),
                    label: const Text('Bayar pemasok'),
                  ),
              ],
              if (p.status != 'cancelled')
                TextButton(
                  onPressed: () => action(c, () async {
                    if (await confirm(
                      c,
                      'Batalkan pembelian?',
                      'Pembelian yang telah dibayar atau stoknya telah dipakai tidak dapat dibatalkan. Pembalikan dicatat dalam riwayat.',
                    )) {
                      await store.cancelPurchase(
                        p.id,
                        'cancel:${p.id}',
                        'Pembatalan oleh pengguna',
                      );
                    }
                  }),
                  child: const Text('Batalkan pembelian'),
                ),
              FutureBuilder(
                future: store.purchasePaymentHistory(id),
                builder: (c, payments) => Column(
                  children: [
                    for (final r in payments.data ?? <Map<String, dynamic>>[])
                      ListTile(
                        title: Text('Pembayaran ${rupiah(r['amount'])}'),
                        subtitle: Text('${r['date']} • ${r['method']}'),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

Future<void> receiveDialog(
  BuildContext c,
  Store store,
  Purchase p,
  Map<String, int> received,
) async {
  final available = p.lines
      .where((l) => (received[l.productId] ?? 0) < l.quantity)
      .toList();
  if (available.isEmpty) {
    ScaffoldMessenger.of(c).showSnackBar(
      const SnackBar(content: Text('Semua barang sudah diterima')),
    );
    return;
  }
  var productId = available.first.productId, busy = false;
  final amount = TextEditingController(
    text:
        (available.first.quantity - (received[available.first.productId] ?? 0))
            .toString(),
  );
  final id = uuid.v4();
  await formDialog(
    context: c,
    builder: (d) => StatefulBuilder(
      builder: (d, set) => AlertDialog(
        title: const Text('Penerimaan stok'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: productId,
              isExpanded: true,
              items: available
                  .map(
                    (l) => DropdownMenuItem(
                      value: l.productId,
                      child: Text(l.name),
                    ),
                  )
                  .toList(),
              onChanged: (v) => set(() {
                productId = v!;
                final l = available.firstWhere((l) => l.productId == productId);
                amount.text = (l.quantity - (received[productId] ?? 0))
                    .toString();
              }),
            ),
            const SizedBox(height: 16),
            IntegerField(
              controller: amount,
              label: 'Jumlah diterima',
              min: 1,
              max: 1000000,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: busy ? null : () => Navigator.pop(d),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: busy
                ? null
                : () => action(d, () async {
                    if (busy) return;
                    set(() => busy = true);
                    try {
                      await store.receivePurchase(
                        id: id,
                        purchaseId: p.id,
                        quantities: {
                          productId: parseIntegerInput(
                            amount.text,
                            'Jumlah diterima',
                            min: 1,
                            max: 1000000,
                          ),
                        },
                        date: DateTime.now().toIso8601String(),
                      );
                      if (d.mounted) Navigator.pop(d);
                    } finally {
                      if (d.mounted) set(() => busy = false);
                    }
                  }),
            child: const Text('Terima stok'),
          ),
        ],
      ),
    ),
  );
  amount.dispose();
}

Future<void> supplierPaymentDialog(
  BuildContext c,
  Store store,
  Purchase p,
  int remaining,
) async {
  final amount = TextEditingController(text: remaining.toString());
  String? account;
  var busy = false;
  final id = uuid.v4();
  final accounts = await store.cashAccounts();
  if (!c.mounted) {
    amount.dispose();
    return;
  }
  await formDialog(
    context: c,
    builder: (d) => StatefulBuilder(
      builder: (d, set) => AlertDialog(
        title: const Text('Pembayaran pemasok'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Sisa utang ${rupiah(remaining)}'),
            IntegerField(
              controller: amount,
              label: 'Jumlah pembayaran (Rp)',
              min: 1,
              max: remaining,
            ),
            const SizedBox(height: 16),
            accountDropdown(accounts, account, (v) => set(() => account = v)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: busy ? null : () => Navigator.pop(d),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: busy
                ? null
                : () => action(d, () async {
                    if (busy) return;
                    set(() => busy = true);
                    try {
                      await store.paySupplier(
                        id: id,
                        purchaseId: p.id,
                        amount: parseIntegerInput(
                          amount.text,
                          'Jumlah pembayaran',
                          min: 1,
                        ),
                        date: DateTime.now().toIso8601String(),
                        method:
                            accounts
                                .where((a) => a.id == account)
                                .firstOrNull
                                ?.type ??
                            'Lainnya',
                        accountId: account,
                      );
                      if (d.mounted) Navigator.pop(d);
                    } finally {
                      if (d.mounted) set(() => busy = false);
                    }
                  }),
            child: const Text('Simpan pembayaran'),
          ),
        ],
      ),
    ),
  );
  amount.dispose();
}

Widget accountDropdown(
  List<CashAccount> accounts,
  String? value,
  ValueChanged<String?> changed,
) => DropdownButtonFormField<String>(
  initialValue: value,
  isExpanded: true,
  decoration: const InputDecoration(labelText: 'Akun pencatatan kas'),
  items: [
    const DropdownMenuItem<String>(
      value: null,
      child: Text('Belum dialokasikan'),
    ),
    for (final a in accounts.where((a) => !a.archived || a.id == value))
      DropdownMenuItem(
        value: a.id,
        enabled: !a.archived,
        child: Text('${a.name}${a.archived ? ' (diarsipkan)' : ''}'),
      ),
  ],
  onChanged: changed,
);

class CashflowPage extends ConsumerWidget {
  const CashflowPage({super.key});
  @override
  Widget build(BuildContext c, WidgetRef ref) {
    final store = ref.watch(storeProvider);
    Future<(List<CashAccount>, Map<String?, int>, List<CashMovementRow>)>
    details() async => (
      await store.cashAccounts(),
      await store.cashBalances(),
      await store.cashLedger(),
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Kas & rekening')),
      body: PageBody(
        children: [
          const Text(
            'Akun ini untuk pencatatan, bukan saldo bank langsung. Saldo awal dan transaksi yang belum dicatat dapat membuat saldo berbeda dari uang aktual. Riwayat lama ditandai belum dialokasikan.',
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => Navigator.push(
              c,
              MaterialPageRoute(builder: (_) => const CashReportsPage()),
            ),
            icon: const Icon(Icons.assessment_outlined),
            label: const Text('Laporan arus kas & tutup harian'),
          ),
          OutlinedButton.icon(
            onPressed: () => cashAccountDialog(c, store),
            icon: const Icon(Icons.add),
            label: const Text('Tambah akun kas'),
          ),
          FutureBuilder(
            future: details(),
            builder: (c, s) {
              if (s.hasError) return Text('${s.error}');
              if (!s.hasData) return const CircularProgressIndicator();
              final accounts = s.data!.$1,
                  balances = s.data!.$2,
                  rows = s.data!.$3..sort((a, b) => b.date.compareTo(a.date));
              return Column(
                children: [
                  for (final a in accounts)
                    Card(
                      child: ListTile(
                        leading: const Icon(
                          Icons.account_balance_wallet_outlined,
                        ),
                        title: Text(a.name),
                        subtitle: Text(a.type),
                        trailing: Text(rupiah(balances[a.id] ?? 0)),
                      ),
                    ),
                  Card(
                    child: ListTile(
                      title: const Text('Belum dialokasikan'),
                      subtitle: const Text(
                        'Termasuk penerimaan/pengeluaran historis yang diturunkan dari catatan; bukan saldo akun yang terverifikasi',
                      ),
                      trailing: Text(rupiah(balances[null] ?? 0)),
                    ),
                  ),
                  if (accounts.any((a) => !a.archived))
                    FilledButton.icon(
                      onPressed: () => cashEntryDialog(c, store, accounts),
                      icon: const Icon(Icons.add_card),
                      label: const Text('Catat mutasi kas'),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    'Riwayat mutasi',
                    style: Theme.of(c).textTheme.titleLarge,
                  ),
                  for (final r in rows.take(100))
                    ListTile(
                      title: Text(
                        '${r.amount < 0 ? '−' : '+'} ${rupiah(r.amount.abs())}',
                      ),
                      subtitle: Text(
                        '${cashCategory(r.category)} • ${r.date.substring(0, 10)}\n${accounts.where((a) => a.id == r.accountId).firstOrNull?.name ?? 'Belum dialokasikan'}',
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

String cashCategory(String category) =>
    {
      'sale_receipt': 'Penerimaan penjualan',
      'sale_receipt_revision': 'Revisi penerimaan',
      'receivable_collection': 'Pelunasan piutang',
      'supplier_payment': 'Pembayaran pemasok',
      'operational_expense': 'Pengeluaran operasional',
      'expense_reversal': 'Pembalikan pengeluaran',
      'owner_capital': 'Setoran modal',
      'owner_withdrawal': 'Penarikan pemilik',
      'transfer': 'Transfer antar akun',
      'opening_adjustment': 'Penyesuaian saldo awal',
      'fee_settlement': 'Pembayaran biaya transaksi',
      'legacy_sale_receipt': 'Penjualan historis',
      'legacy_collection': 'Pelunasan historis',
      'legacy_expense': 'Pengeluaran historis',
    }[category] ??
    category;
Future<void> cashAccountDialog(BuildContext c, Store store) async {
  final name = TextEditingController();
  String type = 'Tunai';
  var busy = false;
  await formDialog(
    context: c,
    builder: (d) => StatefulBuilder(
      builder: (d, set) => AlertDialog(
        title: const Text('Akun kas baru'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Nama akun'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: type,
              items: [
                'Tunai',
                'Bank',
                'QRIS',
                'Lainnya',
              ].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
              onChanged: (v) => set(() => type = v!),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: busy ? null : () => Navigator.pop(d),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: busy
                ? null
                : () => action(d, () async {
                    if (busy) return;
                    set(() => busy = true);
                    try {
                      await store.saveCashAccount(
                        CashAccount(
                          id: uuid.v4(),
                          name: name.text.trim(),
                          type: type,
                        ),
                      );
                      if (d.mounted) Navigator.pop(d);
                    } finally {
                      if (d.mounted) set(() => busy = false);
                    }
                  }),
            child: const Text('Simpan akun'),
          ),
        ],
      ),
    ),
  );
  name.dispose();
}

Future<void> cashEntryDialog(
  BuildContext c,
  Store store,
  List<CashAccount> accounts,
) async {
  final amount = TextEditingController();
  String? account = accounts.firstWhere((a) => !a.archived).id, destination;
  String category = 'owner_capital';
  var busy = false;
  final id = uuid.v4();
  await formDialog(
    context: c,
    builder: (d) => StatefulBuilder(
      builder: (d, set) => AlertDialog(
        title: const Text('Mutasi kas'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              accountDropdown(accounts, account, (v) => set(() => account = v)),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: category,
                isExpanded: true,
                items:
                    [
                          'owner_capital',
                          'owner_withdrawal',
                          'opening_adjustment',
                          'transfer',
                          'fee_settlement',
                        ]
                        .map(
                          (v) => DropdownMenuItem(
                            value: v,
                            child: Text(cashCategory(v)),
                          ),
                        )
                        .toList(),
                onChanged: (v) => set(() => category = v!),
              ),
              if (category == 'transfer')
                accountDropdown(
                  accounts,
                  destination,
                  (v) => set(() => destination = v),
                ),
              const SizedBox(height: 16),
              IntegerField(
                controller: amount,
                label: 'Nominal (Rp)',
                min: category == 'opening_adjustment' ? -maxMoney : 1,
              ),
              if (category == 'opening_adjustment')
                const Text(
                  'Gunakan nilai negatif untuk mengurangi saldo awal. Catatan penyesuaian tetap disimpan.',
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: busy ? null : () => Navigator.pop(d),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: busy
                ? null
                : () => action(d, () async {
                    if (busy) return;
                    if (account == null) throw ArgumentError('Pilih akun');
                    set(() => busy = true);
                    try {
                      await store.recordCash(
                        id: id,
                        accountId: account!,
                        amount: parseIntegerInput(
                          amount.text,
                          'Nominal',
                          min: category == 'opening_adjustment' ? -maxMoney : 1,
                        ),
                        category: category,
                        date: DateTime.now().toIso8601String(),
                        destination: destination,
                      );
                      if (d.mounted) Navigator.pop(d);
                    } finally {
                      if (d.mounted) set(() => busy = false);
                    }
                  }),
            child: const Text('Simpan mutasi'),
          ),
        ],
      ),
    ),
  );
  amount.dispose();
}

class OpnamePage extends ConsumerStatefulWidget {
  const OpnamePage({super.key});
  @override
  ConsumerState<OpnamePage> createState() => _OpnamePageState();
}

class _OpnamePageState extends ConsumerState<OpnamePage> {
  final counts = <String, TextEditingController>{};
  final snapshots = <String, Product>{};
  final reason = TextEditingController();
  String? draftId;
  bool busy = false;
  @override
  void dispose() {
    for (final c in counts.values) {
      c.dispose();
    }
    reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) {
    final store = ref.watch(storeProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Stock opname')),
      body: PageBody(
        children: [
          const Text(
            'Pilih produk lalu masukkan stok fisik. Stok baru berubah setelah konfirmasi. Jika ada transaksi baru, sesi perlu dihitung ulang.',
          ),
          DropdownButtonFormField<String>(
            key: ValueKey(counts.length),
            initialValue: null,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Tambahkan produk hitungan',
            ),
            items: store.products
                .where((p) => !p.archived && !counts.containsKey(p.id))
                .map((p) => DropdownMenuItem(value: p.id, child: Text(p.name)))
                .toList(),
            onChanged: (id) {
              if (id != null) {
                final p = store.products.firstWhere((p) => p.id == id);
                setState(() {
                  snapshots[id] = p;
                  counts[id] = TextEditingController(
                    text: (p.stock < 0 ? 0 : p.stock).toString(),
                  );
                });
              }
            },
          ),
          for (final e in counts.entries)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(snapshots[e.key]!.name),
                    Text(
                      'Stok tercatat saat mulai: ${snapshots[e.key]!.stock}',
                    ),
                    IntegerField(
                      controller: e.value,
                      label: 'Hasil hitung fisik',
                      max: 1000000000,
                      onChanged: (_) => setState(() {}),
                    ),
                    Text(
                      'Selisih: ${(int.tryParse(e.value.text) ?? snapshots[e.key]!.stock) - snapshots[e.key]!.stock}',
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          TextField(
            controller: reason,
            decoration: const InputDecoration(labelText: 'Alasan opname'),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: busy
                ? null
                : () => action(c, () async {
                    if (busy) return;
                    setState(() => busy = true);
                    try {
                      final id = draftId ??= uuid.v4();
                      await store.saveOpnameDraft(
                        id: id,
                        items: [
                          for (final e in counts.entries)
                            OpnameItem(
                              productId: e.key,
                              expectedUpdated: snapshots[e.key]!.updated,
                              expectedStock: snapshots[e.key]!.stock,
                              counted: parseIntegerInput(
                                e.value.text,
                                'Hasil hitung fisik',
                                max: 1000000000,
                              ),
                            ),
                        ],
                        reason: reason.text.trim(),
                      );
                      if (!c.mounted) return;
                      if (await confirm(
                        c,
                        'Konfirmasi hasil hitung?',
                        'Tinjau selisih di formulir. Konfirmasi akan membuat koreksi stok dan menyimpan riwayatnya.',
                      )) {
                        await store.confirmOpname(id, 'opname:$id');
                        if (c.mounted) Navigator.pop(c);
                      }
                    } finally {
                      if (mounted) setState(() => busy = false);
                    }
                  }),
            child: const Text('Tinjau & konfirmasi opname'),
          ),
          const SizedBox(height: 20),
          Text('Riwayat sesi', style: Theme.of(c).textTheme.titleLarge),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: store.opnameSessions(),
            builder: (c, s) => Column(
              children: [
                for (final j in s.data ?? <Map<String, dynamic>>[])
                  Card(
                    child: ListTile(
                      title: Text(j['reason']),
                      subtitle: Text(
                        j['confirmed'] == true
                            ? 'Sudah diposting'
                            : 'Draf — belum mengubah stok',
                      ),
                      onTap: () => showDialog<void>(
                        context: c,
                        builder: (d) => AlertDialog(
                          title: const Text('Rincian opname'),
                          content: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                for (final item in j['items'])
                                  ListTile(
                                    title: Text(
                                      store.products
                                              .where(
                                                (p) =>
                                                    p.id == item['productId'],
                                              )
                                              .firstOrNull
                                              ?.name ??
                                          item['productId'],
                                    ),
                                    subtitle: Text(
                                      '${item['expectedStock']} → ${item['counted']} • Selisih ${(item['counted'] as int) - (item['expectedStock'] as int)}',
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(d),
                              child: const Text('Tutup'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
