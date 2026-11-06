import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import 'seller_product.dart';

class SellerProductRepository {
  const SellerProductRepository(this._dio);

  final Dio _dio;

  Future<List<SellerProduct>> getProducts() async {
    final response = await _dio.get<dynamic>('/seller/products');
    final payload = response.data;
    final dynamic rawItems;

    if (payload is List<dynamic>) {
      rawItems = payload;
    } else if (payload is Map<String, dynamic>) {
      rawItems = payload['items'] ?? payload['data'];
    } else {
      throw const FormatException('Unexpected seller products response');
    }

    if (rawItems is! List<dynamic>) {
      throw const FormatException(
        'Seller products response must contain an items array',
      );
    }

    return rawItems.map((item) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('Invalid seller product item');
      }
      return SellerProduct.fromJson(item);
    }).toList(growable: false);
  }

  Future<void> createProduct(SellerProductDraft draft, {XFile? image}) async {
    await _dio.post<dynamic>(
      '/seller/products',
      data: await _toFormData(draft, image),
    );
  }

  Future<void> updateProduct(
    String productId,
    SellerProductDraft draft, {
    XFile? image,
  }) async {
    await _dio.patch<dynamic>(
      '/seller/products/$productId',
      data: await _toFormData(draft, image),
    );
  }

  Future<void> deleteProduct(String productId) async {
    await _dio.delete<dynamic>('/seller/products/$productId');
  }

  Future<FormData> _toFormData(SellerProductDraft draft, XFile? image) async {
    return FormData.fromMap({
      ...draft.toFormFields(),
      if (image != null)
        'image': MultipartFile.fromBytes(
          await image.readAsBytes(),
          filename: image.name,
        ),
    });
  }
}
