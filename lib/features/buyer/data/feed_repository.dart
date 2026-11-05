import 'package:dio/dio.dart';
import 'feed_models.dart';

class BuyerFeedRepository {
  const BuyerFeedRepository(this._dio);
  final Dio _dio;

  Future<List<BuyerFeedItem>> getFeed({required String tab, int page = 1, String? query}) async {
    final response = await _dio.get<dynamic>('/buyer/feed', queryParameters: {
      'tab': tab,
      'page': page,
      if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
    });
    final payload = response.data;
    final dynamic rawItems;
    if (payload is List<dynamic>) {
      rawItems = payload;
    } else if (payload is Map<String, dynamic>) {
      rawItems = payload['items'] ?? payload['data'];
    } else {
      throw const FormatException('Unexpected buyer feed response');
    }
    if (rawItems is! List<dynamic>) {
      throw const FormatException('Buyer feed response must contain an items array');
    }
    return rawItems.map((item) {
      if (item is! Map<String, dynamic>) throw const FormatException('Invalid buyer feed item');
      return BuyerFeedItem.fromJson(item);
    }).toList(growable: false);
  }
}
