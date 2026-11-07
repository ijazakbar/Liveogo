import 'package:flutter_test/flutter_test.dart';
import 'package:liveogo/features/buyer/data/buyer_commerce_models.dart';

void main() {
  group('BuyerProduct.fromJson', () {
    test('parses an available catalogue product', () {
      final product = BuyerProduct.fromJson({
        'id': 'product-1',
        'title': 'Cotton shirt',
        'price': 2499,
        'currency': 'PKR',
        'seller_name': 'Verified seller',
        'stock_quantity': 5,
        'is_available': true,
      });

      expect(product.id, 'product-1');
      expect(product.price, 2499);
      expect(product.stockQuantity, 5);
      expect(product.isAvailable, isTrue);
    });

    test('rejects negative prices and invalid stock', () {
      expect(
        () => BuyerProduct.fromJson({
          'id': 'product-1',
          'title': 'Cotton shirt',
          'price': -1,
        }),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => BuyerProduct.fromJson({
          'id': 'product-1',
          'title': 'Cotton shirt',
          'price': 10,
          'stock_quantity': -1,
        }),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('BuyerCart.fromJson', () {
    test('parses server-calculated cart totals and line items', () {
      final cart = BuyerCart.fromJson({
        'currency': 'PKR',
        'subtotal': 4998,
        'items': [
          {
            'id': 'cart-item-1',
            'product_id': 'product-1',
            'title': 'Cotton shirt',
            'unit_price': 2499,
            'line_total': 4998,
            'quantity': 2,
            'currency': 'PKR',
          },
        ],
      });

      expect(cart.items, hasLength(1));
      expect(cart.items.single.quantity, 2);
      expect(cart.items.single.lineTotal, 4998);
      expect(cart.subtotal, 4998);
    });

    test('rejects negative server totals', () {
      expect(
        () => BuyerCart.fromJson({
          'subtotal': -1,
          'items': [],
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects cart items with zero quantity', () {
      expect(
        () => BuyerCart.fromJson({
          'subtotal': 0,
          'items': [
            {
              'id': 'cart-item-1',
              'product_id': 'product-1',
              'title': 'Cotton shirt',
              'unit_price': 100,
              'line_total': 0,
              'quantity': 0,
            },
          ],
        }),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
