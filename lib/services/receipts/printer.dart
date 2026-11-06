import 'package:flutter/services.dart';
import '../../domain/receipt.dart';

/// Basic text-only ESC/POS profile. No vendor-specific image/cut commands.
Uint8List receiptEscPos(ReceiptSnapshot receipt, {int paperWidth = 58}) {
  if (paperWidth != 58 && paperWidth != 80) {
    throw ArgumentError('Lebar kertas harus 58 atau 80 mm');
  }
  final columns = paperWidth == 58 ? 32 : 48;
  final lines = <String>[];
  for (final raw in receipt.text().split('\n')) {
    // User-controlled text must never introduce printer commands.
    var line = String.fromCharCodes(
      raw.runes.map((c) => c >= 32 && c <= 126 ? c : 63),
    );
    while (line.length > columns) {
      var split = line.lastIndexOf(' ', columns);
      if (split <= 0) split = columns;
      lines.add(line.substring(0, split));
      line = line.substring(split).trimLeft();
    }
    lines.add(line);
  }
  return Uint8List.fromList([27, 64, ...'${lines.join('\n')}\n\n\n'.codeUnits]);
}

class ReceiptPrinter {
  static const channel = MethodChannel('id.untungku/printer');
  Future<List<Map<String, String>>> paired() async {
    final list = await channel.invokeListMethod<dynamic>('paired') ?? [];
    return list.map((e) => Map<String, String>.from(e as Map)).toList();
  }

  Future<void> printBytes(String address, Uint8List bytes) async {
    if (!RegExp(r'^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$').hasMatch(address)) {
      throw ArgumentError('Pilih printer Bluetooth terlebih dahulu');
    }
    await channel.invokeMethod<void>('print', {
      'address': address,
      'bytes': bytes,
    });
  }
}
