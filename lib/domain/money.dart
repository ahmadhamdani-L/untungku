/// All amounts are integer Rupiah. Percentage rates use basis points (100 = 1%).
const maxMoney = 1000000000000;
void validMoney(int value, [String name = 'Nilai']) {
  if (value < 0 || value > maxMoney) {
    throw ArgumentError('$name harus antara 0 dan $maxMoney');
  }
}

int ceilDiv(int a, int b) => (a + b - 1) ~/ b;
int feeFor(int revenue, int basisPoints) =>
    (revenue * basisPoints + 5000) ~/ 10000;

class ProfitInput {
  final int price, cost, packaging, extra, quantity, discount, fixed, feeBps;
  const ProfitInput({
    required this.price,
    required this.cost,
    this.packaging = 0,
    this.extra = 0,
    this.quantity = 1,
    this.discount = 0,
    this.fixed = 0,
    this.feeBps = 0,
  });
  ProfitResult calculate() {
    for (final value in [price, cost, packaging, extra, discount, fixed]) {
      validMoney(value);
    }
    if (quantity < 1 || quantity > 1000000) {
      throw ArgumentError('Jumlah harus 1–1.000.000');
    }
    if (feeBps < 0 || feeBps >= 10000) {
      throw ArgumentError('Biaya harus 0–99,99%');
    }
    final revenue = price * quantity - discount;
    if (revenue < 0 || price * quantity > maxMoney) {
      throw ArgumentError('Diskon melebihi penjualan atau total terlalu besar');
    }
    final cogs = cost * quantity;
    validMoney(cogs);
    validMoney((cost + packaging + extra) * quantity + fixed);
    final fees = feeFor(revenue, feeBps);
    return ProfitResult(
      revenue,
      cogs,
      revenue - cogs,
      revenue - cogs - (packaging + extra) * quantity - fixed - fees,
      fees,
    );
  }

  int priceForProfit(int targetProfit) {
    calculate();
    validMoney(targetProfit);
    final costs = (cost + packaging + extra) * quantity + fixed;
    validMoney(costs + targetProfit);
    var candidate = ceilDiv(
      ceilDiv((costs + targetProfit) * 10000, 10000 - feeBps) + discount,
      quantity,
    );
    while (true) {
      final revenue = candidate * quantity - discount;
      if (candidate > maxMoney || candidate * quantity > maxMoney) {
        throw ArgumentError('Harga target terlalu besar');
      }
      if (revenue - costs - feeFor(revenue, feeBps) >= targetProfit) {
        return candidate;
      }
      candidate++;
    }
  }

  int targetPrice(int marginBps) {
    calculate();
    if (marginBps < 0 || marginBps + feeBps >= 10000) {
      throw ArgumentError('Target margin tidak mungkin dicapai');
    }
    final costs = (cost + packaging + extra) * quantity + fixed;
    var price = ceilDiv(
      ceilDiv(costs * 10000, 10000 - feeBps - marginBps) + discount,
      quantity,
    );
    // Account for per-transaction fee rounding without double counting discounts.
    while (true) {
      final revenue = price * quantity - discount;
      final profit = revenue - costs - feeFor(revenue, feeBps);
      if (price > maxMoney || price * quantity > maxMoney) {
        throw ArgumentError('Harga target melebihi batas yang didukung');
      }
      if (profit * 10000 >= revenue * marginBps) {
        return price;
      }
      price++;
    }
  }
}

class ProfitResult {
  final int revenue, cogs, gross, net, fees;
  const ProfitResult(this.revenue, this.cogs, this.gross, this.net, this.fees);
  double? get margin => revenue == 0 ? null : net * 100 / revenue;
  double? get markup => cogs == 0 ? null : net * 100 / cogs;
}
