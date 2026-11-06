import '../money.dart';
import '../dates.dart';

class ReturnAdjustment {
  final String id, saleId, date, reason, kind;
  final Map<int, int> quantities;
  final Set<int> restocked;
  final Map<int, String> dispositions;
  final int revenueReduction,
      restoredCost,
      recoveredFees,
      refundEntitlement,
      refunded;
  const ReturnAdjustment({
    required this.id,
    required this.saleId,
    required this.date,
    required this.reason,
    required this.quantities,
    required this.restocked,
    required this.revenueReduction,
    required this.restoredCost,
    required this.recoveredFees,
    required this.refundEntitlement,
    this.refunded = 0,
    this.kind = 'return',
    this.dispositions = const {},
  });
  factory ReturnAdjustment.fromJson(
    Map<String, dynamic> j, {
    int refunded = 0,
  }) => ReturnAdjustment(
    id: j['id'],
    saleId: j['saleId'],
    date: j['date'],
    reason: j['reason'],
    kind: j['kind'] ?? 'return',
    quantities: {
      for (final e in (j['quantities'] as Map).entries)
        int.parse(e.key): e.value,
    },
    restocked: (j['restocked'] as List).cast<int>().toSet(),
    dispositions: {
      for (final e in ((j['dispositions'] ?? {}) as Map).entries)
        int.parse(e.key): e.value as String,
    },
    revenueReduction: j['revenueReduction'],
    restoredCost: j['restoredCost'],
    recoveredFees: j['recoveredFees'],
    refundEntitlement: j['refundEntitlement'],
    refunded: refunded,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'saleId': saleId,
    'date': date,
    'reason': reason,
    'kind': kind,
    'quantities': {
      for (final e in quantities.entries) e.key.toString(): e.value,
    },
    'restocked': restocked.toList()..sort(),
    if (dispositions.isNotEmpty)
      'dispositions': {
        for (final e in dispositions.entries) e.key.toString(): e.value,
      },
    'revenueReduction': revenueReduction,
    'restoredCost': restoredCost,
    'recoveredFees': recoveredFees,
    'refundEntitlement': refundEntitlement,
  };
  void validate() {
    validDate(date);
    for (final value in [
      revenueReduction,
      restoredCost,
      recoveredFees,
      refundEntitlement,
      refunded,
    ]) {
      validMoney(value);
    }
    if (id.isEmpty ||
        saleId.isEmpty ||
        reason.trim().isEmpty ||
        !['return', 'cancellation'].contains(kind) ||
        refunded > refundEntitlement ||
        quantities.values.any((q) => q < 1) ||
        !restocked.every(quantities.containsKey) ||
        dispositions.entries.any(
          (e) =>
              !quantities.containsKey(e.key) ||
              !['resellable', 'damaged', 'non_resellable'].contains(e.value) ||
              (e.value == 'resellable') != restocked.contains(e.key),
        )) {
      throw ArgumentError('Retur tidak valid');
    }
  }

  int get refundOutstanding => refundEntitlement - refunded;
}

/// Assign each sold unit a deterministic share of discounted revenue/fees.
/// The cumulative allocation guarantees exact reconciliation at full return.
int returnedUnitShare({
  required int total,
  required int grossTotal,
  required int lineGrossBefore,
  required int unitPrice,
  required int alreadyReturned,
  required int quantity,
}) {
  if (grossTotal == 0) return 0;
  return total *
          (lineGrossBefore + unitPrice * (alreadyReturned + quantity)) ~/
          grossTotal -
      total * (lineGrossBefore + unitPrice * alreadyReturned) ~/ grossTotal;
}
