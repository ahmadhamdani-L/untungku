import 'dart:convert';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'models.dart';

/// Receipt output is a projection of immutable sale snapshots; it never posts data.
class ReceiptSnapshot {
  final Sale sale;
  final String business, address, phone, footer;
  final Uint8List? logo;
  const ReceiptSnapshot({
    required this.sale,
    required this.business,
    this.address = '',
    this.phone = '',
    this.logo,
    this.footer = 'Terima kasih atas belanja Anda.',
  });
  static Uint8List? decodeLogo(Object? source) {
    if (source is! String || source.length > 400000) return null;
    try {
      final bytes = base64Decode(source);
      if (bytes.length < 24 ||
          bytes.length > 300000 ||
          bytes.take(8).join(',') != '137,80,78,71,13,10,26,10') {
        return null;
      }
      final data = ByteData.sublistView(bytes);
      final width = data.getUint32(16), height = data.getUint32(20);
      return width > 0 && width <= 512 && height > 0 && height <= 512
          ? bytes
          : null;
    } catch (_) {
      return null;
    }
  }

  factory ReceiptSnapshot.fromSettings(
    Sale sale,
    Map<String, dynamic> settings,
  ) => ReceiptSnapshot(
    sale: sale,
    business: settings['business']?.toString() ?? 'Usaha Saya',
    address: settings['receiptAddress']?.toString() ?? '',
    phone: settings['receiptPhone']?.toString() ?? '',
    footer:
        settings['receiptFooter']?.toString() ??
        'Terima kasih atas belanja Anda.',
    logo: decodeLogo(settings['receiptLogo']),
  );
  List<(String, String)> get totals => [
    (
      'Subtotal barang',
      money(sale.lines.fold<int>(0, (sum, l) => sum + l.quantity * l.price)),
    ),
    ('Diskon', money(sale.discount)),
    ('Total penjualan asli', money(sale.originalResult.revenue)),
    if (sale.adjustments.isNotEmpty)
      (
        'Pengurang retur',
        money(sale.originalResult.revenue - sale.result.revenue),
      ),
    ('Total setelah retur', money(sale.result.revenue)),
    ('Pembayaran diterima', money(sale.paid)),
    if (sale.adjustments.isNotEmpty) ...[
      (
        'Refund sudah dibayar',
        money(sale.adjustments.fold<int>(0, (sum, r) => sum + r.refunded)),
      ),
      (
        'Pembayaran bersih setelah refund',
        money(
          sale.paid -
              sale.adjustments.fold<int>(0, (sum, r) => sum + r.refunded),
        ),
      ),
    ],
    if (sale.credit) ('Sisa piutang', money(sale.outstanding)),
    if (sale.refundOutstanding > 0)
      ('Refund belum dibayar', money(sale.refundOutstanding)),
  ];
  static String money(int value) => NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  ).format(value);
  String text() => [
    business,
    if (address.isNotEmpty) address,
    if (phone.isNotEmpty) phone,
    'STRUK PENJUALAN${sale.voided ? ' - DIBATALKAN' : ''}',
    'No: ${sale.id}',
    sale.date,
    if (sale.customer.isNotEmpty) 'Pelanggan: ${sale.customer}',
    '--------------------------------',
    for (final l in sale.lines)
      '${l.name}\n${l.quantity} x ${money(l.price)} = ${money(l.quantity * l.price)}',
    '--------------------------------',
    for (final total in totals) '${total.$1}: ${total.$2}',
    'Status: ${sale.paymentStatus}',
    'Metode: ${sale.payment}',
    if (sale.dueDate != null) 'Jatuh tempo: ${sale.dueDate}',
    if (sale.note.isNotEmpty) 'Catatan: ${sale.note}',
    for (final r in sale.adjustments)
      'Retur ${r.date.substring(0, 10)}: ${r.reason} (${money(r.revenueReduction)})',
    footer,
  ].join('\n');
}
