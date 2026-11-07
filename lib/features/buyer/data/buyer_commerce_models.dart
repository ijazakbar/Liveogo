class BuyerProduct {
  const BuyerProduct({
    required this.id,
    required this.title,
    required this.price,
    required this.currency,
    this.description,
    this.sellerName,
    this.imageUrl,
    this.stockQuantity,
    this.isAvailable = true,
  });

  final String id;
  final String title;
  final num price;
  final String currency;
  final String? description;
  final String? sellerName;
  final String? imageUrl;
  final int? stockQuantity;
  final bool isAvailable;

  factory BuyerProduct.fromJson(Map<String, dynamic> json) {
    final price = _number(json['price'], 'price');
    if (price < 0) {
      throw const FormatException('Product price cannot be negative.');
    }
    final stock = json['stock_quantity'];
    if (stock != null && (stock is! int || stock < 0)) {
      throw const FormatException('Product stock quantity is invalid.');
    }

    return BuyerProduct(
      id: _requiredText(json, 'id'),
      title: _requiredText(json, 'title'),
      price: price,
      currency: _optionalText(json['currency']) ?? 'PKR',
      description: _optionalText(json['description']),
      sellerName: _optionalText(json['seller_name']),
      imageUrl: _optionalText(json['image_url']),
      stockQuantity: stock as int?,
      isAvailable: json['is_available'] is bool
          ? json['is_available'] as bool
          : true,
    );
  }
}

class BuyerCartItem {
  const BuyerCartItem({
    required this.id,
    required this.productId,
    required this.title,
    required this.unitPrice,
    required this.lineTotal,
    required this.currency,
    required this.quantity,
    this.imageUrl,
  });

  final String id;
  final String productId;
  final String title;
  final num unitPrice;
  final num lineTotal;
  final String currency;
  final int quantity;
  final String? imageUrl;

  factory BuyerCartItem.fromJson(Map<String, dynamic> json) {
    final quantity = json['quantity'];
    if (quantity is! int || quantity < 1) {
      throw const FormatException('Cart item quantity must be positive.');
    }
    final unitPrice = _number(json['unit_price'], 'unit_price');
    final lineTotal = _number(json['line_total'], 'line_total');
    if (unitPrice < 0 || lineTotal < 0) {
      throw const FormatException('Cart prices cannot be negative.');
    }
    return BuyerCartItem(
      id: _requiredText(json, 'id'),
      productId: _requiredText(json, 'product_id'),
      title: _requiredText(json, 'title'),
      unitPrice: unitPrice,
      lineTotal: lineTotal,
      currency: _optionalText(json['currency']) ?? 'PKR',
      quantity: quantity,
      imageUrl: _optionalText(json['image_url']),
    );
  }
}

class BuyerCart {
  const BuyerCart({
    required this.items,
    required this.subtotal,
    required this.currency,
  });

  final List<BuyerCartItem> items;
  final num subtotal;
  final String currency;

  factory BuyerCart.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    if (rawItems is! List<dynamic>) {
      throw const FormatException('Cart response must contain an items array.');
    }
    final subtotal = _number(json['subtotal'], 'subtotal');
    if (subtotal < 0) {
      throw const FormatException('Cart subtotal cannot be negative.');
    }
    return BuyerCart(
      items: rawItems.map((item) {
        if (item is! Map<String, dynamic>) {
          throw const FormatException('Cart contains an invalid item.');
        }
        return BuyerCartItem.fromJson(item);
      }).toList(growable: false),
      subtotal: subtotal,
      currency: _optionalText(json['currency']) ?? 'PKR',
    );
  }
}

String _requiredText(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is String && value.trim().isNotEmpty) return value;
  throw FormatException('Response is missing required field: $key');
}

String? _optionalText(dynamic value) =>
    value is String && value.trim().isNotEmpty ? value : null;

num _number(dynamic value, String key) {
  if (value is num) return value;
  throw FormatException('Response field $key must be numeric.');
}
