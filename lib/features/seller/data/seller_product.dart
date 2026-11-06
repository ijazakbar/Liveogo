class SellerProduct {
  const SellerProduct({
    required this.id,
    required this.title,
    required this.price,
    required this.stock,
    this.description,
    this.category,
    this.sku,
    this.imageUrl,
    this.salePrice,
    this.isActive = true,
  });

  final String id;
  final String title;
  final num price;
  final int stock;
  final String? description;
  final String? category;
  final String? sku;
  final String? imageUrl;
  final num? salePrice;
  final bool isActive;

  factory SellerProduct.fromJson(Map<String, dynamic> json) {
    final price = _requiredNumber(json, 'price');
    final stock = _requiredInteger(json, 'stock');
    if (price <= 0) {
      throw const FormatException('Product price must be greater than zero');
    }
    if (stock < 0) {
      throw const FormatException('Product stock cannot be negative');
    }

    return SellerProduct(
      id: _requiredText(json, 'id'),
      title: _requiredText(json, 'title'),
      price: price,
      stock: stock,
      description: _optionalText(json['description']),
      category: _optionalText(json['category']),
      sku: _optionalText(json['sku']),
      imageUrl: _optionalText(json['image_url']),
      salePrice: _optionalNumber(json['sale_price']),
      isActive: json['is_active'] is bool ? json['is_active'] as bool : true,
    );
  }
}

class SellerProductDraft {
  const SellerProductDraft({
    required this.title,
    required this.price,
    required this.stock,
    this.description,
    this.category,
    this.sku,
    this.salePrice,
    this.isActive = true,
  });

  final String title;
  final num price;
  final int stock;
  final String? description;
  final String? category;
  final String? sku;
  final num? salePrice;
  final bool isActive;

  Map<String, String> toFormFields() => {
        'title': title,
        'price': price.toString(),
        'stock': stock.toString(),
        'is_active': isActive.toString(),
        'description': description ?? '',
        'category': category ?? '',
        'sku': sku ?? '',
        'sale_price': salePrice?.toString() ?? '',
      };
}

String _requiredText(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is String && value.trim().isNotEmpty) return value;
  throw FormatException('Product response is missing required field: $key');
}

String? _optionalText(dynamic value) =>
    value is String && value.trim().isNotEmpty ? value : null;

num _requiredNumber(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is num) return value;
  if (value is String) {
    final parsed = num.tryParse(value);
    if (parsed != null) return parsed;
  }
  throw FormatException('Product response has an invalid $key');
}

int _requiredInteger(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is int) return value;
  if (value is String) {
    final parsed = int.tryParse(value);
    if (parsed != null) return parsed;
  }
  throw FormatException('Product response has an invalid $key');
}

num? _optionalNumber(dynamic value) {
  if (value == null) return null;
  if (value is num) return value;
  if (value is String) {
    final parsed = num.tryParse(value);
    if (parsed != null) return parsed;
  }
  throw const FormatException('Product response has an invalid sale_price');
}
