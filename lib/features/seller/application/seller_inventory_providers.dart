import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../data/seller_product.dart';
import '../data/seller_product_repository.dart';

final sellerProductRepositoryProvider = Provider<SellerProductRepository>(
  (ref) => SellerProductRepository(ref.watch(dioProvider)),
);

final sellerProductsProvider = FutureProvider<List<SellerProduct>>(
  (ref) => ref.watch(sellerProductRepositoryProvider).getProducts(),
);
