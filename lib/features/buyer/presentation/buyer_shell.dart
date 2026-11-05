import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../application/feed_providers.dart';
import '../data/feed_models.dart';

final buyerTabProvider = StateProvider<int>((ref) => 0);

class BuyerShell extends ConsumerWidget {
  const BuyerShell({super.key});
  static const _tabs = [
    _BuyerTab(Icons.home_rounded, 'Home'),
    _BuyerTab(Icons.explore_outlined, 'Discover'),
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
        _BuyerPlaceholder(title: 'Discover', icon: Icons.explore),
        _BuyerPlaceholder(title: 'Your cart', icon: Icons.shopping_cart),
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
  static const _feedTabs = {'Live': 'live', 'Following': 'following', 'For You': 'for_you'};
  String _selectedTab = 'For You';
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
                if (items.isEmpty) return const _FeedEmpty();
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
            top: 4, left: 0, right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final tab in _feedTabs.keys)
                  Semantics(
                    button: true,
                    selected: _selectedTab == tab,
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _selectedTab = tab;
                        _pageController.jumpToPage(0);
                      }),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
                        child: Text(tab, style: TextStyle(
                          color: _selectedTab == tab ? Colors.white : Colors.white60,
                          fontWeight: _selectedTab == tab ? FontWeight.bold : FontWeight.normal,
                        )),
                      ),
                    ),
                  ),
              ],
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
        Positioned(top: 58, left: 16, child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(8)),
          child: const Text('LIVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
        )),
      if (item.viewerCount != null)
        Positioned(top: 61, right: 16, child: Row(children: [
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

class _ProductDetailSheet extends StatelessWidget {
  const _ProductDetailSheet({required this.product});
  final FeedProduct product;

  @override
  Widget build(BuildContext context) => SafeArea(child: Padding(
    padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
    child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Center(child: Container(width: 38, height: 4,
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.outlineVariant, borderRadius: BorderRadius.circular(4)))),
      const SizedBox(height: 22),
      Text(product.title, style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 8),
      Text('${product.currency} ${product.price}', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 12),
      const Text('Product details and purchasing become available when the catalogue and checkout API contracts are connected.'),
      const SizedBox(height: 18),
      SizedBox(width: double.infinity, child: FilledButton(
        onPressed: null, child: const Text('Add to cart — not connected yet'))),
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
  const _FeedEmpty();
  @override
  Widget build(BuildContext context) => const Center(child: Padding(
    padding: EdgeInsets.all(28),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.live_tv_outlined, color: Colors.white54, size: 58),
      SizedBox(height: 14),
      Text('Nothing to watch yet', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w700)),
      SizedBox(height: 7),
      Text('Live sellers and product videos will appear here when available.',
        textAlign: TextAlign.center, style: TextStyle(color: Colors.white60)),
    ]),
  ));
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
