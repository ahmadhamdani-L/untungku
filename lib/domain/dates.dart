/// DateTime.parse normalizes invalid dates (February 31); reject those first.
DateTime validDate(String source) {
  final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})(?:T|$)').firstMatch(source);
  if (match == null) {
    throw const FormatException('Tanggal tidak valid');
  }
  final y = int.parse(match[1]!),
      m = int.parse(match[2]!),
      d = int.parse(match[3]!);
  final local = DateTime(y, m, d);
  if (local.year != y || local.month != m || local.day != d) {
    throw const FormatException('Tanggal tidak valid');
  }
  final result = DateTime.parse(source);
  if (result.year < 2020 || result.year > 2200) {
    throw const FormatException('Tanggal di luar rentang');
  }
  return result;
}
