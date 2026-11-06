import 'package:flutter_test/flutter_test.dart';
import 'package:untungku_pro/domain/models.dart';
import 'package:untungku_pro/domain/reporting.dart';
import 'package:untungku_pro/domain/business/returns.dart';

Sale record(
  String id,
  String product,
  String name,
  int quantity, {
  bool voided = false,
}) => Sale(
  id: id,
  date: '2026-10-20',
  voided: voided,
  lines: [
    SaleLine(
      productId: product,
      name: name,
      quantity: quantity,
      price: 10,
      cost: 5,
      packaging: 0,
      extra: 0,
    ),
  ],
);
void main() {
  test('renamed products share one stable ranking entry', () {
    expect(
      bestSellerCounts([
        record('s1', 'p', 'Old name', 2),
        record('s2', 'p', 'New name', 3),
      ]),
      {'p': 5},
    );
  });
  test(
    'partial returns reduce ranking units without changing original sale lines',
    () {
      final original = record('s', 'p', 'Kopi', 3);
      final adjusted = Sale.fromJson(
        original.toJson(),
        adjustments: [
          const ReturnAdjustment(
            id: 'return',
            saleId: 's',
            date: '2026-10-21',
            reason: 'Rusak',
            quantities: {0: 2},
            restocked: {},
            revenueReduction: 20,
            restoredCost: 0,
            recoveredFees: 0,
            refundEntitlement: 20,
          ),
        ],
      );
      expect(bestSellerCounts([adjusted]), {'p': 1});
      expect(adjusted.lines.single.quantity, 3);
    },
  );
  test('same names stay separate and voids are excluded', () {
    expect(
      bestSellerCounts([
        record('s1', 'p1', 'Kopi', 2),
        record('s2', 'p2', 'Kopi', 3),
        record('s3', 'p1', 'Kopi', 9, voided: true),
      ]),
      {'p1': 2, 'p2': 3},
    );
  });
}
