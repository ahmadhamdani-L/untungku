import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;

/// Bundled fonts keep receipts and reports usable without downloading fonts.
Future<pw.ThemeData> offlinePdfTheme() async {
  final regularData = await rootBundle.load(
    'assets/fonts/NotoSans-Regular.ttf',
  );
  final boldData = await rootBundle.load('assets/fonts/NotoSans-Bold.ttf');
  final base = pw.Font.ttf(regularData), bold = pw.Font.ttf(boldData);
  return pw.ThemeData.withFont(
    base: base,
    bold: bold,
    italic: base,
    boldItalic: bold,
  );
}
