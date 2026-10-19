// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ProductRowsTable extends ProductRows
    with TableInfo<$ProductRowsTable, ProductRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, payload];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'product_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProductRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProductRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
    );
  }

  @override
  $ProductRowsTable createAlias(String alias) {
    return $ProductRowsTable(attachedDatabase, alias);
  }
}

class ProductRow extends DataClass implements Insertable<ProductRow> {
  final String id;
  final String payload;
  const ProductRow({required this.id, required this.payload});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['payload'] = Variable<String>(payload);
    return map;
  }

  ProductRowsCompanion toCompanion(bool nullToAbsent) {
    return ProductRowsCompanion(id: Value(id), payload: Value(payload));
  }

  factory ProductRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductRow(
      id: serializer.fromJson<String>(json['id']),
      payload: serializer.fromJson<String>(json['payload']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'payload': serializer.toJson<String>(payload),
    };
  }

  ProductRow copyWith({String? id, String? payload}) =>
      ProductRow(id: id ?? this.id, payload: payload ?? this.payload);
  ProductRow copyWithCompanion(ProductRowsCompanion data) {
    return ProductRow(
      id: data.id.present ? data.id.value : this.id,
      payload: data.payload.present ? data.payload.value : this.payload,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductRow(')
          ..write('id: $id, ')
          ..write('payload: $payload')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, payload);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductRow &&
          other.id == this.id &&
          other.payload == this.payload);
}

class ProductRowsCompanion extends UpdateCompanion<ProductRow> {
  final Value<String> id;
  final Value<String> payload;
  final Value<int> rowid;
  const ProductRowsCompanion({
    this.id = const Value.absent(),
    this.payload = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductRowsCompanion.insert({
    required String id,
    required String payload,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       payload = Value(payload);
  static Insertable<ProductRow> custom({
    Expression<String>? id,
    Expression<String>? payload,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (payload != null) 'payload': payload,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? payload,
    Value<int>? rowid,
  }) {
    return ProductRowsCompanion(
      id: id ?? this.id,
      payload: payload ?? this.payload,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductRowsCompanion(')
          ..write('id: $id, ')
          ..write('payload: $payload, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SaleRowsTable extends SaleRows with TableInfo<$SaleRowsTable, SaleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SaleRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, payload];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sale_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<SaleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SaleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SaleRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
    );
  }

  @override
  $SaleRowsTable createAlias(String alias) {
    return $SaleRowsTable(attachedDatabase, alias);
  }
}

class SaleRow extends DataClass implements Insertable<SaleRow> {
  final String id;
  final String payload;
  const SaleRow({required this.id, required this.payload});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['payload'] = Variable<String>(payload);
    return map;
  }

  SaleRowsCompanion toCompanion(bool nullToAbsent) {
    return SaleRowsCompanion(id: Value(id), payload: Value(payload));
  }

  factory SaleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SaleRow(
      id: serializer.fromJson<String>(json['id']),
      payload: serializer.fromJson<String>(json['payload']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'payload': serializer.toJson<String>(payload),
    };
  }

  SaleRow copyWith({String? id, String? payload}) =>
      SaleRow(id: id ?? this.id, payload: payload ?? this.payload);
  SaleRow copyWithCompanion(SaleRowsCompanion data) {
    return SaleRow(
      id: data.id.present ? data.id.value : this.id,
      payload: data.payload.present ? data.payload.value : this.payload,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SaleRow(')
          ..write('id: $id, ')
          ..write('payload: $payload')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, payload);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SaleRow &&
          other.id == this.id &&
          other.payload == this.payload);
}

class SaleRowsCompanion extends UpdateCompanion<SaleRow> {
  final Value<String> id;
  final Value<String> payload;
  final Value<int> rowid;
  const SaleRowsCompanion({
    this.id = const Value.absent(),
    this.payload = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SaleRowsCompanion.insert({
    required String id,
    required String payload,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       payload = Value(payload);
  static Insertable<SaleRow> custom({
    Expression<String>? id,
    Expression<String>? payload,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (payload != null) 'payload': payload,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SaleRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? payload,
    Value<int>? rowid,
  }) {
    return SaleRowsCompanion(
      id: id ?? this.id,
      payload: payload ?? this.payload,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SaleRowsCompanion(')
          ..write('id: $id, ')
          ..write('payload: $payload, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SaleItemRowsTable extends SaleItemRows
    with TableInfo<$SaleItemRowsTable, SaleItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SaleItemRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _saleIdMeta = const VerificationMeta('saleId');
  @override
  late final GeneratedColumn<String> saleId = GeneratedColumn<String>(
    'sale_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sale_rows (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _lineIndexMeta = const VerificationMeta(
    'lineIndex',
  );
  @override
  late final GeneratedColumn<int> lineIndex = GeneratedColumn<int>(
    'line_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES product_rows (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [saleId, lineIndex, productId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sale_item_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<SaleItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sale_id')) {
      context.handle(
        _saleIdMeta,
        saleId.isAcceptableOrUnknown(data['sale_id']!, _saleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_saleIdMeta);
    }
    if (data.containsKey('line_index')) {
      context.handle(
        _lineIndexMeta,
        lineIndex.isAcceptableOrUnknown(data['line_index']!, _lineIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_lineIndexMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {saleId, lineIndex};
  @override
  SaleItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SaleItemRow(
      saleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sale_id'],
      )!,
      lineIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}line_index'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
    );
  }

  @override
  $SaleItemRowsTable createAlias(String alias) {
    return $SaleItemRowsTable(attachedDatabase, alias);
  }
}

class SaleItemRow extends DataClass implements Insertable<SaleItemRow> {
  final String saleId;
  final int lineIndex;
  final String productId;
  const SaleItemRow({
    required this.saleId,
    required this.lineIndex,
    required this.productId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sale_id'] = Variable<String>(saleId);
    map['line_index'] = Variable<int>(lineIndex);
    map['product_id'] = Variable<String>(productId);
    return map;
  }

  SaleItemRowsCompanion toCompanion(bool nullToAbsent) {
    return SaleItemRowsCompanion(
      saleId: Value(saleId),
      lineIndex: Value(lineIndex),
      productId: Value(productId),
    );
  }

  factory SaleItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SaleItemRow(
      saleId: serializer.fromJson<String>(json['saleId']),
      lineIndex: serializer.fromJson<int>(json['lineIndex']),
      productId: serializer.fromJson<String>(json['productId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'saleId': serializer.toJson<String>(saleId),
      'lineIndex': serializer.toJson<int>(lineIndex),
      'productId': serializer.toJson<String>(productId),
    };
  }

  SaleItemRow copyWith({String? saleId, int? lineIndex, String? productId}) =>
      SaleItemRow(
        saleId: saleId ?? this.saleId,
        lineIndex: lineIndex ?? this.lineIndex,
        productId: productId ?? this.productId,
      );
  SaleItemRow copyWithCompanion(SaleItemRowsCompanion data) {
    return SaleItemRow(
      saleId: data.saleId.present ? data.saleId.value : this.saleId,
      lineIndex: data.lineIndex.present ? data.lineIndex.value : this.lineIndex,
      productId: data.productId.present ? data.productId.value : this.productId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SaleItemRow(')
          ..write('saleId: $saleId, ')
          ..write('lineIndex: $lineIndex, ')
          ..write('productId: $productId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(saleId, lineIndex, productId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SaleItemRow &&
          other.saleId == this.saleId &&
          other.lineIndex == this.lineIndex &&
          other.productId == this.productId);
}

class SaleItemRowsCompanion extends UpdateCompanion<SaleItemRow> {
  final Value<String> saleId;
  final Value<int> lineIndex;
  final Value<String> productId;
  final Value<int> rowid;
  const SaleItemRowsCompanion({
    this.saleId = const Value.absent(),
    this.lineIndex = const Value.absent(),
    this.productId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SaleItemRowsCompanion.insert({
    required String saleId,
    required int lineIndex,
    required String productId,
    this.rowid = const Value.absent(),
  }) : saleId = Value(saleId),
       lineIndex = Value(lineIndex),
       productId = Value(productId);
  static Insertable<SaleItemRow> custom({
    Expression<String>? saleId,
    Expression<int>? lineIndex,
    Expression<String>? productId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (saleId != null) 'sale_id': saleId,
      if (lineIndex != null) 'line_index': lineIndex,
      if (productId != null) 'product_id': productId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SaleItemRowsCompanion copyWith({
    Value<String>? saleId,
    Value<int>? lineIndex,
    Value<String>? productId,
    Value<int>? rowid,
  }) {
    return SaleItemRowsCompanion(
      saleId: saleId ?? this.saleId,
      lineIndex: lineIndex ?? this.lineIndex,
      productId: productId ?? this.productId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (saleId.present) {
      map['sale_id'] = Variable<String>(saleId.value);
    }
    if (lineIndex.present) {
      map['line_index'] = Variable<int>(lineIndex.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SaleItemRowsCompanion(')
          ..write('saleId: $saleId, ')
          ..write('lineIndex: $lineIndex, ')
          ..write('productId: $productId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExpenseRowsTable extends ExpenseRows
    with TableInfo<$ExpenseRowsTable, ExpenseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpenseRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, payload];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expense_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExpenseRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExpenseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExpenseRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
    );
  }

  @override
  $ExpenseRowsTable createAlias(String alias) {
    return $ExpenseRowsTable(attachedDatabase, alias);
  }
}

class ExpenseRow extends DataClass implements Insertable<ExpenseRow> {
  final String id;
  final String payload;
  const ExpenseRow({required this.id, required this.payload});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['payload'] = Variable<String>(payload);
    return map;
  }

  ExpenseRowsCompanion toCompanion(bool nullToAbsent) {
    return ExpenseRowsCompanion(id: Value(id), payload: Value(payload));
  }

  factory ExpenseRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExpenseRow(
      id: serializer.fromJson<String>(json['id']),
      payload: serializer.fromJson<String>(json['payload']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'payload': serializer.toJson<String>(payload),
    };
  }

  ExpenseRow copyWith({String? id, String? payload}) =>
      ExpenseRow(id: id ?? this.id, payload: payload ?? this.payload);
  ExpenseRow copyWithCompanion(ExpenseRowsCompanion data) {
    return ExpenseRow(
      id: data.id.present ? data.id.value : this.id,
      payload: data.payload.present ? data.payload.value : this.payload,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseRow(')
          ..write('id: $id, ')
          ..write('payload: $payload')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, payload);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExpenseRow &&
          other.id == this.id &&
          other.payload == this.payload);
}

class ExpenseRowsCompanion extends UpdateCompanion<ExpenseRow> {
  final Value<String> id;
  final Value<String> payload;
  final Value<int> rowid;
  const ExpenseRowsCompanion({
    this.id = const Value.absent(),
    this.payload = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExpenseRowsCompanion.insert({
    required String id,
    required String payload,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       payload = Value(payload);
  static Insertable<ExpenseRow> custom({
    Expression<String>? id,
    Expression<String>? payload,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (payload != null) 'payload': payload,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExpenseRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? payload,
    Value<int>? rowid,
  }) {
    return ExpenseRowsCompanion(
      id: id ?? this.id,
      payload: payload ?? this.payload,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseRowsCompanion(')
          ..write('id: $id, ')
          ..write('payload: $payload, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MovementRowsTable extends MovementRows
    with TableInfo<$MovementRowsTable, MovementRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MovementRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES product_rows (id)',
    ),
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, productId, payload];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'movement_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<MovementRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MovementRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MovementRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
    );
  }

  @override
  $MovementRowsTable createAlias(String alias) {
    return $MovementRowsTable(attachedDatabase, alias);
  }
}

class MovementRow extends DataClass implements Insertable<MovementRow> {
  final String id;
  final String productId;
  final String payload;
  const MovementRow({
    required this.id,
    required this.productId,
    required this.payload,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['product_id'] = Variable<String>(productId);
    map['payload'] = Variable<String>(payload);
    return map;
  }

  MovementRowsCompanion toCompanion(bool nullToAbsent) {
    return MovementRowsCompanion(
      id: Value(id),
      productId: Value(productId),
      payload: Value(payload),
    );
  }

  factory MovementRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MovementRow(
      id: serializer.fromJson<String>(json['id']),
      productId: serializer.fromJson<String>(json['productId']),
      payload: serializer.fromJson<String>(json['payload']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'productId': serializer.toJson<String>(productId),
      'payload': serializer.toJson<String>(payload),
    };
  }

  MovementRow copyWith({String? id, String? productId, String? payload}) =>
      MovementRow(
        id: id ?? this.id,
        productId: productId ?? this.productId,
        payload: payload ?? this.payload,
      );
  MovementRow copyWithCompanion(MovementRowsCompanion data) {
    return MovementRow(
      id: data.id.present ? data.id.value : this.id,
      productId: data.productId.present ? data.productId.value : this.productId,
      payload: data.payload.present ? data.payload.value : this.payload,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MovementRow(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('payload: $payload')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, productId, payload);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MovementRow &&
          other.id == this.id &&
          other.productId == this.productId &&
          other.payload == this.payload);
}

class MovementRowsCompanion extends UpdateCompanion<MovementRow> {
  final Value<String> id;
  final Value<String> productId;
  final Value<String> payload;
  final Value<int> rowid;
  const MovementRowsCompanion({
    this.id = const Value.absent(),
    this.productId = const Value.absent(),
    this.payload = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MovementRowsCompanion.insert({
    required String id,
    required String productId,
    required String payload,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       productId = Value(productId),
       payload = Value(payload);
  static Insertable<MovementRow> custom({
    Expression<String>? id,
    Expression<String>? productId,
    Expression<String>? payload,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (productId != null) 'product_id': productId,
      if (payload != null) 'payload': payload,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MovementRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? productId,
    Value<String>? payload,
    Value<int>? rowid,
  }) {
    return MovementRowsCompanion(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      payload: payload ?? this.payload,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MovementRowsCompanion(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('payload: $payload, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingRowsTable extends SettingRows
    with TableInfo<$SettingRowsTable, SettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, payload];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'setting_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
    );
  }

  @override
  $SettingRowsTable createAlias(String alias) {
    return $SettingRowsTable(attachedDatabase, alias);
  }
}

class SettingRow extends DataClass implements Insertable<SettingRow> {
  final String id;
  final String payload;
  const SettingRow({required this.id, required this.payload});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['payload'] = Variable<String>(payload);
    return map;
  }

  SettingRowsCompanion toCompanion(bool nullToAbsent) {
    return SettingRowsCompanion(id: Value(id), payload: Value(payload));
  }

  factory SettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingRow(
      id: serializer.fromJson<String>(json['id']),
      payload: serializer.fromJson<String>(json['payload']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'payload': serializer.toJson<String>(payload),
    };
  }

  SettingRow copyWith({String? id, String? payload}) =>
      SettingRow(id: id ?? this.id, payload: payload ?? this.payload);
  SettingRow copyWithCompanion(SettingRowsCompanion data) {
    return SettingRow(
      id: data.id.present ? data.id.value : this.id,
      payload: data.payload.present ? data.payload.value : this.payload,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingRow(')
          ..write('id: $id, ')
          ..write('payload: $payload')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, payload);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingRow &&
          other.id == this.id &&
          other.payload == this.payload);
}

class SettingRowsCompanion extends UpdateCompanion<SettingRow> {
  final Value<String> id;
  final Value<String> payload;
  final Value<int> rowid;
  const SettingRowsCompanion({
    this.id = const Value.absent(),
    this.payload = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingRowsCompanion.insert({
    required String id,
    required String payload,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       payload = Value(payload);
  static Insertable<SettingRow> custom({
    Expression<String>? id,
    Expression<String>? payload,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (payload != null) 'payload': payload,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? payload,
    Value<int>? rowid,
  }) {
    return SettingRowsCompanion(
      id: id ?? this.id,
      payload: payload ?? this.payload,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingRowsCompanion(')
          ..write('id: $id, ')
          ..write('payload: $payload, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProductRowsTable productRows = $ProductRowsTable(this);
  late final $SaleRowsTable saleRows = $SaleRowsTable(this);
  late final $SaleItemRowsTable saleItemRows = $SaleItemRowsTable(this);
  late final $ExpenseRowsTable expenseRows = $ExpenseRowsTable(this);
  late final $MovementRowsTable movementRows = $MovementRowsTable(this);
  late final $SettingRowsTable settingRows = $SettingRowsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    productRows,
    saleRows,
    saleItemRows,
    expenseRows,
    movementRows,
    settingRows,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sale_rows',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('sale_item_rows', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$ProductRowsTableCreateCompanionBuilder =
    ProductRowsCompanion Function({
      required String id,
      required String payload,
      Value<int> rowid,
    });
typedef $$ProductRowsTableUpdateCompanionBuilder =
    ProductRowsCompanion Function({
      Value<String> id,
      Value<String> payload,
      Value<int> rowid,
    });

final class $$ProductRowsTableReferences
    extends BaseReferences<_$AppDatabase, $ProductRowsTable, ProductRow> {
  $$ProductRowsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SaleItemRowsTable, List<SaleItemRow>>
  _saleItemRowsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.saleItemRows,
    aliasName: 'product_rows__id__sale_item_rows__product_id',
  );

  $$SaleItemRowsTableProcessedTableManager get saleItemRowsRefs {
    final manager = $$SaleItemRowsTableTableManager(
      $_db,
      $_db.saleItemRows,
    ).filter((f) => f.productId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_saleItemRowsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MovementRowsTable, List<MovementRow>>
  _movementRowsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.movementRows,
    aliasName: 'product_rows__id__movement_rows__product_id',
  );

  $$MovementRowsTableProcessedTableManager get movementRowsRefs {
    final manager = $$MovementRowsTableTableManager(
      $_db,
      $_db.movementRows,
    ).filter((f) => f.productId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_movementRowsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProductRowsTableFilterComposer
    extends Composer<_$AppDatabase, $ProductRowsTable> {
  $$ProductRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> saleItemRowsRefs(
    Expression<bool> Function($$SaleItemRowsTableFilterComposer f) f,
  ) {
    final $$SaleItemRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.saleItemRows,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleItemRowsTableFilterComposer(
            $db: $db,
            $table: $db.saleItemRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> movementRowsRefs(
    Expression<bool> Function($$MovementRowsTableFilterComposer f) f,
  ) {
    final $$MovementRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.movementRows,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MovementRowsTableFilterComposer(
            $db: $db,
            $table: $db.movementRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProductRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductRowsTable> {
  $$ProductRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProductRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductRowsTable> {
  $$ProductRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  Expression<T> saleItemRowsRefs<T extends Object>(
    Expression<T> Function($$SaleItemRowsTableAnnotationComposer a) f,
  ) {
    final $$SaleItemRowsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.saleItemRows,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleItemRowsTableAnnotationComposer(
            $db: $db,
            $table: $db.saleItemRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> movementRowsRefs<T extends Object>(
    Expression<T> Function($$MovementRowsTableAnnotationComposer a) f,
  ) {
    final $$MovementRowsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.movementRows,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MovementRowsTableAnnotationComposer(
            $db: $db,
            $table: $db.movementRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProductRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductRowsTable,
          ProductRow,
          $$ProductRowsTableFilterComposer,
          $$ProductRowsTableOrderingComposer,
          $$ProductRowsTableAnnotationComposer,
          $$ProductRowsTableCreateCompanionBuilder,
          $$ProductRowsTableUpdateCompanionBuilder,
          (ProductRow, $$ProductRowsTableReferences),
          ProductRow,
          PrefetchHooks Function({bool saleItemRowsRefs, bool movementRowsRefs})
        > {
  $$ProductRowsTableTableManager(_$AppDatabase db, $ProductRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) =>
                  ProductRowsCompanion(id: id, payload: payload, rowid: rowid),
          createCompanionCallback:
              ({
                required String id,
                required String payload,
                Value<int> rowid = const Value.absent(),
              }) => ProductRowsCompanion.insert(
                id: id,
                payload: payload,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProductRowsTable, ProductRow>(table),
                  $$ProductRowsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({saleItemRowsRefs = false, movementRowsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (saleItemRowsRefs) db.saleItemRows,
                    if (movementRowsRefs) db.movementRows,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (saleItemRowsRefs)
                        await $_getPrefetchedData<
                          ProductRow,
                          $ProductRowsTable,
                          SaleItemRow
                        >(
                          currentTable: table,
                          referencedTable: $$ProductRowsTableReferences
                              ._saleItemRowsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductRowsTableReferences(
                                db,
                                table,
                                p0,
                              ).saleItemRowsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.productId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (movementRowsRefs)
                        await $_getPrefetchedData<
                          ProductRow,
                          $ProductRowsTable,
                          MovementRow
                        >(
                          currentTable: table,
                          referencedTable: $$ProductRowsTableReferences
                              ._movementRowsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductRowsTableReferences(
                                db,
                                table,
                                p0,
                              ).movementRowsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.productId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ProductRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductRowsTable,
      ProductRow,
      $$ProductRowsTableFilterComposer,
      $$ProductRowsTableOrderingComposer,
      $$ProductRowsTableAnnotationComposer,
      $$ProductRowsTableCreateCompanionBuilder,
      $$ProductRowsTableUpdateCompanionBuilder,
      (ProductRow, $$ProductRowsTableReferences),
      ProductRow,
      PrefetchHooks Function({bool saleItemRowsRefs, bool movementRowsRefs})
    >;
typedef $$SaleRowsTableCreateCompanionBuilder =
    SaleRowsCompanion Function({
      required String id,
      required String payload,
      Value<int> rowid,
    });
typedef $$SaleRowsTableUpdateCompanionBuilder =
    SaleRowsCompanion Function({
      Value<String> id,
      Value<String> payload,
      Value<int> rowid,
    });

final class $$SaleRowsTableReferences
    extends BaseReferences<_$AppDatabase, $SaleRowsTable, SaleRow> {
  $$SaleRowsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SaleItemRowsTable, List<SaleItemRow>>
  _saleItemRowsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.saleItemRows,
    aliasName: 'sale_rows__id__sale_item_rows__sale_id',
  );

  $$SaleItemRowsTableProcessedTableManager get saleItemRowsRefs {
    final manager = $$SaleItemRowsTableTableManager(
      $_db,
      $_db.saleItemRows,
    ).filter((f) => f.saleId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_saleItemRowsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SaleRowsTableFilterComposer
    extends Composer<_$AppDatabase, $SaleRowsTable> {
  $$SaleRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> saleItemRowsRefs(
    Expression<bool> Function($$SaleItemRowsTableFilterComposer f) f,
  ) {
    final $$SaleItemRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.saleItemRows,
      getReferencedColumn: (t) => t.saleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleItemRowsTableFilterComposer(
            $db: $db,
            $table: $db.saleItemRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SaleRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $SaleRowsTable> {
  $$SaleRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SaleRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SaleRowsTable> {
  $$SaleRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  Expression<T> saleItemRowsRefs<T extends Object>(
    Expression<T> Function($$SaleItemRowsTableAnnotationComposer a) f,
  ) {
    final $$SaleItemRowsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.saleItemRows,
      getReferencedColumn: (t) => t.saleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleItemRowsTableAnnotationComposer(
            $db: $db,
            $table: $db.saleItemRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SaleRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SaleRowsTable,
          SaleRow,
          $$SaleRowsTableFilterComposer,
          $$SaleRowsTableOrderingComposer,
          $$SaleRowsTableAnnotationComposer,
          $$SaleRowsTableCreateCompanionBuilder,
          $$SaleRowsTableUpdateCompanionBuilder,
          (SaleRow, $$SaleRowsTableReferences),
          SaleRow,
          PrefetchHooks Function({bool saleItemRowsRefs})
        > {
  $$SaleRowsTableTableManager(_$AppDatabase db, $SaleRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SaleRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SaleRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SaleRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SaleRowsCompanion(id: id, payload: payload, rowid: rowid),
          createCompanionCallback:
              ({
                required String id,
                required String payload,
                Value<int> rowid = const Value.absent(),
              }) => SaleRowsCompanion.insert(
                id: id,
                payload: payload,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SaleRowsTable, SaleRow>(table),
                  $$SaleRowsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({saleItemRowsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (saleItemRowsRefs) db.saleItemRows],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (saleItemRowsRefs)
                    await $_getPrefetchedData<
                      SaleRow,
                      $SaleRowsTable,
                      SaleItemRow
                    >(
                      currentTable: table,
                      referencedTable: $$SaleRowsTableReferences
                          ._saleItemRowsRefsTable(db),
                      managerFromTypedResult: (p0) => $$SaleRowsTableReferences(
                        db,
                        table,
                        p0,
                      ).saleItemRowsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.saleId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SaleRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SaleRowsTable,
      SaleRow,
      $$SaleRowsTableFilterComposer,
      $$SaleRowsTableOrderingComposer,
      $$SaleRowsTableAnnotationComposer,
      $$SaleRowsTableCreateCompanionBuilder,
      $$SaleRowsTableUpdateCompanionBuilder,
      (SaleRow, $$SaleRowsTableReferences),
      SaleRow,
      PrefetchHooks Function({bool saleItemRowsRefs})
    >;
typedef $$SaleItemRowsTableCreateCompanionBuilder =
    SaleItemRowsCompanion Function({
      required String saleId,
      required int lineIndex,
      required String productId,
      Value<int> rowid,
    });
typedef $$SaleItemRowsTableUpdateCompanionBuilder =
    SaleItemRowsCompanion Function({
      Value<String> saleId,
      Value<int> lineIndex,
      Value<String> productId,
      Value<int> rowid,
    });

final class $$SaleItemRowsTableReferences
    extends BaseReferences<_$AppDatabase, $SaleItemRowsTable, SaleItemRow> {
  $$SaleItemRowsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SaleRowsTable _saleIdTable(_$AppDatabase db) =>
      db.saleRows.createAlias('sale_item_rows__sale_id__sale_rows__id');

  $$SaleRowsTableProcessedTableManager get saleId {
    final $_column = $_itemColumn<String>('sale_id')!;

    final manager = $$SaleRowsTableTableManager(
      $_db,
      $_db.saleRows,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_saleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ProductRowsTable _productIdTable(_$AppDatabase db) => db.productRows
      .createAlias('sale_item_rows__product_id__product_rows__id');

  $$ProductRowsTableProcessedTableManager get productId {
    final $_column = $_itemColumn<String>('product_id')!;

    final manager = $$ProductRowsTableTableManager(
      $_db,
      $_db.productRows,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SaleItemRowsTableFilterComposer
    extends Composer<_$AppDatabase, $SaleItemRowsTable> {
  $$SaleItemRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get lineIndex => $composableBuilder(
    column: $table.lineIndex,
    builder: (column) => ColumnFilters(column),
  );

  $$SaleRowsTableFilterComposer get saleId {
    final $$SaleRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.saleId,
      referencedTable: $db.saleRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleRowsTableFilterComposer(
            $db: $db,
            $table: $db.saleRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductRowsTableFilterComposer get productId {
    final $$ProductRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.productRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductRowsTableFilterComposer(
            $db: $db,
            $table: $db.productRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SaleItemRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $SaleItemRowsTable> {
  $$SaleItemRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get lineIndex => $composableBuilder(
    column: $table.lineIndex,
    builder: (column) => ColumnOrderings(column),
  );

  $$SaleRowsTableOrderingComposer get saleId {
    final $$SaleRowsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.saleId,
      referencedTable: $db.saleRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleRowsTableOrderingComposer(
            $db: $db,
            $table: $db.saleRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductRowsTableOrderingComposer get productId {
    final $$ProductRowsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.productRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductRowsTableOrderingComposer(
            $db: $db,
            $table: $db.productRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SaleItemRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SaleItemRowsTable> {
  $$SaleItemRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get lineIndex =>
      $composableBuilder(column: $table.lineIndex, builder: (column) => column);

  $$SaleRowsTableAnnotationComposer get saleId {
    final $$SaleRowsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.saleId,
      referencedTable: $db.saleRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleRowsTableAnnotationComposer(
            $db: $db,
            $table: $db.saleRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductRowsTableAnnotationComposer get productId {
    final $$ProductRowsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.productRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductRowsTableAnnotationComposer(
            $db: $db,
            $table: $db.productRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SaleItemRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SaleItemRowsTable,
          SaleItemRow,
          $$SaleItemRowsTableFilterComposer,
          $$SaleItemRowsTableOrderingComposer,
          $$SaleItemRowsTableAnnotationComposer,
          $$SaleItemRowsTableCreateCompanionBuilder,
          $$SaleItemRowsTableUpdateCompanionBuilder,
          (SaleItemRow, $$SaleItemRowsTableReferences),
          SaleItemRow,
          PrefetchHooks Function({bool saleId, bool productId})
        > {
  $$SaleItemRowsTableTableManager(_$AppDatabase db, $SaleItemRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SaleItemRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SaleItemRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SaleItemRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> saleId = const Value.absent(),
                Value<int> lineIndex = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SaleItemRowsCompanion(
                saleId: saleId,
                lineIndex: lineIndex,
                productId: productId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String saleId,
                required int lineIndex,
                required String productId,
                Value<int> rowid = const Value.absent(),
              }) => SaleItemRowsCompanion.insert(
                saleId: saleId,
                lineIndex: lineIndex,
                productId: productId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SaleItemRowsTable, SaleItemRow>(table),
                  $$SaleItemRowsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({saleId = false, productId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (saleId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.saleId,
                                referencedTable: $$SaleItemRowsTableReferences
                                    ._saleIdTable(db),
                                referencedColumn: $$SaleItemRowsTableReferences
                                    ._saleIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (productId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.productId,
                                referencedTable: $$SaleItemRowsTableReferences
                                    ._productIdTable(db),
                                referencedColumn: $$SaleItemRowsTableReferences
                                    ._productIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SaleItemRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SaleItemRowsTable,
      SaleItemRow,
      $$SaleItemRowsTableFilterComposer,
      $$SaleItemRowsTableOrderingComposer,
      $$SaleItemRowsTableAnnotationComposer,
      $$SaleItemRowsTableCreateCompanionBuilder,
      $$SaleItemRowsTableUpdateCompanionBuilder,
      (SaleItemRow, $$SaleItemRowsTableReferences),
      SaleItemRow,
      PrefetchHooks Function({bool saleId, bool productId})
    >;
typedef $$ExpenseRowsTableCreateCompanionBuilder =
    ExpenseRowsCompanion Function({
      required String id,
      required String payload,
      Value<int> rowid,
    });
typedef $$ExpenseRowsTableUpdateCompanionBuilder =
    ExpenseRowsCompanion Function({
      Value<String> id,
      Value<String> payload,
      Value<int> rowid,
    });

class $$ExpenseRowsTableFilterComposer
    extends Composer<_$AppDatabase, $ExpenseRowsTable> {
  $$ExpenseRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExpenseRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpenseRowsTable> {
  $$ExpenseRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExpenseRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpenseRowsTable> {
  $$ExpenseRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);
}

class $$ExpenseRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExpenseRowsTable,
          ExpenseRow,
          $$ExpenseRowsTableFilterComposer,
          $$ExpenseRowsTableOrderingComposer,
          $$ExpenseRowsTableAnnotationComposer,
          $$ExpenseRowsTableCreateCompanionBuilder,
          $$ExpenseRowsTableUpdateCompanionBuilder,
          (
            ExpenseRow,
            BaseReferences<_$AppDatabase, $ExpenseRowsTable, ExpenseRow>,
          ),
          ExpenseRow,
          PrefetchHooks Function()
        > {
  $$ExpenseRowsTableTableManager(_$AppDatabase db, $ExpenseRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpenseRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpenseRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpenseRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) =>
                  ExpenseRowsCompanion(id: id, payload: payload, rowid: rowid),
          createCompanionCallback:
              ({
                required String id,
                required String payload,
                Value<int> rowid = const Value.absent(),
              }) => ExpenseRowsCompanion.insert(
                id: id,
                payload: payload,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExpenseRowsTable, ExpenseRow>(table),
                  BaseReferences<_$AppDatabase, $ExpenseRowsTable, ExpenseRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExpenseRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExpenseRowsTable,
      ExpenseRow,
      $$ExpenseRowsTableFilterComposer,
      $$ExpenseRowsTableOrderingComposer,
      $$ExpenseRowsTableAnnotationComposer,
      $$ExpenseRowsTableCreateCompanionBuilder,
      $$ExpenseRowsTableUpdateCompanionBuilder,
      (
        ExpenseRow,
        BaseReferences<_$AppDatabase, $ExpenseRowsTable, ExpenseRow>,
      ),
      ExpenseRow,
      PrefetchHooks Function()
    >;
typedef $$MovementRowsTableCreateCompanionBuilder =
    MovementRowsCompanion Function({
      required String id,
      required String productId,
      required String payload,
      Value<int> rowid,
    });
typedef $$MovementRowsTableUpdateCompanionBuilder =
    MovementRowsCompanion Function({
      Value<String> id,
      Value<String> productId,
      Value<String> payload,
      Value<int> rowid,
    });

final class $$MovementRowsTableReferences
    extends BaseReferences<_$AppDatabase, $MovementRowsTable, MovementRow> {
  $$MovementRowsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProductRowsTable _productIdTable(_$AppDatabase db) =>
      db.productRows.createAlias('movement_rows__product_id__product_rows__id');

  $$ProductRowsTableProcessedTableManager get productId {
    final $_column = $_itemColumn<String>('product_id')!;

    final manager = $$ProductRowsTableTableManager(
      $_db,
      $_db.productRows,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MovementRowsTableFilterComposer
    extends Composer<_$AppDatabase, $MovementRowsTable> {
  $$MovementRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  $$ProductRowsTableFilterComposer get productId {
    final $$ProductRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.productRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductRowsTableFilterComposer(
            $db: $db,
            $table: $db.productRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MovementRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $MovementRowsTable> {
  $$MovementRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProductRowsTableOrderingComposer get productId {
    final $$ProductRowsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.productRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductRowsTableOrderingComposer(
            $db: $db,
            $table: $db.productRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MovementRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MovementRowsTable> {
  $$MovementRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  $$ProductRowsTableAnnotationComposer get productId {
    final $$ProductRowsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.productRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductRowsTableAnnotationComposer(
            $db: $db,
            $table: $db.productRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MovementRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MovementRowsTable,
          MovementRow,
          $$MovementRowsTableFilterComposer,
          $$MovementRowsTableOrderingComposer,
          $$MovementRowsTableAnnotationComposer,
          $$MovementRowsTableCreateCompanionBuilder,
          $$MovementRowsTableUpdateCompanionBuilder,
          (MovementRow, $$MovementRowsTableReferences),
          MovementRow,
          PrefetchHooks Function({bool productId})
        > {
  $$MovementRowsTableTableManager(_$AppDatabase db, $MovementRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MovementRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MovementRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MovementRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MovementRowsCompanion(
                id: id,
                productId: productId,
                payload: payload,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String productId,
                required String payload,
                Value<int> rowid = const Value.absent(),
              }) => MovementRowsCompanion.insert(
                id: id,
                productId: productId,
                payload: payload,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MovementRowsTable, MovementRow>(table),
                  $$MovementRowsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({productId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (productId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.productId,
                                referencedTable: $$MovementRowsTableReferences
                                    ._productIdTable(db),
                                referencedColumn: $$MovementRowsTableReferences
                                    ._productIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MovementRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MovementRowsTable,
      MovementRow,
      $$MovementRowsTableFilterComposer,
      $$MovementRowsTableOrderingComposer,
      $$MovementRowsTableAnnotationComposer,
      $$MovementRowsTableCreateCompanionBuilder,
      $$MovementRowsTableUpdateCompanionBuilder,
      (MovementRow, $$MovementRowsTableReferences),
      MovementRow,
      PrefetchHooks Function({bool productId})
    >;
typedef $$SettingRowsTableCreateCompanionBuilder =
    SettingRowsCompanion Function({
      required String id,
      required String payload,
      Value<int> rowid,
    });
typedef $$SettingRowsTableUpdateCompanionBuilder =
    SettingRowsCompanion Function({
      Value<String> id,
      Value<String> payload,
      Value<int> rowid,
    });

class $$SettingRowsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingRowsTable> {
  $$SettingRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingRowsTable> {
  $$SettingRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingRowsTable> {
  $$SettingRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);
}

class $$SettingRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingRowsTable,
          SettingRow,
          $$SettingRowsTableFilterComposer,
          $$SettingRowsTableOrderingComposer,
          $$SettingRowsTableAnnotationComposer,
          $$SettingRowsTableCreateCompanionBuilder,
          $$SettingRowsTableUpdateCompanionBuilder,
          (
            SettingRow,
            BaseReferences<_$AppDatabase, $SettingRowsTable, SettingRow>,
          ),
          SettingRow,
          PrefetchHooks Function()
        > {
  $$SettingRowsTableTableManager(_$AppDatabase db, $SettingRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) =>
                  SettingRowsCompanion(id: id, payload: payload, rowid: rowid),
          createCompanionCallback:
              ({
                required String id,
                required String payload,
                Value<int> rowid = const Value.absent(),
              }) => SettingRowsCompanion.insert(
                id: id,
                payload: payload,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingRowsTable, SettingRow>(table),
                  BaseReferences<_$AppDatabase, $SettingRowsTable, SettingRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingRowsTable,
      SettingRow,
      $$SettingRowsTableFilterComposer,
      $$SettingRowsTableOrderingComposer,
      $$SettingRowsTableAnnotationComposer,
      $$SettingRowsTableCreateCompanionBuilder,
      $$SettingRowsTableUpdateCompanionBuilder,
      (
        SettingRow,
        BaseReferences<_$AppDatabase, $SettingRowsTable, SettingRow>,
      ),
      SettingRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProductRowsTableTableManager get productRows =>
      $$ProductRowsTableTableManager(_db, _db.productRows);
  $$SaleRowsTableTableManager get saleRows =>
      $$SaleRowsTableTableManager(_db, _db.saleRows);
  $$SaleItemRowsTableTableManager get saleItemRows =>
      $$SaleItemRowsTableTableManager(_db, _db.saleItemRows);
  $$ExpenseRowsTableTableManager get expenseRows =>
      $$ExpenseRowsTableTableManager(_db, _db.expenseRows);
  $$MovementRowsTableTableManager get movementRows =>
      $$MovementRowsTableTableManager(_db, _db.movementRows);
  $$SettingRowsTableTableManager get settingRows =>
      $$SettingRowsTableTableManager(_db, _db.settingRows);
}
