import 'models.dart';

/// Stable product IDs keep renamed products together and identical names apart.
Map<String, int> bestSellerCounts(Iterable<Sale> sales) {
  final counts = <String, int>{};
  for (final sale in sales.where((s) => !s.voided)) {
    for (final line in sale.lines) {
      counts.update(
        line.productId,
        (v) => v + line.quantity,
        ifAbsent: () => line.quantity,
      );
    }
  }
  return counts;
}
