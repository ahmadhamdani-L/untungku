import '../models.dart';

class PosCart {
  final Map<String, int> _quantities = {};
  Map<String, int> get quantities => Map.unmodifiable(_quantities);
  void add(Product product, {bool allowNegativeStock = false}) => setQuantity(
    product,
    (_quantities[product.id] ?? 0) + 1,
    allowNegativeStock: allowNegativeStock,
  );
  void setQuantity(
    Product product,
    int quantity, {
    bool allowNegativeStock = false,
  }) {
    if (quantity < 0 ||
        quantity > 1000000 ||
        product.archived ||
        (!allowNegativeStock && quantity > product.stock && quantity != 0)) {
      throw ArgumentError(
        'Jumlah melebihi stok atau produk tidak dapat dijual',
      );
    }
    if (quantity == 0) {
      _quantities.remove(product.id);
    } else {
      _quantities[product.id] = quantity;
    }
  }

  void clear() => _quantities.clear();
}
