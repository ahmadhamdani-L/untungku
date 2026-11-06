import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/database.dart';
import 'core/security/pin_controller.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'data/store.dart';
import 'features/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');
  final store = Store(AppDatabase.local());
  try {
    await store.load();
    final pin = PinController(SecurePinVault());
    await pin.load();
    runApp(
      ProviderScope(
        overrides: [
          storeProvider.overrideWith((ref) => store),
          pinProvider.overrideWithValue(pin),
        ],
        child: const UntungkuApp(),
      ),
    );
  } catch (e) {
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Data tidak dapat dibuka. Data lokal tidak dihapus. Tutup lalu buka kembali aplikasi.\n$e',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
