import '../dates.dart';
import '../money.dart';

void requiredText(String value, String field) {
  if (value.trim().isEmpty || value.length > 2000) {
    throw ArgumentError('$field wajib diisi (maksimal 2.000 karakter)');
  }
}

class Contact {
  final String id, name, phone, address, notes, created, updated;
  final bool archived;
  const Contact({
    required this.id,
    required this.name,
    required this.created,
    required this.updated,
    this.phone = '',
    this.address = '',
    this.notes = '',
    this.archived = false,
  });
  factory Contact.fromJson(Map<String, dynamic> j) => Contact(
    id: j['id'],
    name: j['name'],
    created: j['created'],
    updated: j['updated'],
    phone: j['phone'] ?? '',
    address: j['address'] ?? '',
    notes: j['notes'] ?? '',
    archived: j['archived'] ?? false,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'address': address,
    'notes': notes,
    'created': created,
    'updated': updated,
    'archived': archived,
  };
  void validate() {
    requiredText(id, 'ID');
    requiredText(name, 'Nama');
    validDate(created);
    validDate(updated);
    for (final s in [phone, address, notes]) {
      if (s.length > 4000) throw ArgumentError('Data kontak terlalu panjang');
    }
  }
}

class CashAccount {
  final String id, name, type;
  final bool archived;
  const CashAccount({
    required this.id,
    required this.name,
    this.type = 'Tunai',
    this.archived = false,
  });
  factory CashAccount.fromJson(Map<String, dynamic> j) => CashAccount(
    id: j['id'],
    name: j['name'],
    type: j['type'],
    archived: j['archived'],
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'archived': archived,
  };
  void validate() {
    requiredText(id, 'ID');
    requiredText(name, 'Nama akun');
    if (!['Tunai', 'Bank', 'QRIS', 'Lainnya'].contains(type)) {
      throw ArgumentError('Jenis akun tidak valid');
    }
  }
}

class PurchaseLine {
  final String productId, name;
  final int quantity, unitCost;
  const PurchaseLine({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.unitCost,
  });
  factory PurchaseLine.fromJson(Map<String, dynamic> j) => PurchaseLine(
    productId: j['productId'],
    name: j['name'],
    quantity: j['quantity'],
    unitCost: j['unitCost'],
  );
  Map<String, dynamic> toJson() => {
    'productId': productId,
    'name': name,
    'quantity': quantity,
    'unitCost': unitCost,
  };
  int get subtotal => quantity * unitCost;
}

class Purchase {
  final String id, date, note, status;
  final String? supplierId;
  final List<PurchaseLine> lines;
  final int discount, additional;
  const Purchase({
    required this.id,
    required this.date,
    required this.lines,
    this.supplierId,
    this.note = '',
    this.status = 'draft',
    this.discount = 0,
    this.additional = 0,
  });
  factory Purchase.fromJson(Map<String, dynamic> j) => Purchase(
    id: j['id'],
    date: j['date'],
    lines: (j['lines'] as List)
        .map((l) => PurchaseLine.fromJson(Map<String, dynamic>.from(l)))
        .toList(),
    supplierId: j['supplierId'],
    note: j['note'],
    status: j['status'],
    discount: j['discount'],
    additional: j['additional'],
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date,
    'lines': lines.map((l) => l.toJson()).toList(),
    'supplierId': supplierId,
    'note': note,
    'status': status,
    'discount': discount,
    'additional': additional,
  };
  int get subtotal => lines.fold(0, (v, l) => v + l.subtotal);
  int get total => subtotal - discount + additional;
  void validate() {
    requiredText(id, 'Nomor pembelian');
    validDate(date);
    validMoney(discount);
    validMoney(additional);
    if (lines.isEmpty ||
        !['draft', 'confirmed', 'cancelled'].contains(status)) {
      throw ArgumentError('Pembelian tidak valid');
    }
    final ids = <String>{};
    for (final l in lines) {
      requiredText(l.productId, 'Produk');
      validMoney(l.unitCost);
      if (l.quantity < 1 || l.quantity > 1000000 || !ids.add(l.productId)) {
        throw ArgumentError('Jumlah atau produk pembelian tidak valid');
      }
      validMoney(l.subtotal);
    }
    validMoney(subtotal);
    if (discount > subtotal) throw ArgumentError('Diskon melebihi pembelian');
    validMoney(total);
  }

  /// Allocate landed cost without losing a Rupiah; cumulative proportional allocation.
  int landedValue(int index) {
    if (subtotal == 0) {
      final units = lines.fold(0, (v, l) => v + l.quantity);
      final before = lines.take(index).fold(0, (v, l) => v + l.quantity);
      return total * (before + lines[index].quantity) ~/ units -
          total * before ~/ units;
    }
    final before = lines.take(index).fold(0, (v, l) => v + l.subtotal);
    return total * (before + lines[index].subtotal) ~/ subtotal -
        total * before ~/ subtotal;
  }

  int receivedValue(int index, int before, int quantity) =>
      landedValue(index) * (before + quantity) ~/ lines[index].quantity -
      landedValue(index) * before ~/ lines[index].quantity;
}

/// Negative existing stock has no positive inventory asset to carry forward.
/// New units adopt receipt cost; old sale snapshots remain untouched.
int weightedAverageCost({
  required int oldQuantity,
  required int oldCost,
  required int receivedQuantity,
  required int receivedValue,
}) {
  validMoney(oldCost);
  validMoney(receivedValue);
  if (receivedQuantity < 1) {
    throw ArgumentError('Jumlah penerimaan wajib positif');
  }
  final existing = oldQuantity > 0 ? oldQuantity : 0;
  final divisor = existing + receivedQuantity;
  return (existing * oldCost + receivedValue + divisor ~/ 2) ~/ divisor;
}

class OpnameItem {
  final String productId, expectedUpdated;
  final int expectedStock, counted;
  const OpnameItem({
    required this.productId,
    required this.expectedUpdated,
    required this.expectedStock,
    required this.counted,
  });
  factory OpnameItem.fromJson(Map<String, dynamic> j) => OpnameItem(
    productId: j['productId'],
    expectedUpdated: j['expectedUpdated'],
    expectedStock: j['expectedStock'],
    counted: j['counted'],
  );
  Map<String, dynamic> toJson() => {
    'productId': productId,
    'expectedUpdated': expectedUpdated,
    'expectedStock': expectedStock,
    'counted': counted,
  };
  int get difference => counted - expectedStock;
}
