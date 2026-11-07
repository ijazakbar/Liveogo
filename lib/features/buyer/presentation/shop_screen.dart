import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../application/buyer_commerce_providers.dart';
import '../data/buyer_commerce_models.dart';

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _addProduct(BuyerProduct product) async {
    try {
      await ref.read(buyerCommerceRepositoryProvider).addToCart(
            productId: product.id,
            quantity: 1,
          );
      ref.invalidate(buyerCartProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${product.title} added to your cart.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not add this item. Please try again.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(buyerProductsProvider(_query));
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Shop',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: (value) => setState(() => _query = value.trim()),
              decoration: InputDecoration(
                hintText: 'Search products and shops',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  tooltip: 'Search',
                  onPressed: () =>
                      setState(() => _query = _searchController.text.trim()),
                  icon: const Icon(Icons.arrow_forward),
                ),
              ),
            ),
          ),
          Expanded(
            child: products.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => _ShopError(
                onRetry: () => ref.invalidate(buyerProductsProvider(_query)),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return const _ShopEmpty();
                }
                return RefreshIndicator(
                  onRefresh: () =>
                      ref.refresh(buyerProductsProvider(_query).future),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.maxWidth >= 900
                          ? 4
                          : constraints.maxWidth >= 600
                              ? 3
                              : 2;
                      return GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: constraints.maxWidth >= 600
                              ? .72
                              : .64,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, index) => _ProductCard(
                          product: items[index],
                          onAdd: () => _addProduct(items[index]),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product, required this.onAdd});

  final BuyerProduct product;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final unavailable = !product.isAvailable ||
        (product.stockQuantity != null && product.stockQuantity == 0);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: product.imageUrl == null
                ? const ColoredBox(
                    color: Color(0xFFE8EDE5),
                    child: Center(
                      child: Icon(
                        Icons.shopping_bag_outlined,
                        size: 42,
                        color: AppTheme.purple,
                      ),
                    ),
                  )
                : Image.network(
                    product.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const ColoredBox(
                      color: Color(0xFFE8EDE5),
                      child: Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          size: 36,
                          color: Colors.black45,
                        ),
                      ),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(11, 10, 11, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                if (product.sellerName != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    product.sellerName!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).hintColor,
                        ),
                  ),
                ],
                const SizedBox(height: 7),
                Text(
                  '${product.currency} ${product.price}',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 9),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonalIcon(
                    onPressed: unavailable ? null : onAdd,
                    icon: const Icon(Icons.add_shopping_cart, size: 17),
                    label: Text(unavailable ? 'Unavailable' : 'Add'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShopEmpty extends StatelessWidget {
  const _ShopEmpty();

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.storefront_outlined, size: 54),
              const SizedBox(height: 12),
              Text(
                'No products found',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              const Text(
                'Approved sellers’ available products will appear here.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
}

class _ShopError extends StatelessWidget {
  const _ShopError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 48),
              const SizedBox(height: 12),
              const Text(
                'The shop could not be loaded.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
}
