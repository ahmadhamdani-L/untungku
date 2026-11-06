import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../domain/business/cashflow.dart';
import '../documents/pdf_theme.dart';

Future<Uint8List> cashflowPdf(
  CashflowReport report, {
  String business = 'Usaha Saya',
  String scope = 'Semua akun',
  int? counted,
}) async {
  final document = pw.Document(theme: await offlinePdfTheme());
  final money = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  final day = DateFormat('dd/MM/yyyy');
  document.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      maxPages: 1000,
      build: (context) => [
        pw.Header(level: 0, text: 'Laporan arus kas - $business'),
        pw.Text(
          '${day.format(report.start)} - ${day.format(report.end.subtract(const Duration(days: 1)))}',
        ),
        pw.Text('Cakupan: $scope'),
        pw.SizedBox(height: 12),
        pw.TableHelper.fromTextArray(
          headers: ['Ringkasan', 'Rupiah'],
          data: [
            ['Saldo awal tercatat', money.format(report.opening)],
            ['Masuk selain transfer', money.format(report.inflow)],
            ['Keluar selain transfer', money.format(report.outflow)],
            ['Transfer bersih', money.format(report.transferNet)],
            ['Saldo akhir tercatat', money.format(report.closing)],
            if (counted != null) ...[
              ['Uang dihitung', money.format(counted)],
              [
                'Selisih terhadap catatan',
                money.format(report.variance(counted)),
              ],
            ],
          ],
        ),
        pw.Paragraph(
          text:
              'Saldo berasal dari catatan, bukan verifikasi saldo bank atau uang aktual. '
              'Riwayat belum dialokasikan tidak membuktikan alokasi ke akun tertentu. '
              'Kas masuk tidak selalu merupakan pendapatan penjualan.',
        ),
        pw.TableHelper.fromTextArray(
          headers: ['Tanggal', 'Akun', 'Kategori', 'Referensi', 'Rupiah'],
          cellStyle: const pw.TextStyle(fontSize: 8),
          data: [
            for (final row in report.entries)
              [
                row.date.substring(0, 10),
                row.accountId ?? 'Belum dialokasikan',
                row.category,
                row.reference,
                money.format(row.amount),
              ],
          ],
        ),
      ],
      footer: (context) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text('${context.pageNumber} / ${context.pagesCount}'),
      ),
    ),
  );
  return document.save();
}
