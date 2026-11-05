class FeedProduct {
  const FeedProduct({required this.id, required this.title, required this.price, required this.currency, this.imageUrl});
  final String id;
  final String title;
  final num price;
  final String currency;
  final String? imageUrl;

  factory FeedProduct.fromJson(Map<String, dynamic> json) => FeedProduct(
    id: _requiredString(json, 'id'),
    title: _requiredString(json, 'title'),
    price: _number(json['price']),
    currency: (json['currency'] as String?) ?? 'PKR',
    imageUrl: _optionalString(json['image_url']),
  );
}

class BuyerFeedItem {
  const BuyerFeedItem({
    required this.id, required this.type, required this.sellerName, required this.caption,
    this.sellerHandle, this.posterUrl, this.mediaUrl, this.isLive = false,
    this.viewerCount, this.pinnedProduct,
  });
  final String id;
  final String type;
  final String sellerName;
  final String caption;
  final String? sellerHandle;
  final String? posterUrl;
  final String? mediaUrl;
  final bool isLive;
  final int? viewerCount;
  final FeedProduct? pinnedProduct;

  factory BuyerFeedItem.fromJson(Map<String, dynamic> json) {
    final productJson = json['pinned_product'];
    return BuyerFeedItem(
      id: _requiredString(json, 'id'),
      type: (json['type'] as String?) ?? 'video',
      sellerName: _requiredString(json, 'seller_name'),
      caption: (json['caption'] as String?) ?? '',
      sellerHandle: _optionalString(json['seller_handle']),
      posterUrl: _optionalString(json['poster_url']),
      mediaUrl: _optionalString(json['media_url']),
      isLive: json['is_live'] == true,
      viewerCount: json['viewer_count'] is num ? (json['viewer_count'] as num).toInt() : null,
      pinnedProduct: productJson is Map<String, dynamic> ? FeedProduct.fromJson(productJson) : null,
    );
  }
}

String _requiredString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is String && value.trim().isNotEmpty) return value;
  throw FormatException('Feed response is missing required field: $key');
}
String? _optionalString(dynamic value) => value is String && value.trim().isNotEmpty ? value : null;
num _number(dynamic value) {
  if (value is num) return value;
  throw const FormatException('Product price must be a number');
}
