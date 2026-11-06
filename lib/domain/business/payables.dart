import 'entities.dart';

class SupplierPayable {
  final String? supplierId;
  final int purchaseCount, total, paid;
  const SupplierPayable({
    required this.supplierId,
    required this.purchaseCount,
    required this.total,
    required this.paid,
  });
  int get outstanding => total - paid;
}

/// Draft orders are not debts. Payments settle debt without changing expenses.
List<SupplierPayable> supplierPayables(
  List<Purchase> purchases,
  Map<String, int> paidByPurchase,
) {
  final groups = <String?, List<Purchase>>{};
  for (final purchase in purchases.where((p) => p.status == 'confirmed')) {
    groups.putIfAbsent(purchase.supplierId, () => []).add(purchase);
  }
  return [
    for (final group in groups.entries)
      SupplierPayable(
        supplierId: group.key,
        purchaseCount: group.value.length,
        total: group.value.fold(0, (sum, p) => sum + p.total),
        paid: group.value.fold(
          0,
          (sum, p) => sum + (paidByPurchase[p.id] ?? 0),
        ),
      ),
  ];
}
