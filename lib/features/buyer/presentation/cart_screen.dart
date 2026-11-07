import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/buyer_commerce_providers.dart';
import '../data/buyer_commerce_models.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  Future<void> _changeQuantity(
    BuildContext context,
    WidgetRef ref,
    BuyerCartItem item,
    int quantity,
  ) async {
    try {
      await ref.read(buyerCommerceRepositoryProvider).updateCartQuantity(
            cartItemId: item.id,
            quantity: quantity,
          );
      ref.invalidate(buyerCartProvider);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not update the cart item.')),
        );
      }
    }
  }

  Future<void> _removeItem(
    BuildContext context,
    WidgetRef ref,
    BuyerCartItem item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove item?'),
        content: Text('Remove ${item.title} from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep item'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref
          .read(buyerCommerceRepositoryProvider)
          .removeCartItem(item.id);
      ref.invalidate(buyerCartProvider);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not remove this cart item.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(buyerCartProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Your cart',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: cart.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_outlined, size: 48),
                const SizedBox(height: 12),
                const Text('Your cart could not be loaded.'),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => ref.invalidate(buyerCartProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try again'),
                ),
              ],
            ),
          ),
        ),
        data: (value) {
          if (value.items.isEmpty) {
            return const _EmptyCart();
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(buyerCartProvider.future),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: value.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = value.items[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        _CartImage(url: item.imageUrl),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '${item.currency} ${item.unitPrice}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  IconButton(
                                    visualDensity: VisualDensity.compact,
                                    tooltip: 'Decrease quantity',
                                    onPressed: item.quantity <= 1
                                        ? null
                                        : () => _changeQuantity(
                                              context,
                                              ref,
                                              item,
                                              item.quantity - 1,
                                            ),
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                    ),
                                  ),
                                  Text(
                                    '${item.quantity}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  IconButton(
                                    visualDensity: VisualDensity.compact,
                                    tooltip: 'Increase quantity',
                                    onPressed: () => _changeQuantity(
                                      context,
                                      ref,
                                      item,
                                      item.quantity + 1,
                                    ),
                                    icon: const Icon(Icons.add_circle_outline),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    tooltip: 'Remove item',
                                    onPressed: () =>
                                        _removeItem(context, ref, item),
                                    icon: const Icon(Icons.delete_outline),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: cart.maybeWhen(
        data: (value) => value.items.isEmpty
            ? null
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Subtotal',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                          Text(
                            '${value.currency} ${value.subtotal}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: null,
                          child: Text('Checkout not yet connected'),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Orders and payment must be confirmed by the LiveOgo server.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
        orElse: () => null,
      ),
    );
  }
}

class _CartImage extends StatelessWidget {
  const _CartImage({this.url});

  final String? url;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 76,
          height: 76,
          child: url == null
              ? const ColoredBox(
                  color: Color(0xFFE8EDE5),
                  child: Icon(Icons.shopping_bag_outlined),
                )
              : Image.network(
                  url!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const ColoredBox(
                    color: Color(0xFFE8EDE5),
                    child: Icon(Icons.image_not_supported_outlined),
                  ),
                ),
        ),
      );
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.shopping_cart_outlined, size: 58),
              const SizedBox(height: 12),
              Text(
                'Your cart is empty',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              const Text(
                'Add products from the Shop to see them here.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
}
