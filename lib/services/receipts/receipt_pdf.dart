import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../domain/receipt.dart';
import '../documents/pdf_theme.dart';

Future<Uint8List> receiptPdf(
  ReceiptSnapshot receipt, {
  int paperWidth = 58,
}) async {
  if (![58, 80].contains(paperWidth)) {
    throw ArgumentError('Lebar kertas harus 58 atau 80 mm');
  }
  pw.MemoryImage? logo;
  if (receipt.logo != null) {
    try {
      final codec = await ui.instantiateImageCodec(receipt.logo!);
      try {
        (await codec.getNextFrame()).image.dispose();
      } finally {
        codec.dispose();
      }
      logo = pw.MemoryImage(receipt.logo!);
    } catch (_) {
      /* Optional damaged logo never prevents a text receipt. */
    }
  }
  final document = pw.Document(theme: await offlinePdfTheme());
  document.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat(
        paperWidth * PdfPageFormat.mm,
        297 * PdfPageFormat.mm,
        marginAll: 4 * PdfPageFormat.mm,
      ),
      maxPages: 1000,
      header: (context) => context.pageNumber == 1
          ? pw.SizedBox()
          : pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  receipt.business,
                  style: const pw.TextStyle(fontSize: 8),
                ),
                pw.Text(
                  '${receipt.sale.voided ? 'DIBATALKAN - ' : ''}No: ${receipt.sale.id} (lanjutan)',
                  style: const pw.TextStyle(fontSize: 8),
                ),
                pw.Divider(),
              ],
            ),
      footer: (context) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          'Halaman ${context.pageNumber} / ${context.pagesCount}',
          style: const pw.TextStyle(fontSize: 8),
        ),
      ),
      build: (c) => [
        if (logo != null)
          pw.Image(logo, width: 64, height: 64, fit: pw.BoxFit.contain),
        pw.Text(
          receipt.business,
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
        ),
        if (receipt.address.isNotEmpty) pw.Text(receipt.address),
        if (receipt.phone.isNotEmpty) pw.Text(receipt.phone),
        pw.Text(receipt.sale.voided ? 'STRUK DIBATALKAN' : 'STRUK PENJUALAN'),
        pw.Text('No: ${receipt.sale.id}'),
        pw.Text(receipt.sale.date),
        if (receipt.sale.customer.isNotEmpty)
          pw.Text('Pelanggan: ${receipt.sale.customer}'),
        pw.Divider(),
        pw.TableHelper.fromTextArray(
          headers: ['Barang', 'Jumlah', 'Total'],
          cellStyle: const pw.TextStyle(fontSize: 8),
          data: [
            for (final line in receipt.sale.lines)
              [
                line.name,
                '${line.quantity} x ${ReceiptSnapshot.money(line.price)}',
                ReceiptSnapshot.money(line.quantity * line.price),
              ],
          ],
        ),
        pw.Divider(),
        for (final total in receipt.totals)
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 2),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Expanded(child: pw.Text(total.$1)),
                pw.Text(total.$2),
              ],
            ),
          ),
        pw.Text('Status: ${receipt.sale.paymentStatus}'),
        pw.Text('Metode: ${receipt.sale.payment}'),
        if (receipt.sale.dueDate != null)
          pw.Text('Jatuh tempo: ${receipt.sale.dueDate}'),
        if (receipt.sale.note.isNotEmpty)
          pw.Text('Catatan: ${receipt.sale.note}'),
        for (final r in receipt.sale.adjustments)
          pw.Text(
            'Retur ${r.date.substring(0, 10)}: ${r.reason} (${ReceiptSnapshot.money(r.revenueReduction)})',
          ),
        pw.Divider(),
        pw.Text(receipt.footer),
      ],
    ),
  );
  return document.save();
}
