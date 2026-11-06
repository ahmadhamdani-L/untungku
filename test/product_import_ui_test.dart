import 'dart:convert';
import 'dart:typed_data';
import 'package:drift/native.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:share_plus/share_plus.dart' show XFile;
import 'package:untungku_pro/data/database.dart';
import 'package:untungku_pro/data/store.dart';
import 'package:untungku_pro/domain/business/product_import.dart';
import 'package:untungku_pro/features/app.dart';

final class CsvFile extends PlatformFile {
  final Uint8List bytes = Uint8List.fromList(utf8.encode(productCsvTemplate));
  @override
  String get name => 'template.csv';
  @override
  Uri get uri => Uri.parse('content://test/template.csv');
  @override
  XFile get xFile => XFile.fromData(bytes, name: name);
  @override
  int? lengthSync() => bytes.length;
  @override
  Future<int?> length() async => bytes.length;
  @override
  Future<Uint8List> readAsBytes() async => bytes;
  @override
  Stream<Uint8List> readAsByteStream() => Stream.value(bytes);
}

class CsvPicker extends FilePickerPlatform {
  @override
  Future<PlatformFile?> pickFile({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    int compressionQuality = 0,
    AndroidOptions androidOptions = const AndroidOptions(),
    DarwinOptions darwinOptions = const DarwinOptions(),
    WindowsOptions windowsOptions = const WindowsOptions(),
    LinuxOptions linuxOptions = const LinuxOptions(),
    WebOptions webOptions = const WebOptions(),
  }) async {
    return CsvFile();
  }
}

void main() {
  testWidgets('CSV file mapping preview cancels safely then commits once', (
    tester,
  ) async {
    final old = FilePickerPlatform.instance;
    FilePickerPlatform.instance = CsvPicker();
    addTearDown(() => FilePickerPlatform.instance = old);
    final db = AppDatabase(NativeDatabase.memory());
    final store = Store(db);
    await store.load();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [storeProvider.overrideWith((ref) => store)],
        child: const MaterialApp(home: ProductImportPage()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pilih file CSV'));
    for (
      var i = 0;
      i < 100 &&
          find.textContaining('template.csv').evaluate().isEmpty &&
          find.byType(SnackBar).evaluate().isEmpty;
      i++
    ) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump();
    }
    expect(
      find.textContaining('template.csv'),
      findsOneWidget,
      reason: find
          .byType(SnackBar)
          .evaluate()
          .map((e) => (e.widget as SnackBar).content)
          .join(),
    );
    Future<void> tap(String text) async {
      await tester.scrollUntilVisible(
        find.text(text),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text(text));
      await tester.pump();
    }

    await tap('Validasi & pratinjau');
    for (
      var i = 0;
      i < 100 && find.textContaining('1 baru').evaluate().isEmpty;
      i++
    ) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump();
    }
    await tap('Konfirmasi impor');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Kembali'));
    await tester.pumpAndSettle();
    expect(store.products, isEmpty);
    await tap('Konfirmasi impor');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Lanjutkan'));
    await tester.pumpAndSettle();
    expect(store.products.single.name, 'Kopi, Susu');
    expect(store.products.single.stock, 10);
    expect(find.text('Impor selesai'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await store.db.close();
  });
}
