import 'package:flutter_test/flutter_test.dart';
import 'package:liveogo/features/seller/data/seller_product.dart';

void main() {
  group('SellerProduct.fromJson', () {
    test('parses required and optional catalogue fields', () {
      final product = SellerProduct.fromJson({
        'id': 'product-1',
        'title': 'Linen shirt',
        'price': '2500',
        'sale_price': 2200,
        'stock': 8,
        'category': 'Clothing',
        'sku': 'LIN-01',
        'image_url': 'https://cdn.example.test/linen.jpg',
        'is_active': false,
      });

      expect(product.id, 'product-1');
      expect(product.price, 2500);
      expect(product.salePrice, 2200);
      expect(product.stock, 8);
      expect(product.category, 'Clothing');
      expect(product.isActive, isFalse);
    });

    test('rejects a product without a valid price', () {
      expect(
        () => SellerProduct.fromJson({
          'id': 'product-1',
          'title': 'Linen shirt',
          'price': 'not-a-price',
          'stock': 8,
        }),
        throwsA(isA<FormatException>()),
      );
    });
  });

  test('draft excludes empty optional fields', () {
    const draft = SellerProductDraft(
      title: 'Linen shirt',
      price: 2500,
      stock: 8,
    );

    expect(draft.toFormFields(), {
      'title': 'Linen shirt',
      'price': '2500',
      'stock': '8',
      'is_active': 'true',
      'description': '',
      'category': '',
      'sku': '',
      'sale_price': '',
    });
  });
}
