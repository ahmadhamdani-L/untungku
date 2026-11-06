import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:untungku_pro/data/database.dart';
import 'package:untungku_pro/data/store.dart';
import 'package:untungku_pro/domain/models.dart';
import 'package:untungku_pro/features/app.dart';

class SavePicker extends FilePickerPlatform {
  Completer<Uri?>? pending;
  String? name, mime;
  Uint8List? data;
  @override
  Future<Uri?> saveFile({
    required String fileName,
    required Uint8List bytes,
    required String mimeType,
    String? dialogTitle,
    String? initialDirectory,
    Function(FilePickerStatus)? onFileSaving,
    WindowsOptions windowsOptions = const WindowsOptions(),
    LinuxOptions linuxOptions = const LinuxOptions(),
    WebOptions webOptions = const WebOptions(),
  }) {
    name = fileName;
    mime = mimeType;
    data = bytes;
    return pending!.future;
  }
}

void main() {
  testWidgets(
    'save/share metadata, cancellation and failure recover without postings',
    (tester) async {
      final oldPicker = FilePickerPlatform.instance;
      final picker = SavePicker();
      FilePickerPlatform.instance = picker;
      final temp = (await tester.runAsync(
        () => Directory.systemTemp.createTemp('receipt-delivery-'),
      ))!;
      final messenger = tester.binding.defaultBinaryMessenger;
      const shareChannel = MethodChannel('dev.fluttercommunity.plus/share');
      const pathChannel = MethodChannel('plugins.flutter.io/path_provider');
      MethodCall? shared;
      Object? shareError;
      messenger.setMockMethodCallHandler(pathChannel, (_) async => temp.path);
      messenger.setMockMethodCallHandler(shareChannel, (call) async {
        shared = call;
        if (shareError != null) throw shareError;
        return ''; // Dismissed; never claim actual delivery.
      });
      addTearDown(() async {
        FilePickerPlatform.instance = oldPicker;
        messenger.setMockMethodCallHandler(shareChannel, null);
        messenger.setMockMethodCallHandler(pathChannel, null);
        await tester.runAsync(() => temp.delete(recursive: true));
      });
      final db = AppDatabase(NativeDatabase.memory());
      final store = Store(db);
      await store.load();
      await store.saveProduct(
        const Product(
          id: 'p',
          name: 'Kopi',
          price: 10000,
          cost: 5000,
          stock: 5,
          created: '2026-11-05',
          updated: '2026-11-05',
        ),
      );
      await store.saveSale(
        const Sale(
          id: 'sale/unsafe',
          date: '2026-11-05T10:00:00',
          lines: [
            SaleLine(
              productId: 'p',
              name: 'Kopi',
              quantity: 1,
              price: 10000,
              cost: 5000,
              packaging: 0,
              extra: 0,
            ),
          ],
        ),
      );
      final before = jsonDecode(store.backup()) as Map<String, dynamic>
        ..remove('created');
      final ledger = (await store.cashLedger()).map((r) => r.toJson()).toList();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [storeProvider.overrideWith((ref) => store)],
          child: const MaterialApp(home: ReceiptPage(saleId: 'sale/unsafe')),
        ),
      );
      await tester.pumpAndSettle();
      Future<void> tap(String label) async {
        await tester.scrollUntilVisible(
          find.text(label),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(find.text(label));
        await tester.pumpAndSettle();
      }

      picker.pending = Completer<Uri?>();
      await tap('Simpan PDF struk');
      expect(picker.name, 'struk-sale_unsafe.pdf');
      expect(picker.mime, 'application/pdf');
      expect(String.fromCharCodes(picker.data!.take(5)), '%PDF-');
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Bagikan PDF struk'),
            )
            .onPressed,
        isNull,
      );
      picker.pending!.complete(null);
      await tester.pumpAndSettle();
      expect(find.text('PDF struk disimpan.'), findsNothing);
      picker.pending = Completer<Uri?>();
      await tap('Simpan PDF struk');
      picker.pending!.completeError(
        PlatformException(code: 'save_failed', message: 'Penyimpanan gagal'),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('Penyimpanan gagal'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      picker.pending = Completer<Uri?>();
      await tap('Simpan PDF struk');
      picker.pending!.complete(Uri.parse('content://test/receipt.pdf'));
      await tester.pumpAndSettle();
      expect(find.text('PDF struk disimpan.'), findsOneWidget);
      for (final item in [
        ('Bagikan PDF struk', 'application/pdf', '.pdf'),
        ('Bagikan gambar struk', 'image/png', '.png'),
      ]) {
        shared = null;
        await tap(item.$1);
        for (var i = 0; i < 100 && shared == null; i++) {
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 20)),
          );
          await tester.pumpAndSettle();
        }
        expect(shared!.arguments['mimeTypes'], [item.$2]);
        final file = File(
          (shared!.arguments['paths'] as List).single as String,
        );
        expect(file.path, endsWith('struk-sale_unsafe${item.$3}'));
        final bytes = await tester.runAsync(() => file.readAsBytes());
        if (item.$3 == '.pdf') {
          expect(String.fromCharCodes(bytes!.take(5)), '%PDF-');
        } else {
          expect(bytes!.take(8).toList(), [137, 80, 78, 71, 13, 10, 26, 10]);
        }
      }
      shareError = PlatformException(
        code: 'share_failed',
        message: 'Berbagi gagal',
      );
      shared = null;
      await tap('Bagikan PDF struk');
      for (var i = 0; i < 100 && shared == null; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)),
        );
        await tester.pumpAndSettle();
      }
      expect(find.textContaining('Berbagi gagal'), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Bagikan PDF struk'),
            )
            .onPressed,
        isNotNull,
      );
      expect(
        jsonDecode(store.backup()) as Map<String, dynamic>..remove('created'),
        before,
      );
      expect(
        (await store.cashLedger()).map((r) => r.toJson()).toList(),
        ledger,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await db.close();
    },
  );
}
