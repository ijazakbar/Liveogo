import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
        BuyerFeedScreen(), _BuyerPlaceholder(title: 'Discover', icon: Icons.explore),
        _BuyerPlaceholder(title: 'Your cart', icon: Icons.shopping_cart),
        _BuyerPlaceholder(title: 'Inbox', icon: Icons.chat_bubble_outline),
        _BuyerPlaceholder(title: 'Your profile', icon: Icons.person_outline),
      ]),
      bottomNavigationBar: NavigationBar(selectedIndex: index,
        onDestinationSelected: (value) => ref.read(buyerTabProvider.notifier).state = value,
        destinations: _tabs.map((tab) => NavigationDestination(icon: Icon(tab.icon), label: tab.label)).toList()),
    );
  }
}
class _BuyerTab { const _BuyerTab(this.icon, this.label); final IconData icon; final String label; }

class BuyerFeedScreen extends StatefulWidget {
  const BuyerFeedScreen({super.key});
  @override
  State<BuyerFeedScreen> createState() => _BuyerFeedScreenState();
}
class _BuyerFeedScreenState extends State<BuyerFeedScreen> {
  String selected = 'For You';
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    body: SafeArea(child: Stack(children: [
      const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.play_circle_outline, color: Colors.white54, size: 64),
        SizedBox(height: 12),
        Text('Your live shopping feed', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
        SizedBox(height: 6),
        Text('Live streams and product videos will appear here.', style: TextStyle(color: Colors.white60)),
      ])),
      Positioned(top: 8, left: 0, right: 0, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        for (final tab in ['Live', 'Following', 'For You'])
          GestureDetector(onTap: () => setState(() => selected = tab),
            child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Text(tab, style: TextStyle(color: selected == tab ? Colors.white : Colors.white60,
                fontWeight: selected == tab ? FontWeight.bold : FontWeight.normal)))),
        const Icon(Icons.search, color: Colors.white),
      ])),
      Positioned(right: 12, bottom: 95, child: Column(children: [
        _FeedAction(icon: Icons.person, label: 'Seller'),
        _FeedAction(icon: Icons.favorite_border, label: 'Like'),
        _FeedAction(icon: Icons.chat_bubble_outline, label: 'Comment'),
        _FeedAction(icon: Icons.share_outlined, label: 'Share'),
        _FeedAction(icon: Icons.shopping_bag, label: 'Shop', color: const Color(0xFFFFC928)),
      ])),
      Positioned(left: 16, right: 88, bottom: 26, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('@liveogo_seller', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        const Text('Discover products in action', style: TextStyle(color: Colors.white)),
        const SizedBox(height: 10),
        GestureDetector(onTap: () => showModalBottomSheet(context: context, isScrollControlled: true,
          backgroundColor: const Color(0xFF191922), shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          builder: (_) => const _ProductSheet()),
          child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .13), borderRadius: BorderRadius.circular(14)),
            child: const Row(children: [Icon(Icons.shopping_bag, color: Color(0xFFFFC928)),
              SizedBox(width: 8), Expanded(child: Text('Featured product · Tap to view', style: TextStyle(color: Colors.white))),
              Icon(Icons.chevron_right, color: Colors.white)])),
        ),
      ])),
    ])),
  );
}
class _FeedAction extends StatelessWidget {
  const _FeedAction({required this.icon, required this.label, this.color = Colors.white});
  final IconData icon; final String label; final Color color;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 18),
    child: Column(children: [CircleAvatar(backgroundColor: Colors.black45, child: Icon(icon, color: color)),
      const SizedBox(height: 4), Text(label, style: const TextStyle(color: Colors.white, fontSize: 10))]));
}
class _ProductSheet extends StatelessWidget {
  const _ProductSheet();
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
    child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Center(child: Container(width: 38, height: 4, decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(4)))),
      const SizedBox(height: 24), const Text('Featured product', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8), const Text('Product information will load from your connected catalogue.', style: TextStyle(color: Colors.white70)),
      const SizedBox(height: 22), SizedBox(width: double.infinity, child: FilledButton(
        onPressed: () => Navigator.pop(context), child: const Text('Continue shopping'))),
    ]));
}
class _BuyerPlaceholder extends StatelessWidget {
  const _BuyerPlaceholder({required this.title, required this.icon});
  final String title; final IconData icon;
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary), const SizedBox(height: 12),
    Text(title, style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 6),
    const Text('This section is ready for its feature implementation.'),
    TextButton(onPressed: () => context.go('/role'), child: const Text('Switch mode')),
  ])));
}
