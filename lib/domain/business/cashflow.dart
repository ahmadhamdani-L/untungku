import '../dates.dart';

class CashEntry {
  final String id, reference, category, date;
  final String? accountId;
  final int amount;
  const CashEntry({
    required this.id,
    required this.reference,
    required this.category,
    required this.date,
    required this.amount,
    this.accountId,
  });
}

class CashflowReport {
  final DateTime start, end;
  final String? accountId;
  final bool allAccounts;
  final int opening, inflow, outflow, transferNet;
  final List<CashEntry> entries;
  final Map<String, int> categories;
  const CashflowReport({
    required this.start,
    required this.end,
    required this.accountId,
    required this.allAccounts,
    required this.opening,
    required this.inflow,
    required this.outflow,
    required this.transferNet,
    required this.entries,
    required this.categories,
  });
  int get closing => opening + inflow - outflow + transferNet;
  int variance(int counted) => counted - closing;

  String csv() {
    String cell(Object? value) {
      var text = value?.toString() ?? 'Belum dialokasikan';
      if (value is String && RegExp(r'^[=+@\-\t\r]').hasMatch(text)) {
        text = "'$text";
      }
      return '"${text.replaceAll('"', '""')}"';
    }

    return [
      ['tanggal', 'akun', 'kategori', 'referensi', 'jumlah_rupiah'],
      ...entries.map(
        (e) => [e.date, e.accountId, e.category, e.reference, e.amount],
      ),
      ['saldo_awal', '', '', '', opening],
      ['masuk_non_transfer', '', '', '', inflow],
      ['keluar_non_transfer', '', '', '', outflow],
      ['transfer_net', '', '', '', transferNet],
      ['saldo_akhir_tercatat', '', '', '', closing],
    ].map((row) => row.map(cell).join(',')).join('\r\n');
  }
}

/// The range is [start, end); accountId null with allAccounts false is unallocated.
CashflowReport cashflowReport(
  Iterable<CashEntry> ledger, {
  required DateTime start,
  required DateTime end,
  bool allAccounts = true,
  String? accountId,
}) {
  if (!end.isAfter(start)) throw ArgumentError('Rentang tanggal tidak valid');
  var opening = 0, inflow = 0, outflow = 0, transfer = 0;
  final rows = <CashEntry>[], categories = <String, int>{};
  for (final row in ledger) {
    if (!allAccounts && row.accountId != accountId) continue;
    final date = validDate(row.date);
    if (date.isBefore(start)) {
      opening += row.amount;
      continue;
    }
    if (!date.isBefore(end)) continue;
    rows.add(row);
    categories.update(
      row.category,
      (v) => v + row.amount,
      ifAbsent: () => row.amount,
    );
    if (row.category == 'transfer') {
      transfer += row.amount;
    } else if (row.amount > 0) {
      inflow += row.amount;
    } else {
      outflow -= row.amount;
    }
  }
  rows.sort((a, b) {
    final order = validDate(a.date).compareTo(validDate(b.date));
    return order == 0 ? a.id.compareTo(b.id) : order;
  });
  return CashflowReport(
    start: start,
    end: end,
    accountId: accountId,
    allAccounts: allAccounts,
    opening: opening,
    inflow: inflow,
    outflow: outflow,
    transferNet: transfer,
    entries: List.unmodifiable(rows),
    categories: Map.unmodifiable(categories),
  );
}
