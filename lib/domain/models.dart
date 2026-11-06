import 'dates.dart';
import 'money.dart';
import 'business/returns.dart';

class Product {
  final String id, sku, name, category;
  final int cost, price, packaging, extra, stock, threshold;
  final bool archived;
  final String barcode;
  final bool favorite;
  final String created, updated;
  const Product({
    required this.id,
    required this.name,
    this.sku = '',
    this.category = '',
    required this.cost,
    required this.price,
    this.packaging = 0,
    this.extra = 0,
    this.stock = 0,
    this.threshold = 5,
    this.archived = false,
    this.barcode = '',
    this.favorite = false,
    required this.created,
    required this.updated,
  });
  factory Product.fromJson(Map<String, dynamic> j) => Product(
    id: j['id'],
    name: j['name'],
    sku: j['sku'],
    category: j['category'],
    cost: j['cost'],
    price: j['price'],
    packaging: j['packaging'],
    extra: j['extra'],
    stock: j['stock'],
    threshold: j['threshold'],
    archived: j['archived'],
    barcode: j['barcode'] ?? '',
    favorite: j['favorite'] ?? false,
    created: j['created'],
    updated: j['updated'],
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'sku': sku,
    'name': name,
    'category': category,
    'cost': cost,
    'price': price,
    'packaging': packaging,
    'extra': extra,
    'stock': stock,
    'threshold': threshold,
    'archived': archived,
    'barcode': barcode,
    'favorite': favorite,
    'created': created,
    'updated': updated,
  };
  Product copy({int? stock, bool? archived}) => Product.fromJson({
    ...toJson(),
    'stock': stock ?? this.stock,
    'archived': archived ?? this.archived,
    'updated': DateTime.now().toIso8601String(),
  });
  void validate({bool allowNegativeStock = false}) {
    if (id.isEmpty ||
        name.trim().isEmpty ||
        (stock < 0 && !allowNegativeStock) ||
        stock < -1000000000 ||
        stock > 1000000000 ||
        threshold < 0 ||
        threshold > 1000000000) {
      throw ArgumentError('Data produk tidak valid');
    }
    if (barcode != barcode.trim() ||
        barcode.length > 256 ||
        barcode.contains(RegExp(r'[\x00-\x1F\x7F]'))) {
      throw ArgumentError('Barcode tidak valid (maksimal 256 karakter)');
    }
    for (final v in [cost, price, packaging, extra]) {
      validMoney(v);
    }
    validDate(created);
    validDate(updated);
  }
}

class SaleLine {
  final String productId, name;
  final int quantity, price, cost, packaging, extra;
  const SaleLine({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
    required this.cost,
    required this.packaging,
    required this.extra,
  });
  factory SaleLine.fromJson(Map<String, dynamic> j) => SaleLine(
    productId: j['productId'],
    name: j['name'],
    quantity: j['quantity'],
    price: j['price'],
    cost: j['cost'],
    packaging: j['packaging'],
    extra: j['extra'],
  );
  Map<String, dynamic> toJson() => {
    'productId': productId,
    'name': name,
    'quantity': quantity,
    'price': price,
    'cost': cost,
    'packaging': packaging,
    'extra': extra,
  };
}

class SalePayment {
  final String id, date, method;
  final String? accountId;
  final int amount;
  const SalePayment({
    required this.id,
    required this.date,
    required this.amount,
    required this.method,
    this.accountId,
  });
  factory SalePayment.fromJson(Map<String, dynamic> j) => SalePayment(
    id: j['id'],
    date: j['date'],
    amount: j['amount'],
    method: j['method'],
    accountId: j['accountId'],
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date,
    'amount': amount,
    'method': method,
    if (accountId != null) 'accountId': accountId,
  };
}

class Sale {
  final String id, date, payment, note;
  final String customer;
  final String? dueDate;
  final String? accountId;
  final bool credit;
  final List<SalePayment> payments;
  final List<ReturnAdjustment> adjustments;
  final List<SaleLine> lines;
  final int discount, fixed, feeBps;
  final bool voided;
  const Sale({
    required this.id,
    required this.date,
    required this.lines,
    this.discount = 0,
    this.fixed = 0,
    this.feeBps = 0,
    this.payment = 'Tunai',
    this.note = '',
    this.voided = false,
    this.customer = '',
    this.dueDate,
    this.accountId,
    this.credit = false,
    this.payments = const [],
    this.adjustments = const [],
  });
  factory Sale.fromJson(
    Map<String, dynamic> j, {
    List<ReturnAdjustment> adjustments = const [],
  }) => Sale(
    adjustments: adjustments,
    id: j['id'],
    date: j['date'],
    lines: (j['lines'] as List)
        .map((e) => SaleLine.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    discount: j['discount'],
    fixed: j['fixed'],
    feeBps: j['feeBps'],
    payment: j['payment'],
    note: j['note'],
    voided: j['voided'],
    customer: j['customer'] ?? '',
    dueDate: j['dueDate'],
    accountId: j['accountId'],
    credit: j['credit'] ?? false,
    payments: (j['payments'] as List? ?? [])
        .map((e) => SalePayment.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date,
    'lines': lines.map((e) => e.toJson()).toList(),
    'discount': discount,
    'fixed': fixed,
    'feeBps': feeBps,
    'payment': payment,
    'note': note,
    'voided': voided,
    'customer': customer,
    'dueDate': dueDate,
    if (accountId != null) 'accountId': accountId,
    'credit': credit,
    'payments': payments.map((p) => p.toJson()).toList(),
  };
  int get paid => credit
      ? payments.fold(0, (v, p) => v + p.amount)
      : originalResult.revenue;
  int get outstanding =>
      voided ? 0 : (result.revenue - paid).clamp(0, maxMoney);
  int get refundOutstanding =>
      adjustments.fold<int>(0, (v, r) => v + r.refundOutstanding);
  String get paymentStatus => voided
      ? 'Dibatalkan'
      : outstanding == 0
      ? 'Lunas'
      : paid == 0
      ? 'Belum lunas'
      : 'Sebagian';
  bool overdueAt(DateTime now) =>
      outstanding > 0 &&
      dueDate != null &&
      validDate(dueDate!).isBefore(DateTime(now.year, now.month, now.day));
  void validatePayments() {
    if (credit && customer.trim().isEmpty) {
      throw ArgumentError('Nama pelanggan wajib untuk piutang');
    }
    if (dueDate != null) {
      validDate(dueDate!);
      if (dueDate!.length != 10 ||
          dueDate!.compareTo(date.substring(0, 10)) < 0) {
        throw ArgumentError('Jatuh tempo tidak boleh sebelum penjualan');
      }
    }
    final ids = <String>{};
    for (final p in payments) {
      validMoney(p.amount);
      validDate(p.date);
      if (p.amount == 0 ||
          p.id.isEmpty ||
          !ids.add(p.id) ||
          p.method.trim().isEmpty ||
          validDate(p.date).isBefore(validDate(date))) {
        throw ArgumentError('Pembayaran tidak valid');
      }
    }
    if ((!credit && payments.isNotEmpty) || paid > originalResult.revenue) {
      throw ArgumentError('Pembayaran melebihi total penjualan');
    }
  }

  ProfitResult get result {
    final original = originalResult;
    final revenue =
        original.revenue -
        adjustments.fold<int>(0, (v, r) => v + r.revenueReduction);
    final cost =
        original.cogs - adjustments.fold<int>(0, (v, r) => v + r.restoredCost);
    final recovered = adjustments.fold<int>(0, (v, r) => v + r.recoveredFees);
    return ProfitResult(
      revenue,
      cost,
      revenue - cost,
      original.net -
          (original.revenue - revenue) +
          (original.cogs - cost) +
          recovered,
      original.fees - recovered,
    );
  }

  ProfitResult get originalResult {
    if (lines.isEmpty) {
      throw ArgumentError('Tambahkan produk');
    }
    int gross = 0, cogs = 0, other = 0;
    for (final l in lines) {
      ProfitInput(
        price: l.price,
        cost: l.cost,
        quantity: l.quantity,
        packaging: l.packaging,
        extra: l.extra,
      ).calculate();
      gross += l.price * l.quantity;
      cogs += l.cost * l.quantity;
      other += (l.packaging + l.extra) * l.quantity;
    }
    validMoney(gross);
    validMoney(cogs);
    validMoney(other + fixed + cogs);
    validMoney(discount);
    validMoney(fixed);
    if (discount > gross || feeBps < 0 || feeBps >= 10000) {
      throw ArgumentError('Diskon atau persentase biaya tidak valid');
    }
    final revenue = gross - discount, fees = feeFor(revenue, feeBps);
    return ProfitResult(
      revenue,
      cogs,
      revenue - cogs,
      revenue - cogs - other - fixed - fees,
      fees,
    );
  }
}

class Expense {
  final String id, date, category, note;
  final int amount;
  const Expense({
    required this.id,
    required this.date,
    required this.category,
    required this.note,
    required this.amount,
  });
  factory Expense.fromJson(Map<String, dynamic> j) => Expense(
    id: j['id'],
    date: j['date'],
    category: j['category'],
    note: j['note'],
    amount: j['amount'],
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date,
    'category': category,
    'note': note,
    'amount': amount,
  };
}
