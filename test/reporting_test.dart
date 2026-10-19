import 'package:flutter_test/flutter_test.dart';
import 'package:untungku_pro/domain/models.dart';
import 'package:untungku_pro/domain/reporting.dart';

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
