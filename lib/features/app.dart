import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../data/store.dart';
import '../domain/models.dart';
import '../domain/money.dart';

part 'dashboard.dart';
part 'products.dart';
part 'transactions.dart';
part 'calculator.dart';
part 'settings.dart';

final storeProvider = ChangeNotifierProvider<Store>(
  (ref) => throw UnimplementedError(),
);
String rupiah(num value) => NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp ',
  decimalDigits: 0,
).format(value);

class UntungkuApp extends ConsumerWidget {
  const UntungkuApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(storeProvider).settings;
    ThemeData theme(Brightness b) => ThemeData(
      useMaterial3: true,
      brightness: b,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF087F5B),
        brightness: b,
      ),
      scaffoldBackgroundColor: b == Brightness.light
          ? const Color(0xFFF6F8F7)
          : const Color(0xFF101A16),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
    return MaterialApp(
      title: 'UntungKu Pro',
      debugShowCheckedModeBanner: false,
      theme: theme(Brightness.light),
      darkTheme: theme(Brightness.dark),
      themeMode: switch (settings['theme']) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      },
      home: settings['onboarded'] == true ? const Home() : const Onboarding(),
    );
  }
}

class Onboarding extends ConsumerWidget {
  const Onboarding({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Brand(size: 88),
                const SizedBox(height: 40),
                Text(
                  'Usaha rapi.\nUntung lebih pasti.',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Catat penjualan, pantau stok, dan pahami laba usaha Anda. Semua dari satu tempat, bahkan tanpa internet.',
                  style: TextStyle(fontSize: 17, height: 1.6),
                ),
                const SizedBox(height: 32),
                const ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.wifi_off_rounded),
                  title: Text('Siap digunakan offline'),
                  subtitle: Text('Tanpa akun. Data tersimpan di perangkat.'),
                ),
                const ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.shield_outlined),
                  title: Text('Data usaha milik Anda'),
                  subtitle: Text(
                    'Backup rutin. Uninstall atau perangkat hilang dapat menghapus data.',
                  ),
                ),
                const SizedBox(height: 28),
                FilledButton.icon(
                  onPressed: () => ref.read(storeProvider).saveSettings({
                    'onboarded': true,
                    'business': 'Usaha Saya',
                    'theme': 'system',
                    'feeBps': 0,
                  }),
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Mulai / lewati pengenalan'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class Brand extends StatelessWidget {
  final double size;
  const Brand({super.key, this.size = 44});
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: const Color(0xFF087F5B),
      borderRadius: BorderRadius.circular(size * .28),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(size * .28),
      child: Image.asset(
        'assets/branding/untungku-icon-512.png',
        width: size,
        height: size,
      ),
    ),
  );
}

class Home extends ConsumerStatefulWidget {
  const Home({super.key});
  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  int index = 0;
  @override
  Widget build(BuildContext context) {
    final store = ref.watch(storeProvider);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Brand(),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'UntungKu Pro',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
                ),
                Text(
                  store.settings['business']?.toString() ?? 'Usaha Saya',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Pengaturan & backup',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsPage()),
            ),
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
      body: IndexedStack(
        index: index,
        children: const [
          Dashboard(),
          ProductsPage(),
          TransactionsPage(),
          CalculatorPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (v) => setState(() => index = v),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view_rounded),
            label: 'Ringkasan',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Produk',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            label: 'Transaksi',
          ),
          NavigationDestination(
            icon: Icon(Icons.calculate_outlined),
            label: 'Kalkulator',
          ),
        ],
      ),
    );
  }
}

class PageBody extends StatelessWidget {
  final List<Widget> children;
  const PageBody({super.key, required this.children});
  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 900),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
        children: children,
      ),
    ),
  );
}

Widget heading(BuildContext c, String title, String subtitle) => Padding(
  padding: const EdgeInsets.only(bottom: 20),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: Theme.of(
          c,
        ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 6),
      Text(subtitle, style: Theme.of(c).textTheme.bodyMedium),
    ],
  ),
);
Widget empty(String title, String detail, IconData icon) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 12),
  child: Column(
    children: [
      Icon(icon, size: 64, color: const Color(0xFF36A17C)),
      const SizedBox(height: 16),
      Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      const SizedBox(height: 8),
      Text(detail, textAlign: TextAlign.center),
    ],
  ),
);
Future<void> action(BuildContext context, Future<void> Function() run) async {
  try {
    await run();
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Invalid argument(s): ', '')),
        ),
      );
    }
  }
}

Future<bool> confirm(BuildContext context, String title, String detail) async =>
    await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(title),
        content: Text(detail),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Kembali'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Lanjutkan'),
          ),
        ],
      ),
    ) ??
    false;
