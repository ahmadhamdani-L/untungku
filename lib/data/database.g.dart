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

class $CustomerRowsTable extends CustomerRows
    with TableInfo<$CustomerRowsTable, CustomerRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomerRowsTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'customer_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomerRow> instance, {
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
  CustomerRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomerRow(
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
  $CustomerRowsTable createAlias(String alias) {
    return $CustomerRowsTable(attachedDatabase, alias);
  }
}

class CustomerRow extends DataClass implements Insertable<CustomerRow> {
  final String id;
  final String payload;
  const CustomerRow({required this.id, required this.payload});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['payload'] = Variable<String>(payload);
    return map;
  }

  CustomerRowsCompanion toCompanion(bool nullToAbsent) {
    return CustomerRowsCompanion(id: Value(id), payload: Value(payload));
  }

  factory CustomerRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomerRow(
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

  CustomerRow copyWith({String? id, String? payload}) =>
      CustomerRow(id: id ?? this.id, payload: payload ?? this.payload);
  CustomerRow copyWithCompanion(CustomerRowsCompanion data) {
    return CustomerRow(
      id: data.id.present ? data.id.value : this.id,
      payload: data.payload.present ? data.payload.value : this.payload,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomerRow(')
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
      (other is CustomerRow &&
          other.id == this.id &&
          other.payload == this.payload);
}

class CustomerRowsCompanion extends UpdateCompanion<CustomerRow> {
  final Value<String> id;
  final Value<String> payload;
  final Value<int> rowid;
  const CustomerRowsCompanion({
    this.id = const Value.absent(),
    this.payload = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomerRowsCompanion.insert({
    required String id,
    required String payload,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       payload = Value(payload);
  static Insertable<CustomerRow> custom({
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

  CustomerRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? payload,
    Value<int>? rowid,
  }) {
    return CustomerRowsCompanion(
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
    return (StringBuffer('CustomerRowsCompanion(')
          ..write('id: $id, ')
          ..write('payload: $payload, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SupplierRowsTable extends SupplierRows
    with TableInfo<$SupplierRowsTable, SupplierRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SupplierRowsTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'supplier_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<SupplierRow> instance, {
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
  SupplierRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SupplierRow(
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
  $SupplierRowsTable createAlias(String alias) {
    return $SupplierRowsTable(attachedDatabase, alias);
  }
}

class SupplierRow extends DataClass implements Insertable<SupplierRow> {
  final String id;
  final String payload;
  const SupplierRow({required this.id, required this.payload});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['payload'] = Variable<String>(payload);
    return map;
  }

  SupplierRowsCompanion toCompanion(bool nullToAbsent) {
    return SupplierRowsCompanion(id: Value(id), payload: Value(payload));
  }

  factory SupplierRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SupplierRow(
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

  SupplierRow copyWith({String? id, String? payload}) =>
      SupplierRow(id: id ?? this.id, payload: payload ?? this.payload);
  SupplierRow copyWithCompanion(SupplierRowsCompanion data) {
    return SupplierRow(
      id: data.id.present ? data.id.value : this.id,
      payload: data.payload.present ? data.payload.value : this.payload,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SupplierRow(')
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
      (other is SupplierRow &&
          other.id == this.id &&
          other.payload == this.payload);
}

class SupplierRowsCompanion extends UpdateCompanion<SupplierRow> {
  final Value<String> id;
  final Value<String> payload;
  final Value<int> rowid;
  const SupplierRowsCompanion({
    this.id = const Value.absent(),
    this.payload = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SupplierRowsCompanion.insert({
    required String id,
    required String payload,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       payload = Value(payload);
  static Insertable<SupplierRow> custom({
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

  SupplierRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? payload,
    Value<int>? rowid,
  }) {
    return SupplierRowsCompanion(
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
    return (StringBuffer('SupplierRowsCompanion(')
          ..write('id: $id, ')
          ..write('payload: $payload, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CashAccountRowsTable extends CashAccountRows
    with TableInfo<$CashAccountRowsTable, CashAccountRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CashAccountRowsTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'cash_account_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<CashAccountRow> instance, {
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
  CashAccountRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CashAccountRow(
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
  $CashAccountRowsTable createAlias(String alias) {
    return $CashAccountRowsTable(attachedDatabase, alias);
  }
}

class CashAccountRow extends DataClass implements Insertable<CashAccountRow> {
  final String id;
  final String payload;
  const CashAccountRow({required this.id, required this.payload});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['payload'] = Variable<String>(payload);
    return map;
  }

  CashAccountRowsCompanion toCompanion(bool nullToAbsent) {
    return CashAccountRowsCompanion(id: Value(id), payload: Value(payload));
  }

  factory CashAccountRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CashAccountRow(
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

  CashAccountRow copyWith({String? id, String? payload}) =>
      CashAccountRow(id: id ?? this.id, payload: payload ?? this.payload);
  CashAccountRow copyWithCompanion(CashAccountRowsCompanion data) {
    return CashAccountRow(
      id: data.id.present ? data.id.value : this.id,
      payload: data.payload.present ? data.payload.value : this.payload,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CashAccountRow(')
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
      (other is CashAccountRow &&
          other.id == this.id &&
          other.payload == this.payload);
}

class CashAccountRowsCompanion extends UpdateCompanion<CashAccountRow> {
  final Value<String> id;
  final Value<String> payload;
  final Value<int> rowid;
  const CashAccountRowsCompanion({
    this.id = const Value.absent(),
    this.payload = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CashAccountRowsCompanion.insert({
    required String id,
    required String payload,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       payload = Value(payload);
  static Insertable<CashAccountRow> custom({
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

  CashAccountRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? payload,
    Value<int>? rowid,
  }) {
    return CashAccountRowsCompanion(
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
    return (StringBuffer('CashAccountRowsCompanion(')
          ..write('id: $id, ')
          ..write('payload: $payload, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OperationRowsTable extends OperationRows
    with TableInfo<$OperationRowsTable, OperationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OperationRowsTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'operation_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<OperationRow> instance, {
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
  OperationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OperationRow(
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
  $OperationRowsTable createAlias(String alias) {
    return $OperationRowsTable(attachedDatabase, alias);
  }
}

class OperationRow extends DataClass implements Insertable<OperationRow> {
  final String id;
  final String payload;
  const OperationRow({required this.id, required this.payload});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['payload'] = Variable<String>(payload);
    return map;
  }

  OperationRowsCompanion toCompanion(bool nullToAbsent) {
    return OperationRowsCompanion(id: Value(id), payload: Value(payload));
  }

  factory OperationRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OperationRow(
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

  OperationRow copyWith({String? id, String? payload}) =>
      OperationRow(id: id ?? this.id, payload: payload ?? this.payload);
  OperationRow copyWithCompanion(OperationRowsCompanion data) {
    return OperationRow(
      id: data.id.present ? data.id.value : this.id,
      payload: data.payload.present ? data.payload.value : this.payload,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OperationRow(')
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
      (other is OperationRow &&
          other.id == this.id &&
          other.payload == this.payload);
}

class OperationRowsCompanion extends UpdateCompanion<OperationRow> {
  final Value<String> id;
  final Value<String> payload;
  final Value<int> rowid;
  const OperationRowsCompanion({
    this.id = const Value.absent(),
    this.payload = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OperationRowsCompanion.insert({
    required String id,
    required String payload,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       payload = Value(payload);
  static Insertable<OperationRow> custom({
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

  OperationRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? payload,
    Value<int>? rowid,
  }) {
    return OperationRowsCompanion(
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
    return (StringBuffer('OperationRowsCompanion(')
          ..write('id: $id, ')
          ..write('payload: $payload, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PurchaseRowsTable extends PurchaseRows
    with TableInfo<$PurchaseRowsTable, PurchaseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PurchaseRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _supplierIdMeta = const VerificationMeta(
    'supplierId',
  );
  @override
  late final GeneratedColumn<String> supplierId = GeneratedColumn<String>(
    'supplier_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES supplier_rows (id)',
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
  List<GeneratedColumn> get $columns => [id, supplierId, payload];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'purchase_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<PurchaseRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('supplier_id')) {
      context.handle(
        _supplierIdMeta,
        supplierId.isAcceptableOrUnknown(data['supplier_id']!, _supplierIdMeta),
      );
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
  PurchaseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PurchaseRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      supplierId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supplier_id'],
      ),
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
    );
  }

  @override
  $PurchaseRowsTable createAlias(String alias) {
    return $PurchaseRowsTable(attachedDatabase, alias);
  }
}

class PurchaseRow extends DataClass implements Insertable<PurchaseRow> {
  final String id;
  final String? supplierId;
  final String payload;
  const PurchaseRow({required this.id, this.supplierId, required this.payload});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || supplierId != null) {
      map['supplier_id'] = Variable<String>(supplierId);
    }
    map['payload'] = Variable<String>(payload);
    return map;
  }

  PurchaseRowsCompanion toCompanion(bool nullToAbsent) {
    return PurchaseRowsCompanion(
      id: Value(id),
      supplierId: supplierId == null && nullToAbsent
          ? const Value.absent()
          : Value(supplierId),
      payload: Value(payload),
    );
  }

  factory PurchaseRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PurchaseRow(
      id: serializer.fromJson<String>(json['id']),
      supplierId: serializer.fromJson<String?>(json['supplierId']),
      payload: serializer.fromJson<String>(json['payload']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'supplierId': serializer.toJson<String?>(supplierId),
      'payload': serializer.toJson<String>(payload),
    };
  }

  PurchaseRow copyWith({
    String? id,
    Value<String?> supplierId = const Value.absent(),
    String? payload,
  }) => PurchaseRow(
    id: id ?? this.id,
    supplierId: supplierId.present ? supplierId.value : this.supplierId,
    payload: payload ?? this.payload,
  );
  PurchaseRow copyWithCompanion(PurchaseRowsCompanion data) {
    return PurchaseRow(
      id: data.id.present ? data.id.value : this.id,
      supplierId: data.supplierId.present
          ? data.supplierId.value
          : this.supplierId,
      payload: data.payload.present ? data.payload.value : this.payload,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PurchaseRow(')
          ..write('id: $id, ')
          ..write('supplierId: $supplierId, ')
          ..write('payload: $payload')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, supplierId, payload);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PurchaseRow &&
          other.id == this.id &&
          other.supplierId == this.supplierId &&
          other.payload == this.payload);
}

class PurchaseRowsCompanion extends UpdateCompanion<PurchaseRow> {
  final Value<String> id;
  final Value<String?> supplierId;
  final Value<String> payload;
  final Value<int> rowid;
  const PurchaseRowsCompanion({
    this.id = const Value.absent(),
    this.supplierId = const Value.absent(),
    this.payload = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PurchaseRowsCompanion.insert({
    required String id,
    this.supplierId = const Value.absent(),
    required String payload,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       payload = Value(payload);
  static Insertable<PurchaseRow> custom({
    Expression<String>? id,
    Expression<String>? supplierId,
    Expression<String>? payload,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (supplierId != null) 'supplier_id': supplierId,
      if (payload != null) 'payload': payload,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PurchaseRowsCompanion copyWith({
    Value<String>? id,
    Value<String?>? supplierId,
    Value<String>? payload,
    Value<int>? rowid,
  }) {
    return PurchaseRowsCompanion(
      id: id ?? this.id,
      supplierId: supplierId ?? this.supplierId,
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
    if (supplierId.present) {
      map['supplier_id'] = Variable<String>(supplierId.value);
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
    return (StringBuffer('PurchaseRowsCompanion(')
          ..write('id: $id, ')
          ..write('supplierId: $supplierId, ')
          ..write('payload: $payload, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StockReceiptRowsTable extends StockReceiptRows
    with TableInfo<$StockReceiptRowsTable, StockReceiptRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StockReceiptRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _purchaseIdMeta = const VerificationMeta(
    'purchaseId',
  );
  @override
  late final GeneratedColumn<String> purchaseId = GeneratedColumn<String>(
    'purchase_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES purchase_rows (id)',
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
  List<GeneratedColumn> get $columns => [id, purchaseId, payload];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stock_receipt_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<StockReceiptRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('purchase_id')) {
      context.handle(
        _purchaseIdMeta,
        purchaseId.isAcceptableOrUnknown(data['purchase_id']!, _purchaseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_purchaseIdMeta);
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
  StockReceiptRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StockReceiptRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      purchaseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}purchase_id'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
    );
  }

  @override
  $StockReceiptRowsTable createAlias(String alias) {
    return $StockReceiptRowsTable(attachedDatabase, alias);
  }
}

class StockReceiptRow extends DataClass implements Insertable<StockReceiptRow> {
  final String id;
  final String purchaseId;
  final String payload;
  const StockReceiptRow({
    required this.id,
    required this.purchaseId,
    required this.payload,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['purchase_id'] = Variable<String>(purchaseId);
    map['payload'] = Variable<String>(payload);
    return map;
  }

  StockReceiptRowsCompanion toCompanion(bool nullToAbsent) {
    return StockReceiptRowsCompanion(
      id: Value(id),
      purchaseId: Value(purchaseId),
      payload: Value(payload),
    );
  }

  factory StockReceiptRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StockReceiptRow(
      id: serializer.fromJson<String>(json['id']),
      purchaseId: serializer.fromJson<String>(json['purchaseId']),
      payload: serializer.fromJson<String>(json['payload']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'purchaseId': serializer.toJson<String>(purchaseId),
      'payload': serializer.toJson<String>(payload),
    };
  }

  StockReceiptRow copyWith({String? id, String? purchaseId, String? payload}) =>
      StockReceiptRow(
        id: id ?? this.id,
        purchaseId: purchaseId ?? this.purchaseId,
        payload: payload ?? this.payload,
      );
  StockReceiptRow copyWithCompanion(StockReceiptRowsCompanion data) {
    return StockReceiptRow(
      id: data.id.present ? data.id.value : this.id,
      purchaseId: data.purchaseId.present
          ? data.purchaseId.value
          : this.purchaseId,
      payload: data.payload.present ? data.payload.value : this.payload,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StockReceiptRow(')
          ..write('id: $id, ')
          ..write('purchaseId: $purchaseId, ')
          ..write('payload: $payload')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, purchaseId, payload);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StockReceiptRow &&
          other.id == this.id &&
          other.purchaseId == this.purchaseId &&
          other.payload == this.payload);
}

class StockReceiptRowsCompanion extends UpdateCompanion<StockReceiptRow> {
  final Value<String> id;
  final Value<String> purchaseId;
  final Value<String> payload;
  final Value<int> rowid;
  const StockReceiptRowsCompanion({
    this.id = const Value.absent(),
    this.purchaseId = const Value.absent(),
    this.payload = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StockReceiptRowsCompanion.insert({
    required String id,
    required String purchaseId,
    required String payload,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       purchaseId = Value(purchaseId),
       payload = Value(payload);
  static Insertable<StockReceiptRow> custom({
    Expression<String>? id,
    Expression<String>? purchaseId,
    Expression<String>? payload,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (purchaseId != null) 'purchase_id': purchaseId,
      if (payload != null) 'payload': payload,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StockReceiptRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? purchaseId,
    Value<String>? payload,
    Value<int>? rowid,
  }) {
    return StockReceiptRowsCompanion(
      id: id ?? this.id,
      purchaseId: purchaseId ?? this.purchaseId,
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
    if (purchaseId.present) {
      map['purchase_id'] = Variable<String>(purchaseId.value);
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
    return (StringBuffer('StockReceiptRowsCompanion(')
          ..write('id: $id, ')
          ..write('purchaseId: $purchaseId, ')
          ..write('payload: $payload, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PurchasePaymentRowsTable extends PurchasePaymentRows
    with TableInfo<$PurchasePaymentRowsTable, PurchasePaymentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PurchasePaymentRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _purchaseIdMeta = const VerificationMeta(
    'purchaseId',
  );
  @override
  late final GeneratedColumn<String> purchaseId = GeneratedColumn<String>(
    'purchase_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES purchase_rows (id)',
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
  List<GeneratedColumn> get $columns => [id, purchaseId, payload];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'purchase_payment_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<PurchasePaymentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('purchase_id')) {
      context.handle(
        _purchaseIdMeta,
        purchaseId.isAcceptableOrUnknown(data['purchase_id']!, _purchaseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_purchaseIdMeta);
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
  PurchasePaymentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PurchasePaymentRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      purchaseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}purchase_id'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
    );
  }

  @override
  $PurchasePaymentRowsTable createAlias(String alias) {
    return $PurchasePaymentRowsTable(attachedDatabase, alias);
  }
}

class PurchasePaymentRow extends DataClass
    implements Insertable<PurchasePaymentRow> {
  final String id;
  final String purchaseId;
  final String payload;
  const PurchasePaymentRow({
    required this.id,
    required this.purchaseId,
    required this.payload,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['purchase_id'] = Variable<String>(purchaseId);
    map['payload'] = Variable<String>(payload);
    return map;
  }

  PurchasePaymentRowsCompanion toCompanion(bool nullToAbsent) {
    return PurchasePaymentRowsCompanion(
      id: Value(id),
      purchaseId: Value(purchaseId),
      payload: Value(payload),
    );
  }

  factory PurchasePaymentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PurchasePaymentRow(
      id: serializer.fromJson<String>(json['id']),
      purchaseId: serializer.fromJson<String>(json['purchaseId']),
      payload: serializer.fromJson<String>(json['payload']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'purchaseId': serializer.toJson<String>(purchaseId),
      'payload': serializer.toJson<String>(payload),
    };
  }

  PurchasePaymentRow copyWith({
    String? id,
    String? purchaseId,
    String? payload,
  }) => PurchasePaymentRow(
    id: id ?? this.id,
    purchaseId: purchaseId ?? this.purchaseId,
    payload: payload ?? this.payload,
  );
  PurchasePaymentRow copyWithCompanion(PurchasePaymentRowsCompanion data) {
    return PurchasePaymentRow(
      id: data.id.present ? data.id.value : this.id,
      purchaseId: data.purchaseId.present
          ? data.purchaseId.value
          : this.purchaseId,
      payload: data.payload.present ? data.payload.value : this.payload,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PurchasePaymentRow(')
          ..write('id: $id, ')
          ..write('purchaseId: $purchaseId, ')
          ..write('payload: $payload')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, purchaseId, payload);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PurchasePaymentRow &&
          other.id == this.id &&
          other.purchaseId == this.purchaseId &&
          other.payload == this.payload);
}

class PurchasePaymentRowsCompanion extends UpdateCompanion<PurchasePaymentRow> {
  final Value<String> id;
  final Value<String> purchaseId;
  final Value<String> payload;
  final Value<int> rowid;
  const PurchasePaymentRowsCompanion({
    this.id = const Value.absent(),
    this.purchaseId = const Value.absent(),
    this.payload = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PurchasePaymentRowsCompanion.insert({
    required String id,
    required String purchaseId,
    required String payload,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       purchaseId = Value(purchaseId),
       payload = Value(payload);
  static Insertable<PurchasePaymentRow> custom({
    Expression<String>? id,
    Expression<String>? purchaseId,
    Expression<String>? payload,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (purchaseId != null) 'purchase_id': purchaseId,
      if (payload != null) 'payload': payload,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PurchasePaymentRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? purchaseId,
    Value<String>? payload,
    Value<int>? rowid,
  }) {
    return PurchasePaymentRowsCompanion(
      id: id ?? this.id,
      purchaseId: purchaseId ?? this.purchaseId,
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
    if (purchaseId.present) {
      map['purchase_id'] = Variable<String>(purchaseId.value);
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
    return (StringBuffer('PurchasePaymentRowsCompanion(')
          ..write('id: $id, ')
          ..write('purchaseId: $purchaseId, ')
          ..write('payload: $payload, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SaleCustomerRowsTable extends SaleCustomerRows
    with TableInfo<$SaleCustomerRowsTable, SaleCustomerRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SaleCustomerRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _saleIdMeta = const VerificationMeta('saleId');
  @override
  late final GeneratedColumn<String> saleId = GeneratedColumn<String>(
    'sale_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sale_rows (id)',
    ),
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES customer_rows (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [saleId, customerId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sale_customer_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<SaleCustomerRow> instance, {
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
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {saleId};
  @override
  SaleCustomerRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SaleCustomerRow(
      saleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sale_id'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      )!,
    );
  }

  @override
  $SaleCustomerRowsTable createAlias(String alias) {
    return $SaleCustomerRowsTable(attachedDatabase, alias);
  }
}

class SaleCustomerRow extends DataClass implements Insertable<SaleCustomerRow> {
  final String saleId;
  final String customerId;
  const SaleCustomerRow({required this.saleId, required this.customerId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sale_id'] = Variable<String>(saleId);
    map['customer_id'] = Variable<String>(customerId);
    return map;
  }

  SaleCustomerRowsCompanion toCompanion(bool nullToAbsent) {
    return SaleCustomerRowsCompanion(
      saleId: Value(saleId),
      customerId: Value(customerId),
    );
  }

  factory SaleCustomerRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SaleCustomerRow(
      saleId: serializer.fromJson<String>(json['saleId']),
      customerId: serializer.fromJson<String>(json['customerId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'saleId': serializer.toJson<String>(saleId),
      'customerId': serializer.toJson<String>(customerId),
    };
  }

  SaleCustomerRow copyWith({String? saleId, String? customerId}) =>
      SaleCustomerRow(
        saleId: saleId ?? this.saleId,
        customerId: customerId ?? this.customerId,
      );
  SaleCustomerRow copyWithCompanion(SaleCustomerRowsCompanion data) {
    return SaleCustomerRow(
      saleId: data.saleId.present ? data.saleId.value : this.saleId,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SaleCustomerRow(')
          ..write('saleId: $saleId, ')
          ..write('customerId: $customerId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(saleId, customerId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SaleCustomerRow &&
          other.saleId == this.saleId &&
          other.customerId == this.customerId);
}

class SaleCustomerRowsCompanion extends UpdateCompanion<SaleCustomerRow> {
  final Value<String> saleId;
  final Value<String> customerId;
  final Value<int> rowid;
  const SaleCustomerRowsCompanion({
    this.saleId = const Value.absent(),
    this.customerId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SaleCustomerRowsCompanion.insert({
    required String saleId,
    required String customerId,
    this.rowid = const Value.absent(),
  }) : saleId = Value(saleId),
       customerId = Value(customerId);
  static Insertable<SaleCustomerRow> custom({
    Expression<String>? saleId,
    Expression<String>? customerId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (saleId != null) 'sale_id': saleId,
      if (customerId != null) 'customer_id': customerId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SaleCustomerRowsCompanion copyWith({
    Value<String>? saleId,
    Value<String>? customerId,
    Value<int>? rowid,
  }) {
    return SaleCustomerRowsCompanion(
      saleId: saleId ?? this.saleId,
      customerId: customerId ?? this.customerId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (saleId.present) {
      map['sale_id'] = Variable<String>(saleId.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SaleCustomerRowsCompanion(')
          ..write('saleId: $saleId, ')
          ..write('customerId: $customerId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReturnRowsTable extends ReturnRows
    with TableInfo<$ReturnRowsTable, ReturnRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReturnRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _saleIdMeta = const VerificationMeta('saleId');
  @override
  late final GeneratedColumn<String> saleId = GeneratedColumn<String>(
    'sale_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sale_rows (id)',
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
  List<GeneratedColumn> get $columns => [id, saleId, payload];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'return_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReturnRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('sale_id')) {
      context.handle(
        _saleIdMeta,
        saleId.isAcceptableOrUnknown(data['sale_id']!, _saleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_saleIdMeta);
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
  ReturnRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReturnRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      saleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sale_id'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
    );
  }

  @override
  $ReturnRowsTable createAlias(String alias) {
    return $ReturnRowsTable(attachedDatabase, alias);
  }
}

class ReturnRow extends DataClass implements Insertable<ReturnRow> {
  final String id;
  final String saleId;
  final String payload;
  const ReturnRow({
    required this.id,
    required this.saleId,
    required this.payload,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['sale_id'] = Variable<String>(saleId);
    map['payload'] = Variable<String>(payload);
    return map;
  }

  ReturnRowsCompanion toCompanion(bool nullToAbsent) {
    return ReturnRowsCompanion(
      id: Value(id),
      saleId: Value(saleId),
      payload: Value(payload),
    );
  }

  factory ReturnRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReturnRow(
      id: serializer.fromJson<String>(json['id']),
      saleId: serializer.fromJson<String>(json['saleId']),
      payload: serializer.fromJson<String>(json['payload']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'saleId': serializer.toJson<String>(saleId),
      'payload': serializer.toJson<String>(payload),
    };
  }

  ReturnRow copyWith({String? id, String? saleId, String? payload}) =>
      ReturnRow(
        id: id ?? this.id,
        saleId: saleId ?? this.saleId,
        payload: payload ?? this.payload,
      );
  ReturnRow copyWithCompanion(ReturnRowsCompanion data) {
    return ReturnRow(
      id: data.id.present ? data.id.value : this.id,
      saleId: data.saleId.present ? data.saleId.value : this.saleId,
      payload: data.payload.present ? data.payload.value : this.payload,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReturnRow(')
          ..write('id: $id, ')
          ..write('saleId: $saleId, ')
          ..write('payload: $payload')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, saleId, payload);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReturnRow &&
          other.id == this.id &&
          other.saleId == this.saleId &&
          other.payload == this.payload);
}

class ReturnRowsCompanion extends UpdateCompanion<ReturnRow> {
  final Value<String> id;
  final Value<String> saleId;
  final Value<String> payload;
  final Value<int> rowid;
  const ReturnRowsCompanion({
    this.id = const Value.absent(),
    this.saleId = const Value.absent(),
    this.payload = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReturnRowsCompanion.insert({
    required String id,
    required String saleId,
    required String payload,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       saleId = Value(saleId),
       payload = Value(payload);
  static Insertable<ReturnRow> custom({
    Expression<String>? id,
    Expression<String>? saleId,
    Expression<String>? payload,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (saleId != null) 'sale_id': saleId,
      if (payload != null) 'payload': payload,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReturnRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? saleId,
    Value<String>? payload,
    Value<int>? rowid,
  }) {
    return ReturnRowsCompanion(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
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
    if (saleId.present) {
      map['sale_id'] = Variable<String>(saleId.value);
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
    return (StringBuffer('ReturnRowsCompanion(')
          ..write('id: $id, ')
          ..write('saleId: $saleId, ')
          ..write('payload: $payload, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RefundRowsTable extends RefundRows
    with TableInfo<$RefundRowsTable, RefundRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RefundRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _returnIdMeta = const VerificationMeta(
    'returnId',
  );
  @override
  late final GeneratedColumn<String> returnId = GeneratedColumn<String>(
    'return_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES return_rows (id)',
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
  List<GeneratedColumn> get $columns => [id, returnId, payload];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'refund_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<RefundRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('return_id')) {
      context.handle(
        _returnIdMeta,
        returnId.isAcceptableOrUnknown(data['return_id']!, _returnIdMeta),
      );
    } else if (isInserting) {
      context.missing(_returnIdMeta);
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
  RefundRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RefundRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      returnId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}return_id'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
    );
  }

  @override
  $RefundRowsTable createAlias(String alias) {
    return $RefundRowsTable(attachedDatabase, alias);
  }
}

class RefundRow extends DataClass implements Insertable<RefundRow> {
  final String id;
  final String returnId;
  final String payload;
  const RefundRow({
    required this.id,
    required this.returnId,
    required this.payload,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['return_id'] = Variable<String>(returnId);
    map['payload'] = Variable<String>(payload);
    return map;
  }

  RefundRowsCompanion toCompanion(bool nullToAbsent) {
    return RefundRowsCompanion(
      id: Value(id),
      returnId: Value(returnId),
      payload: Value(payload),
    );
  }

  factory RefundRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RefundRow(
      id: serializer.fromJson<String>(json['id']),
      returnId: serializer.fromJson<String>(json['returnId']),
      payload: serializer.fromJson<String>(json['payload']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'returnId': serializer.toJson<String>(returnId),
      'payload': serializer.toJson<String>(payload),
    };
  }

  RefundRow copyWith({String? id, String? returnId, String? payload}) =>
      RefundRow(
        id: id ?? this.id,
        returnId: returnId ?? this.returnId,
        payload: payload ?? this.payload,
      );
  RefundRow copyWithCompanion(RefundRowsCompanion data) {
    return RefundRow(
      id: data.id.present ? data.id.value : this.id,
      returnId: data.returnId.present ? data.returnId.value : this.returnId,
      payload: data.payload.present ? data.payload.value : this.payload,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RefundRow(')
          ..write('id: $id, ')
          ..write('returnId: $returnId, ')
          ..write('payload: $payload')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, returnId, payload);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RefundRow &&
          other.id == this.id &&
          other.returnId == this.returnId &&
          other.payload == this.payload);
}

class RefundRowsCompanion extends UpdateCompanion<RefundRow> {
  final Value<String> id;
  final Value<String> returnId;
  final Value<String> payload;
  final Value<int> rowid;
  const RefundRowsCompanion({
    this.id = const Value.absent(),
    this.returnId = const Value.absent(),
    this.payload = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RefundRowsCompanion.insert({
    required String id,
    required String returnId,
    required String payload,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       returnId = Value(returnId),
       payload = Value(payload);
  static Insertable<RefundRow> custom({
    Expression<String>? id,
    Expression<String>? returnId,
    Expression<String>? payload,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (returnId != null) 'return_id': returnId,
      if (payload != null) 'payload': payload,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RefundRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? returnId,
    Value<String>? payload,
    Value<int>? rowid,
  }) {
    return RefundRowsCompanion(
      id: id ?? this.id,
      returnId: returnId ?? this.returnId,
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
    if (returnId.present) {
      map['return_id'] = Variable<String>(returnId.value);
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
    return (StringBuffer('RefundRowsCompanion(')
          ..write('id: $id, ')
          ..write('returnId: $returnId, ')
          ..write('payload: $payload, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OpnameRowsTable extends OpnameRows
    with TableInfo<$OpnameRowsTable, OpnameRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OpnameRowsTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'opname_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<OpnameRow> instance, {
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
  OpnameRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OpnameRow(
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
  $OpnameRowsTable createAlias(String alias) {
    return $OpnameRowsTable(attachedDatabase, alias);
  }
}

class OpnameRow extends DataClass implements Insertable<OpnameRow> {
  final String id;
  final String payload;
  const OpnameRow({required this.id, required this.payload});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['payload'] = Variable<String>(payload);
    return map;
  }

  OpnameRowsCompanion toCompanion(bool nullToAbsent) {
    return OpnameRowsCompanion(id: Value(id), payload: Value(payload));
  }

  factory OpnameRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OpnameRow(
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

  OpnameRow copyWith({String? id, String? payload}) =>
      OpnameRow(id: id ?? this.id, payload: payload ?? this.payload);
  OpnameRow copyWithCompanion(OpnameRowsCompanion data) {
    return OpnameRow(
      id: data.id.present ? data.id.value : this.id,
      payload: data.payload.present ? data.payload.value : this.payload,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OpnameRow(')
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
      (other is OpnameRow &&
          other.id == this.id &&
          other.payload == this.payload);
}

class OpnameRowsCompanion extends UpdateCompanion<OpnameRow> {
  final Value<String> id;
  final Value<String> payload;
  final Value<int> rowid;
  const OpnameRowsCompanion({
    this.id = const Value.absent(),
    this.payload = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OpnameRowsCompanion.insert({
    required String id,
    required String payload,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       payload = Value(payload);
  static Insertable<OpnameRow> custom({
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

  OpnameRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? payload,
    Value<int>? rowid,
  }) {
    return OpnameRowsCompanion(
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
    return (StringBuffer('OpnameRowsCompanion(')
          ..write('id: $id, ')
          ..write('payload: $payload, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CashMovementRowsTable extends CashMovementRows
    with TableInfo<$CashMovementRowsTable, CashMovementRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CashMovementRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cash_account_rows (id)',
    ),
  );
  static const VerificationMeta _referenceMeta = const VerificationMeta(
    'reference',
  );
  @override
  late final GeneratedColumn<String> reference = GeneratedColumn<String>(
    'reference',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    accountId,
    reference,
    category,
    date,
    amount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cash_movement_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<CashMovementRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    }
    if (data.containsKey('reference')) {
      context.handle(
        _referenceMeta,
        reference.isAcceptableOrUnknown(data['reference']!, _referenceMeta),
      );
    } else if (isInserting) {
      context.missing(_referenceMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CashMovementRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CashMovementRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      ),
      reference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
    );
  }

  @override
  $CashMovementRowsTable createAlias(String alias) {
    return $CashMovementRowsTable(attachedDatabase, alias);
  }
}

class CashMovementRow extends DataClass implements Insertable<CashMovementRow> {
  final String id;
  final String? accountId;
  final String reference;
  final String category;
  final String date;
  final int amount;
  const CashMovementRow({
    required this.id,
    this.accountId,
    required this.reference,
    required this.category,
    required this.date,
    required this.amount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || accountId != null) {
      map['account_id'] = Variable<String>(accountId);
    }
    map['reference'] = Variable<String>(reference);
    map['category'] = Variable<String>(category);
    map['date'] = Variable<String>(date);
    map['amount'] = Variable<int>(amount);
    return map;
  }

  CashMovementRowsCompanion toCompanion(bool nullToAbsent) {
    return CashMovementRowsCompanion(
      id: Value(id),
      accountId: accountId == null && nullToAbsent
          ? const Value.absent()
          : Value(accountId),
      reference: Value(reference),
      category: Value(category),
      date: Value(date),
      amount: Value(amount),
    );
  }

  factory CashMovementRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CashMovementRow(
      id: serializer.fromJson<String>(json['id']),
      accountId: serializer.fromJson<String?>(json['accountId']),
      reference: serializer.fromJson<String>(json['reference']),
      category: serializer.fromJson<String>(json['category']),
      date: serializer.fromJson<String>(json['date']),
      amount: serializer.fromJson<int>(json['amount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'accountId': serializer.toJson<String?>(accountId),
      'reference': serializer.toJson<String>(reference),
      'category': serializer.toJson<String>(category),
      'date': serializer.toJson<String>(date),
      'amount': serializer.toJson<int>(amount),
    };
  }

  CashMovementRow copyWith({
    String? id,
    Value<String?> accountId = const Value.absent(),
    String? reference,
    String? category,
    String? date,
    int? amount,
  }) => CashMovementRow(
    id: id ?? this.id,
    accountId: accountId.present ? accountId.value : this.accountId,
    reference: reference ?? this.reference,
    category: category ?? this.category,
    date: date ?? this.date,
    amount: amount ?? this.amount,
  );
  CashMovementRow copyWithCompanion(CashMovementRowsCompanion data) {
    return CashMovementRow(
      id: data.id.present ? data.id.value : this.id,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      reference: data.reference.present ? data.reference.value : this.reference,
      category: data.category.present ? data.category.value : this.category,
      date: data.date.present ? data.date.value : this.date,
      amount: data.amount.present ? data.amount.value : this.amount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CashMovementRow(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('reference: $reference, ')
          ..write('category: $category, ')
          ..write('date: $date, ')
          ..write('amount: $amount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, accountId, reference, category, date, amount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CashMovementRow &&
          other.id == this.id &&
          other.accountId == this.accountId &&
          other.reference == this.reference &&
          other.category == this.category &&
          other.date == this.date &&
          other.amount == this.amount);
}

class CashMovementRowsCompanion extends UpdateCompanion<CashMovementRow> {
  final Value<String> id;
  final Value<String?> accountId;
  final Value<String> reference;
  final Value<String> category;
  final Value<String> date;
  final Value<int> amount;
  final Value<int> rowid;
  const CashMovementRowsCompanion({
    this.id = const Value.absent(),
    this.accountId = const Value.absent(),
    this.reference = const Value.absent(),
    this.category = const Value.absent(),
    this.date = const Value.absent(),
    this.amount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CashMovementRowsCompanion.insert({
    required String id,
    this.accountId = const Value.absent(),
    required String reference,
    required String category,
    required String date,
    required int amount,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       reference = Value(reference),
       category = Value(category),
       date = Value(date),
       amount = Value(amount);
  static Insertable<CashMovementRow> custom({
    Expression<String>? id,
    Expression<String>? accountId,
    Expression<String>? reference,
    Expression<String>? category,
    Expression<String>? date,
    Expression<int>? amount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accountId != null) 'account_id': accountId,
      if (reference != null) 'reference': reference,
      if (category != null) 'category': category,
      if (date != null) 'date': date,
      if (amount != null) 'amount': amount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CashMovementRowsCompanion copyWith({
    Value<String>? id,
    Value<String?>? accountId,
    Value<String>? reference,
    Value<String>? category,
    Value<String>? date,
    Value<int>? amount,
    Value<int>? rowid,
  }) {
    return CashMovementRowsCompanion(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      reference: reference ?? this.reference,
      category: category ?? this.category,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (reference.present) {
      map['reference'] = Variable<String>(reference.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CashMovementRowsCompanion(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('reference: $reference, ')
          ..write('category: $category, ')
          ..write('date: $date, ')
          ..write('amount: $amount, ')
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
  late final $CustomerRowsTable customerRows = $CustomerRowsTable(this);
  late final $SupplierRowsTable supplierRows = $SupplierRowsTable(this);
  late final $CashAccountRowsTable cashAccountRows = $CashAccountRowsTable(
    this,
  );
  late final $OperationRowsTable operationRows = $OperationRowsTable(this);
  late final $PurchaseRowsTable purchaseRows = $PurchaseRowsTable(this);
  late final $StockReceiptRowsTable stockReceiptRows = $StockReceiptRowsTable(
    this,
  );
  late final $PurchasePaymentRowsTable purchasePaymentRows =
      $PurchasePaymentRowsTable(this);
  late final $SaleCustomerRowsTable saleCustomerRows = $SaleCustomerRowsTable(
    this,
  );
  late final $ReturnRowsTable returnRows = $ReturnRowsTable(this);
  late final $RefundRowsTable refundRows = $RefundRowsTable(this);
  late final $OpnameRowsTable opnameRows = $OpnameRowsTable(this);
  late final $CashMovementRowsTable cashMovementRows = $CashMovementRowsTable(
    this,
  );
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
    customerRows,
    supplierRows,
    cashAccountRows,
    operationRows,
    purchaseRows,
    stockReceiptRows,
    purchasePaymentRows,
    saleCustomerRows,
    returnRows,
    refundRows,
    opnameRows,
    cashMovementRows,
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

  static MultiTypedResultKey<$SaleCustomerRowsTable, List<SaleCustomerRow>>
  _saleCustomerRowsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.saleCustomerRows,
    aliasName: 'sale_rows__id__sale_customer_rows__sale_id',
  );

  $$SaleCustomerRowsTableProcessedTableManager get saleCustomerRowsRefs {
    final manager = $$SaleCustomerRowsTableTableManager(
      $_db,
      $_db.saleCustomerRows,
    ).filter((f) => f.saleId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _saleCustomerRowsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ReturnRowsTable, List<ReturnRow>>
  _returnRowsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.returnRows,
    aliasName: 'sale_rows__id__return_rows__sale_id',
  );

  $$ReturnRowsTableProcessedTableManager get returnRowsRefs {
    final manager = $$ReturnRowsTableTableManager(
      $_db,
      $_db.returnRows,
    ).filter((f) => f.saleId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_returnRowsRefsTable($_db));
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

  Expression<bool> saleCustomerRowsRefs(
    Expression<bool> Function($$SaleCustomerRowsTableFilterComposer f) f,
  ) {
    final $$SaleCustomerRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.saleCustomerRows,
      getReferencedColumn: (t) => t.saleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleCustomerRowsTableFilterComposer(
            $db: $db,
            $table: $db.saleCustomerRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> returnRowsRefs(
    Expression<bool> Function($$ReturnRowsTableFilterComposer f) f,
  ) {
    final $$ReturnRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.returnRows,
      getReferencedColumn: (t) => t.saleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReturnRowsTableFilterComposer(
            $db: $db,
            $table: $db.returnRows,
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

  Expression<T> saleCustomerRowsRefs<T extends Object>(
    Expression<T> Function($$SaleCustomerRowsTableAnnotationComposer a) f,
  ) {
    final $$SaleCustomerRowsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.saleCustomerRows,
      getReferencedColumn: (t) => t.saleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleCustomerRowsTableAnnotationComposer(
            $db: $db,
            $table: $db.saleCustomerRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> returnRowsRefs<T extends Object>(
    Expression<T> Function($$ReturnRowsTableAnnotationComposer a) f,
  ) {
    final $$ReturnRowsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.returnRows,
      getReferencedColumn: (t) => t.saleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReturnRowsTableAnnotationComposer(
            $db: $db,
            $table: $db.returnRows,
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
          PrefetchHooks Function({
            bool saleItemRowsRefs,
            bool saleCustomerRowsRefs,
            bool returnRowsRefs,
          })
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
          prefetchHooksCallback:
              ({
                saleItemRowsRefs = false,
                saleCustomerRowsRefs = false,
                returnRowsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (saleItemRowsRefs) db.saleItemRows,
                    if (saleCustomerRowsRefs) db.saleCustomerRows,
                    if (returnRowsRefs) db.returnRows,
                  ],
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
                          managerFromTypedResult: (p0) =>
                              $$SaleRowsTableReferences(
                                db,
                                table,
                                p0,
                              ).saleItemRowsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.saleId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (saleCustomerRowsRefs)
                        await $_getPrefetchedData<
                          SaleRow,
                          $SaleRowsTable,
                          SaleCustomerRow
                        >(
                          currentTable: table,
                          referencedTable: $$SaleRowsTableReferences
                              ._saleCustomerRowsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SaleRowsTableReferences(
                                db,
                                table,
                                p0,
                              ).saleCustomerRowsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.saleId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (returnRowsRefs)
                        await $_getPrefetchedData<
                          SaleRow,
                          $SaleRowsTable,
                          ReturnRow
                        >(
                          currentTable: table,
                          referencedTable: $$SaleRowsTableReferences
                              ._returnRowsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SaleRowsTableReferences(
                                db,
                                table,
                                p0,
                              ).returnRowsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.saleId == item.id,
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
      PrefetchHooks Function({
        bool saleItemRowsRefs,
        bool saleCustomerRowsRefs,
        bool returnRowsRefs,
      })
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
typedef $$CustomerRowsTableCreateCompanionBuilder =
    CustomerRowsCompanion Function({
      required String id,
      required String payload,
      Value<int> rowid,
    });
typedef $$CustomerRowsTableUpdateCompanionBuilder =
    CustomerRowsCompanion Function({
      Value<String> id,
      Value<String> payload,
      Value<int> rowid,
    });

final class $$CustomerRowsTableReferences
    extends BaseReferences<_$AppDatabase, $CustomerRowsTable, CustomerRow> {
  $$CustomerRowsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SaleCustomerRowsTable, List<SaleCustomerRow>>
  _saleCustomerRowsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.saleCustomerRows,
    aliasName: 'customer_rows__id__sale_customer_rows__customer_id',
  );

  $$SaleCustomerRowsTableProcessedTableManager get saleCustomerRowsRefs {
    final manager = $$SaleCustomerRowsTableTableManager(
      $_db,
      $_db.saleCustomerRows,
    ).filter((f) => f.customerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _saleCustomerRowsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CustomerRowsTableFilterComposer
    extends Composer<_$AppDatabase, $CustomerRowsTable> {
  $$CustomerRowsTableFilterComposer({
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

  Expression<bool> saleCustomerRowsRefs(
    Expression<bool> Function($$SaleCustomerRowsTableFilterComposer f) f,
  ) {
    final $$SaleCustomerRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.saleCustomerRows,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleCustomerRowsTableFilterComposer(
            $db: $db,
            $table: $db.saleCustomerRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CustomerRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomerRowsTable> {
  $$CustomerRowsTableOrderingComposer({
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

class $$CustomerRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomerRowsTable> {
  $$CustomerRowsTableAnnotationComposer({
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

  Expression<T> saleCustomerRowsRefs<T extends Object>(
    Expression<T> Function($$SaleCustomerRowsTableAnnotationComposer a) f,
  ) {
    final $$SaleCustomerRowsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.saleCustomerRows,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleCustomerRowsTableAnnotationComposer(
            $db: $db,
            $table: $db.saleCustomerRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CustomerRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomerRowsTable,
          CustomerRow,
          $$CustomerRowsTableFilterComposer,
          $$CustomerRowsTableOrderingComposer,
          $$CustomerRowsTableAnnotationComposer,
          $$CustomerRowsTableCreateCompanionBuilder,
          $$CustomerRowsTableUpdateCompanionBuilder,
          (CustomerRow, $$CustomerRowsTableReferences),
          CustomerRow,
          PrefetchHooks Function({bool saleCustomerRowsRefs})
        > {
  $$CustomerRowsTableTableManager(_$AppDatabase db, $CustomerRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomerRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomerRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomerRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) =>
                  CustomerRowsCompanion(id: id, payload: payload, rowid: rowid),
          createCompanionCallback:
              ({
                required String id,
                required String payload,
                Value<int> rowid = const Value.absent(),
              }) => CustomerRowsCompanion.insert(
                id: id,
                payload: payload,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CustomerRowsTable, CustomerRow>(table),
                  $$CustomerRowsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({saleCustomerRowsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (saleCustomerRowsRefs) db.saleCustomerRows,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (saleCustomerRowsRefs)
                    await $_getPrefetchedData<
                      CustomerRow,
                      $CustomerRowsTable,
                      SaleCustomerRow
                    >(
                      currentTable: table,
                      referencedTable: $$CustomerRowsTableReferences
                          ._saleCustomerRowsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CustomerRowsTableReferences(
                            db,
                            table,
                            p0,
                          ).saleCustomerRowsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.customerId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CustomerRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomerRowsTable,
      CustomerRow,
      $$CustomerRowsTableFilterComposer,
      $$CustomerRowsTableOrderingComposer,
      $$CustomerRowsTableAnnotationComposer,
      $$CustomerRowsTableCreateCompanionBuilder,
      $$CustomerRowsTableUpdateCompanionBuilder,
      (CustomerRow, $$CustomerRowsTableReferences),
      CustomerRow,
      PrefetchHooks Function({bool saleCustomerRowsRefs})
    >;
typedef $$SupplierRowsTableCreateCompanionBuilder =
    SupplierRowsCompanion Function({
      required String id,
      required String payload,
      Value<int> rowid,
    });
typedef $$SupplierRowsTableUpdateCompanionBuilder =
    SupplierRowsCompanion Function({
      Value<String> id,
      Value<String> payload,
      Value<int> rowid,
    });

final class $$SupplierRowsTableReferences
    extends BaseReferences<_$AppDatabase, $SupplierRowsTable, SupplierRow> {
  $$SupplierRowsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PurchaseRowsTable, List<PurchaseRow>>
  _purchaseRowsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.purchaseRows,
    aliasName: 'supplier_rows__id__purchase_rows__supplier_id',
  );

  $$PurchaseRowsTableProcessedTableManager get purchaseRowsRefs {
    final manager = $$PurchaseRowsTableTableManager(
      $_db,
      $_db.purchaseRows,
    ).filter((f) => f.supplierId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_purchaseRowsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SupplierRowsTableFilterComposer
    extends Composer<_$AppDatabase, $SupplierRowsTable> {
  $$SupplierRowsTableFilterComposer({
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

  Expression<bool> purchaseRowsRefs(
    Expression<bool> Function($$PurchaseRowsTableFilterComposer f) f,
  ) {
    final $$PurchaseRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.purchaseRows,
      getReferencedColumn: (t) => t.supplierId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchaseRowsTableFilterComposer(
            $db: $db,
            $table: $db.purchaseRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SupplierRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $SupplierRowsTable> {
  $$SupplierRowsTableOrderingComposer({
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

class $$SupplierRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SupplierRowsTable> {
  $$SupplierRowsTableAnnotationComposer({
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

  Expression<T> purchaseRowsRefs<T extends Object>(
    Expression<T> Function($$PurchaseRowsTableAnnotationComposer a) f,
  ) {
    final $$PurchaseRowsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.purchaseRows,
      getReferencedColumn: (t) => t.supplierId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchaseRowsTableAnnotationComposer(
            $db: $db,
            $table: $db.purchaseRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SupplierRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SupplierRowsTable,
          SupplierRow,
          $$SupplierRowsTableFilterComposer,
          $$SupplierRowsTableOrderingComposer,
          $$SupplierRowsTableAnnotationComposer,
          $$SupplierRowsTableCreateCompanionBuilder,
          $$SupplierRowsTableUpdateCompanionBuilder,
          (SupplierRow, $$SupplierRowsTableReferences),
          SupplierRow,
          PrefetchHooks Function({bool purchaseRowsRefs})
        > {
  $$SupplierRowsTableTableManager(_$AppDatabase db, $SupplierRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SupplierRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SupplierRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SupplierRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) =>
                  SupplierRowsCompanion(id: id, payload: payload, rowid: rowid),
          createCompanionCallback:
              ({
                required String id,
                required String payload,
                Value<int> rowid = const Value.absent(),
              }) => SupplierRowsCompanion.insert(
                id: id,
                payload: payload,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SupplierRowsTable, SupplierRow>(table),
                  $$SupplierRowsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({purchaseRowsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (purchaseRowsRefs) db.purchaseRows],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (purchaseRowsRefs)
                    await $_getPrefetchedData<
                      SupplierRow,
                      $SupplierRowsTable,
                      PurchaseRow
                    >(
                      currentTable: table,
                      referencedTable: $$SupplierRowsTableReferences
                          ._purchaseRowsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$SupplierRowsTableReferences(
                            db,
                            table,
                            p0,
                          ).purchaseRowsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.supplierId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SupplierRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SupplierRowsTable,
      SupplierRow,
      $$SupplierRowsTableFilterComposer,
      $$SupplierRowsTableOrderingComposer,
      $$SupplierRowsTableAnnotationComposer,
      $$SupplierRowsTableCreateCompanionBuilder,
      $$SupplierRowsTableUpdateCompanionBuilder,
      (SupplierRow, $$SupplierRowsTableReferences),
      SupplierRow,
      PrefetchHooks Function({bool purchaseRowsRefs})
    >;
typedef $$CashAccountRowsTableCreateCompanionBuilder =
    CashAccountRowsCompanion Function({
      required String id,
      required String payload,
      Value<int> rowid,
    });
typedef $$CashAccountRowsTableUpdateCompanionBuilder =
    CashAccountRowsCompanion Function({
      Value<String> id,
      Value<String> payload,
      Value<int> rowid,
    });

final class $$CashAccountRowsTableReferences
    extends
        BaseReferences<_$AppDatabase, $CashAccountRowsTable, CashAccountRow> {
  $$CashAccountRowsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$CashMovementRowsTable, List<CashMovementRow>>
  _cashMovementRowsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.cashMovementRows,
    aliasName: 'cash_account_rows__id__cash_movement_rows__account_id',
  );

  $$CashMovementRowsTableProcessedTableManager get cashMovementRowsRefs {
    final manager = $$CashMovementRowsTableTableManager(
      $_db,
      $_db.cashMovementRows,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _cashMovementRowsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CashAccountRowsTableFilterComposer
    extends Composer<_$AppDatabase, $CashAccountRowsTable> {
  $$CashAccountRowsTableFilterComposer({
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

  Expression<bool> cashMovementRowsRefs(
    Expression<bool> Function($$CashMovementRowsTableFilterComposer f) f,
  ) {
    final $$CashMovementRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cashMovementRows,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CashMovementRowsTableFilterComposer(
            $db: $db,
            $table: $db.cashMovementRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CashAccountRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $CashAccountRowsTable> {
  $$CashAccountRowsTableOrderingComposer({
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

class $$CashAccountRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CashAccountRowsTable> {
  $$CashAccountRowsTableAnnotationComposer({
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

  Expression<T> cashMovementRowsRefs<T extends Object>(
    Expression<T> Function($$CashMovementRowsTableAnnotationComposer a) f,
  ) {
    final $$CashMovementRowsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cashMovementRows,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CashMovementRowsTableAnnotationComposer(
            $db: $db,
            $table: $db.cashMovementRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CashAccountRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CashAccountRowsTable,
          CashAccountRow,
          $$CashAccountRowsTableFilterComposer,
          $$CashAccountRowsTableOrderingComposer,
          $$CashAccountRowsTableAnnotationComposer,
          $$CashAccountRowsTableCreateCompanionBuilder,
          $$CashAccountRowsTableUpdateCompanionBuilder,
          (CashAccountRow, $$CashAccountRowsTableReferences),
          CashAccountRow,
          PrefetchHooks Function({bool cashMovementRowsRefs})
        > {
  $$CashAccountRowsTableTableManager(
    _$AppDatabase db,
    $CashAccountRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CashAccountRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CashAccountRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CashAccountRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CashAccountRowsCompanion(
                id: id,
                payload: payload,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String payload,
                Value<int> rowid = const Value.absent(),
              }) => CashAccountRowsCompanion.insert(
                id: id,
                payload: payload,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CashAccountRowsTable, CashAccountRow>(table),
                  $$CashAccountRowsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({cashMovementRowsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (cashMovementRowsRefs) db.cashMovementRows,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (cashMovementRowsRefs)
                    await $_getPrefetchedData<
                      CashAccountRow,
                      $CashAccountRowsTable,
                      CashMovementRow
                    >(
                      currentTable: table,
                      referencedTable: $$CashAccountRowsTableReferences
                          ._cashMovementRowsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CashAccountRowsTableReferences(
                            db,
                            table,
                            p0,
                          ).cashMovementRowsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.accountId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CashAccountRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CashAccountRowsTable,
      CashAccountRow,
      $$CashAccountRowsTableFilterComposer,
      $$CashAccountRowsTableOrderingComposer,
      $$CashAccountRowsTableAnnotationComposer,
      $$CashAccountRowsTableCreateCompanionBuilder,
      $$CashAccountRowsTableUpdateCompanionBuilder,
      (CashAccountRow, $$CashAccountRowsTableReferences),
      CashAccountRow,
      PrefetchHooks Function({bool cashMovementRowsRefs})
    >;
typedef $$OperationRowsTableCreateCompanionBuilder =
    OperationRowsCompanion Function({
      required String id,
      required String payload,
      Value<int> rowid,
    });
typedef $$OperationRowsTableUpdateCompanionBuilder =
    OperationRowsCompanion Function({
      Value<String> id,
      Value<String> payload,
      Value<int> rowid,
    });

class $$OperationRowsTableFilterComposer
    extends Composer<_$AppDatabase, $OperationRowsTable> {
  $$OperationRowsTableFilterComposer({
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

class $$OperationRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $OperationRowsTable> {
  $$OperationRowsTableOrderingComposer({
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

class $$OperationRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OperationRowsTable> {
  $$OperationRowsTableAnnotationComposer({
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

class $$OperationRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OperationRowsTable,
          OperationRow,
          $$OperationRowsTableFilterComposer,
          $$OperationRowsTableOrderingComposer,
          $$OperationRowsTableAnnotationComposer,
          $$OperationRowsTableCreateCompanionBuilder,
          $$OperationRowsTableUpdateCompanionBuilder,
          (
            OperationRow,
            BaseReferences<_$AppDatabase, $OperationRowsTable, OperationRow>,
          ),
          OperationRow,
          PrefetchHooks Function()
        > {
  $$OperationRowsTableTableManager(_$AppDatabase db, $OperationRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OperationRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OperationRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OperationRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OperationRowsCompanion(
                id: id,
                payload: payload,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String payload,
                Value<int> rowid = const Value.absent(),
              }) => OperationRowsCompanion.insert(
                id: id,
                payload: payload,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OperationRowsTable, OperationRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $OperationRowsTable,
                    OperationRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OperationRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OperationRowsTable,
      OperationRow,
      $$OperationRowsTableFilterComposer,
      $$OperationRowsTableOrderingComposer,
      $$OperationRowsTableAnnotationComposer,
      $$OperationRowsTableCreateCompanionBuilder,
      $$OperationRowsTableUpdateCompanionBuilder,
      (
        OperationRow,
        BaseReferences<_$AppDatabase, $OperationRowsTable, OperationRow>,
      ),
      OperationRow,
      PrefetchHooks Function()
    >;
typedef $$PurchaseRowsTableCreateCompanionBuilder =
    PurchaseRowsCompanion Function({
      required String id,
      Value<String?> supplierId,
      required String payload,
      Value<int> rowid,
    });
typedef $$PurchaseRowsTableUpdateCompanionBuilder =
    PurchaseRowsCompanion Function({
      Value<String> id,
      Value<String?> supplierId,
      Value<String> payload,
      Value<int> rowid,
    });

final class $$PurchaseRowsTableReferences
    extends BaseReferences<_$AppDatabase, $PurchaseRowsTable, PurchaseRow> {
  $$PurchaseRowsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SupplierRowsTable _supplierIdTable(_$AppDatabase db) => db
      .supplierRows
      .createAlias('purchase_rows__supplier_id__supplier_rows__id');

  $$SupplierRowsTableProcessedTableManager? get supplierId {
    final $_column = $_itemColumn<String>('supplier_id');
    if ($_column == null) return null;
    final manager = $$SupplierRowsTableTableManager(
      $_db,
      $_db.supplierRows,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_supplierIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$StockReceiptRowsTable, List<StockReceiptRow>>
  _stockReceiptRowsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.stockReceiptRows,
    aliasName: 'purchase_rows__id__stock_receipt_rows__purchase_id',
  );

  $$StockReceiptRowsTableProcessedTableManager get stockReceiptRowsRefs {
    final manager = $$StockReceiptRowsTableTableManager(
      $_db,
      $_db.stockReceiptRows,
    ).filter((f) => f.purchaseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _stockReceiptRowsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $PurchasePaymentRowsTable,
    List<PurchasePaymentRow>
  >
  _purchasePaymentRowsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.purchasePaymentRows,
        aliasName: 'purchase_rows__id__purchase_payment_rows__purchase_id',
      );

  $$PurchasePaymentRowsTableProcessedTableManager get purchasePaymentRowsRefs {
    final manager = $$PurchasePaymentRowsTableTableManager(
      $_db,
      $_db.purchasePaymentRows,
    ).filter((f) => f.purchaseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _purchasePaymentRowsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PurchaseRowsTableFilterComposer
    extends Composer<_$AppDatabase, $PurchaseRowsTable> {
  $$PurchaseRowsTableFilterComposer({
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

  $$SupplierRowsTableFilterComposer get supplierId {
    final $$SupplierRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supplierId,
      referencedTable: $db.supplierRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SupplierRowsTableFilterComposer(
            $db: $db,
            $table: $db.supplierRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> stockReceiptRowsRefs(
    Expression<bool> Function($$StockReceiptRowsTableFilterComposer f) f,
  ) {
    final $$StockReceiptRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stockReceiptRows,
      getReferencedColumn: (t) => t.purchaseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockReceiptRowsTableFilterComposer(
            $db: $db,
            $table: $db.stockReceiptRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> purchasePaymentRowsRefs(
    Expression<bool> Function($$PurchasePaymentRowsTableFilterComposer f) f,
  ) {
    final $$PurchasePaymentRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.purchasePaymentRows,
      getReferencedColumn: (t) => t.purchaseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchasePaymentRowsTableFilterComposer(
            $db: $db,
            $table: $db.purchasePaymentRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PurchaseRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $PurchaseRowsTable> {
  $$PurchaseRowsTableOrderingComposer({
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

  $$SupplierRowsTableOrderingComposer get supplierId {
    final $$SupplierRowsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supplierId,
      referencedTable: $db.supplierRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SupplierRowsTableOrderingComposer(
            $db: $db,
            $table: $db.supplierRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PurchaseRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PurchaseRowsTable> {
  $$PurchaseRowsTableAnnotationComposer({
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

  $$SupplierRowsTableAnnotationComposer get supplierId {
    final $$SupplierRowsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supplierId,
      referencedTable: $db.supplierRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SupplierRowsTableAnnotationComposer(
            $db: $db,
            $table: $db.supplierRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> stockReceiptRowsRefs<T extends Object>(
    Expression<T> Function($$StockReceiptRowsTableAnnotationComposer a) f,
  ) {
    final $$StockReceiptRowsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stockReceiptRows,
      getReferencedColumn: (t) => t.purchaseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockReceiptRowsTableAnnotationComposer(
            $db: $db,
            $table: $db.stockReceiptRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> purchasePaymentRowsRefs<T extends Object>(
    Expression<T> Function($$PurchasePaymentRowsTableAnnotationComposer a) f,
  ) {
    final $$PurchasePaymentRowsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.purchasePaymentRows,
          getReferencedColumn: (t) => t.purchaseId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PurchasePaymentRowsTableAnnotationComposer(
                $db: $db,
                $table: $db.purchasePaymentRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$PurchaseRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PurchaseRowsTable,
          PurchaseRow,
          $$PurchaseRowsTableFilterComposer,
          $$PurchaseRowsTableOrderingComposer,
          $$PurchaseRowsTableAnnotationComposer,
          $$PurchaseRowsTableCreateCompanionBuilder,
          $$PurchaseRowsTableUpdateCompanionBuilder,
          (PurchaseRow, $$PurchaseRowsTableReferences),
          PurchaseRow,
          PrefetchHooks Function({
            bool supplierId,
            bool stockReceiptRowsRefs,
            bool purchasePaymentRowsRefs,
          })
        > {
  $$PurchaseRowsTableTableManager(_$AppDatabase db, $PurchaseRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PurchaseRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PurchaseRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PurchaseRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> supplierId = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PurchaseRowsCompanion(
                id: id,
                supplierId: supplierId,
                payload: payload,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> supplierId = const Value.absent(),
                required String payload,
                Value<int> rowid = const Value.absent(),
              }) => PurchaseRowsCompanion.insert(
                id: id,
                supplierId: supplierId,
                payload: payload,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PurchaseRowsTable, PurchaseRow>(table),
                  $$PurchaseRowsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                supplierId = false,
                stockReceiptRowsRefs = false,
                purchasePaymentRowsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (stockReceiptRowsRefs) db.stockReceiptRows,
                    if (purchasePaymentRowsRefs) db.purchasePaymentRows,
                  ],
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
                        if (supplierId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.supplierId,
                                    referencedTable:
                                        $$PurchaseRowsTableReferences
                                            ._supplierIdTable(db),
                                    referencedColumn:
                                        $$PurchaseRowsTableReferences
                                            ._supplierIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (stockReceiptRowsRefs)
                        await $_getPrefetchedData<
                          PurchaseRow,
                          $PurchaseRowsTable,
                          StockReceiptRow
                        >(
                          currentTable: table,
                          referencedTable: $$PurchaseRowsTableReferences
                              ._stockReceiptRowsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PurchaseRowsTableReferences(
                                db,
                                table,
                                p0,
                              ).stockReceiptRowsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.purchaseId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (purchasePaymentRowsRefs)
                        await $_getPrefetchedData<
                          PurchaseRow,
                          $PurchaseRowsTable,
                          PurchasePaymentRow
                        >(
                          currentTable: table,
                          referencedTable: $$PurchaseRowsTableReferences
                              ._purchasePaymentRowsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PurchaseRowsTableReferences(
                                db,
                                table,
                                p0,
                              ).purchasePaymentRowsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.purchaseId == item.id,
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

typedef $$PurchaseRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PurchaseRowsTable,
      PurchaseRow,
      $$PurchaseRowsTableFilterComposer,
      $$PurchaseRowsTableOrderingComposer,
      $$PurchaseRowsTableAnnotationComposer,
      $$PurchaseRowsTableCreateCompanionBuilder,
      $$PurchaseRowsTableUpdateCompanionBuilder,
      (PurchaseRow, $$PurchaseRowsTableReferences),
      PurchaseRow,
      PrefetchHooks Function({
        bool supplierId,
        bool stockReceiptRowsRefs,
        bool purchasePaymentRowsRefs,
      })
    >;
typedef $$StockReceiptRowsTableCreateCompanionBuilder =
    StockReceiptRowsCompanion Function({
      required String id,
      required String purchaseId,
      required String payload,
      Value<int> rowid,
    });
typedef $$StockReceiptRowsTableUpdateCompanionBuilder =
    StockReceiptRowsCompanion Function({
      Value<String> id,
      Value<String> purchaseId,
      Value<String> payload,
      Value<int> rowid,
    });

final class $$StockReceiptRowsTableReferences
    extends
        BaseReferences<_$AppDatabase, $StockReceiptRowsTable, StockReceiptRow> {
  $$StockReceiptRowsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PurchaseRowsTable _purchaseIdTable(_$AppDatabase db) => db
      .purchaseRows
      .createAlias('stock_receipt_rows__purchase_id__purchase_rows__id');

  $$PurchaseRowsTableProcessedTableManager get purchaseId {
    final $_column = $_itemColumn<String>('purchase_id')!;

    final manager = $$PurchaseRowsTableTableManager(
      $_db,
      $_db.purchaseRows,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_purchaseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$StockReceiptRowsTableFilterComposer
    extends Composer<_$AppDatabase, $StockReceiptRowsTable> {
  $$StockReceiptRowsTableFilterComposer({
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

  $$PurchaseRowsTableFilterComposer get purchaseId {
    final $$PurchaseRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.purchaseId,
      referencedTable: $db.purchaseRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchaseRowsTableFilterComposer(
            $db: $db,
            $table: $db.purchaseRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StockReceiptRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $StockReceiptRowsTable> {
  $$StockReceiptRowsTableOrderingComposer({
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

  $$PurchaseRowsTableOrderingComposer get purchaseId {
    final $$PurchaseRowsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.purchaseId,
      referencedTable: $db.purchaseRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchaseRowsTableOrderingComposer(
            $db: $db,
            $table: $db.purchaseRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StockReceiptRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StockReceiptRowsTable> {
  $$StockReceiptRowsTableAnnotationComposer({
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

  $$PurchaseRowsTableAnnotationComposer get purchaseId {
    final $$PurchaseRowsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.purchaseId,
      referencedTable: $db.purchaseRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchaseRowsTableAnnotationComposer(
            $db: $db,
            $table: $db.purchaseRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StockReceiptRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StockReceiptRowsTable,
          StockReceiptRow,
          $$StockReceiptRowsTableFilterComposer,
          $$StockReceiptRowsTableOrderingComposer,
          $$StockReceiptRowsTableAnnotationComposer,
          $$StockReceiptRowsTableCreateCompanionBuilder,
          $$StockReceiptRowsTableUpdateCompanionBuilder,
          (StockReceiptRow, $$StockReceiptRowsTableReferences),
          StockReceiptRow,
          PrefetchHooks Function({bool purchaseId})
        > {
  $$StockReceiptRowsTableTableManager(
    _$AppDatabase db,
    $StockReceiptRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StockReceiptRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StockReceiptRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StockReceiptRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> purchaseId = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StockReceiptRowsCompanion(
                id: id,
                purchaseId: purchaseId,
                payload: payload,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String purchaseId,
                required String payload,
                Value<int> rowid = const Value.absent(),
              }) => StockReceiptRowsCompanion.insert(
                id: id,
                purchaseId: purchaseId,
                payload: payload,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$StockReceiptRowsTable, StockReceiptRow>(table),
                  $$StockReceiptRowsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({purchaseId = false}) {
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
                    if (purchaseId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.purchaseId,
                                referencedTable:
                                    $$StockReceiptRowsTableReferences
                                        ._purchaseIdTable(db),
                                referencedColumn:
                                    $$StockReceiptRowsTableReferences
                                        ._purchaseIdTable(db)
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

typedef $$StockReceiptRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StockReceiptRowsTable,
      StockReceiptRow,
      $$StockReceiptRowsTableFilterComposer,
      $$StockReceiptRowsTableOrderingComposer,
      $$StockReceiptRowsTableAnnotationComposer,
      $$StockReceiptRowsTableCreateCompanionBuilder,
      $$StockReceiptRowsTableUpdateCompanionBuilder,
      (StockReceiptRow, $$StockReceiptRowsTableReferences),
      StockReceiptRow,
      PrefetchHooks Function({bool purchaseId})
    >;
typedef $$PurchasePaymentRowsTableCreateCompanionBuilder =
    PurchasePaymentRowsCompanion Function({
      required String id,
      required String purchaseId,
      required String payload,
      Value<int> rowid,
    });
typedef $$PurchasePaymentRowsTableUpdateCompanionBuilder =
    PurchasePaymentRowsCompanion Function({
      Value<String> id,
      Value<String> purchaseId,
      Value<String> payload,
      Value<int> rowid,
    });

final class $$PurchasePaymentRowsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PurchasePaymentRowsTable,
          PurchasePaymentRow
        > {
  $$PurchasePaymentRowsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PurchaseRowsTable _purchaseIdTable(_$AppDatabase db) => db
      .purchaseRows
      .createAlias('purchase_payment_rows__purchase_id__purchase_rows__id');

  $$PurchaseRowsTableProcessedTableManager get purchaseId {
    final $_column = $_itemColumn<String>('purchase_id')!;

    final manager = $$PurchaseRowsTableTableManager(
      $_db,
      $_db.purchaseRows,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_purchaseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PurchasePaymentRowsTableFilterComposer
    extends Composer<_$AppDatabase, $PurchasePaymentRowsTable> {
  $$PurchasePaymentRowsTableFilterComposer({
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

  $$PurchaseRowsTableFilterComposer get purchaseId {
    final $$PurchaseRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.purchaseId,
      referencedTable: $db.purchaseRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchaseRowsTableFilterComposer(
            $db: $db,
            $table: $db.purchaseRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PurchasePaymentRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $PurchasePaymentRowsTable> {
  $$PurchasePaymentRowsTableOrderingComposer({
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

  $$PurchaseRowsTableOrderingComposer get purchaseId {
    final $$PurchaseRowsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.purchaseId,
      referencedTable: $db.purchaseRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchaseRowsTableOrderingComposer(
            $db: $db,
            $table: $db.purchaseRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PurchasePaymentRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PurchasePaymentRowsTable> {
  $$PurchasePaymentRowsTableAnnotationComposer({
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

  $$PurchaseRowsTableAnnotationComposer get purchaseId {
    final $$PurchaseRowsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.purchaseId,
      referencedTable: $db.purchaseRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchaseRowsTableAnnotationComposer(
            $db: $db,
            $table: $db.purchaseRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PurchasePaymentRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PurchasePaymentRowsTable,
          PurchasePaymentRow,
          $$PurchasePaymentRowsTableFilterComposer,
          $$PurchasePaymentRowsTableOrderingComposer,
          $$PurchasePaymentRowsTableAnnotationComposer,
          $$PurchasePaymentRowsTableCreateCompanionBuilder,
          $$PurchasePaymentRowsTableUpdateCompanionBuilder,
          (PurchasePaymentRow, $$PurchasePaymentRowsTableReferences),
          PurchasePaymentRow,
          PrefetchHooks Function({bool purchaseId})
        > {
  $$PurchasePaymentRowsTableTableManager(
    _$AppDatabase db,
    $PurchasePaymentRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PurchasePaymentRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PurchasePaymentRowsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PurchasePaymentRowsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> purchaseId = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PurchasePaymentRowsCompanion(
                id: id,
                purchaseId: purchaseId,
                payload: payload,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String purchaseId,
                required String payload,
                Value<int> rowid = const Value.absent(),
              }) => PurchasePaymentRowsCompanion.insert(
                id: id,
                purchaseId: purchaseId,
                payload: payload,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PurchasePaymentRowsTable, PurchasePaymentRow>(
                    table,
                  ),
                  $$PurchasePaymentRowsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({purchaseId = false}) {
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
                    if (purchaseId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.purchaseId,
                                referencedTable:
                                    $$PurchasePaymentRowsTableReferences
                                        ._purchaseIdTable(db),
                                referencedColumn:
                                    $$PurchasePaymentRowsTableReferences
                                        ._purchaseIdTable(db)
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

typedef $$PurchasePaymentRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PurchasePaymentRowsTable,
      PurchasePaymentRow,
      $$PurchasePaymentRowsTableFilterComposer,
      $$PurchasePaymentRowsTableOrderingComposer,
      $$PurchasePaymentRowsTableAnnotationComposer,
      $$PurchasePaymentRowsTableCreateCompanionBuilder,
      $$PurchasePaymentRowsTableUpdateCompanionBuilder,
      (PurchasePaymentRow, $$PurchasePaymentRowsTableReferences),
      PurchasePaymentRow,
      PrefetchHooks Function({bool purchaseId})
    >;
typedef $$SaleCustomerRowsTableCreateCompanionBuilder =
    SaleCustomerRowsCompanion Function({
      required String saleId,
      required String customerId,
      Value<int> rowid,
    });
typedef $$SaleCustomerRowsTableUpdateCompanionBuilder =
    SaleCustomerRowsCompanion Function({
      Value<String> saleId,
      Value<String> customerId,
      Value<int> rowid,
    });

final class $$SaleCustomerRowsTableReferences
    extends
        BaseReferences<_$AppDatabase, $SaleCustomerRowsTable, SaleCustomerRow> {
  $$SaleCustomerRowsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SaleRowsTable _saleIdTable(_$AppDatabase db) =>
      db.saleRows.createAlias('sale_customer_rows__sale_id__sale_rows__id');

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

  static $CustomerRowsTable _customerIdTable(_$AppDatabase db) => db
      .customerRows
      .createAlias('sale_customer_rows__customer_id__customer_rows__id');

  $$CustomerRowsTableProcessedTableManager get customerId {
    final $_column = $_itemColumn<String>('customer_id')!;

    final manager = $$CustomerRowsTableTableManager(
      $_db,
      $_db.customerRows,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_customerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SaleCustomerRowsTableFilterComposer
    extends Composer<_$AppDatabase, $SaleCustomerRowsTable> {
  $$SaleCustomerRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
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

  $$CustomerRowsTableFilterComposer get customerId {
    final $$CustomerRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customerRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomerRowsTableFilterComposer(
            $db: $db,
            $table: $db.customerRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SaleCustomerRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $SaleCustomerRowsTable> {
  $$SaleCustomerRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
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

  $$CustomerRowsTableOrderingComposer get customerId {
    final $$CustomerRowsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customerRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomerRowsTableOrderingComposer(
            $db: $db,
            $table: $db.customerRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SaleCustomerRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SaleCustomerRowsTable> {
  $$SaleCustomerRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
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

  $$CustomerRowsTableAnnotationComposer get customerId {
    final $$CustomerRowsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customerRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomerRowsTableAnnotationComposer(
            $db: $db,
            $table: $db.customerRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SaleCustomerRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SaleCustomerRowsTable,
          SaleCustomerRow,
          $$SaleCustomerRowsTableFilterComposer,
          $$SaleCustomerRowsTableOrderingComposer,
          $$SaleCustomerRowsTableAnnotationComposer,
          $$SaleCustomerRowsTableCreateCompanionBuilder,
          $$SaleCustomerRowsTableUpdateCompanionBuilder,
          (SaleCustomerRow, $$SaleCustomerRowsTableReferences),
          SaleCustomerRow,
          PrefetchHooks Function({bool saleId, bool customerId})
        > {
  $$SaleCustomerRowsTableTableManager(
    _$AppDatabase db,
    $SaleCustomerRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SaleCustomerRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SaleCustomerRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SaleCustomerRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> saleId = const Value.absent(),
                Value<String> customerId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SaleCustomerRowsCompanion(
                saleId: saleId,
                customerId: customerId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String saleId,
                required String customerId,
                Value<int> rowid = const Value.absent(),
              }) => SaleCustomerRowsCompanion.insert(
                saleId: saleId,
                customerId: customerId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SaleCustomerRowsTable, SaleCustomerRow>(table),
                  $$SaleCustomerRowsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({saleId = false, customerId = false}) {
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
                                referencedTable:
                                    $$SaleCustomerRowsTableReferences
                                        ._saleIdTable(db),
                                referencedColumn:
                                    $$SaleCustomerRowsTableReferences
                                        ._saleIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (customerId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.customerId,
                                referencedTable:
                                    $$SaleCustomerRowsTableReferences
                                        ._customerIdTable(db),
                                referencedColumn:
                                    $$SaleCustomerRowsTableReferences
                                        ._customerIdTable(db)
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

typedef $$SaleCustomerRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SaleCustomerRowsTable,
      SaleCustomerRow,
      $$SaleCustomerRowsTableFilterComposer,
      $$SaleCustomerRowsTableOrderingComposer,
      $$SaleCustomerRowsTableAnnotationComposer,
      $$SaleCustomerRowsTableCreateCompanionBuilder,
      $$SaleCustomerRowsTableUpdateCompanionBuilder,
      (SaleCustomerRow, $$SaleCustomerRowsTableReferences),
      SaleCustomerRow,
      PrefetchHooks Function({bool saleId, bool customerId})
    >;
typedef $$ReturnRowsTableCreateCompanionBuilder =
    ReturnRowsCompanion Function({
      required String id,
      required String saleId,
      required String payload,
      Value<int> rowid,
    });
typedef $$ReturnRowsTableUpdateCompanionBuilder =
    ReturnRowsCompanion Function({
      Value<String> id,
      Value<String> saleId,
      Value<String> payload,
      Value<int> rowid,
    });

final class $$ReturnRowsTableReferences
    extends BaseReferences<_$AppDatabase, $ReturnRowsTable, ReturnRow> {
  $$ReturnRowsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SaleRowsTable _saleIdTable(_$AppDatabase db) =>
      db.saleRows.createAlias('return_rows__sale_id__sale_rows__id');

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

  static MultiTypedResultKey<$RefundRowsTable, List<RefundRow>>
  _refundRowsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.refundRows,
    aliasName: 'return_rows__id__refund_rows__return_id',
  );

  $$RefundRowsTableProcessedTableManager get refundRowsRefs {
    final manager = $$RefundRowsTableTableManager(
      $_db,
      $_db.refundRows,
    ).filter((f) => f.returnId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_refundRowsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ReturnRowsTableFilterComposer
    extends Composer<_$AppDatabase, $ReturnRowsTable> {
  $$ReturnRowsTableFilterComposer({
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

  Expression<bool> refundRowsRefs(
    Expression<bool> Function($$RefundRowsTableFilterComposer f) f,
  ) {
    final $$RefundRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.refundRows,
      getReferencedColumn: (t) => t.returnId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RefundRowsTableFilterComposer(
            $db: $db,
            $table: $db.refundRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ReturnRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReturnRowsTable> {
  $$ReturnRowsTableOrderingComposer({
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
}

class $$ReturnRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReturnRowsTable> {
  $$ReturnRowsTableAnnotationComposer({
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

  Expression<T> refundRowsRefs<T extends Object>(
    Expression<T> Function($$RefundRowsTableAnnotationComposer a) f,
  ) {
    final $$RefundRowsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.refundRows,
      getReferencedColumn: (t) => t.returnId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RefundRowsTableAnnotationComposer(
            $db: $db,
            $table: $db.refundRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ReturnRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReturnRowsTable,
          ReturnRow,
          $$ReturnRowsTableFilterComposer,
          $$ReturnRowsTableOrderingComposer,
          $$ReturnRowsTableAnnotationComposer,
          $$ReturnRowsTableCreateCompanionBuilder,
          $$ReturnRowsTableUpdateCompanionBuilder,
          (ReturnRow, $$ReturnRowsTableReferences),
          ReturnRow,
          PrefetchHooks Function({bool saleId, bool refundRowsRefs})
        > {
  $$ReturnRowsTableTableManager(_$AppDatabase db, $ReturnRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReturnRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReturnRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReturnRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> saleId = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReturnRowsCompanion(
                id: id,
                saleId: saleId,
                payload: payload,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String saleId,
                required String payload,
                Value<int> rowid = const Value.absent(),
              }) => ReturnRowsCompanion.insert(
                id: id,
                saleId: saleId,
                payload: payload,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReturnRowsTable, ReturnRow>(table),
                  $$ReturnRowsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({saleId = false, refundRowsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (refundRowsRefs) db.refundRows],
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
                                referencedTable: $$ReturnRowsTableReferences
                                    ._saleIdTable(db),
                                referencedColumn: $$ReturnRowsTableReferences
                                    ._saleIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (refundRowsRefs)
                    await $_getPrefetchedData<
                      ReturnRow,
                      $ReturnRowsTable,
                      RefundRow
                    >(
                      currentTable: table,
                      referencedTable: $$ReturnRowsTableReferences
                          ._refundRowsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ReturnRowsTableReferences(
                            db,
                            table,
                            p0,
                          ).refundRowsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.returnId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ReturnRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReturnRowsTable,
      ReturnRow,
      $$ReturnRowsTableFilterComposer,
      $$ReturnRowsTableOrderingComposer,
      $$ReturnRowsTableAnnotationComposer,
      $$ReturnRowsTableCreateCompanionBuilder,
      $$ReturnRowsTableUpdateCompanionBuilder,
      (ReturnRow, $$ReturnRowsTableReferences),
      ReturnRow,
      PrefetchHooks Function({bool saleId, bool refundRowsRefs})
    >;
typedef $$RefundRowsTableCreateCompanionBuilder =
    RefundRowsCompanion Function({
      required String id,
      required String returnId,
      required String payload,
      Value<int> rowid,
    });
typedef $$RefundRowsTableUpdateCompanionBuilder =
    RefundRowsCompanion Function({
      Value<String> id,
      Value<String> returnId,
      Value<String> payload,
      Value<int> rowid,
    });

final class $$RefundRowsTableReferences
    extends BaseReferences<_$AppDatabase, $RefundRowsTable, RefundRow> {
  $$RefundRowsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ReturnRowsTable _returnIdTable(_$AppDatabase db) =>
      db.returnRows.createAlias('refund_rows__return_id__return_rows__id');

  $$ReturnRowsTableProcessedTableManager get returnId {
    final $_column = $_itemColumn<String>('return_id')!;

    final manager = $$ReturnRowsTableTableManager(
      $_db,
      $_db.returnRows,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_returnIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RefundRowsTableFilterComposer
    extends Composer<_$AppDatabase, $RefundRowsTable> {
  $$RefundRowsTableFilterComposer({
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

  $$ReturnRowsTableFilterComposer get returnId {
    final $$ReturnRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.returnId,
      referencedTable: $db.returnRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReturnRowsTableFilterComposer(
            $db: $db,
            $table: $db.returnRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RefundRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $RefundRowsTable> {
  $$RefundRowsTableOrderingComposer({
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

  $$ReturnRowsTableOrderingComposer get returnId {
    final $$ReturnRowsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.returnId,
      referencedTable: $db.returnRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReturnRowsTableOrderingComposer(
            $db: $db,
            $table: $db.returnRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RefundRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RefundRowsTable> {
  $$RefundRowsTableAnnotationComposer({
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

  $$ReturnRowsTableAnnotationComposer get returnId {
    final $$ReturnRowsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.returnId,
      referencedTable: $db.returnRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReturnRowsTableAnnotationComposer(
            $db: $db,
            $table: $db.returnRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RefundRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RefundRowsTable,
          RefundRow,
          $$RefundRowsTableFilterComposer,
          $$RefundRowsTableOrderingComposer,
          $$RefundRowsTableAnnotationComposer,
          $$RefundRowsTableCreateCompanionBuilder,
          $$RefundRowsTableUpdateCompanionBuilder,
          (RefundRow, $$RefundRowsTableReferences),
          RefundRow,
          PrefetchHooks Function({bool returnId})
        > {
  $$RefundRowsTableTableManager(_$AppDatabase db, $RefundRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RefundRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RefundRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RefundRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> returnId = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RefundRowsCompanion(
                id: id,
                returnId: returnId,
                payload: payload,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String returnId,
                required String payload,
                Value<int> rowid = const Value.absent(),
              }) => RefundRowsCompanion.insert(
                id: id,
                returnId: returnId,
                payload: payload,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RefundRowsTable, RefundRow>(table),
                  $$RefundRowsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({returnId = false}) {
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
                    if (returnId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.returnId,
                                referencedTable: $$RefundRowsTableReferences
                                    ._returnIdTable(db),
                                referencedColumn: $$RefundRowsTableReferences
                                    ._returnIdTable(db)
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

typedef $$RefundRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RefundRowsTable,
      RefundRow,
      $$RefundRowsTableFilterComposer,
      $$RefundRowsTableOrderingComposer,
      $$RefundRowsTableAnnotationComposer,
      $$RefundRowsTableCreateCompanionBuilder,
      $$RefundRowsTableUpdateCompanionBuilder,
      (RefundRow, $$RefundRowsTableReferences),
      RefundRow,
      PrefetchHooks Function({bool returnId})
    >;
typedef $$OpnameRowsTableCreateCompanionBuilder =
    OpnameRowsCompanion Function({
      required String id,
      required String payload,
      Value<int> rowid,
    });
typedef $$OpnameRowsTableUpdateCompanionBuilder =
    OpnameRowsCompanion Function({
      Value<String> id,
      Value<String> payload,
      Value<int> rowid,
    });

class $$OpnameRowsTableFilterComposer
    extends Composer<_$AppDatabase, $OpnameRowsTable> {
  $$OpnameRowsTableFilterComposer({
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

class $$OpnameRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $OpnameRowsTable> {
  $$OpnameRowsTableOrderingComposer({
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

class $$OpnameRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OpnameRowsTable> {
  $$OpnameRowsTableAnnotationComposer({
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

class $$OpnameRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OpnameRowsTable,
          OpnameRow,
          $$OpnameRowsTableFilterComposer,
          $$OpnameRowsTableOrderingComposer,
          $$OpnameRowsTableAnnotationComposer,
          $$OpnameRowsTableCreateCompanionBuilder,
          $$OpnameRowsTableUpdateCompanionBuilder,
          (
            OpnameRow,
            BaseReferences<_$AppDatabase, $OpnameRowsTable, OpnameRow>,
          ),
          OpnameRow,
          PrefetchHooks Function()
        > {
  $$OpnameRowsTableTableManager(_$AppDatabase db, $OpnameRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OpnameRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OpnameRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OpnameRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OpnameRowsCompanion(id: id, payload: payload, rowid: rowid),
          createCompanionCallback:
              ({
                required String id,
                required String payload,
                Value<int> rowid = const Value.absent(),
              }) => OpnameRowsCompanion.insert(
                id: id,
                payload: payload,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OpnameRowsTable, OpnameRow>(table),
                  BaseReferences<_$AppDatabase, $OpnameRowsTable, OpnameRow>(
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

typedef $$OpnameRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OpnameRowsTable,
      OpnameRow,
      $$OpnameRowsTableFilterComposer,
      $$OpnameRowsTableOrderingComposer,
      $$OpnameRowsTableAnnotationComposer,
      $$OpnameRowsTableCreateCompanionBuilder,
      $$OpnameRowsTableUpdateCompanionBuilder,
      (OpnameRow, BaseReferences<_$AppDatabase, $OpnameRowsTable, OpnameRow>),
      OpnameRow,
      PrefetchHooks Function()
    >;
typedef $$CashMovementRowsTableCreateCompanionBuilder =
    CashMovementRowsCompanion Function({
      required String id,
      Value<String?> accountId,
      required String reference,
      required String category,
      required String date,
      required int amount,
      Value<int> rowid,
    });
typedef $$CashMovementRowsTableUpdateCompanionBuilder =
    CashMovementRowsCompanion Function({
      Value<String> id,
      Value<String?> accountId,
      Value<String> reference,
      Value<String> category,
      Value<String> date,
      Value<int> amount,
      Value<int> rowid,
    });

final class $$CashMovementRowsTableReferences
    extends
        BaseReferences<_$AppDatabase, $CashMovementRowsTable, CashMovementRow> {
  $$CashMovementRowsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CashAccountRowsTable _accountIdTable(_$AppDatabase db) => db
      .cashAccountRows
      .createAlias('cash_movement_rows__account_id__cash_account_rows__id');

  $$CashAccountRowsTableProcessedTableManager? get accountId {
    final $_column = $_itemColumn<String>('account_id');
    if ($_column == null) return null;
    final manager = $$CashAccountRowsTableTableManager(
      $_db,
      $_db.cashAccountRows,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CashMovementRowsTableFilterComposer
    extends Composer<_$AppDatabase, $CashMovementRowsTable> {
  $$CashMovementRowsTableFilterComposer({
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

  ColumnFilters<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  $$CashAccountRowsTableFilterComposer get accountId {
    final $$CashAccountRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.cashAccountRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CashAccountRowsTableFilterComposer(
            $db: $db,
            $table: $db.cashAccountRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CashMovementRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $CashMovementRowsTable> {
  $$CashMovementRowsTableOrderingComposer({
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

  ColumnOrderings<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  $$CashAccountRowsTableOrderingComposer get accountId {
    final $$CashAccountRowsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.cashAccountRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CashAccountRowsTableOrderingComposer(
            $db: $db,
            $table: $db.cashAccountRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CashMovementRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CashMovementRowsTable> {
  $$CashMovementRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get reference =>
      $composableBuilder(column: $table.reference, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  $$CashAccountRowsTableAnnotationComposer get accountId {
    final $$CashAccountRowsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.cashAccountRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CashAccountRowsTableAnnotationComposer(
            $db: $db,
            $table: $db.cashAccountRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CashMovementRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CashMovementRowsTable,
          CashMovementRow,
          $$CashMovementRowsTableFilterComposer,
          $$CashMovementRowsTableOrderingComposer,
          $$CashMovementRowsTableAnnotationComposer,
          $$CashMovementRowsTableCreateCompanionBuilder,
          $$CashMovementRowsTableUpdateCompanionBuilder,
          (CashMovementRow, $$CashMovementRowsTableReferences),
          CashMovementRow,
          PrefetchHooks Function({bool accountId})
        > {
  $$CashMovementRowsTableTableManager(
    _$AppDatabase db,
    $CashMovementRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CashMovementRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CashMovementRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CashMovementRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> accountId = const Value.absent(),
                Value<String> reference = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CashMovementRowsCompanion(
                id: id,
                accountId: accountId,
                reference: reference,
                category: category,
                date: date,
                amount: amount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> accountId = const Value.absent(),
                required String reference,
                required String category,
                required String date,
                required int amount,
                Value<int> rowid = const Value.absent(),
              }) => CashMovementRowsCompanion.insert(
                id: id,
                accountId: accountId,
                reference: reference,
                category: category,
                date: date,
                amount: amount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CashMovementRowsTable, CashMovementRow>(table),
                  $$CashMovementRowsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({accountId = false}) {
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
                    if (accountId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.accountId,
                                referencedTable:
                                    $$CashMovementRowsTableReferences
                                        ._accountIdTable(db),
                                referencedColumn:
                                    $$CashMovementRowsTableReferences
                                        ._accountIdTable(db)
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

typedef $$CashMovementRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CashMovementRowsTable,
      CashMovementRow,
      $$CashMovementRowsTableFilterComposer,
      $$CashMovementRowsTableOrderingComposer,
      $$CashMovementRowsTableAnnotationComposer,
      $$CashMovementRowsTableCreateCompanionBuilder,
      $$CashMovementRowsTableUpdateCompanionBuilder,
      (CashMovementRow, $$CashMovementRowsTableReferences),
      CashMovementRow,
      PrefetchHooks Function({bool accountId})
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
  $$CustomerRowsTableTableManager get customerRows =>
      $$CustomerRowsTableTableManager(_db, _db.customerRows);
  $$SupplierRowsTableTableManager get supplierRows =>
      $$SupplierRowsTableTableManager(_db, _db.supplierRows);
  $$CashAccountRowsTableTableManager get cashAccountRows =>
      $$CashAccountRowsTableTableManager(_db, _db.cashAccountRows);
  $$OperationRowsTableTableManager get operationRows =>
      $$OperationRowsTableTableManager(_db, _db.operationRows);
  $$PurchaseRowsTableTableManager get purchaseRows =>
      $$PurchaseRowsTableTableManager(_db, _db.purchaseRows);
  $$StockReceiptRowsTableTableManager get stockReceiptRows =>
      $$StockReceiptRowsTableTableManager(_db, _db.stockReceiptRows);
  $$PurchasePaymentRowsTableTableManager get purchasePaymentRows =>
      $$PurchasePaymentRowsTableTableManager(_db, _db.purchasePaymentRows);
  $$SaleCustomerRowsTableTableManager get saleCustomerRows =>
      $$SaleCustomerRowsTableTableManager(_db, _db.saleCustomerRows);
  $$ReturnRowsTableTableManager get returnRows =>
      $$ReturnRowsTableTableManager(_db, _db.returnRows);
  $$RefundRowsTableTableManager get refundRows =>
      $$RefundRowsTableTableManager(_db, _db.refundRows);
  $$OpnameRowsTableTableManager get opnameRows =>
      $$OpnameRowsTableTableManager(_db, _db.opnameRows);
  $$CashMovementRowsTableTableManager get cashMovementRows =>
      $$CashMovementRowsTableTableManager(_db, _db.cashMovementRows);
}
