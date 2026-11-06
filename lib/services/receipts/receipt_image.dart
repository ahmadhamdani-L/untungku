import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/painting.dart';
import '../../domain/receipt.dart';

Future<Uint8List> receiptImage(
  ReceiptSnapshot receipt, {
  int paperWidth = 58,
}) async {
  if (![58, 80].contains(paperWidth)) {
    throw ArgumentError('Lebar kertas tidak valid');
  }
  final width = paperWidth == 58 ? 320.0 : 440.0;
  final painter = TextPainter(
    text: TextSpan(
      text: receipt.text(),
      style: const TextStyle(
        color: Color(0xFF000000),
        fontFamily: 'monospace',
        fontSize: 14,
        height: 1.5,
      ),
    ),
    textDirection: TextDirection.ltr,
  );
  painter.layout(maxWidth: width - 32);
  ui.Image? logo;
  if (receipt.logo != null) {
    try {
      final codec = await ui.instantiateImageCodec(receipt.logo!);
      try {
        logo = (await codec.getNextFrame()).image;
      } finally {
        codec.dispose();
      }
    } catch (_) {
      /* A damaged optional logo must not block the text receipt. */
    }
  }
  final logoHeight = logo == null ? 0.0 : 112.0;
  final height = painter.height + 32 + logoHeight;
  if (height > 12000) {
    painter.dispose();
    logo?.dispose();
    throw StateError('Struk terlalu panjang untuk gambar. Gunakan PDF.');
  }
  final recorder = ui.PictureRecorder();
  // Record one complete receipt independently of screen scrolling or theme.
  final output = Canvas(recorder);
  output.scale(2);
  output.drawRect(
    Rect.fromLTWH(0, 0, width, height),
    Paint()..color = const Color(0xFFFFFFFF),
  );
  if (logo != null) {
    final size = logo.width > logo.height ? logo.width : logo.height;
    output.drawImageRect(
      logo,
      Rect.fromLTWH(0, 0, logo.width.toDouble(), logo.height.toDouble()),
      Rect.fromLTWH(16, 16, 100 * logo.width / size, 100 * logo.height / size),
      Paint(),
    );
    logo.dispose();
  }
  painter.paint(output, Offset(16, 16 + logoHeight));
  painter.dispose();
  final picture = recorder.endRecording();
  final image = await picture.toImage((width * 2).ceil(), (height * 2).ceil());
  try {
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    if (bytes == null) throw StateError('Gambar struk tidak dapat dibuat');
    return bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
  } finally {
    image.dispose();
    picture.dispose();
  }
}
