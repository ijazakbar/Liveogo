import 'package:dio/dio.dart';

import 'buyer_commerce_models.dart';

class BuyerCommerceRepository {
  const BuyerCommerceRepository(this._dio);

  final Dio _dio;

  Future<List<BuyerProduct>> getProducts({
    String? query,
    int page = 1,
  }) async {
    final response = await _dio.get<dynamic>(
      '/buyer/products',
      queryParameters: {
        'page': page,
        if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
      },
    );
    final payload = response.data;
    final dynamic rawItems;
    if (payload is List<dynamic>) {
      rawItems = payload;
    } else if (payload is Map<String, dynamic>) {
      rawItems = payload['items'] ?? payload['data'];
    } else {
      throw const FormatException('Unexpected product catalogue response.');
    }
    if (rawItems is! List<dynamic>) {
      throw const FormatException('Catalogue response must contain an items array.');
    }
    return rawItems.map((item) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('Catalogue contains an invalid product.');
      }
      return BuyerProduct.fromJson(item);
    }).toList(growable: false);
  }

  Future<BuyerCart> getCart() async {
    final response = await _dio.get<dynamic>('/buyer/cart');
    if (response.data is! Map<String, dynamic>) {
      throw const FormatException('Unexpected cart response.');
    }
    return BuyerCart.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> addToCart({
    required String productId,
    required int quantity,
  }) async {
    if (productId.trim().isEmpty || quantity < 1) {
      throw ArgumentError('A product and positive quantity are required.');
    }
    await _dio.post<dynamic>(
      '/buyer/cart/items',
      data: {'product_id': productId, 'quantity': quantity},
    );
  }

  Future<void> updateCartQuantity({
    required String cartItemId,
    required int quantity,
  }) async {
    if (cartItemId.trim().isEmpty || quantity < 1) {
      throw ArgumentError('A cart item and positive quantity are required.');
    }
    await _dio.patch<dynamic>(
      '/buyer/cart/items/${Uri.encodeComponent(cartItemId)}',
      data: {'quantity': quantity},
    );
  }

  Future<void> removeCartItem(String cartItemId) async {
    if (cartItemId.trim().isEmpty) {
      throw ArgumentError.value(cartItemId, 'cartItemId');
    }
    await _dio.delete<dynamic>(
      '/buyer/cart/items/${Uri.encodeComponent(cartItemId)}',
    );
  }
}
