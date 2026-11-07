import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../data/buyer_commerce_models.dart';
import '../data/buyer_commerce_repository.dart';

final buyerCommerceRepositoryProvider = Provider<BuyerCommerceRepository>(
  (ref) => BuyerCommerceRepository(ref.watch(dioProvider)),
);

final buyerProductsProvider =
    FutureProvider.family<List<BuyerProduct>, String>((ref, query) {
  return ref.watch(buyerCommerceRepositoryProvider).getProducts(
        query: query,
      );
});

final buyerCartProvider = FutureProvider<BuyerCart>((ref) {
  return ref.watch(buyerCommerceRepositoryProvider).getCart();
});
