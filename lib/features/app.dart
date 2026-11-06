import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart' show compute;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../core/security/pin_controller.dart';
import '../core/security/backup_cipher.dart';
import '../data/store.dart';
import '../data/database.dart' show CashMovementRow;
import '../domain/business/entities.dart';
import '../domain/business/cashflow.dart';
import '../domain/business/returns.dart';
import '../domain/business/pos_cart.dart';
import '../domain/business/product_import.dart';
import '../domain/business/insights.dart';
import '../services/ads.dart';
import '../services/reports/cashflow_pdf.dart';
import '../services/receipts/printer.dart';
import '../services/receipts/receipt_pdf.dart';
import '../services/receipts/receipt_image.dart';
import '../domain/receipt.dart';
import 'privacy.dart';
import '../domain/models.dart';
import '../domain/money.dart';
import '../domain/input_validation.dart';
import 'shared/integer_field.dart';
import '../domain/reporting.dart';

part 'dashboard.dart';
part 'products.dart';
part 'transactions.dart';
part 'calculator.dart';
part 'settings.dart';
part 'security.dart';
part 'receivables.dart';
part 'insights.dart';
part 'management.dart';
part 'cash_reports.dart';
part 'returns.dart';
part 'pos.dart';
part 'receipts.dart';
part 'printer_settings.dart';
part 'product_import.dart';
part 'business_insights.dart';

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
        seedColor: const Color(0xFF1565C0),
        brightness: b,
      ),
      fontFamily: 'Roboto',
      appBarTheme: AppBarTheme(
        backgroundColor: b == Brightness.light
            ? const Color(0xFFF5F7FA)
            : const Color(0xFF101916),
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: b == Brightness.light
            ? Colors.white
            : const Color(0xFF1C2923),
        elevation: 0,
        height: 72,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      scaffoldBackgroundColor: b == Brightness.light
          ? const Color(0xFFF5F7FA)
          : const Color(0xFF101916),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: b == Brightness.light
            ? Colors.white
            : const Color(0xFF1C2923),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
        ),
      ),
      cardTheme: CardThemeData(
        color: b == Brightness.light ? Colors.white : const Color(0xFF1C2923),
        margin: const EdgeInsets.symmetric(vertical: 5),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
    return MaterialApp(
      title: 'UntungKu Pro',
      builder: (context, child) {
        final pin = ref.watch(pinProvider);
        return pin == null
            ? child!
            : SecurityGate(controller: pin, child: child!);
      },
      locale: const Locale('id', 'ID'),
      supportedLocales: const [Locale('id', 'ID'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
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
                  onPressed: () => action(context, () async {
                    final store = ref.read(storeProvider);
                    await store.saveSettings({
                      ...store.settings,
                      'onboarded': true,
                      'business': store.settings['business'] ?? 'Usaha Saya',
                      'theme': store.settings['theme'] ?? 'system',
                      'feeBps': store.settings['feeBps'] ?? 0,
                    });
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
      color: const Color(0xFF1565C0),
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) transactionAds.start();
    });
  }

  @override
  void dispose() {
    transactionAds.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(storeProvider);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Brand(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'UntungKu Pro',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                  ),
                  Text(
                    store.settings['business']?.toString() ?? 'Usaha Saya',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Piutang pelanggan',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ReceivablesPage()),
            ),
            icon: const Icon(Icons.account_balance_wallet_outlined),
          ),
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
          ManagementPage(),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const OptionalAdBanner(),
          NavigationBar(
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
              NavigationDestination(
                icon: Icon(Icons.more_horiz),
                label: 'Lainnya',
              ),
            ],
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
        ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
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

Widget balanceCard(
  BuildContext c,
  String label,
  String value,
  String detail,
  IconData icon,
) => Container(
  padding: const EdgeInsets.all(24),
  decoration: BoxDecoration(
    gradient: const LinearGradient(
      colors: [Color(0xFF07583F), Color(0xFF10966B)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(24),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFFBEECD8),
                fontSize: 11,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Icon(icon, color: const Color(0xFFBEECD8)),
        ],
      ),
      const SizedBox(height: 12),
      Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 30,
        ),
      ),
      const SizedBox(height: 10),
      Text(detail, style: const TextStyle(color: Colors.white, height: 1.5)),
    ],
  ),
);

Future<void> showSaveSuccess(BuildContext context, String message) async {
  var busy = false;
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (d) => StatefulBuilder(
      builder: (d, set) => PopScope(
        canPop: false,
        child: AlertDialog(
          icon: const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFF087F5B),
            size: 48,
          ),
          title: Text(message),
          content: const Text('Data usaha Anda sudah tersimpan di perangkat.'),
          actions: [
            FilledButton(
              onPressed: busy
                  ? null
                  : () async {
                      set(() => busy = true);
                      try {
                        await transactionAds.completed();
                      } finally {
                        if (d.mounted) Navigator.pop(d);
                      }
                    },
              child: const Text('Selesai'),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> formDialog({
  required BuildContext context,
  required WidgetBuilder builder,
}) async {
  final route = DialogRoute<void>(context: context, builder: builder);
  await Navigator.of(context).push(route);
  await route.completed;
}
