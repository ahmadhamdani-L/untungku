import 'models.dart';

/// Stable product IDs keep renamed products together and identical names apart.
Map<String, int> bestSellerCounts(Iterable<Sale> sales) {
  final counts = <String, int>{};
  for (final sale in sales.where((s) => !s.voided)) {
    final returned = <int, int>{};
    for (final adjustment in sale.adjustments) {
      for (final entry in adjustment.quantities.entries) {
        returned.update(
          entry.key,
          (value) => value + entry.value,
          ifAbsent: () => entry.value,
        );
      }
    }
    for (var index = 0; index < sale.lines.length; index++) {
      final line = sale.lines[index];
      final quantity = line.quantity - (returned[index] ?? 0);
      if (quantity > 0) {
        counts.update(
          line.productId,
          (v) => v + quantity,
          ifAbsent: () => quantity,
        );
      }
    }
  }
  return counts;
}
