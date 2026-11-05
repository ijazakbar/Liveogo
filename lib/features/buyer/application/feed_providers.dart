import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';
import '../data/feed_models.dart';
import '../data/feed_repository.dart';

final buyerFeedRepositoryProvider = Provider<BuyerFeedRepository>((ref) =>
    BuyerFeedRepository(ref.watch(dioProvider)));

final buyerFeedProvider = FutureProvider.family<List<BuyerFeedItem>, String>((ref, tab) =>
    ref.watch(buyerFeedRepositoryProvider).getFeed(tab: tab));
