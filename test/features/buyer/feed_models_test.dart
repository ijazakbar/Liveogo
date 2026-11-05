import 'package:flutter_test/flutter_test.dart';
import 'package:liveogo/features/buyer/data/feed_models.dart';

void main() {
  group('BuyerFeedItem.fromJson', () {
    test('parses feed metadata and a pinned product', () {
      final item = BuyerFeedItem.fromJson({
        'id': 'feed-1',
        'type': 'live',
        'seller_name': 'Example seller',
        'seller_handle': 'example',
        'caption': 'A seller-provided caption',
        'is_live': true,
        'viewer_count': 42,
        'pinned_product': {
          'id': 'product-1',
          'title': 'Cotton shirt',
          'price': 1999,
          'currency': 'PKR',
        },
      });

      expect(item.id, 'feed-1');
      expect(item.isLive, isTrue);
      expect(item.viewerCount, 42);
      expect(item.pinnedProduct?.title, 'Cotton shirt');
      expect(item.pinnedProduct?.price, 1999);
    });

    test('rejects feed items without required identity fields', () {
      expect(
        () => BuyerFeedItem.fromJson({'id': 'feed-1'}),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
