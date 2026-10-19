import 'package:flutter_test/flutter_test.dart';
import 'package:untungku_pro/domain/money.dart';

void main() {
  test(
    'net contribution includes discount, quantity, packaging and fee once',
    () {
      final r = const ProfitInput(
        price: 20000,
        cost: 10000,
        packaging: 1000,
        extra: 500,
        quantity: 3,
        discount: 3000,
        fixed: 1000,
        feeBps: 500,
      ).calculate();
      expect(r.revenue, 57000);
      expect(r.cogs, 30000);
      expect(r.gross, 27000);
      expect(r.fees, 2850);
      expect(r.net, 18650);
    },
  );
  test('zero denominators are undefined', () {
    final r = const ProfitInput(price: 0, cost: 0).calculate();
    expect(r.margin, isNull);
    expect(r.markup, isNull);
  });
  test('fee rounding uses integer half up', () {
    expect(feeFor(1, 5000), 1);
    expect(feeFor(101, 5000), 51);
  });
  test('reject invalid and extreme inputs', () {
    for (final p in [
      const ProfitInput(price: -1, cost: 0),
      const ProfitInput(price: 1, cost: 0, discount: 2),
      const ProfitInput(price: 1, cost: 0, quantity: 0),
      const ProfitInput(price: 1, cost: 0, feeBps: 10000),
      const ProfitInput(price: 1000000000001, cost: 0),
      const ProfitInput(price: 1000000000000, cost: 0, quantity: 2),
    ]) {
      expect(p.calculate, throwsArgumentError);
    }
  });
  test('negative contribution supported', () {
    expect(const ProfitInput(price: 1, cost: 10).calculate().net, -9);
  });
  test('impossible target rejected', () {
    expect(
      () =>
          const ProfitInput(price: 1, cost: 1, feeBps: 1000).targetPrice(9000),
      throwsArgumentError,
    );
  });
  test('target pricing meets margin after exact fee rounding', () {
    for (final fee in [0, 1, 499, 2500, 9999]) {
      for (final margin in [0, 100, 2000]) {
        if (fee + margin >= 10000) {
          continue;
        }
        for (final q in [1, 3, 17]) {
          final input = ProfitInput(
            price: 10000,
            cost: 231,
            packaging: 7,
            extra: 3,
            quantity: q,
            discount: 5,
            fixed: 17,
            feeBps: fee,
          );
          final p = input.targetPrice(margin);
          final r = ProfitInput(
            price: p,
            cost: 231,
            packaging: 7,
            extra: 3,
            quantity: q,
            discount: 5,
            fixed: 17,
            feeBps: fee,
          ).calculate();
          expect(r.net * 10000, greaterThanOrEqualTo(r.revenue * margin));
        }
      }
    }
  });
}
