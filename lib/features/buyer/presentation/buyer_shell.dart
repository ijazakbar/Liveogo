import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/application/auth_providers.dart';
import '../application/buyer_commerce_providers.dart';
import '../application/feed_providers.dart';
import '../data/feed_models.dart';
import 'cart_screen.dart';
import 'shop_screen.dart';

final buyerTabProvider = StateProvider<int>((ref) => 0);

class BuyerShell extends ConsumerWidget {
  const BuyerShell({super.key});
  static const _tabs = [
    _BuyerTab(Icons.home_rounded, 'Home'),
    _BuyerTab(Icons.storefront_outlined, 'Shop'),
    _BuyerTab(Icons.shopping_cart_outlined, 'Cart'),
    _BuyerTab(Icons.chat_bubble_outline, 'Inbox'),
    _BuyerTab(Icons.person_outline, 'Profile'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(buyerTabProvider);
    return Scaffold(
      body: IndexedStack(index: index, children: const [
        BuyerFeedScreen(),
        ShopScreen(),
        CartScreen(),
        _BuyerPlaceholder(title: 'Inbox', icon: Icons.chat_bubble_outline),
        _BuyerPlaceholder(title: 'Your profile', icon: Icons.person_outline),
      ]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => ref.read(buyerTabProvider.notifier).state = value,
        destinations: _tabs.map((tab) => NavigationDestination(icon: Icon(tab.icon), label: tab.label)).toList(),
      ),
    );
  }
}

class _BuyerTab {
  const _BuyerTab(this.icon, this.label);
  final IconData icon;
  final String label;
}

class BuyerFeedScreen extends ConsumerStatefulWidget {
  const BuyerFeedScreen({super.key});
  @override
  ConsumerState<BuyerFeedScreen> createState() => _BuyerFeedScreenState();
}

class _BuyerFeedScreenState extends ConsumerState<BuyerFeedScreen> {
  static const _feedTabs = {
    'Following': 'following',
    'For You': 'for_you',
    'LIVE': 'live',
  };
  String _selectedTab = 'LIVE';
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _signOut() async {
    await clearAuthSession(ref);
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final tabKey = _feedTabs[_selectedTab]!;
    final feed = ref.watch(buyerFeedProvider(tabKey));
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(children: [
          Positioned.fill(
            child: feed.when(
              loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
              error: (error, stack) => _FeedError(
                message: error.toString().contains('DioException')
                    ? 'Could not connect to the LiveOgo feed service.'
                    : 'The feed could not be loaded. Please try again.',
                onRetry: () => ref.invalidate(buyerFeedProvider(tabKey)),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return _FeedEmpty(
                    onRefresh: () => ref.invalidate(buyerFeedProvider(tabKey)),
                    onStartLive: () => context.go('/seller'),
                    onExploreForYou: () => setState(() {
                      _selectedTab = 'For You';
                      if (_pageController.hasClients) {
                        _pageController.jumpToPage(0);
                      }
                    }),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () => ref.refresh(buyerFeedProvider(tabKey).future),
                  child: PageView.builder(
                    controller: _pageController,
                    scrollDirection: Axis.vertical,
                    itemCount: items.length,
                    itemBuilder: (context, index) => _FeedPage(item: items[index]),
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: 2,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text.rich(
                  TextSpan(children: [
                    TextSpan(
                      text: 'Live',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.2,
                      ),
                    ),
                    TextSpan(
                      text: 'Ogo',
                      style: TextStyle(
                        color: Color(0xFFB7F36B),
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.2,
                      ),
                    ),
                  ]),
                ),
                TextButton(
                  onPressed: _signOut,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.white.withValues(alpha: .08),
                    shape: const StadiumBorder(),
                  ),
                  child: const Text('Sign out'),
                ),
              ],
            ),
          ),
          Positioned(
            top: 52,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: .58),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: Colors.white.withValues(alpha: .06)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final tab in _feedTabs.keys)
                      Semantics(
                        button: true,
                        selected: _selectedTab == tab,
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _selectedTab = tab;
                            if (_pageController.hasClients) {
                              _pageController.jumpToPage(0);
                            }
                          }),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 13,
                              vertical: 11,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  tab,
                                  style: TextStyle(
                                    color: _selectedTab == tab
                                        ? Colors.white
                                        : Colors.white60,
                                    fontWeight: _selectedTab == tab
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Container(
                                  height: 3,
                                  width: 44,
                                  color: _selectedTab == tab
                                      ? const Color(0xFFB7F36B)
                                      : Colors.transparent,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _FeedPage extends StatelessWidget {
  const _FeedPage({required this.item});
  final BuyerFeedItem item;

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      if (item.posterUrl != null)
        Image.network(item.posterUrl!, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const _MediaFallback())
      else
        const _MediaFallback(),
      const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Colors.black38, Colors.transparent, Colors.black87],
        stops: [0, .38, 1],
      ))),
      if (item.isLive)
        Positioned(top: 108, left: 16, child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(8)),
          child: const Text('LIVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
        )),
      if (item.viewerCount != null)
        Positioned(top: 111, right: 16, child: Row(children: [
          const Icon(Icons.visibility, color: Colors.white, size: 16),
          const SizedBox(width: 5),
          Text('${item.viewerCount}', style: const TextStyle(color: Colors.white)),
        ])),
      Positioned(left: 16, right: 20, bottom: 28, child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.sellerHandle == null ? item.sellerName : '@${item.sellerHandle}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          if (item.caption.isNotEmpty) ...[
            const SizedBox(height: 7),
            Text(item.caption, maxLines: 3, overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white)),
          ],
          if (item.pinnedProduct != null) ...[
            const SizedBox(height: 12),
            _PinnedProductCard(product: item.pinnedProduct!),
          ],
        ],
      )),
    ],
  );
}

class _PinnedProductCard extends StatelessWidget {
  const _PinnedProductCard({required this.product});
  final FeedProduct product;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.black.withValues(alpha: .62),
    borderRadius: BorderRadius.circular(14),
    child: InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        builder: (_) => _ProductDetailSheet(product: product),
      ),
      child: Padding(
        padding: const EdgeInsets.all(11),
        child: Row(children: [
          const Icon(Icons.shopping_bag_outlined, color: Colors.amber),
          const SizedBox(width: 9),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(product.title, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            const SizedBox(height: 3),
            Text('${product.currency} ${product.price}', style: const TextStyle(color: Colors.white70)),
          ])),
          const Icon(Icons.chevron_right, color: Colors.white),
        ]),
      ),
    ),
  );
}

class _ProductDetailSheet extends ConsumerWidget {
  const _ProductDetailSheet({required this.product});
  final FeedProduct product;

  @override
  Widget build(BuildContext context, WidgetRef ref) => SafeArea(child: Padding(
    padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
    child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Center(child: Container(width: 38, height: 4,
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.outlineVariant, borderRadius: BorderRadius.circular(4)))),
      const SizedBox(height: 22),
      Text(product.title, style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 8),
      Text('${product.currency} ${product.price}', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 12),
      const Text('Product availability and price are confirmed by the seller catalogue when the item is added.'),
      const SizedBox(height: 18),
      SizedBox(width: double.infinity, child: FilledButton.icon(
        onPressed: () async {
          try {
            await ref.read(buyerCommerceRepositoryProvider).addToCart(
              productId: product.id,
              quantity: 1,
            );
            ref.invalidate(buyerCartProvider);
            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Added to your cart.')),
              );
            }
          } catch (_) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Could not add this product. Please try again.')),
              );
            }
          }
        },
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('Add to cart'),
      )),
    ]),
  ));
}

class _MediaFallback extends StatelessWidget {
  const _MediaFallback();
  @override
  Widget build(BuildContext context) => const ColoredBox(
    color: Color(0xFF171923),
    child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.play_circle_outline, color: Colors.white54, size: 62),
      SizedBox(height: 10),
      Text('Media preview unavailable', style: TextStyle(color: Colors.white70)),
    ])),
  );
}

class _FeedEmpty extends StatelessWidget {
  const _FeedEmpty({
    required this.onRefresh,
    required this.onStartLive,
    required this.onExploreForYou,
  });

  final VoidCallback onRefresh;
  final VoidCallback onStartLive;
  final VoidCallback onExploreForYou;

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      gradient: RadialGradient(
        center: Alignment(0, -.15),
        radius: 1.15,
        colors: [Color(0xFF17291D), Color(0xFF080C09), Colors.black],
        stops: [0, .65, 1],
      ),
    ),
    child: Center(child: SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(28, 150, 28, 28),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.shopping_bag_rounded, color: Color(0xFFB7F36B), size: 68),
        const SizedBox(height: 18),
        const Text.rich(TextSpan(children: [
          TextSpan(text: 'Live', style: TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w900, letterSpacing: -2)),
          TextSpan(text: 'Ogo', style: TextStyle(color: Color(0xFFB7F36B), fontSize: 38, fontWeight: FontWeight.w900, letterSpacing: -2)),
        ])),
        const SizedBox(height: 24),
        const Text(
          'No one is LIVE right now',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 16),
        const Text(
          'When an approved seller starts broadcasting, the LIVE stream will appear here.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white60, fontSize: 16, height: 1.45),
        ),
        const SizedBox(height: 26),
        SizedBox(
          width: 210,
          child: FilledButton(
            onPressed: onRefresh,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFB7F36B),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            child: const Text('Refresh LIVE', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 210,
          child: OutlinedButton(
            onPressed: onStartLive,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white70,
              side: BorderSide(color: Colors.white.withValues(alpha: .12)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Start your LIVE'),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 210,
          child: OutlinedButton(
            onPressed: onExploreForYou,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white70,
              side: BorderSide(color: Colors.white.withValues(alpha: .12)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Explore For You'),
          ),
        ),
      ]),
    )),
  );
}

class _FeedError extends StatelessWidget {
  const _FeedError({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(child: Padding(
    padding: const EdgeInsets.all(28),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.cloud_off_outlined, color: Colors.white70, size: 48),
      const SizedBox(height: 12),
      Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
      const SizedBox(height: 14),
      OutlinedButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: const Text('Try again')),
    ]),
  ));
}

class _BuyerPlaceholder extends StatelessWidget {
  const _BuyerPlaceholder({required this.title, required this.icon});
  final String title;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
      const SizedBox(height: 12),
      Text(title, style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 6),
      const Text('This section is not connected yet.'),
      TextButton(onPressed: () => context.go('/role'), child: const Text('Switch mode')),
    ],
  )));
}
