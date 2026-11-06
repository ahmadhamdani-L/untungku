import 'money.dart';

/// Plain integer input only: never silently round or infer currency separators.
int parseIntegerInput(
  String source,
  String label, {
  int min = 0,
  int max = maxMoney,
}) {
  final input = source.trim();
  if (!RegExp(r'^-?[0-9]+$').hasMatch(input)) {
    throw ArgumentError('$label harus berupa angka bulat tanpa pemisah');
  }
  final value = int.tryParse(input);
  if (value == null || value < min || value > max) {
    throw ArgumentError('$label harus antara $min dan $max');
  }
  return value;
}

String? integerInputError(
  String? source,
  String label, {
  int min = 0,
  int max = maxMoney,
}) {
  try {
    parseIntegerInput(source ?? '', label, min: min, max: max);
    return null;
  } on ArgumentError catch (e) {
    return e.message.toString();
  }
}

String? requiredInputError(
  String? value, {
  String label = 'Isian',
  int maxLength = 2000,
}) {
  if (value == null || value.trim().isEmpty) return '$label wajib diisi';
  if (value.length > maxLength) return '$label maksimal $maxLength karakter';
  return null;
}
